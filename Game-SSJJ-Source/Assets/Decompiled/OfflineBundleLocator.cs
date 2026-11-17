using System.Collections.Generic;
using System.IO;
using UnityEngine;

/// <summary>
/// 离线模式的本地资产包定位器。
///
/// 客户端 StreamingAssets/AssetBundles/Windows 下按 <c>&lt;bundleName&gt;_&lt;md5&gt;</c> 平铺存放，
/// 清单文件 <c>Windows/AssetBundles</c>（XML）记录 name -> md5 映射。
/// 离线模式没有下载队列，引擎的 IsAssetBundleDownloaded 对本地包会返回 false，
/// 所以这里直接用磁盘存在性做判定。
/// </summary>
public static class OfflineBundleLocator
{
    private static Dictionary<string, bool> _cache;
    private static Dictionary<string, string> _nameToFile;

    private static string WindowsDir
    {
        get { return Path.Combine(Application.streamingAssetsPath, "AssetBundles/Windows"); }
    }

    private static void Build()
    {
        if (_cache != null) return;
        _cache = new Dictionary<string, bool>(System.StringComparer.OrdinalIgnoreCase);
        _nameToFile = new Dictionary<string, string>(System.StringComparer.OrdinalIgnoreCase);

        string dir = WindowsDir;
        if (!Directory.Exists(dir))
        {
            Debug.LogWarning("[OFFLINE-BUNDLE] dir missing " + dir);
            return;
        }

        // 1) 清单优先
        string manifest = Path.Combine(dir, "AssetBundles");
        if (File.Exists(manifest))
        {
            try
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.LoadXml(File.ReadAllText(manifest));
                System.Xml.XmlNodeList nodes = doc.SelectNodes("/AssetBundles/AssetBundle");
                if (nodes != null)
                {
                    for (int i = 0; i < nodes.Count; i++)
                    {
                        System.Xml.XmlElement e = nodes[i] as System.Xml.XmlElement;
                        if (e == null) continue;
                        string name = e.GetAttribute("name");
                        string md5 = e.GetAttribute("md5");
                        if (string.IsNullOrEmpty(name)) continue;
                        // 磁盘命名规则：<name 的最后一段>_<md5>，放在 <name 首段>/ 目录下
                        int slash = name.LastIndexOf('/');
                        string leaf = (slash >= 0) ? name.Substring(slash + 1) : name;
                        string file = Path.Combine(Path.Combine(dir, SubDir(name)), leaf + "_" + md5);
                        if (File.Exists(file))
                        {
                            _cache[name] = true;
                            _nameToFile[name] = file;
                        }
                        else
                        {
                            _cache[name] = false;
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogWarning("[OFFLINE-BUNDLE] manifest parse failed: " + ex.Message);
            }
        }

        // 2) 兜底：裸扫描（无清单项时按 <name>_<32hex> 前缀匹配）
        string[] files = Directory.GetFiles(dir, "*", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            string fn = Path.GetFileName(files[i]);
            int us = fn.LastIndexOf('_');
            if (us <= 0) continue;
            string md5 = fn.Substring(us + 1);
            if (md5.Length != 32) continue;
            string rel = files[i].Substring(dir.Length).TrimStart('/', '\\').Replace('\\', '/');
            string bundleName = rel.Substring(0, rel.LastIndexOf('_'));
            if (!_cache.ContainsKey(bundleName))
            {
                _cache[bundleName] = true;
                _nameToFile[bundleName] = files[i];
            }
        }

        Debug.Log("[OFFLINE-BUNDLE] indexed " + _cache.Count + " bundles from " + dir);
        int shown = 0;
        foreach (KeyValuePair<string, bool> kv in _cache)
        {
            if (shown++ >= 12) break;
            Debug.Log("[OFFLINE-BUNDLE] key='" + kv.Key + "' ok=" + kv.Value);
        }
    }

    private static string SubDir(string bundleName)
    {
        int idx = bundleName.IndexOf('/');
        return (idx > 0) ? bundleName.Substring(0, idx) : "";
    }

    /// <summary>本地磁盘上是否存在该 bundle（离线即视为"已下载"）。</summary>
    public static bool IsLocalBundleAvailable(string bundleName)
    {
        if (string.IsNullOrEmpty(bundleName)) return false;
        Build();
        bool ok;
        if (_cache.TryGetValue(bundleName, out ok)) return ok;
        _cache[bundleName] = false;
        return false;
    }

    /// <summary>取 bundle 的本地文件绝对路径，找不到返回 null。</summary>
    public static string GetLocalBundlePath(string bundleName)
    {
        if (string.IsNullOrEmpty(bundleName)) return null;
        Build();
        string p;
        return _nameToFile.TryGetValue(bundleName, out p) ? p : null;
    }
}
