"""Copies the bots' and the emotes' PNGs into the newest Roblox Studio's content folder, so the game shows them on this PC
before they're approved and uploaded (practices.md: pictures stay local until approved):
rbxasset://textures/wb_bots/Bot_<Name>.png and rbxasset://textures/wb_emotes/Emote_<Id>.png. python -I to_studio.py
"""

import os
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCES = {"wb_bots": (HERE / "out", "Bot_"), "wb_emotes": (HERE.parent / "emotes" / "out", "Emote_")}


def main():
    versions = Path(os.environ["LOCALAPPDATA"]) / "Roblox" / "Versions"
    studios = [p for p in versions.glob("version-*") if (p / "RobloxStudioBeta.exe").is_file()]
    if not studios:
        sys.exit(f"No Roblox Studio found in {versions}")
    studio = max(studios, key=lambda p: (p / "RobloxStudioBeta.exe").stat().st_mtime)
    for folder, (src, prefix) in SOURCES.items():
        target = studio / "content" / "textures" / folder
        target.mkdir(parents=True, exist_ok=True)
        files = sorted(src.glob(f"{prefix}*.png"))
        for f in files:
            shutil.copyfile(f, target / f.name)
        print(f"{len(files)} to {target} (rbxasset://textures/{folder}/)")


if __name__ == "__main__":
    main()
