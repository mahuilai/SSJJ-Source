using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;
using physics;
using physics.data;
using physics.configData;

/// <summary>
/// 离线端推进区（跳台/喷泉）：原版由服务端 mapInfo.ThrustList 下发，
/// 离线改为读取地图的场景特效配置（sceneeffectconfig.xml 里的 tiaodai/guangsu），
/// 按原版 CThrustArea 结构注入 clipMap，和在线表现一致。
/// </summary>
public static class OfflineThrustAreas
{
    private static readonly HashSet<int> s_done = new HashSet<int>();

    public static void Apply(IPyEngine engine, int sceneId)
    {
        if (engine == null || s_done.Contains(sceneId)) return;
        s_done.Add(sceneId);
        try
        {
            string path = Path.Combine(Application.streamingAssetsPath, "map" + sceneId, "sceneeffectconfig.xml");
            if (!File.Exists(path))
            {
                Debug.LogWarning("[OFFLINE-THRUST] config missing map" + sceneId);
                return;
            }
            string xml = File.ReadAllText(path);
            // 收集喷泉/跳台位置：tiaodai（跳带）/guangsu（光速）优先，diban 作为兜底底座位置
            List<Vector3> spots = new List<Vector3>();
            foreach (Match m in Regex.Matches(xml, "<effectData[^>]*model_name=\"(tiaodai|guangsu|diban)\"[^>]*>", RegexOptions.IgnoreCase))
            {
                string tag = m.Value;
                bool isPad = tag.IndexOf("tiaodai", StringComparison.OrdinalIgnoreCase) >= 0
                    || tag.IndexOf("guangsu", StringComparison.OrdinalIgnoreCase) >= 0;
                if (!isPad) continue;
                Match pm = Regex.Match(tag, "position=\"([-0-9. ]+)\"");
                if (!pm.Success) continue;
                string[] xyz = pm.Groups[1].Value.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (xyz.Length < 3) continue;
                float x, y, z;
                if (!float.TryParse(xyz[0], NumberStyles.Float, CultureInfo.InvariantCulture, out x)) continue;
                if (!float.TryParse(xyz[1], NumberStyles.Float, CultureInfo.InvariantCulture, out y)) continue;
                if (!float.TryParse(xyz[2], NumberStyles.Float, CultureInfo.InvariantCulture, out z)) continue;
                Vector3 p = new Vector3(x, y, z);
                bool dup = false;
                for (int i = 0; i < spots.Count; i++)
                {
                    if ((spots[i] - p).sqrMagnitude < 1f) { dup = true; break; }
                }
                if (!dup) spots.Add(p);
            }
            if (spots.Count == 0)
            {
                Debug.Log("[OFFLINE-THRUST] map" + sceneId + " no pad in effect config");
                return;
            }
            IPyClipMap clip = engine.GetWorld().GetClipMap();
            if (clip == null) return;
            for (int i = 0; i < spots.Count; i++)
            {
                SceneThrustAreaData data = new SceneThrustAreaData();
                data.position = new float[] { spots[i].x, spots[i].y, spots[i].z };
                data.direction = new float[] { 0f, 0f, 1f };
                data.height = 100;
                data.radius = 240;
                data.speed = 2500;
                data.moveflag = 0;
                CThrustArea area = new CThrustArea();
                area.PraseConfig(data);
                clip.GetThrustAreaList().Add(area);
                clip.SetNumThrustArea(clip.GetNumThrustArea() + 1);
                Debug.Log("[OFFLINE-THRUST] map" + sceneId + " pad " + i + " at " + spots[i].ToString("F0")
                    + " dir=up speed=2500 h=100 r=240");
            }
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[OFFLINE-THRUST] fail: " + ex.Message);
        }
    }
}
