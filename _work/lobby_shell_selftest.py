# -*- coding: utf-8 -*-
"""Run with python _work/lobby_shell_selftest.py."""
import ctypes
from ctypes import wintypes
import hashlib
import http.server
from pathlib import Path
import re
import sys
import threading
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET
from urllib.error import HTTPError
from urllib.request import urlopen

sys.path.insert(0, str(Path(__file__).resolve().parent))
import lobby_host_window as host
import launch_lobby
import gateway_8080 as gateway
from lobby_assets import LobbyAssets, read_manifest


class OriginalSkinTests(unittest.TestCase):
    def require_skin(self):
        if not getattr(host, "SKIN", Path("/missing-skin")).is_dir():
            self.skipTest("Original MicroClient skin is not installed")

    def test_frame_geometry_and_descriptor(self):
        self.require_skin()
        game = ET.parse(host.SKIN / "GameBoxFrame.xml").getroot()
        main = ET.parse(host.SKIN / "MainFrame.xml").getroot()
        settings = ET.parse(host.SKIN / "SettingsDialog.xml").getroot()
        self.assertEqual(game.attrib["size"], "1280,640")
        self.assertEqual(game.attrib["sizebox"], "6,6,6,6")
        self.assertEqual(game.attrib["caption"], "0,0,0,36")
        self.assertEqual(game.find(".//*[@name='toolBar']").attrib["height"], "34")
        self.assertEqual(game.find(".//*[@name='frameLayout']").attrib["inset"], "1,1,1,1")
        self.assertEqual(main.attrib["size"], "1061,747")
        self.assertEqual(main.find(".//*[@bkimage='l_button.png']").attrib["height"], "49")
        self.assertEqual(main.find(".//*[@name='main_close_bt']").attrib["pos"], "1015,14,1039,36")
        self.assertEqual(settings.attrib["size"], "462,402")
        descriptor = ET.parse(host.ROOT / "Lobby" / "META-INF" / "AIR" / "application.xml")
        window = descriptor.find("{*}initialWindow")
        self.assertEqual(tuple(int(window.findtext("{*}" + key)) for key in ("width", "height")),
                         host.VIEWPORT_SIZE)
        self.assertEqual(window.findtext("{*}renderMode"), "direct")

    def test_original_button_art_and_icons_decode(self):
        self.require_skin()
        from PIL import Image

        for filename in ("GameBoxFrame.xml", "MainFrame.xml", "SettingsDialog.xml"):
            tree = ET.parse(host.SKIN / filename)
            for element in tree.iter():
                for attr, value in element.attrib.items():
                    if not attr.endswith("image") or not value:
                        continue
                    asset = re.search(r"file='([^']+)'", value)
                    path = host.SKIN / (asset[1] if asset else value).replace("\\", "/")
                    with self.subTest(path=path), Image.open(path) as img:
                        img.load()
                        self.assertEqual(img.format, "PNG")

        for path in (host.SKIN / "ico.ico", host.ROOT / "icon1.ico"):
            with Image.open(path) as img:
                self.assertTrue({(16, 16), (32, 32)} <= img.ico.sizes())
                img.load()
        path, icons = host.load_icons()
        try:
            self.assertIn(path, host.ICON_PATHS)
            self.assertTrue(all(icons))
        finally:
            for icon in filter(None, icons):
                host.u.DestroyIcon(icon)

    def test_cached_stage3d_revision_matches_its_name(self):
        digest = "f91a075b03135fbb5a2e60cd4b386f2d"
        engine = Path(__file__).with_name("lobby_host") / "cache" / f"ClientView_{digest}.swf"
        if not engine.is_file():
            self.skipTest("Matching ClientView cache is not installed")
        self.assertEqual(hashlib.md5(engine.read_bytes()).hexdigest(), digest)


