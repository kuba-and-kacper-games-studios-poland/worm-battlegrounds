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

- [ ] Check both projects are in UmeSync and connected; run `rokit install` in both folders
- [ ] Write the game's decisions into `.claude/rules/game/practices.md` (the table on [[Implementation plan#Decisions this plan makes]]) and their story in `docs/game/lessons.md`
- [ ] `configs/place_loader.lua`: the `Lobby`, `Match` and `UmeLobby` rows, the same store names, `DisabledModules` per map, the Studio map switch ([[Architecture#Place loader config]])
- [ ] In the place: run `.other/create_placeloader_dirs.lua`, add the `Lobby`, `Match` and `Shared` folders, `Workspace.Ume.Lobby.BaseSpawn`, and the `Arenas`, `Skins`, `Items`, `Effects` asset folders ([[Architecture#In the place]])
- [ ] Remove BackpackPlus from `0_Console` and `TopBar_Controller`; set `Core_Controller`'s core guis
- [ ] Rename the template's `Main_Game/Game` to `Match`; create empty modules for the rest of [[Architecture#Module map]] so every name exists
- [ ] `CharacterPark` (Utils)
- [ ] The `WormBattlegrounds` theme's tokens: palette, team and rarity colours, fonts, radius, stroke
- [ ] Done when: Studio boots the `Lobby` map with no errors; with `Ume_StudioMapId = "Match"` it boots the `Match` map; avatars stay parked
:::

:::milestone[Arena]{version="P1" goal="A destructible studded arena on the 2D plane"}
[[Match modules#Arena]].

- [ ] `Arena` loader, grid, chunks with greedy meshing and the studs texture, carving
- [ ] Falling blocks: flood fill, debris assemblies, writing them back
- [ ] Liquid (water, lava, none), bounds, drop zone, lighting preset, gravity, collision groups
- [ ] Map rows (`Arena/Data/Maps`) for all 6 maps; a greybox Picnic Plains template
- [ ] Done when: the checks on [[Match modules#Arena]] pass
:::

:::milestone[Worms and movement]{version="P2" goal="Worms that walk, jump, fall, get hurt and die on the plane, seen by a side-on camera"}
[[Match modules#Worms]], [[Match modules#WormControl]], [[Match modules#MatchCamera]].

- [ ] `Worms`: the worm model (placeholder until the Classic skin exists), constraints, health, damage, heal, knockback, fall damage, hazards, ghosts
- [ ] `WormControl`: input on keyboard, touch and pad, network ownership while walking, stamina, the server checks
- [ ] `MatchCamera`: side-on, following, panning, bounds; the `FOV_Controller` lock
- [ ] `WormTag` and `DamagePop` billboards
- [ ] Done when: the checks on the three module pages pass
:::

:::milestone[The match loop]{version="P3" goal="A whole match without weapons: drop, turns, timer, wind, rounds, sudden death, a winner"}
[[Match modules#Match]].

- [ ] `Match`: roster from Studio metadata, teams and colours (`I.Team` in team modes), the phase machine, the drop phase with markers
- [ ] Turn order team by team, the 15-second timer, wind, rounds, settle, sudden death, placement, win
- [ ] `MatchHud` first parts: turn banner, timer, wind, stamina, waiting overlay, drop picker; `DropMarker`
- [ ] Done when: the checks on [[Match modules#Match]] pass (a knockout here can be a command-bar `I.Worms.Kill`)
:::

:::milestone[Aiming and the Bazooka]{version="P4" goal="Aim and fire on every device; explosions carve, hurt, throw and knock out"}
[[Match modules#Combat]], [[Match modules#MatchHud]].

- [ ] `Arsenal` with the Bazooka row; `I.G_Combat` launch math
- [ ] `Combat`: the fire pipeline, the `Rocket` behavior, `Explode`, damage, knockback, kill credit, settle hand-off
- [ ] `MatchHud` aiming: drag on mouse and touch, right stick and the up-and-down power bar on a pad, cancel, the aim line, the last-shot marker
- [ ] Effects: explosion, splash, camera shake, haptics, sounds (placeholders until the real ones)
- [ ] Kill feed
- [ ] Done when: two Studio players can knock each other into the water with Bazooka shots on PC, on the phone emulator and with a pad
:::

:::milestone[The full arsenal]{version="P5" goal="All 14 weapons and 6 utilities, with uses and cooldowns"}
[[Arsenal]], [[Match modules#Combat]].

- [ ] Arsenal rows for every weapon and utility ([[Data & networking#Arsenal rows]])
- [ ] Behaviors: `Bouncer`, `Snail`, `Crawler`, `Homing` (target pick), `Roller` (detonate), `Hitscan`, `Melee`, the spear's pierce
- [ ] Utilities: heals and the four movement effects
- [ ] Uses and cooldowns in the Replicator; the loadout bar (Bazooka box, 3–5 slots, keys, LB/RB, taps)
- [ ] Match loadout from `STUDIO_METADATA` until P8
- [ ] Done when: the check on [[Match modules#Combat]] passes for every item
:::

:::milestone[Bots]{version="P6" goal="AI that fills empty spots and plays solo matches at three difficulties"}
[[Match modules#Bots]].

- [ ] Bot participants, names, skins, loadouts by difficulty
- [ ] Target and weapon choice, shot solving with `PredictArc`, hit rates 30 / 60 / 85%
- [ ] The tutorial bot
- [ ] Done when: an 8-player Studio match with 1 player and 7 bots plays to the end on its own
:::

:::milestone[End of a match]{version="P7" goal="Results, rematch, leaving, dropping out and spectating"}
[[Match modules#Match]], [[Match screen]].

- [ ] Stats (damage, knockouts, best shot) and the `Results` widget
- [ ] Rematch votes and replaying on the same server
- [ ] Leave game (ghost, placement), disconnect and the 60-second rejoin window (in-server part), the knocked-out panel
- [ ] Top bar buttons: Leave game, Mute music, Settings; the Settings switches
- [ ] Done when: a match ends on results, a rematch replays it, and a player who leaves is placed last among the living
:::

:::milestone[Profile, economy and levels]{version="P8" goal="Coins, items, loadouts and XP are saved and paid out"}
[[Lobby & meta modules]], [[Data & networking#Saved for each player]].

- [ ] Currency: `Coins` and `Diamonds`; Inventory categories and every item file
- [ ] `Loadout` (server and lobby panel, picker widget, coin unlocks); the match reads `GetMatchLoadout`
- [ ] `Progression` (XP, levels, level skins, the `Level` attribute, leaderstats)
- [ ] `MatchRewards`: coins by kind and place, anti-farming, Double Coins, XP, statistics, the save before results
- [ ] `Cosmetics` skins: equip, the match uses the equipped skin
- [ ] Done when: a Studio match pays the right coins by place, XP levels the player up, and the loadout chosen in the lobby is the one in the match (switch the map attribute between runs)
:::

:::milestone[Lobby and match servers]{version="P9" goal="The real flow: lobby → public, solo or custom match → back, with parties and rejoin"}
[[Lobby & meta modules#Lobby]], [[Lobby & meta modules#MatchBoard]], [[Lobby & meta modules#Party]], [[Architecture#Travel between servers]].

- [ ] `Lobby` gui and module (background, panels on, routing on join, the private-lobby guard)
- [ ] `MatchBoard`: rows, timers, join, votes, waiting room, solo, custom lobbies, `Launch` with metadata and `TeleportGui`
- [ ] `Party`: invites, leader, travelling together; Roblox's invite prompt
- [ ] The match side: reading `I.Config.Metadata`, kicking strangers, back to lobby, writing `Match.Rejoin`; the lobby's rejoin offer
- [ ] `VoiceChat`
- [ ] **Owner gate:** a published test place
- [ ] Done when: in the published test, 3 players (2 in a party) start a Duo row, play it with a bot, and land back in one lobby; a dropped player rejoins within 60 s
:::

:::milestone[Crates and cosmetics]{version="P10" goal="Crates with honest odds, shiny copies, skins and emotes"}
[[Lobby & meta modules#Crates]], [[Lobby & meta modules#Cosmetics]].

- [ ] Crate rows and odds checks, `Crates_Open`, the policy gate for diamond crates
- [ ] The crates panel, `CrateOdds` (Details), `CrateOpen` reveal, shiny at 10 copies
- [ ] The `Skins` widget; emotes: the shop, the lobby row, the match wheel, the 5-second limit
- [ ] Done when: the checks on both module pages pass
:::

:::milestone[Monetization]{version="P11" goal="Diamonds, game passes and VIP, by Roblox's rules"}
[[Lobby & meta modules#Shop]], [[Currencies & crates#Diamonds]].

- [ ] **Owner gate:** product and game pass ids
- [ ] Marketplace rows and rewards; the `Shop` widget with live prices; the currency bar
- [ ] Slot passes in `Loadout`, Double Coins in `MatchRewards`, VIP: skin, gold name, chat tag, the free daily skin crate
- [ ] Done when: in the published test, each pass and one diamond pack work once each, and the purchase log shows the pack
:::

:::milestone[Tutorial]{version="P12" goal="A new player learns by playing in their first five minutes"}
[[Lobby & meta modules#Tutorial]], [[Lobby#First time playing]].

- [ ] The tutorial match hints, the tutorial crate, the equip pointer, `TutorialHint`
- [ ] Routing new players straight into the tutorial match
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
