using UnityEngine;

/// <summary>[OFFLINE-PARKOUR] 阶梯式跑酷关卡：2m 前进 + 1.2m 上升 + 左右交替 1.6m。</summary>
[DefaultExecutionOrder(21500)]
public class OfflineParkour : MonoBehaviour
{
    private struct Plat { public float x, y, z, hx, hz; }

    private Plat[] _plats;
    private Material _mat;
    private int _reached, _deaths;
    private float _bestY;
    private Vector3 _spawn;
    private bool _ready;
    private float _buildAt;

    private void Update()
    {
        if (!_ready)
        {
            if (OfflineGameController.setting == null) return;
            if (!OfflineGameController.setting.Parkour) { Destroy(gameObject); return; }
            if (_buildAt <= 0f) _buildAt = Time.time + 20f;
            if (Time.time < _buildAt) return;
            BuildCourse();
            return;
        }
        try
        {
            PlayerEntity p = Contexts.sharedInstance.player.cameraOwnerEntity;
            if (p == null || !p.hasBasicInfo || p.basicInfo.Current == null) return;
            var d = p.basicInfo.Current;
            Camera cam0 = null;
            Camera[] cs = Camera.allCameras;
            for (int ci = 0; ci < cs.Length; ci++) { if (cs[ci] != null && cs[ci].name == "Eye") { cam0 = cs[ci]; break; } }
            if (cam0 != null) { Vector3 cp = cam0.transform.position; d.X = cp.x; d.Y = cp.y; d.Z = cp.z; }
            float ex = d.X, ey = d.Y, ez = d.Z;
            float feet = ey - 150f;

            for (int i = 0; i < _plats.Length; i++)
            {
                Plat pl = _plats[i];
                if (Mathf.Abs(ex - pl.x) > pl.hx * 1.3f || Mathf.Abs(ez - pl.z) > pl.hz * 1.3f) continue;
                // 只在“落到平台面附近”时吸附；飞在上方不会被粘住
                if (feet > pl.y + 130f || feet < pl.y - 130f) continue;
                if (p.hasMove && p.move.PyPlayerMove != null)
                    p.move.PyPlayerMove.SetPosition(ex, pl.y + 150f, ez);
                if (i > _reached) _reached = i;
                if (pl.y > _bestY) _bestY = pl.y;
                break;
            }

            if (ey < _spawn.y - 3000f)
            {
                _deaths++;
                int back = Mathf.Max(0, _reached);
                Plat pl = _plats[back];
                if (p.hasMove && p.move.PyPlayerMove != null)
                    p.move.PyPlayerMove.SetPosition(pl.x, pl.y + 150f, pl.z);
                Debug.Log("[OFFLINE-PARKOUR] fall -> respawn at " + back + " deaths=" + _deaths);
            }
        }
        catch (System.Exception) { }
    }

    private void BuildCourse()
    {
        float bx = 0f, by = 200f, bz = 0f;
        try
        {
            PlayerEntity p = Contexts.sharedInstance.player.cameraOwnerEntity;
            if (p != null && p.hasBasicInfo && p.basicInfo.Current != null)
            {
                bx = p.basicInfo.Current.X;
                by = p.basicInfo.Current.Y - 150f;
                bz = p.basicInfo.Current.Z;
                Camera cb = null; Camera[] cbs = Camera.allCameras;
                for (int ci2 = 0; ci2 < cbs.Length; ci2++) { if (cbs[ci2] != null && cbs[ci2].name == "Eye") { cb = cbs[ci2]; break; } }
                if (cb != null) { bx = cb.transform.position.x; by = cb.transform.position.y - 150f; bz = cb.transform.position.z; }
            }
        }
        catch (System.Exception) { }

        const int n = 64;
        _plats = new Plat[n];
        by += 0f;                       // 抬到地图上方 1km，完全脱离 BSP 碰撞
        _spawn = new Vector3(bx, by + 150f, bz);
        GameObject pad = GameObject.CreatePrimitive(PrimitiveType.Cube);
        pad.name = "PK_start";
        Object.Destroy(pad.GetComponent<Collider>());
        pad.transform.position = new Vector3(bx, by + 10f, bz);
        pad.transform.localScale = new Vector3(1200f, 20f, 1200f);
        Renderer pr = pad.GetComponent<Renderer>();
        if (pr != null) { if (_mat == null) { Shader s0 = Shader.Find("SSJJ/Diffuse"); if (s0 == null) s0 = Shader.Find("Standard"); _mat = new Material(s0); _mat.color = new Color(0.95f, 0.55f, 0.12f); } pr.material = _mat; }
        for (int i = 0; i < n; i++)
        {
            Plat p;
            p.x = bx + 800f + i * 200f;                      // 每级前进 2m
            p.z = bz + ((i % 2 == 0) ? 160f : -160f); // 左右交替 1.6m
            p.y = by + 20f + i * 120f;                // 每级上升 1.2m
            p.hx = 130f; p.hz = 130f;                 // 2.6m 见方
            _plats[i] = p;

            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.name = "PK_" + i;
            cube.transform.position = new Vector3(p.x, p.y, p.z);
            cube.transform.localScale = new Vector3(p.hx * 2f, 24f, p.hz * 2f);
            Renderer r = cube.GetComponent<Renderer>();
            if (r != null)
            {
                if (_mat == null)
                {
                    Shader sh = Shader.Find("SSJJ/Diffuse");
                    if (sh == null) sh = Shader.Find("Standard");
                    _mat = new Material(sh);
                    _mat.color = new Color(0.95f, 0.55f, 0.12f);
                }
                r.material = _mat;
            }
        }
        _ready = true;
        try
        {
            PlayerEntity me = Contexts.sharedInstance.player.cameraOwnerEntity;
            if (me != null && me.hasMove && me.move.PyPlayerMove != null)
                me.move.PyPlayerMove.SetPosition(_plats[0].x, _plats[0].y + 150f, _plats[0].z);
        }
        catch (System.Exception) { }
        Debug.Log("[OFFLINE-PARKOUR] built " + n + " steps from " + _spawn.ToString("F0"));
    }

    private void OnGUI()
    {
        if (!_ready) return;
        GUI.Label(new Rect(20f, Screen.height - 90f, 560f, 26f),
            "跑酷  平台 " + (_reached + 1) + "/" + _plats.Length +
            "  高度 " + ((_bestY - _spawn.y + 150f) / 100f).ToString("F1") + "m  掉落 " + _deaths);
        GUI.Label(new Rect(20f, Screen.height - 66f, 560f, 26f), "沿橙色台阶往上跳，掉下去回到当前平台");
    }
}
