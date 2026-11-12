#!/usr/bin/env python3
"""herdr popup: browse every Claude Code session (open and closed) and jump to it.

  claude-sessions.py            fzf picker (run inside a herdr popup)
  claude-sessions.py --preview <session-id>

Enter on a session that is already open in a herdr pane focuses that pane.
Enter on a closed one opens a new herdr tab in the session's folder and runs
`claude --resume <id>` there. ctrl-f forks instead of resuming.
"""
import glob
import json
import os
import re
import shlex
import subprocess
import sys
import time

PROJECTS = os.path.expanduser("~/.claude/projects")


def herdr(*args):
    out = subprocess.run(["herdr", *args], capture_output=True, text=True)
    try:
        return json.loads(out.stdout)
    except Exception:
        return {}


def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(c.get("text", "") for c in content if isinstance(c, dict) and c.get("type") == "text")
    return ""


def is_real_prompt(t):
    t = t.strip()
    if t.startswith("<pasted_content"):
        return True
    return t and not t.startswith("<") and not t.startswith("Caveat:")


def scan(path, want_prompts=0):
    sid = os.path.basename(path)[:-6]
    info = {"id": sid, "path": path, "cwd": "", "custom": "", "ai": "", "first": "", "n": 0, "prompts": []}
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if '"type":"user"' not in line and '-title"' not in line and not (not info["cwd"] and '"cwd"' in line):
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            if not info["cwd"] and d.get("cwd"):
                info["cwd"] = d["cwd"]
            t = d.get("type")
            if t == "custom-title":
                info["custom"] = d.get("customTitle", "")
            elif t == "ai-title":
                info["ai"] = d.get("aiTitle", "")
            elif t == "user" and not d.get("isSidechain") and not d.get("isMeta"):
                msg = text_of((d.get("message") or {}).get("content"))
                msg = re.sub(r"</?pasted_content[^>]*>", "", msg) if "<pasted_content" in msg else msg
                if is_real_prompt(msg):
                    info["n"] += 1
                    if not info["first"]:
                        info["first"] = msg
                    if want_prompts:
                        info["prompts"].append(msg)
    info["title"] = " ".join((info["custom"] or info["ai"] or info["first"] or "(empty)").split())
    return info


def open_sessions():
    panes = herdr("pane", "list").get("result", {}).get("panes", [])
    return {
        (p.get("agent_session") or {}).get("value"): p["pane_id"]
        for p in panes
        if (p.get("agent_session") or {}).get("value")
    }


def ago(ts):
    s = int(time.time() - ts)
    for unit, n in (("d", 86400), ("h", 3600), ("m", 60)):
        if s >= n:
            return f"{s // n}{unit}"
    return f"{s}s"


def preview(sid):
    path = next(iter(glob.glob(f"{PROJECTS}/*/{sid}.jsonl")), None)
    if not path:
        return
    i = scan(path, want_prompts=1)
    print(f"\033[1m{i['title']}\033[0m")
    print(f"folder:  {i['cwd']}")
    print(f"id:      {sid}")
    print(f"updated: {time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime(path)))}")
    print(f"prompts: {i['n']}\n")
    for p in i["prompts"][-8:]:
        p = " ".join(p.split())
        print("› " + (p[:300] + "…" if len(p) > 300 else p) + "\n")


def main():
    files = sorted(glob.glob(f"{PROJECTS}/*/*.jsonl"), key=os.path.getmtime, reverse=True)
    live = open_sessions()
    home = os.path.expanduser("~")
    rows = []
    for f in files:
        i = scan(f)
        if i["n"] == 0:
            continue
        mark = "\033[32m●\033[0m" if i["id"] in live else " "
        folder = (i["cwd"] or "?").replace(home, "~")
        rows.append(f"{i['id']}\t{i['cwd']}\t{mark} {ago(os.path.getmtime(f)):>4}  \033[36m{folder[:28]:<28}\033[0m  {i['title']}")
    if not rows:
        print("No Claude sessions found.")
        time.sleep(2)
        return

    me = shlex.quote(os.path.abspath(__file__))
    res = subprocess.run(
        ["fzf", "--ansi", "--delimiter=\t", "--with-nth=3", "--no-sort", "--reverse",
         "--expect=ctrl-f", "--prompt=claude › ",
         "--header=enter: open/resume (● = already open)   ctrl-f: fork into new tab   esc: cancel",
         f"--preview=python3 {me} --preview {{1}}", "--preview-window=right,45%,wrap"],
        input="\n".join(rows), capture_output=False, stdout=subprocess.PIPE, text=True,
    )
    lines = res.stdout.splitlines()
    if len(lines) < 2:
        return
    key, sel = lines[0], lines[1]
    sid, cwd = sel.split("\t")[:2]
    fork = key == "ctrl-f"

    if sid in live and not fork:
        herdr("agent", "focus", live[sid])
        return

    if not os.path.isdir(cwd):
        cwd = home
    title = scan(next(iter(glob.glob(f"{PROJECTS}/*/{sid}.jsonl")))).get("title", "claude")
    label = ("⑂ " if fork else "") + title[:24]
    tab = herdr("tab", "create", "--cwd", cwd, "--label", label, "--focus")
    pane = tab.get("result", {}).get("root_pane", {}).get("pane_id")
    if not pane:
        return
    cmd = f"claude --resume {sid}"
    if fork:
        cmd += " --fork-session -n " + shlex.quote("⑂ " + title[:40])
    herdr("pane", "run", pane, cmd)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    else:
        main()
