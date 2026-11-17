using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// map1（Dust2）场景重建 —— 走 SSJJ 官方 BspRender 的同一套语义。
///
/// 关键结论（改这个脚本前务必先读）：
///  1. map1 的 BSP version==1 -> BspReader.loadUnity3DSversion() 判为
///     isUnity3DSversion=true -> BspRender.CreateMaterial() 使用 "SSJJ/UnityMap"。
///     该 shader 属性只有 _MainTex / _LightMap / _NewLightMapType / _ZWrite，
///     没有 _Color，因此不可能出现色调偏移；贴图是原样直出的。
///  2. BaseSceneParse.isNoRenderTexture() 明确把 "unitylighttexture" 和
///     "skytexture" 标成 noRender。这两个 shader 在 map1 里占了 7534 + 836
///     个三角形（总量的 65%）—— 它们是光照代理面/天空面，本来就不该画出来。
///     之前把它们当普通贴图输出，就是"贴图贴错、亮度不对"的真正原因。
///     bsp_raw.py 已按官方语义剔除，只保留 4500 个真实贴图三角形。
///  3. 顶点色是 BSP 里烘好的原始亮度（35..255），由 bsp_raw.py 写进 mesh 的
///     color 通道；材质不做任何二次调色。
///  4. 天空盒用官方 Skybox 预制件的 6 面 quad（Right/Left/Top/Bottom/Front/Back），
///     贴图映射按 LoadSkyboxSystem.OnInitEntityResource：
///        Right=skybox0  Left=skybox1  Top=skybox2
///        Bottom=skybox3 Front=skybox4 Back=skybox5
///     shader 用客户端内建的 SSJJ/Skybox。
/// </summary>
public static class BuildMap1
{
    private const string ScenePath = "Assets/Bundles/Scenes/map_1.unity";
    private const string MeshAsset = "Assets/Bundles/Map1/BSP/map1_bsp.asset";
    private const string TexDir = "Assets/Bundles/Map1/Textures";
    private const string MatDir = "Assets/Bundles/Map1/Materials";
    private const string BundleRoot = "Assets/StreamingAssets/AssetBundles/Windows";
    private const string ClientWin =
        @"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows";

    // bsp_raw.py genmesh 输出的 submesh 顺序（必须逐字一致）
    private static readonly string[] Order =
    {
        "c_dust2_damen2", "c_dust2_qiang06", "c_dust2_damen", "c_dust2_di02",
        "c_dust2_di01", "c_dust2_qiang05", "c_dust2_d13", "c_dust2_tianhuaban",
        "c_dust_d11", "c_dust2_qiang03", "c_dust2_qiang07", "c_dust2_neiqiang01",
        "c_dust2_qiang09", "c_dust2_di03", "c_dust2_qiang04", "c_dust2_qiang01",
        "c_dust2_metal1", "c_dust2_wood4", "c_dust2_wood3", "c_dust2_wood2",
        "c_dust2_wood1"
    };

    // info_player_start_CT[0]: ssjj(x,水平z,高度y)=(4251.96, 1234.44, 1767.84)
    // 竖直射线确认脚下 c_dust2_di03 地面在 y=1737.36，实体高出 30.5 —— 正是玩家半身高度。
    // SsjjToUnity(x,y,z)=(-y_horizontal, y_height, x) => (-1234.44, 1767.84, 4251.96)
    private static readonly Vector3 SpawnPos = new Vector3(-1234.44f, 1767.84f, 4251.96f);

