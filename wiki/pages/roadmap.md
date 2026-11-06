---
title: "Roadmap"
summary: "The build order for Worm Battlegrounds: 14 phases from an empty ume project to a game ready to launch. Each phase ends with something to check in Studio."
icon: checklist
status: active
panel: true
order: 3
type: "Roadmap"
tags: [build]
---

::::roadmap
:::milestone[Foundations]{version="P0" goal="The project is set up for the game: maps, folders, modules off and on, the theme, the rules written down"}
Everything later phases rely on. See [[Architecture]].

- [x] Check both projects are in UmeSync and connected; run `rokit install` in both folders
- [x] Write the game's decisions into `.claude/rules/game/practices.md` (the table on [[Implementation plan#Decisions this plan makes]]) and their story in `docs/game/lessons.md`
- [x] `configs/place_loader.lua`: the `Lobby`, `Match` and `UmeLobby` rows, the same store names, `DisabledModules` per map, the Studio map switch ([[Architecture#Place loader config]])
- [x] In the place: run `.other/create_placeloader_dirs.lua`, add the `Lobby`, `Match` and `Shared` folders, `Workspace.Ume.Lobby.BaseSpawn`, and the `Arenas`, `Skins`, `Items`, `Effects` asset folders ([[Architecture#In the place]])
- [x] Remove BackpackPlus from `0_Console` and `TopBar_Controller`; set `Core_Controller`'s core guis
- [x] Rename the template's `Main_Game/Game` to `Match`; create empty modules for the rest of [[Architecture#Module map]] so every name exists
- [x] `CharacterPark` (Utils)
- [x] The `WormBattlegrounds` theme's tokens: palette, team and rarity colours, fonts, radius, stroke
- [x] Done when: Studio boots the `Lobby` map with no errors; with `Ume_StudioMapId = "Match"` it boots the `Match` map; avatars stay parked
:::

:::milestone[Arena]{version="P1" goal="A destructible studded arena on the 2D plane"}
[[Match modules#Arena]].

- [x] `Arena` loader and carving: authored parts in `2022 Stud`, cut by CSG in 1-stud steps (replaced the planned grid and greedy-meshed chunks)
- [x] Falling ground: groups cut loose from bedrock fall and anchor where they land; floating ledges; props that break
- [x] Liquid (water, lava), bounds, collision groups, the worm plane, `GetHazard`, `Arena_Loaded`
- [ ] A map's lighting preset and gravity
- [x] Map rows (MatchBoard's `MAPS`) for the 6 planned maps and Desert; Picnic Plains and Desert built in MapLab
- [ ] The other planned maps' templates (P13)
- [x] Done when: the checks on [[Match modules#Arena]] pass
:::

:::milestone[Worms and movement]{version="P2" goal="Worms that walk, jump, fall, get hurt and die on the plane, seen by a side-on camera"}
[[Match modules#Worms]], [[Match modules#WormControl]], [[Match modules#MatchCamera]].

- [x] `Worms`: the worm model (placeholder until the Classic skin exists), constraints, health, damage, heal, knockback, fall damage, hazards, ghosts
- [ ] Worm animations (the skins have none yet)
- [x] `WormControl`: input on keyboard, touch and pad, network ownership while walking, stamina, the server checks
- [x] `MatchCamera`: side-on, following the worm and the shot, panning, zoom, bounds; the `FOV` buff's base instead of a lock
- [x] `WormTag` and `DamagePop` billboards
- [ ] Done when: the checks on the three module pages pass (keyboard and mouse checked; touch and gamepad not yet)
:::

:::milestone[The match loop]{version="P3" goal="A whole match without weapons: drop, turns, timer, wind, rounds, sudden death, a winner"}
[[Match modules#Match]].

- [x] `Match`: roster from Studio metadata, teams and colours (`I.Team` in team modes), the phase machine, the drop phase with markers
- [x] Turn order team by team, the 15-second timer, wind, rounds, settle, sudden death, placement, win
- [x] `MatchHud` first parts: turn banner, timer, wind, stamina, waiting overlay, drop picker; `DropMarker`
- [x] Done when: the checks on [[Match modules#Match]] pass (a knockout here can be a command-bar `I.Worms.Kill`)
:::

:::milestone[Aiming and the Bazooka]{version="P4" goal="Aim and fire on every device; explosions carve, hurt, throw and knock out"}
[[Match modules#Combat]], [[Match modules#MatchHud]].

- [x] `Arsenal` with the Bazooka row; `I.G_Combat` launch math
- [x] `Combat`: the fire pipeline, the `Rocket` behavior, `Explode`, damage, knockback, kill credit, settle hand-off
- [x] `MatchHud` aiming: first a drag and an aim line; since 2026-11-06 a crosshair and a held charge that bounces until let go, on every device, seen by everyone
- [ ] The last-shot marker
- [x] Effects: flash, fireball, fire, sparks, smoke, flying chunks, camera shake, haptics (placeholder particle pictures)
- [ ] Sounds
- [x] Kill feed
- [ ] Done when: two Studio players can knock each other into the water with Bazooka shots on PC, on the phone emulator and with a pad (PC checked; touch and gamepad not yet)
:::

:::milestone[The full arsenal]{version="P5" goal="All 14 weapons and 6 utilities, with uses and cooldowns"}
[[Arsenal]], [[Match modules#Combat]].

- [x] Arsenal rows for every weapon and utility ([[Data & networking#Arsenal rows]])
- [x] Behaviors: `Bouncer`, `Snail`, `Crawler`, `Homing` (target pick), `Roller` (detonate), `Hitscan`, `Melee`, the spear's pierce
- [x] Utilities: heals and the four movement effects
- [x] Uses and cooldowns in the Replicator; the loadout bar (Bazooka box, 3–5 slots, keys, LB/RB, taps)
- [x] Match loadout from `STUDIO_METADATA` until P8
- [x] Done when: the check on [[Match modules#Combat]] passes for every item
:::

:::milestone[Bots]{version="P6" goal="AI that fills empty spots and plays solo matches at three difficulties"}
[[Match modules#Bots]].

- [x] Bot participants, names, skins, loadouts by difficulty
- [x] Target and weapon choice, shot solving with `PredictArc`, hit rates 30 / 60 / 85%
- [x] The tutorial bot
- [x] Done when: an 8-player Studio match with 1 player and 7 bots plays to the end on its own
:::

:::milestone[End of a match]{version="P7" goal="Results, rematch, leaving, dropping out and spectating"}
[[Match modules#Match]], [[Match screen]].

- [x] Stats (damage, knockouts, best shot) and the `Results` widget
- [x] Rematch votes and replaying on the same server
- [x] Leave game (ghost, placement), disconnect and the 60-second rejoin window (in-server part), the knocked-out panel
- [x] Top bar buttons: Leave game, Mute music, Settings; the Settings switches
- [x] Done when: a match ends on results, a rematch replays it, and a player who leaves is placed last among the living
:::

:::milestone[Profile, economy and levels]{version="P8" goal="Coins, items, loadouts and XP are saved and paid out"}
[[Lobby & meta modules]], [[Data & networking#Saved for each player]].

- [x] Currency: `Coins` and `Diamonds`; Inventory categories and every item file
- [x] `Loadout` (server and lobby panel, picker widget, coin unlocks); the match reads `GetMatchLoadout`
- [x] `Progression` (XP, levels, level skins, the `Level` attribute, leaderstats)
- [x] `MatchRewards`: coins by kind and place, anti-farming, Double Coins, XP, statistics, the save before results
- [x] `Cosmetics` skins: equip, the match uses the equipped skin
- [x] Done when: a Studio match pays the right coins by place, XP levels the player up, and the loadout chosen in the lobby is the one in the match (switch the map attribute between runs)
:::

:::milestone[Lobby and match servers]{version="P9" goal="The real flow: lobby → public, solo or custom match → back, with parties and rejoin"}
[[Lobby & meta modules#Lobby]], [[Lobby & meta modules#MatchBoard]], [[Lobby & meta modules#Party]], [[Architecture#Travel between servers]].

- [x] `Lobby` gui and module (background, panels on, routing on join, the private-lobby guard)
- [x] `MatchBoard`: rows, timers, join, votes, waiting room, solo, custom lobbies, `Launch` with metadata and `TeleportGui`
- [x] `Party`: invites, leader, travelling together; Roblox's invite prompt
- [x] The match side: reading `I.Config.Metadata`, kicking strangers, back to lobby, writing `Match.Rejoin`; the lobby's rejoin offer
- [x] `VoiceChat`
- [x] **Owner gate:** the published lobby and match places
- [ ] Done when: in the published test, 3 players (2 in a party) start a Duo row, play it with a bot, and land back in one lobby; a dropped player rejoins within 60 s
:::

:::milestone[Crates and cosmetics]{version="P10" goal="Crates with honest odds, shiny copies, skins and emotes"}
[[Lobby & meta modules#Crates]], [[Lobby & meta modules#Cosmetics]].

- [x] Crate rows and odds checks, `Crates_Open`, the policy gate for diamond crates
- [x] The crates window, `CrateOdds` (Details), `CrateOpen` reveal, shiny at 10 copies
- [ ] The reveal's burst effect
- [x] The `Skins` widget; emotes: the shop, the lobby row, the match wheel, the 5-second limit
- [ ] Emote animations and voice lines (the emote's name shows instead)
- [x] Done when: the checks on both module pages pass
:::

:::milestone[Monetization]{version="P11" goal="Diamonds, game passes and VIP, by Roblox's rules"}
[[Lobby & meta modules#Shop]], [[Currencies & crates#Diamonds]].

- [ ] **Owner gate:** product and game pass ids (all 0 for now)
- [x] Marketplace rows and rewards; the `Shop` widget with live prices; the currency bar
- [x] Slot passes in `Loadout`, Double Coins in `MatchRewards`, VIP: skin, gold name, chat tag, the free daily skin crate
- [ ] Done when: in the published test, each pass and one diamond pack work once each, and the purchase log shows the pack
:::

:::milestone[Tutorial]{version="P12" goal="A new player learns by playing in their first five minutes"}
[[Lobby & meta modules#Tutorial]], [[Lobby#First time playing]].

- [x] The tutorial match hints, the tutorial crate, the equip pointer, `TutorialHint`
- [x] Routing new players straight into the tutorial match
- [ ] Done when: the check on [[Lobby & meta modules#Tutorial]] passes in the published test
:::

:::milestone[Content and launch checks]{version="P13" goal="All maps, skins and sounds in; every device checked; ready to publish"}
- [ ] The 6 arena templates, every skin and emote, sounds and music, lighting presets, the lobby background and thumbnails
- [ ] `Analytics` (funnel and economy events)
- [ ] Every gui on Desktop, Mobile and Console in the Gui tool; console navigation through every lobby window
- [ ] Performance: part counts per arena, network stats (`network stats` command), no per-frame work while idle
- [ ] Policy checks as Belgium, the Netherlands, the UK, Australia and Brazil (diamond crates hidden where restricted)
- [ ] `IsProductionReady` on, `GameVersion` set, both projects' READMEs current
- [ ] Done when: the [[Build brief]]'s content-at-launch table is all in, and a full session (tutorial → public match → crate → rematch) plays on PC, phone and console without errors
:::
::::
