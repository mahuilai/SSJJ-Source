using UnityEngine;
using SSJJMath;

/// <summary>
/// 第一人称手模可见性兜底。
///
/// 背景：手模（viewhand/man）、武器（weapon/black_dagger）由引擎自己的
/// FirstPersonModule / LoadFirstHandSystem 负责加载与挂载，它们挂在 Eye 相机下、
/// 层为 PlayerSkin(14)。离线模式下 eye.cullingMask 若只含 FPSArmWeapon，
/// 手模就渲染不出来。这里只做两件事：把 PlayerSkin 补进 eye 的 cullingMask，
/// 以及输出诊断日志。不再自己 LoadFromFile 建模型，避免与引擎重复加载同一个包。
/// </summary>
[DefaultExecutionOrder(21000)]
public class OfflineFirstPersonRig : MonoBehaviour
{
    private int _poseFailLog;
    private bool _fpsMaskClean;
    private int _fpsMaskLog;
    private int _fovW;
    private int _fovH;
    private int _fovLog;
    private GameObject _testCube;
    private int _poseCalib;
    private float _diagT;
    private bool _diagLogged;
    private float _fixT;
    private int _fixCount;
    private int _flagLogs;
    private float _flagT;
    private static float s_testYaw;
    private float _shotT;
    private int _shotCount;
    private float _boundsT;
    private int _boundsLogs;
    private float _calibT;
    private int _calibStep;
    private static bool s_enableCalib = false;
    private static int s_duckLogged = -1;
    private static float s_duckDiag;
    private bool _meleeDumped;
    private bool _reanchored;
    private bool _shrunk;

    private void AutoCapture()
    {
        _shotT += Time.deltaTime;
        PlayerEntity fp = null;
        try { fp = Contexts.sharedInstance.player.myPlayerEntity; } catch (System.Exception) { }
        if (fp != null && _shotT > 3f)
        {
            _shotT = 0f;
            _shotCount++;
            string p = "D:/SSJJ-4399/battle/3_64/fp_auto_current.png";
            ScreenCapture.CaptureScreenshot(p);
            Debug.Log("[OFFLINE-SHOT] " + p + " count=" + _shotCount + " in-game!");
        }
        _calibT += Time.deltaTime;
        if (!_reanchored && _diagT > 2f && GameObject.Find("FirstHand") != null)
        {
            _reanchored = true;
            Assets.Sources.Modules.Player.Anim.FirstPerson.LoadFirstHandSystem.OfflineForceReanchor(0f);
            Debug.Log("[OFFLINE-FPREANCHOR] after warmup");
        }
        if (s_enableCalib && _calibStep < 4 && _calibT > 8f)
        {
            _calibT = 0f;
            _calibStep++;
            Assets.Sources.Modules.Player.Anim.FirstPerson.LoadFirstHandSystem.OfflineCalibStep = _calibStep;
            Assets.Sources.Modules.Player.Anim.FirstPerson.LoadFirstHandSystem.OfflineForceReanchor(0f);
            Debug.Log("[OFFLINE-FPCALIB] step=" + _calibStep);
        }
        _boundsT += Time.deltaTime;
        if (_boundsLogs < 10 && _boundsT > 1.5f)
        {
            _boundsT = 0f;
            _boundsLogs++;
            try
            {
                Camera eyeCam = Camera.main;
                GameObject fh = GameObject.Find("FirstHand");
                if (eyeCam != null && fh != null)
                {
                    var rs = fh.GetComponentsInChildren<Renderer>();
                    string s = "[OFFLINE-FPBOUNDS] eye=" + eyeCam.name + " eyePos=" + eyeCam.transform.position.ToString("F1")
                        + " near=" + eyeCam.nearClipPlane + " mask=" + LayerNames(eyeCam.cullingMask);
                    int n = 0;
                    for (int i = 0; i < rs.Length && n < 5; i++)
                    {
                        Renderer r = rs[i];
                        if (r == null || !r.enabled || !r.gameObject.activeInHierarchy) continue;
                        Vector3 c = r.bounds.center;
                        Vector3 vp = eyeCam.WorldToViewportPoint(c);
                        s += " [" + r.name + " vp=" + vp.ToString("F2") + " d=" + Vector3.Distance(c, eyeCam.transform.position).ToString("F1")
                            + " ext=" + r.bounds.extents.ToString("F1") + " l=" + r.gameObject.layer + "]";
                        n++;
                    }
                    Debug.Log(s);
                }
            }
            catch (System.Exception ex) { Debug.LogWarning("[OFFLINE-FPBOUNDS] fail " + ex.Message); }
        }
    }

