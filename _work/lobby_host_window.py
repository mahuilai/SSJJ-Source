# -*- coding: utf-8 -*-
"""Native Win32 container window for the 1024x650 AIR lobby viewport.

Restores the classic 4399 micro-client windowed frame (title bar, minimize/close
buttons, draggable border) around SSJJ_FlashAir_Battle16397 via SetParent without
altering the AIR DirectX surface style or dimensions.
"""
import ctypes
from ctypes import wintypes
import threading

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32
gdi32 = ctypes.windll.gdi32

WS_OVERLAPPED = 0x00000000
WS_CAPTION = 0x00C00000
WS_SYSMENU = 0x00080000
WS_MINIMIZEBOX = 0x00020000
WS_CLIPCHILDREN = 0x02000000
WS_VISIBLE = 0x10000000
HOST_STYLE = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_CLIPCHILDREN

WM_CLOSE = 0x0010
WM_DESTROY = 0x0002
WM_ACTIVATE = 0x0006
WM_SETFOCUS = 0x0007
WM_APP_ATTACH = 0x8001

SWP_NOZORDER = 0x0004
SWP_NOACTIVATE = 0x0010
SWP_SHOWWINDOW = 0x0040

WNDPROC = ctypes.WINFUNCTYPE(
    ctypes.c_longlong if ctypes.sizeof(ctypes.c_void_p) == 8 else ctypes.c_long,
    wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM
)

LRESULT = ctypes.c_longlong if ctypes.sizeof(ctypes.c_void_p) == 8 else ctypes.c_long
user32.DefWindowProcW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
user32.DefWindowProcW.restype = LRESULT
user32.SetParent.argtypes = [wintypes.HWND, wintypes.HWND]
user32.SetParent.restype = wintypes.HWND
user32.SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, wintypes.UINT]
user32.SetWindowPos.restype = wintypes.BOOL
user32.PostMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
user32.PostMessageW.restype = wintypes.BOOL
user32.LoadCursorW.argtypes = [wintypes.HINSTANCE, wintypes.LPCWSTR]
user32.LoadCursorW.restype = wintypes.HANDLE
user32.RegisterClassExW.argtypes = [ctypes.c_void_p]
user32.RegisterClassExW.restype = wintypes.ATOM
user32.CreateWindowExW.argtypes = [
    wintypes.DWORD, wintypes.LPCWSTR, wintypes.LPCWSTR, wintypes.DWORD,
    ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
    wintypes.HWND, wintypes.HMENU, wintypes.HINSTANCE, wintypes.LPVOID,
]
user32.CreateWindowExW.restype = wintypes.HWND
user32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
user32.ShowWindow.restype = wintypes.BOOL
user32.SetForegroundWindow.argtypes = [wintypes.HWND]
user32.SetForegroundWindow.restype = wintypes.BOOL
user32.SetFocus.argtypes = [wintypes.HWND]
user32.SetFocus.restype = wintypes.HWND
user32.DestroyWindow.argtypes = [wintypes.HWND]
user32.DestroyWindow.restype = wintypes.BOOL
user32.IsWindow.argtypes = [wintypes.HWND]
user32.IsWindow.restype = wintypes.BOOL
user32.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
user32.GetWindowRect.restype = wintypes.BOOL
user32.GetClientRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
user32.GetClientRect.restype = wintypes.BOOL
kernel32.GetModuleHandleW.argtypes = [wintypes.LPCWSTR]
kernel32.GetModuleHandleW.restype = wintypes.HINSTANCE
gdi32.GetStockObject.argtypes = [ctypes.c_int]
gdi32.GetStockObject.restype = wintypes.HGDIOBJ


class WNDCLASSEXW(ctypes.Structure):
    _fields_ = [
        ("cbSize", wintypes.UINT),
        ("style", wintypes.UINT),
        ("lpfnWndProc", WNDPROC),
        ("cbClsExtra", ctypes.c_int),
        ("cbWndExtra", ctypes.c_int),
        ("hInstance", wintypes.HINSTANCE),
        ("hIcon", wintypes.HICON),
        ("hCursor", wintypes.HANDLE),
        ("hbrBackground", wintypes.HBRUSH),
        ("lpszMenuName", wintypes.LPCWSTR),
        ("lpszClassName", wintypes.LPCWSTR),
        ("hIconSm", wintypes.HICON),
    ]