    [MenuItem("SSJJ/10. map1(Dust2) 场景重建")]
    public static void Build()
    {
        AssetDatabase.Refresh();

        var mesh = AssetDatabase.LoadAssetAtPath<Mesh>(MeshAsset);
        if (mesh == null)
        {
            Debug.LogError("[M1] mesh asset 读取失败: " + MeshAsset);
            EditorApplication.Exit(1);
            return;
        }
        Debug.Log("[M1] mesh verts=" + mesh.vertexCount + " subs=" + mesh.subMeshCount +
                  " bounds=" + mesh.bounds + " colors=" +
                  (mesh.colors == null ? 0 : mesh.colors.Length));
        if (mesh.subMeshCount != Order.Length)
        {
            Debug.LogError("[M1] submesh 数量不符: 期望 " + Order.Length + " 实际 " + mesh.subMeshCount);
            EditorApplication.Exit(1);
            return;
        }
        if (mesh.colors == null || mesh.colors.Length != mesh.vertexCount)
        {
            Debug.LogWarning("[M1] 顶点色缺失，mesh.colors=" + (mesh.colors == null ? 0 : mesh.colors.Length));
        }

        // ---- 材质：SSJJ/UnityMap 语义 shader + 原始贴图 + lightmap0 ----
        var unityMap = Shader.Find("SSJJ/UnityMapOffline");
        if (unityMap == null)
        {
            Debug.LogError("[M1] 找不到 SSJJ/UnityMapOffline shader");
            EditorApplication.Exit(1);
            return;
        }
        var lightmap = AssetDatabase.LoadAssetAtPath<Texture2D>(TexDir + "/lightmap0.png");
        if (lightmap == null) Debug.LogWarning("[M1] lightmap0.png 缺失，将不做 lightmap 叠加");

        Directory.CreateDirectory(MatDir);
        var mats = new Material[mesh.subMeshCount];
        int missing = 0;
        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            string key = Order[i];
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(TexDir + "/" + key + ".png");
            if (tex == null)
            {
                missing++;
                Debug.LogWarning("[M1] 贴图缺失: " + key);
            }
            string matPath = MatDir + "/UM_" + key + ".mat";
            var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
            if (mat == null)
            {
                mat = new Material(unityMap);
                AssetDatabase.CreateAsset(mat, matPath);
            }
            mat.shader = unityMap;
            mat.mainTexture = tex;
            if (lightmap != null) mat.SetTexture("_LightMap", lightmap);
            mat.SetFloat("_NewLightMapType", 0f);
            mat.SetFloat("_ZWrite", 1f);
            // BSP 三角形绕序与 Unity 相反（面法线朝下），必须关背面剔除
            mat.SetFloat("_Cull", 0f);
            // 顶点色 = BSP 烘好的原始亮度，强度 1 表示完全按原始明暗输出
            mat.SetFloat("_VertexColorStrength", 0f);
            mats[i] = mat;
        }
        AssetDatabase.SaveAssets();

        // ---- 场景 ----
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var root = new GameObject("UnitySceneRoot");
        var geo = new GameObject("Map1_Geometry");
        geo.transform.SetParent(root.transform, false);
        var mf = geo.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;
        var mr = geo.AddComponent<MeshRenderer>();
        mr.sharedMaterials = mats;
        mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        mr.receiveShadows = false;
        geo.isStatic = true;
        Debug.Log("[M1] materials=" + mats.Length + " missingTex=" + missing);

        // ---- 碰撞体：BSP brush 抽取出的实体几何（bsp_clip_extract.py 产出） ----
        // BspReader 的 lump[8]/lump[9]/lump[2] 是 BSP 的 brush(CSG) 体，官方引擎用它做
        // BspClipMap 的碰撞判定。这里把同一批 brush 求凸包后导出成三角网格，
        // 交给 Unity 的 MeshCollider 做物理。
        //   - 只保留 contentFlags != 0 的实体 brush（墙/地/箱），
        //     water/lava/slime/areaportal 这些非实体内容已被过滤掉。
        //   - 坐标同渲染网格：(X, 水平Z, 高度Y) -> Unity (-水平Z, 高度Y, X)。
        var clipMesh = BuildClipMesh();
        if (clipMesh != null)
        {
            var col = new GameObject("Map1_Collision");
            col.transform.SetParent(root.transform, false);
            var cmf = col.AddComponent<MeshFilter>();
            cmf.sharedMesh = clipMesh;
            var cmc = col.AddComponent<MeshCollider>();
            cmc.sharedMesh = clipMesh;
            cmc.convex = false;
            // 碰撞层用 Default，物理射线/胶囊都能命中
            col.layer = 0;
            // 不挂 MeshRenderer：这是纯判定体，不参与渲染
            Debug.Log("[M1] collision verts=" + clipMesh.vertexCount +
                      " tris=" + (clipMesh.triangles.Length / 3) +
                      " bounds=" + clipMesh.bounds);
        }
        else
        {
            Debug.LogError("[M1] 碰撞体构建失败 —— 玩家会掉出地图");
        }

        // ---- 天空盒：官方 Skybox 预制件结构 ----
        var skyRoot = new GameObject("Skybox");
        skyRoot.transform.SetParent(root.transform, false);
        skyRoot.transform.position = Vector3.zero;
        // 官方预制件里 Skybox 根节点 localScale=30000、localPosition=(0,0,-10)，
        // 这里只要足够大包住整图即可，中心不偏移。
        skyRoot.transform.localScale = Vector3.one;
        var skyShader = Shader.Find("SSJJ/SkyboxOffline");
        if (skyShader == null) { Debug.LogError("[M1] 找不到 SSJJ/SkyboxOffline"); EditorApplication.Exit(1); return; }

