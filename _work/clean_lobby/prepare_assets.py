# -*- coding: utf-8 -*-
import os, sys, json, zlib, zipfile, io, glob, shutil, subprocess

sys.stdout.reconfigure(encoding='utf-8')

BASE_DIR = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby"
FGUI_OUT = os.path.join(BASE_DIR, "fgui_unpacked")
os.makedirs(FGUI_OUT, exist_ok=True)

def decrypt_fgui(path):
    b = bytearray(open(path, "rb").read())
    key = b"3.1415"
    for k in range((len(b) + 1023) // 1024):
        pos = k * 1024 + 91
        if pos < len(b):
            b[pos] ^= key[5 - k % 6]
    return zlib.decompress(bytes(b[2:]), -15)

# 1. Unpack HallModePanel and NewShop fgui packages
fgui_dir = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\output\fgui"
for pat in ["*HallModePanel*.fgui", "*NewShop*.fgui", "*Main_*.fgui", "*Common_*.fgui"]:
    for p in glob.glob(os.path.join(fgui_dir, pat)):
        pkg_name = os.path.basename(p).split("_")[0]
        target_dir = os.path.join(FGUI_OUT, pkg_name)
        os.makedirs(target_dir, exist_ok=True)
        dec = decrypt_fgui(p)
        with zipfile.ZipFile(io.BytesIO(dec)) as z:
            z.extractall(target_dir)
        print(f"[prepare] Extracted FGUI package {pkg_name} -> {target_dir} ({len(os.listdir(target_dir))} files)")

# 2. Export full 21,669-item catalog from GameData.final.bin via Java Amf3Decoder
jdir = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\java_next"
java_src = r'''
import com.strikegod.downloader.service.Amf3Decoder;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

public class ExportFullCatalogJson {
    static String esc(Object o) {
        if (o == null) return "";
        String s = String.valueOf(o);
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n").replace("\t", " ");
    }
    static int toInt(Object o, int def) {
        if (o == null) return def;
        if (o instanceof Number n) return n.intValue();
        try { return Integer.parseInt(String.valueOf(o).trim()); } catch (Exception e) { return def; }
    }
    public static void main(String[] args) throws Exception {
        byte[] b = Files.readAllBytes(Paths.get("d:/逆向/SSJJ双塔惊魂/_work/GameData.final.bin"));
        Map<?,?> m = (Map<?,?>) new Amf3Decoder(b).decodeOne();

        String[][] tables = {
            {"shop_weapon", "1"},
            {"shop_avatar", "2"},
            {"shop_item", "3"},
            {"shop_compositePack", "4"},
            {"shop_skin", "8"},
            {"shop_item_personalise", "10"},
            {"dyeing_box", "11"},
            {"shop_weapon_slot", "15"},
            {"shop_avatarParts", "16"},
            {"medal", "17"},
            {"shop_ring", "21"}
        };

        StringBuilder sb = new StringBuilder(1024 * 1024 * 4);
        sb.append("{\n\"items\": [\n");
        boolean first = true;
        int total = 0;

        for (String[] td : tables) {
            String tname = td[0];
            int itemType = Integer.parseInt(td[1]);
            Map<?,?> sub = (Map<?,?>) m.get(tname);
            if (sub == null) continue;
            int tcount = 0;
            for (var e : sub.entrySet()) {
                int tid = toInt(e.getKey(), -1);
                if (tid < 0) continue;
                String name = tname + "_" + tid;
                String codeName = "";
                String res = "";
                int subType = 0;
                int wSlot = 0;
                int rare = 0;
                int group = 0;
                int roleType = 0;
                int isSkin = 0;
                if (e.getValue() instanceof Map<?,?> row) {
                    if (row.get("name") != null) name = String.valueOf(row.get("name"));
                    else if (row.get("title") != null) name = String.valueOf(row.get("title"));
                    else if (row.get("desc") != null) name = String.valueOf(row.get("desc"));
                    if (row.get("codeName") != null) codeName = String.valueOf(row.get("codeName"));
                    else if (row.get("carrer") != null) codeName = String.valueOf(row.get("carrer"));
                    else if (row.get("icon") != null) codeName = String.valueOf(row.get("icon"));
                    if (row.get("res") != null) res = String.valueOf(row.get("res"));
                    else if (row.get("icon") != null) res = String.valueOf(row.get("icon"));
                    wSlot = toInt(row.get("type"), 0);
                    subType = toInt(row.get("subType"), 0);
                    rare = toInt(row.get("weaponType"), toInt(row.get("rareType"), toInt(row.get("quality"), 0)));
                    group = toInt(row.get("group"), 0);
                    roleType = toInt(row.get("roleType"), 0);
                    isSkin = toInt(row.get("isSkin"), 0);
                }
                if (!first) sb.append(",\n");
                first = false;
                sb.append("{\"t\":").append(itemType)
                  .append(",\"id\":").append(tid)
                  .append(",\"n\":\"").append(esc(name)).append("\"")
                  .append(",\"c\":\"").append(esc(codeName)).append("\"")
                  .append(",\"r\":\"").append(esc(res)).append("\"")
                  .append(",\"sl\":").append(wSlot)
                  .append(",\"st\":").append(subType)
                  .append(",\"q\":").append(rare)
                  .append(",\"g\":").append(group)
                  .append(",\"rt\":").append(roleType)
                  .append(",\"sk\":").append(isSkin)
                  .append("}");
                total++;
                tcount++;
            }
            System.out.println("Table " + tname + " (type " + itemType + "): " + tcount);
        }
        sb.append("\n],\n\"totalCount\": ").append(total).append("\n}\n");
        Path outPath = Paths.get("d:/逆向/SSJJ双塔惊魂/_work/clean_lobby/catalog_21669.json");
        Files.writeString(outPath, sb.toString(), StandardCharsets.UTF_8);
        System.out.println("Wrote " + total + " items to " + outPath + " (" + Files.size(outPath) + " bytes)");
    }
}
'''
open(os.path.join(jdir, "ExportFullCatalogJson.java"), "w", encoding="utf-8").write(java_src)
subprocess.run(["javac", "-encoding", "UTF-8", "ExportFullCatalogJson.java"], cwd=jdir, check=True)
res = subprocess.run(["java", "-Dfile.encoding=UTF-8", "-cp", ".", "ExportFullCatalogJson"], cwd=jdir, capture_output=True, text=True, encoding="utf-8")
print(res.stdout)
if res.stderr:
    print("STDERR:", res.stderr)

# 3. Decode config_i18n.txt -> clean_lobby/i18n.txt
i18n_src = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache\config_i18n_bea1face87fee27ca976135ddfffbe09.txt"
if os.path.isfile(i18n_src):
    b = bytearray(open(i18n_src, "rb").read())
    key = b"3.1415"
    for k in range((len(b) + 1023) // 1024):
        pos = k * 1024 + 91
        if pos < len(b):
            b[pos] ^= key[5 - k % 6]
    dec = zlib.decompress(bytes(b)).decode("utf-8", errors="replace")
    i18n_out = os.path.join(BASE_DIR, "i18n.txt")
    open(i18n_out, "w", encoding="utf-8").write(dec)
    print(f"[prepare] Wrote {i18n_out} ({len(dec)} chars)")

