using Assets.Sources.Components.Interface.Info.Weapon;
using UnityEngine;

// [OFFLINE-PATCH] 自建第一人称视图：游戏的 FP 相机锚点/骨骼动画在离线环境无法把武器
// 摆进视野（模型停在视野外/绑定姿态）。这里直接按武器信息加载视图预制件，挂到 Eye
// 相机下用固定 FPS 位姿渲染，完全绕开原 rig。
public class OfflineFpsView : MonoBehaviour
{
    private GameObject _root;
    private string _currentWeapon;
    private AssetBundle _bundle;
    private int _calib;

    private void LateUpdate()
    {
        Contexts ctx = Contexts.sharedInstance;
        if (ctx == null) return;
        WeaponEntity we = ctx.weapon != null ? ctx.weapon.currentWeaponEntity : null;
        if (we == null || !we.hasBasicInfo || we.basicInfo.Info == null) return;
        IEntitsWeaponInfo info = we.basicInfo.Info;
        if (_root != null && _currentWeapon == info.Name)
        {
            Pose();
            // [OFFLINE-SCOPE] 完全按原版 HideFirstPersonViewSystem 的判定隐藏自建视图：
            //   1) fov.IsHideFristView（PlayerFovHideHandPredicationSystem 依据 WeaponCrossTable.IsHideHand 设置）
            //   2) 武器组合模式 HideFirstPersonView
            //   3) 视图动画 662（原版同样隐藏）
            //   4) 踢击状态 PLAYER_KICKING_P1
            bool hide = false;
            try
            {
                PlayerEntity me = ctx.player != null ? ctx.player.myPlayerEntity : null;
                if (me != null)
                {
                    if (me.hasFov)
                    {
                        // IsHideFristView 只覆盖部分开镜武器（RifleScopeFovRightAction）；
                        // 延迟开镜（RifleScope2FovRightAction）不置该位，原版靠视图动画 36 把枪移出视野，
                        // 我们的自建视图没有原版枪动画，所以补上 IsZoom 同源判定。
                        hide = me.fov.IsHideFristView || me.fov.IsZoom();
                        if (!hide && me.fov.IsZoom() && me.hasCurrentWeapon)
                        {
                            // 兜底复刻 PlayerFovHideHandPredicationSystem：开镜且该武器 UiModels 标了隐藏手模。
                            var row = Assets.Sources.CsvLoader.WeaponCrossLoader.Instance.Table.Find_Name(me.currentWeapon.Name);
                            if (row != null && row.IsHideHand) hide = true;
                        }
                    }
                    if (!hide && ctx.gameRule != null && ctx.gameRule.hasWeaponCombination
                        && ctx.gameRule.weaponCombination.HideFirstPersonView) hide = true;
                    if (!hide && me.hasViewAnim && me.viewAnim.ViewAnimInfo != null
                        && ((Assets.Sources.Components.Interface.Info.AnimState.IAnimStateInfo)me.viewAnim.ViewAnimInfo).StateId == 662) hide = true;
                    if (!hide && me.HasStatus(share.constant.PlayerInfoStatusConstant.PLAYER_KICKING_P1.ID)) hide = true;
                }
            }
            catch (System.Exception) { }
            if (_root.activeSelf == hide) _root.SetActive(!hide);
            if (Time.frameCount % 40 == 0)
            {
                PlayerEntity dbg = ctx.player != null ? ctx.player.myPlayerEntity : null;
                UnityEngine.Debug.Log("[OFFLINE-SCOPE] hide=" + hide
                    + " zoom=" + ((dbg != null && dbg.hasFov) ? dbg.fov.IsZoom().ToString() : "-")
                    + " isHideView=" + ((dbg != null && dbg.hasFov) ? dbg.fov.IsHideFristView.ToString() : "-")
                    + " fov=" + ((dbg != null && dbg.hasFov) ? dbg.fov.Fov.ToString("F0") : "-")
                    + " active=" + _root.activeSelf + " weapon=" + info.Name);
            }
            return;
        }
        _currentWeapon = info.Name;
        Build(info);
    }