    /// <summary>[OFFLINE-SCOPE] 相机主人是否处于「开镜隐藏第一人称」状态。</summary>
    private static bool FpHidden()
    {
        try
        {
            var pctx = Contexts.sharedInstance.player;
            if (pctx == null || !pctx.isCameraOwner) return false;
            PlayerEntity ce = pctx.cameraOwnerEntity;
            return ce != null && ce.hasFov && ce.fov.IsHideFristView;
        }
        catch (System.Exception) { return false; }
    }

    private void LateUpdate()
    {
        // [OFFLINE-SCOPE] 原来这里每帧把三个对象全部 SetActive(true)（执行顺序 21000，
        // 在所有渲染系统之后），把 SyncFirstPersonVisibility 的开镜隐藏整个推翻。
        // 开镜期间直接跳过强制激活。
        try
        {
            if (!FpHidden())
            {
                var pctx = Contexts.sharedInstance.player;
                PlayerEntity ce = (pctx != null && pctx.isCameraOwner) ? pctx.cameraOwnerEntity : null;
                if (ce != null && ce.hasFirstPersonUnityObjects)
                {
                    var fpu = ce.firstPersonUnityObjects;
                    if (fpu.WeaponGameObject != null && !fpu.WeaponGameObject.activeSelf)
                        fpu.WeaponGameObject.SetActive(true);
                    if (fpu.HandGameObject != null && !fpu.HandGameObject.activeSelf)
                        fpu.HandGameObject.SetActive(true);
                    if (fpu.HandCameraObject != null && !fpu.HandCameraObject.activeSelf)
                        fpu.HandCameraObject.SetActive(true);
                    Camera hc = fpu.HandCameraObject != null ? fpu.HandCameraObject.GetComponent<Camera>() : null;
                    if (hc != null && !hc.enabled)
                        hc.enabled = true;
                }
                GameObject fh = GameObject.Find("FirstHand");
                if (fh != null && !fh.activeSelf)
                    fh.SetActive(true);
            }
        }
        catch (System.Exception) { }

        // [OFFLINE-TEST] F7 每次切换 90° 手模偏航并重锚（头部相机保持在眼睛处）。
        if (!OfflineHud.IsModalPanelOpen && Input.GetKeyDown(KeyCode.F7))
        {
            s_testYaw += 90f;
            Assets.Sources.Modules.Player.Anim.FirstPerson.LoadFirstHandSystem.OfflineForceReanchor(s_testYaw);
            Debug.Log("[OFFLINE-FP-YAW] yaw=" + s_testYaw);
        }
        // [OFFLINE-TEST] F8 切换 FirstHand 根 X 镜像：验证 config 矩阵的左右手坐标系翻转。
        if (!OfflineHud.IsModalPanelOpen && Input.GetKeyDown(KeyCode.F8))
        {
            GameObject fh = GameObject.Find("FirstHand");
            if (fh != null)
            {
                Vector3 s = fh.transform.localScale;
                fh.transform.localScale = new Vector3(-s.x, s.y, s.z);
                Debug.Log("[OFFLINE-FP-MIRROR] scale=" + fh.transform.localScale.ToString("F2"));
            }
        }
        // [OFFLINE-DUCK] 原版链路：把蹲键写进 UserCmd.Buttons(0x80)，由引擎 DuckManager 结算视高/跳蹲。
        try
        {
            bool duckKey = !OfflineHud.IsModalPanelOpen && (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift)
                || Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.C));
            SSJJUserCmd.UserCmd cur = Contexts.sharedInstance.userCommand.commands.getCurrentCmd();
            if (cur != null)
            {
                if (duckKey) cur.Buttons |= 0x80;
                else cur.Buttons &= ~0x80;
                // [OFFLINE-DUCK] 原版空中也能保持蹲姿：快照 DuckState/视高直接跟按键走，
                // 不依赖 DuckManager 的落地判定，否则跳起就自动站直。
                PlayerEntity meDuck = Contexts.sharedInstance.player.cameraOwnerEntity;
                if (meDuck != null && meDuck.hasBasicInfo && meDuck.basicInfo.Current != null)
                {
                    int duckState = duckKey ? 2 : 3;
                    float viewHeight = duckKey ? 93f : 150f;
                    meDuck.basicInfo.Current.DuckState = duckState;
                    meDuck.basicInfo.Current.ViewHeight = viewHeight;
                    if (meDuck.basicInfo.Next != null)
                    {
                        meDuck.basicInfo.Next.DuckState = duckState;
                        meDuck.basicInfo.Next.ViewHeight = viewHeight;
                    }
                    // PlayerMoveInitSystem normally copies this from a server snapshot.
                    // Offline has no crouch snapshot, so keep the local movement/animation
                    // component in sync with the same held input, including while airborne.
                    if (meDuck.hasMove)
                    {
                        meDuck.move.DuckState = duckState;
                        meDuck.move.ViewHeightBase = viewHeight;
                    }
                }
                if (Input.GetMouseButton(0) && !OfflineHud.IsModalPanelOpen) cur.Buttons |= 0x40;
                else cur.Buttons &= ~0x40;
                if (Input.GetMouseButton(1) && !OfflineHud.IsModalPanelOpen) cur.Buttons |= 0x200;
                else cur.Buttons &= ~0x200;
            }
            if (Time.realtimeSinceStartup - s_duckDiag > 1f)
            {
                s_duckDiag = Time.realtimeSinceStartup;
                PlayerEntity meD = Contexts.sharedInstance.player.cameraOwnerEntity;
                string st = (meD != null && meD.hasMove) ? meD.move.DuckState.ToString() : "-";
                string h = (meD != null && meD.hasBasicInfo && meD.basicInfo.Current != null) ? meD.basicInfo.Current.ViewHeight.ToString("F0") : "-";
                string hb = (meD != null && meD.hasMove) ? meD.move.ViewHeightBase.ToString("F0") : "-";
                string og = (meD != null && meD.hasMove) ? meD.move.OnGround.ToString() : "-";
                string leg = (meD != null && meD.hasLegAnim && meD.legAnim.LegsAnimInfo != null)
                    ? ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)meD.legAnim.LegsAnimInfo).StateId.ToString() : "-";
                Debug.Log("[OFFLINE-DUCK] key=" + duckKey + " btn=" + (cur != null ? cur.Buttons : 0)
                    + " state=" + st + " viewCur=" + h + " viewBase=" + hb + " ground=" + og + " leg=" + leg);
            }
        }
        catch (System.Exception) { }
        // [OFFLINE-MELEE] 一次性输出各背包近战武器的攻击候选动画名，便于核对。
        if (!_meleeDumped && _diagT > 12f && OfflineGameController.setting != null)
        {
            _meleeDumped = true;
            try
            {
                for (int bi = 1; bi <= OfflineGameSetting.BagCount; bi++)
                {
                    string melee = OfflineGameController.setting.GetBag(bi).melee;
                    if (string.IsNullOrEmpty(melee)) continue;
                    var info = Assets.Sources.Info.Weapon.WeaponInfoFactory.Instance.GetWeaponInfo(melee) as Assets.Sources.Components.Interface.Info.Weapon.IEntitsWeaponInfo;
                    Debug.Log("[OFFLINE-MELEE] bag" + bi + " " + melee + " -> " + Assets.Sources.Modules.Player.Anim.FirstPerson.ViewAnimSystem.DumpAttackAnimNames(info));
                }
            }
            catch (System.Exception ex) { Debug.LogWarning("[OFFLINE-MELEE] dump fail " + ex.Message); }
        }
        // [OFFLINE-FOV] 原版视野：SSJJ 的 75 是水平 FOV，垂直 FOV 随宽高比变化。
        // 分辨率/窗口变更（或每帧）都按 FovUtility.SsjjFovToUnityFov 重算，同步 Eye 与手部相机。
        try
        {
            if (Screen.width != _fovW || Screen.height != _fovH)
            {
                _fovW = Screen.width;
                _fovH = Screen.height;
                float vf = FovUtility.SsjjFovToUnityFov(75f, (float)Screen.width, (float)Screen.height);
                Camera[] camsF = Camera.allCameras;
                for (int i = 0; i < camsF.Length; i++)
                {
                    Camera c = camsF[i];
                    if (c == null) continue;
                    if (c.name == "Eye" || c.name == "Main Camera" || c.name.StartsWith("HandCamera"))
                    {
                        c.fieldOfView = vf;
                    }
                }
                // 分辨率切换后相机/层掩码可能被重建：重跑掩码清理并恢复手部相机参数，
                // 否则 Main Camera 与 Eye 同时绘制 FPS 层会闪屏。
                _fpsMaskClean = false;
                Camera eyeC = null;
                Camera handC = null;
                for (int i = 0; i < camsF.Length; i++)
                {
                    Camera c2 = camsF[i];
                    if (c2 == null) continue;
                    if (c2.name == "Eye") eyeC = c2;
                    else if (c2.name.StartsWith("HandCamera")) handC = c2;
                }
                if (handC != null && eyeC != null)
                {
                    int fpsMask2 = LayerMask.GetMask(new string[2] { "FPSArmWeapon", "FirstHandEffect" });
                    handC.cullingMask = fpsMask2;
                    handC.clearFlags = CameraClearFlags.Depth;
                    handC.depth = eyeC.depth + 1f;
                    handC.enabled = true;
                    eyeC.cullingMask &= ~fpsMask2;
                }
                if (_fovLog++ < 6)
                {
                    Debug.Log("[OFFLINE-FOV] screen=" + Screen.width + "x" + Screen.height + " vfov=" + vf.ToString("F2"));
                }
            }
        }
        catch (System.Exception) { }
        _diagT += Time.deltaTime;
        AutoCapture();
        if (!_diagLogged && _diagT > 8f)
        {
            _diagLogged = true;
            DumpDiagnostics();
        }

        // 手模可能在进图后若干秒才挂上，持续补掩码
        _fixT += Time.deltaTime;
        if (_fixT > 1f)
        {
            _fixT = 0f;
            EnsureHandVisible();
        }

        // 诊断：持续观察相机归属实体的视图标记，确认 FirstPersonView 到底有没有被置上。
        _flagT += Time.deltaTime;
        if (_flagT > 3f)
        {
            _flagT = 0f;
            DumpViewFlags();
        }
    




        // [OFFLINE-PATCH] 闪烁根因：Main Camera 与 Eye 同时渲染 FPS 层（双重绘制）。
        // 原版 FPS 层只应由 Eye 渲染，这里从其它相机剔除。
        try
        {
            if (!_fpsMaskClean)
            {
                int fpsLayers = LayerMask.GetMask(new string[2] { "FPSArmWeapon", "FirstHandEffect" });
                if (fpsLayers != 0)
                {
                    Camera[] cams = Camera.allCameras;
                    for (int i = 0; i < cams.Length; i++)
                    {
                        Camera c = cams[i];
                        if (c == null || c.name.StartsWith("HandCamera")) continue;
                        if ((c.cullingMask & fpsLayers) != 0)
                        {
                            c.cullingMask &= ~fpsLayers;
                            Debug.Log("[OFFLINE-FPMASK] stripped FPS layers from camera " + c.name);
                        }
                    }
                    _fpsMaskClean = true;
                }
            }
        }
        catch (System.Exception ex)
        {
            if (_fpsMaskLog++ < 3) Debug.LogWarning("[OFFLINE-FPMASK] fail " + ex.Message);
        }
}

    /// <summary>
    /// 打印 cameraOwner 的视图标记 + FirstHand 子节点数 + 相机模式。
    /// LoadFirstHandSystem 的加载组要求实体持有 FirstPersonView 标记（由 SwitchPersonViewSystem
    /// 依据 worldCamera.cameraMode 写入），没有这个标记手模整条链都不会跑。
    /// </summary>
    private void DumpViewFlags()
    {
        if (_flagLogs++ > 12) return;
        try
        {
            var pctx = Contexts.sharedInstance.player;
            var wc = Contexts.sharedInstance.worldCamera;
            PlayerEntity ce = pctx.isCameraOwner ? pctx.cameraOwnerEntity : null;
            string s = "[OFFLINE-FPV] mode=" + (wc.hasCameraMode ? ((int)wc.cameraMode.Mode).ToString() : "-")
                + " hasOwner=" + (ce != null);
            if (ce != null)
            {
                s += " id=" + ce.entityId.Value
                    + " 1pv=" + ce.isFirstPersonView
                    + " 3pv=" + ce.isThirdPersonView
                    + " camOwner=" + ce.isCameraOwner
                    + " dead=" + (ce.hasBasicInfo && ce.basicInfo.IsDead)
                    + " hasFPUnity=" + ce.hasFirstPersonUnityObjects
                    + " hasFPRes=" + ce.hasFirstPersonViewResource;
            }
            GameObject root = GameObject.Find("FirstHand");
            s += " firstHandChildren=" + (root != null ? root.transform.childCount : -1);
            try
            {
                if (ce != null && ce.hasFirstPersonUnityObjects)
                {
                    var fpu = ce.firstPersonUnityObjects;
                    s += " handObj=" + DescribeFp(fpu.HandGameObject) + " weaponObj=" + DescribeFp(fpu.WeaponGameObject);
                }
            }
            catch (System.Exception) { }

            // 直接数一遍真实命中的实体数（不靠判断 has 组件）
            int fpMarked = 0, loadable = 0, candidates = 0;
            var all = pctx.GetGroup(PlayerMatcher.EntityId);
            var it = all.GetEnumerator();
            while (it.MoveNext())
            {
                PlayerEntity e = it.Current;
                if (e == null) continue;
                candidates++;
                bool fp = e.isFirstPersonView;
                if (fp) fpMarked++;
                if (fp && !e.hasFirstPersonUnityObjects && !e.hasLoadFirstPersonViewResource
                    && !e.hasFirstPersonViewResource) loadable++;
            }
            s += " ents=" + candidates + " fpMarked=" + fpMarked + " loadable=" + loadable;

            // 逐帧计数：LoadFirstHandSystem 一旦跑过就会给实体加 LoadFirstPersonViewResource（哪怕是瞬时）
            // 用 LoadFirstHandSystem 的真实组条件手算一遍，同时打标记观察是否被置上。
            s += " lfSeen=" + ce.hasLoadFirstPersonViewResource;
            s += " fpLoadCalls=" + Assets.Sources.Modules.Player.Anim.FirstPerson.LoadFirstHandSystem.s_offlineLoadCalls;

            // 用真正的 LoadFirstHandSystem 加载组条件复算一遍，看门禁卡在哪一项
            int gFP = pctx.GetGroup(PlayerMatcher.FirstPersonView).count;
            int gNotUnity = pctx.GetGroup(PlayerMatcher.FirstPersonUnityObjects).count;
            int gRes = pctx.GetGroup(PlayerMatcher.FirstPersonViewResource).count;
            int gLoadFlag = pctx.GetGroup(PlayerMatcher.LoadFirstPersonViewResource).count;
            s += " grp[fp=" + gFP + ",unity=" + gNotUnity + ",res=" + gRes + ",loadFlag=" + gLoadFlag + "]";

            // 直接枚举一次，逐个字段核对
            var fpGroup = pctx.GetGroup(PlayerMatcher.FirstPersonView).GetEnumerator();
            while (fpGroup.MoveNext())
            {
                PlayerEntity e = fpGroup.Current;
                if (e == null) continue;
                s += " cand{id=" + e.entityId.Value
                    + " uni=" + e.hasFirstPersonUnityObjects
                    + " lf=" + e.hasLoadFirstPersonViewResource
                    + " res=" + e.hasFirstPersonViewResource
                    + " wi=" + (e.hasCurrentWeapon ? (e.currentWeapon.WeaponInfo != null ? e.currentWeapon.WeaponInfo.Name : "null") : "noCW")
                    + " req=" + (e.hasFirstPersonViewResource ? "yes" : "-")
                    + "}";
            }

            // 模块系统表
            var feat = Assets.Sources.Framework.System.GameModuleFeature.Instance;
            if (feat != null)
            {
                var mod = feat.GetType();
                foreach (string fn in new string[] { "_resourceLoadSystem", "_commonResourceLoadSystem", "_resourceInitSystem" })
                {
                    var f = mod.GetField(fn, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    object o = (f != null) ? f.GetValue(feat) : null;
                    if (o == null) { s += " " + fn + "=null"; continue; }
                    var lst = o.GetType().GetProperty("Systems").GetValue(o, null) as System.Collections.IList;
                    s += " " + fn + "=" + ((lst != null) ? lst.Count : -1);
                    if (lst != null && fn == "_resourceLoadSystem")
                    {
                        for (int i = 0; i < lst.Count; i++)
                            s += "[" + (lst[i] == null ? "null" : lst[i].GetType().Name) + "]";
                    }
                }
            }
            else s += " feat=null";
            Debug.Log(s);
        }
        catch (System.Exception e)
        {
            Debug.Log("[OFFLINE-FPV] ex " + e.GetType().Name + ":" + e.Message);
        }
    }

    private static string LayerNames(int mask)
    {
        string s = "";
        for (int i = 0; i < 32; i++)
        {
            if ((mask & (1 << i)) == 0) continue;
            string n = LayerMask.LayerToName(i);
            s += (n.Length > 0 ? n : i.ToString()) + ",";
        }
        return s;
    }

    /// <summary>
    /// 把手模所在层补进渲染手模的相机的 cullingMask。
    /// 判定依据：相机子物体里存在 Renderer 且其层未被 cullingMask 覆盖。
    /// </summary>
    private static string DescribeFp(GameObject go)
    {
        if (go == null) return "null";
        var sb = new System.Text.StringBuilder();
        sb.Append(go.name).Append("(a=").Append(go.activeInHierarchy).Append(",pos=").Append(go.transform.position.ToString("F0")).Append(")");
        var rs = go.GetComponentsInChildren<Renderer>(true);
        for (int i = 0; i < rs.Length && i < 6; i++)
        {
            var r = rs[i];
            if (r == null) continue;
            sb.Append(" [").Append(r.name).Append(" ai=").Append(r.gameObject.activeInHierarchy)
              .Append(" en=").Append(r.enabled).Append(" l=").Append(r.gameObject.layer).Append("]");
        }
        return sb.ToString();
    }

    private void EnsureHandVisible()
    {
        // [OFFLINE-SCOPE] 开镜隐藏期间不能把 FPSArmWeapon 层补回 Eye 相机：只要 Eye 渲染
        // 这一层，就算对象 SetActive(false) 之外的手模部件也会被重新画出来（镜片上糊手）。
        if (FpHidden()) return;
        Camera[] all = Camera.allCameras;
        for (int ci = 0; ci < all.Length; ci++)
        {
            Camera c = all[ci];
            if (c == null || !c.isActiveAndEnabled) continue;
            Renderer[] rs = c.GetComponentsInChildren<Renderer>(true);
            if (rs.Length == 0) continue;

            int add = 0;
            for (int i = 0; i < rs.Length; i++)
            {
                int lay = rs[i].gameObject.layer;
                if (lay == 0) continue;             // Default 层不碰
                if (lay == c.gameObject.layer) continue;
                if ((c.cullingMask & (1 << lay)) == 0) add |= 1 << lay;
            }
            if (add == 0) continue;

            int before = c.cullingMask;
            c.cullingMask |= add;
            _fixCount++;
            Debug.Log("[OFFLINE-FP] camera " + c.name + " cullingMask " + LayerNames(before)
                + " -> " + LayerNames(c.cullingMask) + " (added " + LayerNames(add) + ", fix#" + _fixCount + ")");
        }
    }

    /// <summary>
    /// 手模树诊断：LoadFirstHandSystem 把 gameobj/weaponObj 都挂到名为 "FirstHand"
    /// 的根节点下，层设为 FPSArmWeapon，再由 HandCamera（cullingMask 只有 FPSArmWeapon）
    /// 单独渲染。这里把整棵树的状态打出来，确认到底有没有加载。
    /// </summary>
    private static void DumpHandTree()
    {
        int fpsLayer = LayerMask.NameToLayer("FPSArmWeapon");
        GameObject root = GameObject.Find("FirstHand");
        if (root == null)
        {
            Debug.Log("[OFFLINE-FPHAND] FirstHand root NOT FOUND  fpsLayer=" + fpsLayer);
            return;
        }
        Renderer[] rs = root.GetComponentsInChildren<Renderer>(true);
        string s = "[OFFLINE-FPHAND] FirstHand active=" + root.activeInHierarchy
            + " children=" + root.transform.childCount
            + " renderers=" + rs.Length
            + " pos=" + root.transform.position.ToString("F1")
            + " parent=" + ((root.transform.parent != null) ? root.transform.parent.name : "-")
            + " scale=" + root.transform.lossyScale.ToString("F3");
        for (int i = 0; i < rs.Length && i < 16; i++)
        {
            s += " [" + rs[i].name
                + " layer=" + LayerMask.LayerToName(rs[i].gameObject.layer)
                + " act=" + rs[i].gameObject.activeInHierarchy
                + " en=" + rs[i].enabled
                + " size=" + rs[i].bounds.size.ToString("F2") + "]";
        }
        Debug.Log(s);

        // [OFFLINE-FPHAND] 完整树遍历：确认武器对象是否挂进来、状态如何
        try
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            void Walk(Transform t, int depth)
            {
                if (depth > 9 || sb.Length > 3500) return;
                Renderer r = t.GetComponent<Renderer>();
                sb.Append("|").Append(new string(' ', depth * 2)).Append(t.name)
                    .Append(" a=").Append(t.gameObject.activeSelf)
                    .Append(" L=").Append(LayerMask.LayerToName(t.gameObject.layer));
                if (depth <= 1 || r != null)
                    sb.Append(" wp=").Append(t.position.ToString("F1"));
                if (r != null)
                {
                    sb.Append(" R=").Append(r.enabled).Append(" T=").Append(r.GetType().Name)
                       .Append(" mat=").Append((r.sharedMaterial == null) ? "null" : r.sharedMaterial.name)
                       .Append(" sh=").Append((r.sharedMaterial == null || r.sharedMaterial.shader == null) ? "null" : r.sharedMaterial.shader.name)
                       .Append(" bnds=").Append(r.bounds.size.ToString("F1"));
                    SkinnedMeshRenderer smr = r as SkinnedMeshRenderer;
                    if (smr != null)
                        sb.Append(" rootBone=").Append((smr.rootBone == null) ? "NULL" : smr.rootBone.name)
                           .Append(" bones=").Append((smr.bones == null) ? 0 : smr.bones.Length)
                           .Append(" mesh=").Append((smr.sharedMesh == null) ? "NULL" : smr.sharedMesh.name)
                           .Append(" lb=").Append(smr.localBounds.size.ToString("F1"));
                }
                sb.Append(" ");
                for (int c = 0; c < t.childCount; c++) Walk(t.GetChild(c), depth + 1);
            }
            Walk(root.transform, 0);
            Debug.Log("[OFFLINE-FPTREE] " + sb.ToString());
        }
        catch (System.Exception tex)
        {
            Debug.Log("[OFFLINE-FPTREE] walk fail " + tex.Message);
        }

        Camera[] all = Camera.allCameras;
        for (int i = 0; i < all.Length; i++)
        {
            Camera c = all[i];
            if (c == null) continue;
            Debug.Log("[OFFLINE-FPHAND] cam=" + c.name + " depth=" + c.depth.ToString("F1")
                + " clear=" + c.clearFlags + " mask=" + LayerNames(c.cullingMask)
                + " pos=" + c.transform.position.ToString("F1")
                + " parent=" + (c.transform.parent != null ? c.transform.parent.name : "-")
                + " enabled=" + c.isActiveAndEnabled);
        }
    }


    private void DumpDiagnostics()
    {
        DumpHandTree();
        string loaded = "";
        int cnt = 0;
        foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
        {
            if (b == null) continue;
            cnt++;
            if (cnt <= 40) loaded += b.name + "|";
        }
        Debug.Log("[OFFLINE-FP] loadedBundleCount=" + cnt + " names=" + loaded);

        Camera[] all = Camera.allCameras;
        for (int ci = 0; ci < all.Length; ci++)
        {
            Camera c = all[ci];
            if (c == null) continue;
            Renderer[] rs = c.GetComponentsInChildren<Renderer>(true);
            if (rs.Length == 0) continue;
            string s = "cam=" + c.name + " fov=" + c.fieldOfView.ToString("F1")
                + " far=" + c.farClipPlane.ToString("F0")
                + " mask=" + LayerNames(c.cullingMask) + " renderers=" + rs.Length;
            for (int i = 0; i < rs.Length && i < 12; i++)
            {
                s += " [" + rs[i].name + " layer=" + LayerNames(1 << rs[i].gameObject.layer)
                    + " active=" + rs[i].gameObject.activeInHierarchy
                    + " enabled=" + rs[i].enabled
                    + " scale=" + rs[i].transform.lossyScale.ToString("F3")
                    + " size=" + rs[i].bounds.size.ToString("F2") + "]";
            }
            Debug.Log("[OFFLINE-FP] handcam " + s);
            // [OFFLINE-TRACE] 相机管线诊断：是否渲染到 RenderTexture。
            Camera[] allCams2 = Camera.allCameras;
            for (int cj = 0; cj < allCams2.Length; cj++)
            {
                Camera cc = allCams2[cj];
                if (cc == null) continue;
                Debug.Log("[OFFLINE-FPCAMS] name=" + cc.name + " depth=" + cc.depth.ToString("F1")
                    + " enabled=" + cc.enabled + " active=" + cc.isActiveAndEnabled
                    + " rt=" + (cc.targetTexture == null ? "null" : cc.targetTexture.name)
                    + " clear=" + cc.clearFlags + " near=" + cc.nearClipPlane.ToString("F2")
                    + " fov=" + cc.fieldOfView.ToString("F1"));
            }

            // [OFFLINE-TRACE] 运行时：第一人称武器在 Eye 相机视口中的位置。
            try
            {
                PlayerEntity fp = Contexts.sharedInstance.player.myPlayerEntity;
                if (fp != null && fp.hasFirstPersonUnityObjects && fp.firstPersonUnityObjects.WeaponGameObject != null)
                {
                    Renderer wrd = fp.firstPersonUnityObjects.WeaponGameObject.GetComponentInChildren<Renderer>();
                    if (wrd != null)
                    {
                        Vector3 vp = c.WorldToViewportPoint(wrd.bounds.center);
                        Material wm = wrd.sharedMaterial;
                        Debug.Log("[OFFLINE-FPVP] rt weapon=" + wrd.name + " viewport=" + vp.ToString("F3")
                            + " dist=" + Vector3.Distance(wrd.bounds.center, c.transform.position).ToString("F1")
                            + " center=" + wrd.bounds.center.ToString("F1")
                            + " isVisible=" + wrd.isVisible + " rEnabled=" + wrd.enabled
                            + " goActive=" + wrd.gameObject.activeInHierarchy
                            + " mat=" + (wm == null ? "null" : wm.name)
                            + " shader=" + (wm == null || wm.shader == null ? "null" : wm.shader.name)
                            + " shaderOk=" + (wm != null && wm.shader != null && wm.shader.isSupported));
                    }
                }
            }
            catch (System.Exception vpx) { Debug.LogWarning("[OFFLINE-FPVP] fail " + vpx.Message); }
        }
    }
}