class LobbyHostWindow:
    """Manages a Win32 host frame that embeds the AIR lobby viewport."""

    def __init__(self, title="4399生死狙击 - SSJJ_FlashAir", width=1024, height=650):
        self.title = title
        self.width = width
        self.height = height
        self.hwnd = None
        self.child_hwnd = None
        self.closed = threading.Event()
        self._ready = threading.Event()
        self._wndproc_ref = None
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()
        self._ready.wait(timeout=3.0)

    def _wnd_proc(self, hwnd, msg, wparam, lparam):
        if msg == WM_APP_ATTACH and lparam:
            child = wintypes.HWND(lparam)
            self.child_hwnd = child
            user32.SetParent(child, hwnd)
            user32.SetWindowPos(
                child, 0, 0, 0, self.width, self.height,
                SWP_NOZORDER | SWP_NOACTIVATE | SWP_SHOWWINDOW,
            )
            user32.ShowWindow(hwnd, 5)  # SW_SHOW
            user32.SetForegroundWindow(hwnd)
            return 0
        if msg in (WM_ACTIVATE, WM_SETFOCUS) and self.child_hwnd:
            if msg == WM_SETFOCUS or (wparam & 0xFFFF) != 0:
                user32.SetFocus(self.child_hwnd)
        if msg == WM_CLOSE:
            if self.child_hwnd and user32.IsWindow(self.child_hwnd):
                user32.PostMessageW(self.child_hwnd, WM_CLOSE, 0, 0)
            self.closed.set()
            user32.DestroyWindow(hwnd)
            return 0
        if msg == WM_DESTROY:
            self.closed.set()
            user32.PostQuitMessage(0)
            return 0
        return user32.DefWindowProcW(hwnd, msg, wparam, lparam)

    def _run_loop(self):
        try:
            user32.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
            user32.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p
            user32.SetThreadDpiAwarenessContext(ctypes.c_void_p(-1))  # DPI_AWARENESS_CONTEXT_UNAWARE
        except Exception:
            pass
        try:
            h_desk = user32.OpenDesktopW("Default", 0, False, 0x01FF)
            if h_desk:
                user32.SetThreadDesktop(h_desk)
        except Exception:
            pass
        hinst = kernel32.GetModuleHandleW(None)
        cls_name = "SSJJLobbyHostWindow"
        self._wndproc_ref = WNDPROC(self._wnd_proc)
        wc = WNDCLASSEXW()
        wc.cbSize = ctypes.sizeof(WNDCLASSEXW)
        wc.lpfnWndProc = self._wndproc_ref
        wc.hInstance = hinst
        wc.hCursor = user32.LoadCursorW(None, ctypes.cast(32512, wintypes.LPCWSTR))  # IDC_ARROW
        wc.hbrBackground = gdi32.GetStockObject(4)    # BLACK_BRUSH
        wc.lpszClassName = cls_name

        user32.RegisterClassExW(ctypes.byref(wc))

        rc = wintypes.RECT(0, 0, self.width, self.height)
        user32.AdjustWindowRect(ctypes.byref(rc), HOST_STYLE, False)
        win_w = rc.right - rc.left
        win_h = rc.bottom - rc.top
        scr_w = user32.GetSystemMetrics(0)
        scr_h = user32.GetSystemMetrics(1)
        pos_x = max(0, (scr_w - win_w) // 2)
        pos_y = max(0, (scr_h - win_h) // 2)

        user32.CreateWindowExW.restype = wintypes.HWND
        self.hwnd = user32.CreateWindowExW(
            0, cls_name, self.title, HOST_STYLE,
            pos_x, pos_y, win_w, win_h,
            None, None, hinst, None,
        )
        self._ready.set()
        if not self.hwnd:
            return

        msg = wintypes.MSG()
        while user32.GetMessageW(ctypes.byref(msg), None, 0, 0) > 0:
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageW(ctypes.byref(msg))

    def attach(self, child_hwnd):
        """Embed the AIR viewport into this host window on its UI thread."""
        if not self.hwnd or not child_hwnd:
            return False
        val = int(child_hwnd if isinstance(child_hwnd, int) else (child_hwnd.value or 0))
        if not val:
            return False
        user32.PostMessageW(self.hwnd, WM_APP_ATTACH, 0, val)
        return True

    def close(self):
        if self.hwnd and user32.IsWindow(self.hwnd):
            user32.PostMessageW(self.hwnd, WM_CLOSE, 0, 0)
