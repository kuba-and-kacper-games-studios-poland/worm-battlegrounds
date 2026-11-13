---
title: "Tutorial match: the player's shot can't miss the bot"
date: 2026-11-13
status: open
kind: changed
pages: ["Lobby", "Match modules", "Lobby & meta modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Aimbot.lua
---

**What changed.** The owner asked for the tutorial to be "stupid-proof so you cannot miss the shot on the tutorial
arena". Before, a new player could still miss the bot: too short or too long a charge, or the wrong angle. They then got
the Retry hint and the bot's turn. Now, in the tutorial match, every shot the player fires flies a path that lands on
the bot, whatever their aim and charge. A tap with almost no charge still hits. The tutorial bot falls to any hit
(Bots' `HEALTH` Tutorial 10), so the first shot wins the match.

**Where.** `Fire._onFire` (the player's `Combat_Fire` request): when `I.Match.GetMetadata().Kind == "Tutorial"`, the
server swaps the sent angle, power and target for `Aimbot.GetShot(participantId, itemId)`. That new function returns the
admin aim guide's solved shot at an enemy snail: the arc from `AIMBOT_POWERS` that lands within `AIMBOT_HIT_MARGIN`
(2.5 studs), else the nearest landing. Only the player's request is steered; bots and other match kinds are unchanged.
The client still draws its own aim line from where the player points, so the shot can leave in a different direction
than the line shows.

**How to check.** In Studio, set Workspace's `StudioTutorial` to true and play. Land, then click on the bot with a very
short tap: the bot is knocked out and the hint says "You won! Head back to the lobby". Checked in Studio on 2026-11-13
with an 80 ms tap. The touch and pad flows weren't checked, and neither was a map where land blocks every arc between
the two spots (there, the nearest landing is used, which may not hit).

**For the wiki.** Lobby (its tutorial part): the tutorial match's first shot always hits the bot, so the "Retry after a
miss" step only comes up when the turn runs out without a shot. Match modules (Combat): the tutorial match steers the
player's shots with `Aimbot.GetShot`. Lobby & meta modules (Tutorial): the same in one line.
