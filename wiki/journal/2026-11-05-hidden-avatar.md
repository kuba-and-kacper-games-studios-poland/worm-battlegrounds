---
title: "The Roblox avatar no longer shows on the match's waiting screen"
date: 2026-11-05
status: open
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Utils/CharacterPark/Server.lua
---

**What changed.** Before a match's camera takes over (the "Waiting for players" screen), Roblox's own camera looks
at the player's avatar, which waits anchored 60 studs below the arena. It used to show there, hanging in the sky
(under the grey baseplate before that was taken out of play). Now the avatar, its clothes, hats, face and name are
hidden as soon as it spawns, so the waiting screen shows only the sky and the arena. Players still play only as
worms.

**Where.** `CharacterPark._park` hides the avatar with `I.HideOnPlay.Hide` and turns its name off
(`DisplayDistanceType = None`); `_hideAdded` hides pieces that load later. In the place, the template's baseplate
(`Workspace.Ume.Env`) is now moved to ServerStorage when the game starts (`Utils_MoveChildTo`).

**How to check.** Start a match in Studio: the waiting screen shows no avatar; in the client, every part and decal
of the player's character has `Transparency` 1 (16 of 16 in the Studio test).

**For the wiki.** Probably nothing: no page describes the avatar. A History line on Match screen if the owner wants
fixes listed.
