using UnityEngine;

// [OFFLINE-PATCH] 原版第一人称需要一个 HandCamera（effectprefab/handcamera）来渲染
// FPSArmWeapon 层；离线环境 loadResults["HandCamera"] 为空，导致手模永远不可见。
// 这里在运行时自建该相机（能取到官方预制件就用，取不到就用普通 Camera）。
public class OfflineHandCameraFix : MonoBehaviour
{
    private Camera _cam;
    private float _nextTry;

    private void LateUpdate()
    {
        if (_cam != null)
        {
            Sync();
            return;
        }
        if (Time.realtimeSinceStartup < _nextTry) return;
        _nextTry = Time.realtimeSinceStartup + 1f;

        Camera eye = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { eye = cams[i]; break; }
        }
        if (eye == null) return;

        // 先找游戏是否已经创建过 HandCamera（含未激活的）。
        Camera existing = null;
        Camera[] all = Resources.FindObjectsOfTypeAll<Camera>();
        for (int i = 0; i < all.Length; i++)
        {
            if (all[i] != null && all[i].name == "HandCamera") { existing = all[i]; break; }
        }
        // 注意：FindObjectsOfTypeAll 也会返回未实例化的预制件资产，不能直接激活复用。
        // 这里只在“已在场景内”的情况下复用。
        if (existing != null && existing.gameObject.scene.IsValid())
        {
            _cam = existing;
            _cam.gameObject.SetActive(true);
            _cam.enabled = true;
            Sync();
            Debug.Log("[OFFLINE-HANDCAM] using existing scene HandCamera");
            return;
        }

        try
        {
            GameObject prefab = null;
            foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
            {
                if (b == null || b.name != "effectprefab/handcamera") continue;
                prefab = b.LoadAsset<GameObject>("HandCamera");
                if (prefab == null)
                {
                    string[] names = b.GetAllAssetNames();
                    for (int i = 0; i < names.Length; i++)
                    {
                        GameObject c = b.LoadAsset<GameObject>(names[i]);
                        if (c != null) { prefab = c; break; }
                    }
                }
                break;
            }
            if (prefab == null && existing != null) prefab = existing.gameObject;
            GameObject go = prefab != null ? Object.Instantiate(prefab) : new GameObject("HandCamera");
            go.name = "HandCamera";
            go.transform.SetParent(eye.transform, false);
            go.transform.localPosition = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
            Camera cam = go.GetComponent<Camera>();
            if (cam == null) cam = go.AddComponent<Camera>();
            _cam = cam;
            Sync();
            Debug.Log("[OFFLINE-HANDCAM] created from " + (prefab != null ? "prefab" : "scratch"));
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-HANDCAM] create fail " + ex.Message);
        }
    }

    private void Sync()
    {
        if (_cam == null) return;
        int mask = LayerMask.GetMask(new string[2] { "FPSArmWeapon", "FirstHandEffect" });
        if (mask == 0) mask = 1 << LayerMask.NameToLayer("FPSArmWeapon");
        _cam.cullingMask = mask;
        _cam.clearFlags = CameraClearFlags.Depth;
        _cam.depth = 1f;
        _cam.nearClipPlane = 1f;
        _cam.farClipPlane = 20000f;
        // 与 Eye 完全一致的投影参数，保证手模与主视角对齐。
        Camera eye2 = null;
        Camera[] cams2 = Camera.allCameras;
        for (int i = 0; i < cams2.Length; i++)
        {
            if (cams2[i] != null && cams2[i].name == "Eye") { eye2 = cams2[i]; break; }
        }
        if (eye2 != null)
        {
            _cam.fieldOfView = eye2.fieldOfView;
            _cam.aspect = eye2.aspect;
            _cam.nearClipPlane = 0.3f;
            _cam.farClipPlane = 20000f;
            _cam.transform.SetParent(eye2.transform, false);
            _cam.transform.localPosition = new Vector3(0f, 0f, 2f);
            _cam.transform.localRotation = Quaternion.identity;
        }
        else
        {
            _cam.fieldOfView = 45f;
        }
        _cam.renderingPath = RenderingPath.Forward;
        _cam.allowHDR = false;
        _cam.allowMSAA = false;
        if (!_cam.gameObject.activeSelf) _cam.gameObject.SetActive(true);
        if (!_cam.enabled) _cam.enabled = true;
        // 去重：Eye 相机也包含 FPS 层，会和 HandCamera 双重渲染（双层手模/两把枪）。
        Camera eye = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { eye = cams[i]; break; }
        }
        if (eye != null && eye != _cam)
        {
            int fpsLayers = LayerMask.GetMask(new string[2] { "FPSArmWeapon", "FirstHandEffect" });
            if ((eye.cullingMask & fpsLayers) != 0)
            {
                eye.cullingMask &= ~fpsLayers;
                Debug.Log("[OFFLINE-HANDCAM] removed FPS layers from Eye mask");
            }
        }
    }
}