@unittest.skipUnless(hasattr(host, "Layout"), "Custom chrome is absent from this checkout")
class HostStructureTests(unittest.TestCase):
    def instance(self):
        instance = host.LobbyHostWindow.__new__(host.LobbyHostWindow)
        instance.child_hwnd = 20
        instance.layout = host.Layout()
        return instance

    def test_viewport_layout_and_hit_boundaries(self):
        layout = host.Layout()
        left, top, right, bottom = layout.viewport
        self.assertEqual((right - left, bottom - top), (1024, 650))
        self.assertEqual((left, top, layout.width - right, layout.height - bottom), (2, 40, 2, 2))
        for name, (x1, y1, x2, y2) in layout.buttons.items():
            with self.subTest(button=name):
                self.assertEqual(layout.button_at(x1, y1), name)
                self.assertEqual(layout.button_at(x2 - 1, y2 - 1), name)
                self.assertIsNone(layout.button_at(x2, y2 - 1))
                self.assertIsNone(layout.button_at(x2 - 1, y2))
                self.assertLessEqual(y2, top)
        point = host.point_from_message((0xFFFC << 16) | 0xFFFE)
        self.assertEqual((point.x, point.y), (-2, -4))

    def test_attach_preserves_air_style_and_uses_move_only_flags(self):
        instance = self.instance()
        instance.child_hwnd = None

        def rect(hwnd, pointer):
            result = ctypes.cast(pointer, ctypes.POINTER(wintypes.RECT)).contents
            result.right, result.bottom = host.VIEWPORT_SIZE
            return True

        def screen(hwnd, pointer):
            point = ctypes.cast(pointer, ctypes.POINTER(wintypes.POINT)).contents
            if hwnd == 20 and position.called:
                point.x, point.y = instance.layout.viewport[:2]
            return True

        with patch.multiple(host.u, GetWindowRect=rect, ClientToScreen=screen), \
                patch.object(host, "snapshot", return_value=((1024, 650), (1024, 650), (0x16CF0000, 0x40100))), \
                patch.object(host.u, "GetParent", return_value=0), \
                patch.object(host.u, "SetParent", return_value=1) as parent, \
                patch.object(host.u, "SetWindowPos", return_value=1) as position, \
                patch.object(host.u, "ShowWindow"), patch.object(host.u, "SetForegroundWindow"), \
                patch.object(host.u, "PostMessageW"):
            instance._attach(10, 20)
            parent.assert_called_once_with(20, 10)
            position.assert_called_once_with(20, None, 2, 40, 0, 0, host.AIR_ANCHOR_FLAGS)
            self.assertTrue(host.AIR_ANCHOR_FLAGS & host.SWP_NOSIZE)

    def test_paint_skips_air_and_blits_without_background_erase(self):
        instance = self.instance()
        instance._buffer = (201, 202, 203)
        with patch.object(host.u, "BeginPaint", return_value=101), patch.object(host.u, "EndPaint") as end, \
                patch.object(instance, "_draw_frame") as draw, \
                patch.object(host.g, "ExcludeClipRect") as exclude, patch.object(host.g, "BitBlt") as blit:
            self.assertEqual(instance._wnd_proc(10, host.WM_ERASEBKGND, 0, 0), 1)
            draw.assert_not_called()
            instance._wnd_proc(10, host.WM_PAINT, 0, 0)
            draw.assert_called_once_with(201)
            exclude.assert_called_once_with(101, *instance.layout.viewport)
            blit.assert_called_once()
            end.assert_called_once()

    def test_close_posts_wm_close_to_air_before_destroying_host(self):
        instance = self.instance()
        calls = []
        with patch.object(host.u, "IsWindow", return_value=True), \
                patch.object(host.u, "PostMessageW", side_effect=lambda *args: calls.append(args)), \
                patch.object(host.u, "DestroyWindow", side_effect=lambda hwnd: calls.append((hwnd,))):
            instance._wnd_proc(10, host.WM_CLOSE, 0, 0)
        self.assertEqual(calls, [(20, host.WM_CLOSE, 0, 0), (10,)])

    def test_focus_is_forwarded_when_the_host_activates(self):
        instance = self.instance()
        with patch.object(host.u, "PostMessageW") as post, patch.object(host.u, "DefWindowProcW"):
            instance._wnd_proc(10, host.WM_ACTIVATE, 1, 0)
            post.assert_called_once_with(10, host.WM_APP_FOCUS, 0, 0)
        with patch.object(host.u, "GetForegroundWindow", return_value=10), \
                patch.object(host.u, "IsWindow", return_value=True), \
                patch.object(host.u, "IsIconic", return_value=False), \
                patch.object(host.u, "GetFocus", side_effect=[10, 20]), \
                patch.object(host.u, "SetFocus") as focus:
            instance._wnd_proc(10, host.WM_APP_FOCUS, 0, 0)
            focus.assert_called_once_with(20)


class LauncherTests(unittest.TestCase):
    def test_descriptor_update_preserves_comment_and_line_endings(self):
        with TemporaryDirectory() as temp:
            path = Path(temp) / "META-INF" / "AIR" / "application.xml"
            path.parent.mkdir(parents=True)
            original = (b"<initialWindow>\r\n"
                        b"    <!-- <transparent></transparent> -->\r\n"
                        b"    <transparent>false</transparent>\r\n"
                        b"</initialWindow>\r\n")
            path.write_bytes(original)
            with patch.object(launch_lobby, "LOBBY_DIR", temp):
                launch_lobby.ensure_official_window_flags()
            self.assertEqual(path.read_bytes(), original.replace(b">false<", b">true<"))


