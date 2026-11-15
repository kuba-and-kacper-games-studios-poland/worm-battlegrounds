---
title: "Admin commands: lobby unlocks, and match commands by snail name"
date: 2026-11-16
status: open
kind: added
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/AdminPanel/CommandBar/Server.lua
---

**What changed.** New admin commands (level 255, the command bar), for the lobby and the match servers:

- `cosmetics give_skin <player> <setId>`: one more copy of each piece of a set (a whole skin), ids autocompleted
  from `Cosmetics_SetIds` (`Set_BigTop`…).
- `cosmetics unlock_skins <player>`, `cosmetics unlock_emotes <player>`: one copy of every piece, or every emote, the
  player doesn't own yet.
- `loadout unlock_weapons <player>`: one copy of every weapon and utility (Loadout's `SLOT_CATEGORIES`) not owned yet.
- `loadout unlock_slots <player>`: all 6 loadout slots open for good, whatever passes they own (`I.Loadout.OpenAllSlots`
  saves `Loadout.CoinSlots.Slot4` to `Slot6` as true; each true coin slot opens one).

One item with a count stays `inventory add_standard <player> <itemId> [quantity]`.

The match commands that took a participant id (`combat give/refill`, `snails damage/heal/kill/push`,
`snailcontrol turn/end/refill`, `match win`) now take `snail?`: the snail's name (spaces as underscores), its
player's username or its id (`P_<userId>`, `B_<n>`), ignoring case, and the start of a name when only one snail
matches (`flea` for Fleaper). Without it they still act on the invoker's snail. Names are autocompleted from
`Match_Snails`, set again at every phase change. Replies name the snail ("Gave Uzi to Fleaper"). The lookup is
`I.Match.FindParticipant(query)`.

**How to check.** Checked in Studio on 2026-11-16: the lobby commands gave 8 emotes, the Big Top set, 23 pieces and
19 weapons and utilities and opened 6 slots; in a 1v1 against a bot, `snails damage 5 flea`, `snails heal 3 FLEAPER`,
`combat give Uzi fleaper` and `snails push 0 5 B_2` hit the bot, `snails damage 2 viridian` the player, and
`snails heal 5 nobody` answered "No snail nobody in play".

**For the wiki.** Admin tools only, so `:::private` if anywhere: the Architecture page's admin commands, if it lists
them.
