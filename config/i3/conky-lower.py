#!/usr/bin/env python3
"""Lower the Conky window in i3.

i3 does not honor the _NET_WM_STATE_BELOW hint on floating windows: if it
manages Conky, it paints it above tiled windows. That is why Conky is launched
as an 'override' window (i3 ignores it) and this script lowers it to the bottom
of the X stack. It stays behind the windows and remains visible on every
workspace, as on the XFCE desktop.
"""

import ctypes
import ctypes.util
import sys
import time

X = ctypes.CDLL(ctypes.util.find_library("X11") or "libX11.so.6")


class XClassHint(ctypes.Structure):
    _fields_ = [("res_name", ctypes.c_char_p), ("res_class", ctypes.c_char_p)]


X.XOpenDisplay.restype = ctypes.c_void_p
X.XOpenDisplay.argtypes = [ctypes.c_char_p]
X.XDefaultRootWindow.restype = ctypes.c_ulong
X.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
X.XQueryTree.argtypes = [
    ctypes.c_void_p,
    ctypes.c_ulong,
    ctypes.POINTER(ctypes.c_ulong),
    ctypes.POINTER(ctypes.c_ulong),
    ctypes.POINTER(ctypes.POINTER(ctypes.c_ulong)),
    ctypes.POINTER(ctypes.c_uint),
]
X.XGetClassHint.argtypes = [ctypes.c_void_p, ctypes.c_ulong, ctypes.POINTER(XClassHint)]
X.XLowerWindow.argtypes = [ctypes.c_void_p, ctypes.c_ulong]
X.XFlush.argtypes = [ctypes.c_void_p]
X.XCloseDisplay.argtypes = [ctypes.c_void_p]


def child_windows(display, window):
    root = ctypes.c_ulong()
    parent = ctypes.c_ulong()
    children = ctypes.POINTER(ctypes.c_ulong)()
    count = ctypes.c_uint()
    if not X.XQueryTree(
        display,
        window,
        ctypes.byref(root),
        ctypes.byref(parent),
        ctypes.byref(children),
        ctypes.byref(count),
    ):
        return []
    return [children[i] for i in range(count.value)]


def wm_class(display, window):
    hint = XClassHint()
    if not X.XGetClassHint(display, window, ctypes.byref(hint)):
        return ""
    name = (hint.res_name or b"").decode(errors="replace")
    cls = (hint.res_class or b"").decode(errors="replace")
    return f"{name} {cls}".lower()


def main(timeout=10.0):
    display = X.XOpenDisplay(None)
    if not display:
        print("conky-lower: no se pudo abrir el display X", file=sys.stderr)
        return 1

    root = X.XDefaultRootWindow(display)
    deadline = time.monotonic() + timeout
    found = []
    while time.monotonic() < deadline:
        found = [
            window
            for window in child_windows(display, root)
            if "conky" in wm_class(display, window)
        ]
        if found:
            break
        time.sleep(0.2)

    for window in found:
        X.XLowerWindow(display, window)
    X.XFlush(display)
    X.XCloseDisplay(display)

    if not found:
        print("conky-lower: could not find the Conky window", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
