#!/usr/bin/env python3

from pathlib import Path
import re
import sys


CONFIG = Path.home() / ".config/hypr/configs/monitors.lua"


def set_monitor(
    output: str = "",
    mode: str = "preferred",
    position: str = "auto",
    scale: str = "1",
):
    if not CONFIG.exists():
        print(f"Config not found: {CONFIG}")
        sys.exit(1)

    text = CONFIG.read_text()

    pattern = re.compile(
        r"""
        hl\.monitor\s*\(\s*\{
        \s*output\s*=\s*"[^"]*"\s*,?
        \s*mode\s*=\s*"[^"]*"\s*,?
        \s*position\s*=\s*"[^"]*"\s*,?
        \s*scale\s*=\s*"[^"]*"\s*,?
        \s*\}
        \s*\)
        """,
        re.VERBOSE,
    )

    replacement = f'''hl.monitor({{
    output   = "{output}",
    mode     = "{mode}",
    position = "{position}",
    scale    = "{scale}",
}})'''

    new_text, count = pattern.subn(replacement, text, count=1)

    if count == 0:
        print("hl.monitor block not found")
        sys.exit(1)

    CONFIG.write_text(new_text)

    print("Monitor configuration updated.")


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else ""
    mode = sys.argv[2] if len(sys.argv) > 2 else "preferred"
    position = sys.argv[3] if len(sys.argv) > 3 else "auto"
    scale = sys.argv[4] if len(sys.argv) > 4 else "1"

    set_monitor(output, mode, position, scale)