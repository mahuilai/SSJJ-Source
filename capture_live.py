import ctypes
import win32gui
import win32ui
import win32con
from PIL import Image

def capture_window():
    hwnd = win32gui.FindWindow("ApolloRuntimeContentWindow", None)
    if not hwnd:
        print("No ApolloRuntimeContentWindow found")
        return
    rect = win32gui.GetWindowRect(hwnd)
    w = rect[2] - rect[0]
    h = rect[3] - rect[1]
    print(f"Found window: {w}x{h}")
    hwndDC = win32gui.GetWindowDC(hwnd)
    mfcDC = win32ui.CreateDCFromHandle(hwndDC)
    saveDC = mfcDC.CreateCompatibleDC()
    saveBitMap = win32ui.CreateBitmap()
    saveBitMap.CreateCompatibleBitmap(mfcDC, w, h)
    saveDC.SelectObject(saveBitMap)
    ctypes.windll.user32.PrintWindow(hwnd, saveDC.GetSafeHdc(), 2)
    bmpinfo = saveBitMap.GetInfo()
    bmpstr = saveBitMap.GetBitmapBits(True)
    im = Image.frombuffer("RGB", (bmpinfo["bmWidth"], bmpinfo["bmHeight"]), bmpstr, "raw", "BGRX", 0, 1)
    out_path = r"C:\Users\Mahuilai\.gemini\antigravity\brain\a81afa3a-ff8f-4868-b75e-fb18da89ec49\live_official_lobby_captured.png"
    im.save(out_path)
    print(f"Saved {out_path}")
    win32gui.DeleteObject(saveBitMap.GetHandle())
    saveDC.DeleteDC()
    mfcDC.DeleteDC()
    win32gui.ReleaseDC(hwnd, hwndDC)

if __name__ == "__main__":
    capture_window()
