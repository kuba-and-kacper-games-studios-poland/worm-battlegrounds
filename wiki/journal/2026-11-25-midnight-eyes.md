---
title: "Midnight body: the eyes stay on the face"
date: 2026-11-25
status: open
kind: fixed
pages: ["Skins", "Shadow Clan"]
files:
  - art/skins/fix_eyes.py
  - art/skins/README.md
---

**What changed.** The Midnight body piece (the Shadow Clan set, the Ninja snail) showed its eyes slid up and out of its
face whenever the snail moved, whatever hat it wore (the owner: "the eyes are weirdly rigged"). Its eyes and mask were
skinned to the eyestalk bones, so the idle pose, the walk and emotes dragged them along with the stalks. They now
follow the head. No other body or piece had it (checked in Studio for all ten bodies, hats and necks; the owner checked
the rest in game).

**Where.** The place: `Assets.Skins.Ninja` › `Body` mesh rbxassetid://120785162196984 (was 93275485609327), from the
model "Snail Pieces Ninja v2" (75314008032709) uploaded to The Snail Studio group; the old snail is in
`ServerStorage.!dump.Ninja_before_eyes_2026-11-25`. The fix is `art/skins/fix_eyes.py` (art/skins README → Midnight's
eyes). Lives only in the place until it's saved and published.

**How to check.** Wear the Midnight body with any hat in the lobby or a match: the eyes stay on the face while the
snail idles, walks and emotes. Checked in Studio with the eyestalks bent far over.

**For the wiki.** Shadow Clan: no change players would read about beyond the fix; a History line.