        // 半边长：map1 范围约 11k 单位，取 20000 确保完全包住
        const float R = 20000f;
        var sideTex = new string[] { "skybox0", "skybox1", "skybox2", "skybox3", "skybox4", "skybox5" };
        var sideName = new string[] { "Right", "Left", "Top", "Bottom", "Front", "Back" };
        // 每个面：位置 + 朝向（让可见面朝向原点内侧）
        var sidePos = new Vector3[]
        {
            new Vector3( R, 0, 0),   // Right  +X
            new Vector3(-R, 0, 0),   // Left   -X
            new Vector3(0,  R, 0),   // Top    +Y
            new Vector3(0, -R, 0),   // Bottom -Y
            new Vector3(0, 0,  R),   // Front  +Z
            new Vector3(0, 0, -R),   // Back   -Z
        };
        var sideRot = new Vector3[]
        {
            new Vector3(0, -90, 0),  // Right：法线朝 -X（朝内）
            new Vector3(0,  90, 0),  // Left ：法线朝 +X
            new Vector3(90,  0, 0),  // Top  ：法线朝 -Y（朝下）
            new Vector3(-90, 0, 0),  // Bottom：法线朝 +Y
            new Vector3(0, 180, 0),  // Front：法线朝 -Z
            new Vector3(0,   0, 0),  // Back ：法线朝 +Z
        };

        int bound = 0;
        for (int i = 0; i < 6; i++)
        {
            var quad = GameObject.CreatePrimitive(PrimitiveType.Quad);
            quad.name = sideName[i];
            Object.DestroyImmediate(quad.GetComponent<Collider>());
            quad.transform.SetParent(skyRoot.transform, false);
            quad.transform.localPosition = sidePos[i];
            quad.transform.localRotation = Quaternion.Euler(sideRot[i]);
            quad.transform.localScale = new Vector3(R * 2.05f, R * 2.05f, 1f);

            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(TexDir + "/" + sideTex[i] + ".png");
            var mat = new Material(skyShader);
            mat.mainTexture = tex;
            // 天空盒不写深度、不参与光照
            mat.SetFloat("_ZWrite", 0f);
            mat.renderQueue = 1000;
            if (tex != null) bound++; else Debug.LogWarning("[M1] 天空盒贴图缺失: " + sideTex[i]);
            quad.GetComponent<MeshRenderer>().sharedMaterial = mat;
            quad.GetComponent<MeshRenderer>().shadowCastingMode =
                UnityEngine.Rendering.ShadowCastingMode.Off;
            quad.GetComponent<MeshRenderer>().receiveShadows = false;
        }
        // 外面再包一层"兜底"：即使某面朝错，背面的 skybox 也不会露黑
        RenderSettings.skybox = null;
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        // 【原始亮度】环境光必须为纯黑。
        // 原因：SSJJ/UnityMap 的亮度来源只有两处 —— 顶点色(BSP 烘好的光照) 和
        // _LightMap(lightmap0)。任何额外的 ambient 都会把暗部抬亮，造成整体泛白。
        // 之前设成 Color.white 就是"亮度不对"的一个来源。
        RenderSettings.ambientLight = Color.black;
        RenderSettings.fog = false;
        QualitySettings.shadowDistance = 0f;
        Debug.Log("[M1] skybox faces bound=" + bound + "/6 shader=" + skyShader.name);

        var spawn = new GameObject("SpawnPoint");
        spawn.transform.position = SpawnPos;
        spawn.transform.rotation = Quaternion.Euler(0f, 0f, 0f);
        Debug.Log("[M1] spawn unity=" + SpawnPos);

        EditorSceneManager.SaveScene(scene, ScenePath);
        Debug.Log("[M1] scene saved: " + ScenePath);

        // ---- 打包 ----
        var outDir = Path.GetFullPath(BundleRoot);
        Directory.CreateDirectory(outDir);
        foreach (var f in Directory.GetFiles(outDir, "map_1*", SearchOption.AllDirectories))
            File.Delete(f);

        var build = new AssetBundleBuild();
        build.assetBundleName = "unitymaps/map_1";
        build.assetNames = new[] { ScenePath };
        var manifest = BuildPipeline.BuildAssetBundles(
            outDir, new[] { build }, BuildAssetBundleOptions.ChunkBasedCompression,
            BuildTarget.StandaloneWindows64);
        if (manifest == null) { Debug.LogError("[M1] bundle build failed"); EditorApplication.Exit(1); return; }

        var built = Path.Combine(outDir, "unitymaps", "map_1");
        if (!File.Exists(built)) { Debug.LogError("[M1] bundle missing: " + built); EditorApplication.Exit(1); return; }

        var md5 = CalcMd5(built);
        var clientDir = Path.Combine(ClientWin, "unitymaps");
        Directory.CreateDirectory(clientDir);
        foreach (var f in Directory.GetFiles(clientDir, "map_1_*")) File.Delete(f);
        var deployed = Path.Combine(clientDir, "map_1_" + md5);
        File.Copy(built, deployed, true);

