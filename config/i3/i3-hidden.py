#!/usr/bin/env python3
"""
Hide / restore windows on an i3 workspace ("show desktop").

Marks: every hidden window receives a UNIQUE mark with the prefix
"hidden_desktop_<ws>_" (i3 does not allow the same mark on several windows).

Subcommands:
    toggle   -> If there are hidden windows on the focused workspace, restore
                them; otherwise hide the windows on the focused workspace.
                (used by the Super+D shortcut)
    daemon   -> Watches i3 events and automatically restores hidden windows
                when a new window is opened on the same workspace.
"""

import json
import os
import signal
import subprocess
import sys
import time

PREFIX = "hidden_desktop_"
PIDFILE = "/tmp/i3-hidden.pid"


# ---------------------------------------------------------------------------
# i3 helpers
# ---------------------------------------------------------------------------

def i3_json(*args):
    """Run i3-msg and return the parsed JSON."""
    out = subprocess.check_output(["i3-msg", *args], text=True)
    return json.loads(out)


def i3_cmd(command):
    """Run an i3 command without waiting for its output."""
    subprocess.run(["i3-msg", command], capture_output=True, text=True)


def focused_workspace():
    workspaces = i3_json("-t", "get_workspaces")
    return next((w["name"] for w in workspaces if w.get("focused")), None)


def workspace_windows(workspace):
    """Container IDs of ALL windows (tiled and floating) on a workspace."""
    tree = i3_json("-t", "get_tree")
    result = []

    def walk(node, in_workspace):
        if node.get("type") == "workspace":
            in_workspace = (node.get("name") == workspace)
            if not in_workspace:
                return
        if in_workspace and node.get("window") is not None:
            result.append(node["id"])
        for child in node.get("nodes", []):
            walk(child, in_workspace)
        for child in node.get("floating_nodes", []):
            walk(child, in_workspace)

    walk(tree, False)
    return result


def hidden_marks(workspace):
    """Mark(s) of the hidden windows belonging to a workspace."""
    prefix = f"{PREFIX}{workspace}_"
    marks = i3_json("-t", "get_marks")
    return [mark for mark in marks if mark.startswith(prefix)]


def workspace_of_container(tree, target_id):
    """Name of the workspace that contains the container with id target_id."""
    def dfs(node, current_workspace):
        if node.get("type") == "workspace":
            current_workspace = node.get("name")
        if node.get("id") == target_id:
            return current_workspace
        for child in node.get("nodes", []):
            found = dfs(child, current_workspace)
            if found is not None:
                return found
        for child in node.get("floating_nodes", []):
            found = dfs(child, current_workspace)
            if found is not None:
                return found
        return None

    return dfs(tree, None)


# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------

def hide(workspace):
    """Mark and send every window on the workspace to the scratchpad."""
    for index, container_id in enumerate(workspace_windows(workspace)):
        mark = f"{PREFIX}{workspace}_{index}"
        i3_cmd(f'[con_id={container_id}] mark --replace {mark}, move scratchpad')


def restore(workspace):
    """Bring back that workspace's hidden windows, tile them, and remove marks."""
    for mark in hidden_marks(workspace):
        i3_cmd(f'[con_mark="{mark}"] move container to workspace "{workspace}", '
               f"floating disable, unmark {mark}")


def toggle():
    workspace = focused_workspace()
    if not workspace:
        return
    if hidden_marks(workspace):
        restore(workspace)
    else:
        hide(workspace)


def daemon():
    # Singleton: if another instance exists, terminate it and take its place.
    try:
        with open(PIDFILE) as handle:
            old_pid = int(handle.read().strip())
        if (old_pid and old_pid != os.getpid()
                and os.path.exists(f"/proc/{old_pid}")):
            os.kill(old_pid, signal.SIGTERM)
            time.sleep(0.2)
    except (ValueError, FileNotFoundError, ProcessLookupError, OSError):
        pass

    with open(PIDFILE, "w") as handle:
        handle.write(str(os.getpid()))

    process = subprocess.Popen(
        ["i3-msg", "-t", "subscribe", "-m", '["window"]'],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )

    def _cleanup(_sig, _frame):
        process.terminate()
        try:
            os.unlink(PIDFILE)
        except OSError:
            pass
        sys.exit(0)

    signal.signal(signal.SIGTERM, _cleanup)
    signal.signal(signal.SIGINT, _cleanup)

    for line in process.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if event.get("change") != "new":
            continue

        # Brief wait so i3 finishes placing the new window.
        time.sleep(0.12)

        new_id = event["container"]["id"]
        try:
            tree = i3_json("-t", "get_tree")
        except (subprocess.CalledProcessError, ValueError):
            continue

        workspace = workspace_of_container(tree, new_id)
        if not workspace or workspace.startswith("__"):
            continue
        if not hidden_marks(workspace):
            continue

        restore(workspace)
        # Focus must stay on the newly opened window, not on the restored ones.
        i3_cmd(f"[con_id={new_id}] focus")


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "toggle"
    if mode == "daemon":
        daemon()
    else:
        toggle()