@unittest.skipIf(hasattr(host, "Layout"), "Native caption tests apply to the shipped host")
class NativeCaptionTests(unittest.TestCase):
    def test_attach_only_posts_to_host_thread(self):
        window = host.LobbyHostWindow.__new__(host.LobbyHostWindow)
        window.hwnd = 10
        with patch.object(host.user32, "PostMessageW") as post:
            self.assertTrue(window.attach(20))
            post.assert_called_once_with(10, host.WM_APP_ATTACH, 0, 20)


class AssetRoutesTests(unittest.TestCase):
    def test_local_gateway_serves_matching_assets_and_audits_misses(self):
        with TemporaryDirectory() as temp:
            root = Path(temp)
            cache = root / "_work" / "lobby_host" / "cache"
            cache.mkdir(parents=True)
            engine = b"CWS" + b"stage3d module fixture"
            digest = hashlib.md5(engine).hexdigest()
            correct_engine = f"ClientView_{digest}.swf"
            (cache / correct_engine).write_bytes(engine)
            (cache / f"RenderThread_{digest}.swf").write_bytes(b"FWSwrong revision")

            def write_flat(url, data):
                (cache / url.replace("/", "_")).write_bytes(data)

            weapon = "resource/swf/WeaponAssets/weapon_147.swf"
            skin = "resource/swf/SkinAssets/skin_147_1.swf"
            portrait = "resource/swf/RoleAssets/avatar_147_4.swf"
            archive = f"resources/lobbyweaponskin/test_zip_{digest}"
            write_flat(weapon, b"FWSweapon icon")
            write_flat("resource/swf/SkinAssets/skin_118_1.swf", b"FWStemplate")
            write_flat(archive, engine)
            for url, data in ((skin, b"FWSskin icon"), (portrait, b"FWSportrait")):
                mirror = root / "资源下载" / "hall" / url
                mirror.parent.mkdir(parents=True, exist_ok=True)
                mirror.write_bytes(data)

            signed = "resource/swf/RoleAssets/signed.swf"
            write_flat(signed, engine)
            invalid = "resource/view/invalid.xml"
            write_flat(invalid, b"wrong")
            contract = {signed: (digest, len(engine)), invalid: (digest, len(engine))}
            assets = LobbyAssets(root, gateway.file_md5)
            with patch.multiple(gateway, LOBBY_ASSETS=assets, RES_CONTRACT=contract, PREPARED_FORCE={}), \
                    patch.object(gateway, "log_req") as log, \
                    patch.object(gateway, "_ensure_avm2_timeline_swf", side_effect=lambda data: data) as normalize, \
                    http.server.ThreadingHTTPServer(("127.0.0.1", 0), gateway.GatewayHandler) as server:
                worker = threading.Thread(target=server.serve_forever)
                worker.start()
                try:
                    base = f"http://127.0.0.1:{server.server_port}/"
                    for url, want in ((correct_engine, engine), (weapon, b"FWSweapon icon"),
                                      (portrait, b"FWSportrait"), (skin, b"FWSskin icon"),
                                      (archive, engine), (signed, engine)):
                        with self.subTest(url=url), urlopen(base + url, timeout=3) as response:
                            self.assertEqual(response.read(), want)
                    for url in (invalid, f"RenderThread_{digest}.swf", "resource/swf/SkinAssets/skin_999_1.swf"):
                        with self.assertRaises(HTTPError) as error:
                            urlopen(base + url, timeout=3)
                        self.assertEqual(error.exception.code, 404)
                        self.assertTrue(any(f"404 {url} " in str(call) for call in log.call_args_list))
                    self.assertEqual([call.args[0] for call in normalize.call_args_list],
                                     [b"FWSweapon icon", b"FWSportrait", b"FWSskin icon"])
                finally:
                    server.shutdown()
                    worker.join()

    def test_prepared_override_only_changes_its_manifest_row(self):
        with TemporaryDirectory() as temp:
            path = Path(temp) / "res_config.xml"
            digest = "a" * 32
            path.write_text(
                f'<root><a url="resource/{digest}.swf" size="8" md5="{digest}" encode="true"/>'
                f'<b md5="{digest}" url="resource/b.swf" size="8" encode="true"/></root>', encoding="utf-8",
            )
            url = f"resource/{digest}.swf"
            self.assertEqual(read_manifest(path)[url], (digest, 8))
            with patch.multiple(gateway, LOCAL_RESC_LOCAL=path, PREPARED_FORCE={url: ("b" * 32, 12)}):
                first, second = ET.fromstring(gateway.res_config_bytes())
            self.assertEqual((first.get("url"), first.get("md5"), first.get("encode")), (url, "b" * 32, "false"))
            self.assertEqual((second.get("md5"), second.get("size"), second.get("encode")), (digest, "8", "true"))


if __name__ == "__main__":
    unittest.main()