        var mfPath = Path.Combine(ClientWin, "AssetBundles");
        if (File.Exists(mfPath))
        {
            var txt = File.ReadAllText(mfPath);
            string entry = "<AssetBundle name=\"unitymaps/map_1\" md5=\"" + md5 + "\" crc=\"0\" />";
            if (System.Text.RegularExpressions.Regex.IsMatch(
                    txt, @"<AssetBundle name=""unitymaps/map_1"" md5=""[0-9a-f]+"" crc=""0"" />"))
            {
                txt = System.Text.RegularExpressions.Regex.Replace(
                    txt, @"<AssetBundle name=""unitymaps/map_1"" md5=""[0-9a-f]+"" crc=""0"" />", entry);
            }
            else
            {
                txt = txt.Replace("</AssetBundles>", "  " + entry + "\n</AssetBundles>");
            }
            File.WriteAllText(mfPath, txt);
            Debug.Log("[M1] manifest updated: " + entry);
        }

        Debug.Log("[M1] DONE md5=" + md5 + " bytes=" + new FileInfo(built).Length + " deployed=" + deployed);
        EditorApplication.Exit(0);
    }

    /// <summary>
    /// 从 bsp_clip_extract.py 导出的 map1_clip.json 重建碰撞网格。
    /// JSON 格式：{"verts":[[x,y,z],...], "tris":[[a,b,c],...]}，坐标已是 Unity 系。
    /// </summary>
    private static Mesh BuildClipMesh()
    {
        string p = "Assets/Bundles/Map1/Collision/map1_clip.json";
        if (!File.Exists(p))
        {
            Debug.LogError("[M1] clip json 不存在: " + p + "（先跑 tools/bsp_clip_extract.py）");
            return null;
        }
        // 极简 JSON 解析：只认 {"verts":[[..],..],"tris":[[..],..]} 这种定形结构
        string s = File.ReadAllText(p);
        int iv = s.IndexOf("\"verts\":");
        int it = s.IndexOf("\"tris\":");
        if (iv < 0 || it < 0) { Debug.LogError("[M1] clip json 格式不认识"); return null; }

        var verts = new List<Vector3>();
        int i = iv + 8;
        while (i < it && s[i] != '[') i++;
        i++;
        while (i < s.Length)
        {
            while (i < s.Length && (s[i] == ',' || s[i] == ' ' || s[i] == '\n' || s[i] == '\r')) i++;
            if (i >= s.Length || s[i] == ']') break;
            if (s[i] != '[') break;
            i++;
            int end = s.IndexOf(']', i);
            var parts = s.Substring(i, end - i).Split(',');
            verts.Add(new Vector3(
                float.Parse(parts[0], System.Globalization.CultureInfo.InvariantCulture),
                float.Parse(parts[1], System.Globalization.CultureInfo.InvariantCulture),
                float.Parse(parts[2], System.Globalization.CultureInfo.InvariantCulture)));
            i = end + 1;
        }

        var tris = new List<int>();
        i = it + 7;
        while (i < s.Length && s[i] != '[') i++;
        i++;
        while (i < s.Length)
        {
            while (i < s.Length && (s[i] == ',' || s[i] == ' ' || s[i] == '\n' || s[i] == '\r')) i++;
            if (i >= s.Length || s[i] == ']') break;
            if (s[i] != '[') break;
            i++;
            int end = s.IndexOf(']', i);
            var parts = s.Substring(i, end - i).Split(',');
            tris.Add(int.Parse(parts[0]));
            tris.Add(int.Parse(parts[1]));
            tris.Add(int.Parse(parts[2]));
            i = end + 1;
        }

        if (verts.Count < 3 || tris.Count < 3)
        {
            Debug.LogError("[M1] clip json 解析为空 verts=" + verts.Count + " tris=" + tris.Count);
            return null;
        }

        var mesh = new Mesh();
        mesh.name = "map1_clip";
        // 50200 顶点 / 113370 索引，超过 UInt16 必须用 32 位索引
        mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        mesh.SetVertices(verts);
        mesh.SetTriangles(tris, 0);
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        string assetPath = "Assets/Bundles/Map1/Collision/map1_clip.asset";
        var old = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
        if (old != null) AssetDatabase.DeleteAsset(assetPath);
        AssetDatabase.CreateAsset(mesh, assetPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        return AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
    }

    private static string CalcMd5(string path)
    {
        using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var fs = File.OpenRead(path))
            return System.BitConverter.ToString(md5.ComputeHash(fs)).Replace("-", "").ToLower();
    }
}