    private void Build(IEntitsWeaponInfo info)
    {
        if (_root != null)
        {
            Object.Destroy(_root);
            _root = null;
        }
        try
        {
            string path = OfflineBundleLocator.GetLocalBundlePath(info.AssetBundleName);
            if (string.IsNullOrEmpty(path) || !System.IO.File.Exists(path))
            {
                Debug.LogWarning("[OFFLINE-FPSVIEW] bundle missing " + info.AssetBundleName);
                return;
            }
            if (_bundle != null)
            {
                _bundle = null; // 借用游戏已加载的 bundle 时不能卸载
            }
            // 优先复用游戏自己加载好的同款 bundle（重复加载同文件会被 Unity 拒绝）。
            try
            {
                foreach (AssetBundle b in AssetBundle.GetAllLoadedAssetBundles())
                {
                    if (b != null && b.name == info.AssetBundleName) { _bundle = b; break; }
                }
            }
            catch (System.Exception)
            {
            }
            if (_bundle == null)
            {
                _bundle = AssetBundle.LoadFromFile(path);
            }
            if (_bundle == null)
            {
                // 文件被游戏自身占用时 LoadFromFile 会失败，退回内存加载。
                try
                {
                    byte[] bytes = System.IO.File.ReadAllBytes(path);
                    _bundle = AssetBundle.LoadFromMemory(bytes);
                }
                catch (System.Exception ex)
                {
                    Debug.LogWarning("[OFFLINE-FPSVIEW] memory load fail " + ex.Message);
                }
            }
            if (_bundle == null)
            {
                Debug.LogWarning("[OFFLINE-FPSVIEW] load failed " + path);
                return;
            }
            string assetName = info.ViewWeaponAssetName;
            GameObject prefab = null;
            if (!string.IsNullOrEmpty(assetName))
            {
                prefab = _bundle.LoadAsset<GameObject>(assetName);
                if (prefab == null)
                {
                    string leaf = assetName;
                    int slash = leaf.LastIndexOf('/');
                    if (slash >= 0) leaf = leaf.Substring(slash + 1);
                    int dot = leaf.LastIndexOf('.');
                    if (dot > 0) leaf = leaf.Substring(0, dot);
                    prefab = _bundle.LoadAsset<GameObject>(leaf);
                }
            }
            if (prefab == null) prefab = _bundle.LoadAsset<GameObject>("hand");
            if (prefab == null) prefab = _bundle.LoadAsset<GameObject>("gun");
            if (prefab == null)
            {
                string[] names = _bundle.GetAllAssetNames();
                for (int i = 0; i < names.Length; i++)
                {
                    GameObject candidate = _bundle.LoadAsset<GameObject>(names[i]);
                    if (candidate != null) { prefab = candidate; break; }
                }
            }
            if (prefab == null)
            {
                Debug.LogWarning("[OFFLINE-FPSVIEW] prefab not found weapon=" + info.Name + " asset=" + assetName);
                return;
            }
            _root = Object.Instantiate(prefab);
            _root.name = "OfflineFpsView_" + info.Name;
            // 关闭实例上的动画组件，保持静态姿态（避免绑定姿态覆盖）。
            Animator[] anims = _root.GetComponentsInChildren<Animator>(true);
            for (int i = 0; i < anims.Length; i++) anims[i].enabled = false;
            Component[] comps = _root.GetComponentsInChildren<Component>(true);
            for (int i = 0; i < comps.Length; i++)
            {
                Component c = comps[i];
                if (c == null) continue;
                string tn = c.GetType().Name;
                if (tn == "SJAnimator" || tn == "SJAnimatorComponent")
                {
                    if (c is Behaviour) ((Behaviour)c).enabled = false;
                }
            }
            SetLayer(_root, LayerMask.NameToLayer("FPSArmWeapon"));
            Pose();
            Debug.Log("[OFFLINE-FPSVIEW] built weapon=" + info.Name + " prefab=" + prefab.name);
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning("[OFFLINE-FPSVIEW] build fail " + ex);
        }
    }

    private static void SetLayer(GameObject go, int layer)
    {
        if (layer < 0) return;
        go.layer = layer;
        for (int i = 0; i < go.transform.childCount; i++)
        {
            SetLayer(go.transform.GetChild(i).gameObject, layer);
        }
    }

    private void Pose()
    {
        if (_root == null) return;
        Camera eye = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            if (cams[i] != null && cams[i].name == "Eye") { eye = cams[i]; break; }
        }
        if (eye == null) return;
        if (_root.transform.parent != eye.transform)
        {
            _root.transform.SetParent(eye.transform, true);
            _root.transform.localPosition = new Vector3(2f, -38f, 40f);
            _root.transform.localRotation = Quaternion.Euler(0f, 6f, 0f);
            _root.transform.localScale = Vector3.one * 0.14f;
            // 生成一个静止的 FPS 观察位姿，让模型稳定可见。
            Debug.Log("[OFFLINE-FPSVIEW] attached to Eye");
        }
        // 视口自动校准：把模型对齐到画面右下（目标 0.72, 0.28）并缩放到目标高度占比。
        if (_calib < 240)
        {
            Renderer r = _root.GetComponentInChildren<Renderer>();
            if (r != null)
            {
                _calib++;
                Vector3 vp = eye.WorldToViewportPoint(r.bounds.center);
                float dist = Vector3.Distance(r.bounds.center, eye.transform.position);
                float wpp = 2f * dist * Mathf.Tan(eye.fieldOfView * 0.5f * Mathf.Deg2Rad);
                float ex = 0.72f - vp.x;
                float ey = 0.28f - vp.y;
                Vector3 lp = _root.transform.localPosition;
                lp.x += ex * wpp * 0.6f;
                lp.y += ey * wpp * 0.6f;
                _root.transform.localPosition = lp;
                // 屏幕高度占比校准：目标 bbox 高度约视口的 0.5。
                if (wpp > 0.01f)
                {
                    float frac = r.bounds.size.y / wpp;
                    if (frac > 0.001f)
                    {
                        float k = Mathf.Clamp(0.5f / frac, 0.85f, 1.18f);
                        _root.transform.localScale *= k;
                    }
                }
                if (_calib % 60 == 0)
                {
                    Debug.Log("[OFFLINE-FPSVIEW] calib #" + _calib + " vp=" + vp.ToString("F3")
                        + " local=" + lp.ToString("F1") + " scale=" + _root.transform.localScale.x.ToString("F4"));
                }
            }
        }
    }
}
