---
title: "Lobby & meta modules"
summary: "The modules around the matches: the lobby screen, public match rows, party, custom lobbies, loadout, crates, skins and emotes, levels, the shop, the tutorial, and what changes in ume's existing modules."
icon: home
status: active
order: 3
type: "Plan"
tags: [build]
suggestions:
  - id: crate-skip
    text: "Opening a Worm Battlegrounds 10-pack of crates plays the reveal animation 10 times. After a player's first 10 crate openings, add a Skip button that jumps straight to the results (the animation still matches the odds when watched)?"
    options: [Yes, Later, No]
  - id: rejoin-auto
    text: "When a Worm Battlegrounds player drops out of a match and comes back to the game within 60 seconds, they land in the lobby, which asks 'Rejoin your match?'. Send them straight back into the match instead, without asking?"
    options: ["Send them straight back", "Keep asking"]
  - id: party-ready
    text: "A Worm Battlegrounds party joins a public match row when its leader presses Join. Add a ready check (every member taps Ready within 10 seconds) so a member who's away doesn't get pulled into a match?"
    options: [Yes, Later, No]
---

The modules that run in the **lobby** (the `Lobby` map), and the ones both maps share: player data, economy and
cosmetics. They live in `src/modules/Main_Game/` (and three small ones in `src/modules/Utils/`). What players see and
the numbers: [[Lobby]], [[Loadout & inventory]], [[Currencies & crates]], [[Levels & XP]], [[Emotes]]. How the
servers connect: [[Architecture#Travel between servers]].

## Lobby

| | |
|---|---|
| Runs on | Server, Client · Lobby map |
| Guis | `Lobby` (the background and first-time pointers) |
| Uses | `I.Player`, `I.Tutorial`, `I.WidgetManager`, `I.TeleportToServer`, `I.TeleportExternal`, `I.BGM_Controller` |

The lobby screen's frame and the routing when a player arrives.

- **On join (server, `I.G_Player.OnPlayerAdded` at `Default`):**
  1. A reserved server that booted the `Lobby` map (an expired match entry, [[Architecture#Travel between servers]])
     sends everyone to a public lobby.
  2. Tutorial not done (`I.Tutorial.IsMatchDone(player)` false) → launch the tutorial match
     (`I.MatchBoard.Launch` with `Kind = "Tutorial"`).
  3. `Match.Rejoin` in the profile and still fresh → `Lobby_RejoinOffer` to the client, which asks "Rejoin your
     match?" (`I.WidgetManager.ShowConfirmation`); yes → `Lobby_Rejoin` → `I.TeleportToServer` with the access code.
     The key is cleared either way.
- **Client:** shows the `Lobby` gui (the flat illustrated background, under every lobby panel), turns the other lobby
  panels on, plays the lobby march (`I.BGM_Controller`), and hosts the tutorial's pointer arrows for `Tutorial`.

**Done when:** a fresh Studio profile with the tutorial marked done sees the lobby with every panel; with a fake
`Match.Rejoin` written from the command bar, the next join asks to rejoin.

## MatchBoard

| | |
|---|---|
| Runs on | Server, Client · Lobby map |
| Exposes | `I.MatchBoard` (server) |
| Guis | `MatchBoard` (middle panel), `SoloSetup`, `CustomLobby` |
| World | `ReplicatedStorage.Ume.MatchBoard` (one `Configuration` per row) |
| Uses | `I.Party`, `I.Loadout`, `I.Cosmetics`, `I.Teleport`, `I.Notify`, `I.G_Arena` map rows |

The middle of the lobby: Play solo, the 3 public match rows, custom lobbies, the waiting room, and launching every
match. Rows are **per lobby server** for now ([[Architecture]] suggests sharing them later).

**Server handlers** (`Scripts/Server/`):

| Handler | Does |
|---|---|
| `Rows.lua` | Keeps 3 public rows: 1 deathmatch (2, 4, 6 or 8 players) and 2 team matches (Duo at 4, 6 or 8; Trio at 6; Quads at 8). Each row picks a random map that fits its size (8 → The Big Mashup; 2–6 → one of the 5 others). A row's 30-second timer (`EndsAt`) starts when its first player joins; an empty row waits. A started row is replaced by a new random one |
| `Join.lua` | `MatchBoard_Join (rowId)`: the player's whole party joins together; refused (with a Notify) when it doesn't fit, or the party is bigger than a team (asked on [[Lobby]]). `MatchBoard_Leave`. A player is in one row at most |
| `Votes.lua` | `MatchBoard_Vote`: when two thirds of the joined players (rounded up) voted, the row starts at once |
| `Solo.lua` | `MatchBoard_PlaySolo (difficulty)`: 1v1 against one bot at Easy, Medium or Hard, launched at once |
| `Custom.lua` | `MatchBoard_CreateCustom (mapId, mode, size)`, `MatchBoard_InviteCustom (target)`, `MatchBoard_InviteAnswer (roomId, accept)`, `MatchBoard_StartCustom`, `MatchBoard_LeaveCustom`. A room is a hidden row only its members see; its creator starts it |
| `Launch.lua` | `Launch(players, metadata)`: teams first (parties kept on one team, then solo players, then empty spots for bots), builds the metadata ([[Architecture#Match metadata]]), calls `I.Teleport(players, MATCH_PLACE_ID, "Match", metadata, "TeleportGui")`. On failure (always in Studio) the players go back to the board with "Couldn't start the match" (Studio: prints the metadata) |

**Row attributes** (on each `Configuration`): `Kind` (`Public` or `Custom`), `Mode`, `Size`, `MapId`, `Players` (JSON
list of user ids), `Teams` (JSON), `EndsAt` (server time, 0 while empty), `Votes`, `VotesNeeded`, `Owner` (custom),
`Members` (custom, JSON).

**Client:** draws the rows from the attributes (map thumbnail, mode and map name, `3 / 8`, the countdown from `EndsAt`,
Join or Join teams), swaps to the **waiting room** when I'm in a row (the map's picture behind it, "Duo team
deathmatch • Picnic Plains", "Match starts in 0:29", `5 / 8 players`, every name, Vote to start `4 / 6`, Leave match),
opens `SoloSetup` and `CustomLobby` through WidgetManager, and answers invites (`MatchBoard_Invited` →
`ShowConfirmation`).

**Settings:** `MATCH_PLACE_ID` (`game.PlaceId`), `ROW_SECONDS` 30, `VOTE_FRACTION` 2/3, `PUBLIC_ROWS` (the 3 row
kinds), `SOLO_DIFFICULTIES` (`Easy`, `Medium`, `Hard`; the middle label is asked on [[Lobby]]).

**Done when:** in Studio with 3 test players, all three see the same rows and timers; two join a Duo row and see each
other in the waiting room; both vote and the row "starts" (metadata printed, a new row appears).

## Party

| | |
|---|---|
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server: `GetParty(player)`, `GetMembers(partyId)`, `IsLeader(player)`) |
| Guis | `Party` (left panel) |
| Uses | `I.Friends` (the Roblox invite prompt), `I.Notify`, `I.WidgetManager` |

Parties of up to 4 in the same lobby server.

- `Party_Invite (target)` → the target gets `Party_Invited (fromUserId)` and a confirmation; `Party_Answer
  (fromUserId, accept)`; `Party_Leave`; `Party_Kick (target)` (leader only). A player is in one party; the leader
  leaving passes the lead on.
- State is two attributes on each `Player`, written by the server: `PartyId`, `PartyLeader`. Everyone's panel draws
  from them.
- **Invite friends** (not in this server) opens Roblox's own invite prompt (`I.Friends`), which brings them to this
  server.
- Only the leader joins rows, plays solo isn't offered while in a party of 2 or more, and a party travels together
  (MatchBoard sends the whole party).

**Settings:** `MAX_PARTY` 4, `INVITE_SECONDS` 30.

**Done when:** in Studio, player 1 invites player 2, player 2 accepts, both panels list both; player 1 joins a row and
player 2 is in it too.

## Loadout

| | |
|---|---|
| Runs on | Server, Client · both maps (the client panel only on the Lobby map) |
| Exposes | `I.Loadout` (server) |
| Guis | `Loadout` (left panel), `LoadoutPicker` (widget) |
| Saves | `Profile.Loadout` |
| Uses | `I.Inventory`, `I.G_Arsenal`, `I.Currency`, `I.G_Marketplace`, `I.Replicator` |

The 3–5 slots a player takes into a match ([[Loadout & inventory]]).

- `Loadout_Set (slot, itemId?)`: the slot is unlocked, the item is an owned weapon or utility, not the Bazooka, and not
  in another slot; `nil` empties the slot.
- `Loadout_UnlockSlot (slot)` (RemoteFunction): slot 4 for 2,500 coins, slot 5 for 6,000 coins once slot 4 is open.
  Slot 4 and Slot 5 game passes open them too; slot 5 counts only once slot 4 is open, whichever way.
- `GetUnlocked(player)` → 3, 4 or 5. `GetMatchLoadout(player)` → the filled slots (a list of item ids) with each
  item's shiny state, for the match server.
- Replicator `Loadout` folder: `Slot1`…`Slot5` (item id or `""`), `Unlocked`.
- **Client:** the panel (one box per slot, locked boxes show their prices: coins or Robux), the picker widget (every
  owned weapon and utility as tiles with rarity, `copies / 10` toward shiny, uses and cooldown from `I.G_Arsenal`,
  `HoverInfo` details), the emotes smiley row above it (drawn by `Cosmetics`).

**Done when:** equipping two items and rejoining keeps them; equipping the same item twice is refused; buying slot 4
with coins takes 2,500 and opens the box.

## Crates

| | |
|---|---|
| Runs on | Server, Client, Global · Lobby map |
| Exposes | `I.Crates` (server), `I.G_Crates` (both: rows and odds) |
| Guis | `Crates` (right panel), `CrateOpen`, `CrateOdds` |
| Data | `Data/Crates/<CrateId>.lua` ([[Data & networking#Crates]]) |
| Uses | `I.Inventory`, `I.Currency`, `I.Policy`, `I.Shop` (VIP crate), `I.Random`, `I.Rarity` (looks) |

Buying and opening crates ([[Currencies & crates#Crates]]).

- `Crates_Open (crateId, count, payWith)` (RemoteFunction, `count` 1 or 10, `payWith` `Coins`, `Diamonds` or
  `VipDaily`): the server checks the crate exists and is sold for that currency, **diamond crates are refused while
  `I.Policy.GetArePaidRandomItemsRestricted(player)` is true** (true until the policy loads: fail closed), takes the
  price (`I.Currency.Subtract`; the 10-pack price from the row), rolls each crate from the row's odds with `I.Random`,
  adds one copy per result (`I.Inventory.AddItem`), and returns the results with each item's copies and whether it
  just turned shiny (10 copies).
- Odds rows add up to exactly 100%; the module checks it at start and warns per crate.
- **Restricted regions:** players where paid random items are restricted don't see the diamond crates; the coin crates
  stay (fail closed). The final treatment is asked on [[Currencies & crates]].
- **Prices are labels, never fake discounts:** a 10-pack shows "10 for 900", never "10% off" forever or a crossed-out
  price (Roblox bans both since April 2026; see the open suggestion on [[Currencies & crates]]).
- **Client:** the panel (Weapon, Premium, Utility and Skin crates with their prices and a labelled **Details** button
  that opens `CrateOdds`), the reveal in `CrateOpen` (the animation lands on what the server rolled; rarer results
  get a longer, brighter reveal), the tutorial crate card while `Tutorial` shows it.

**Done when:** opening 10 weapon crates with 900 coins in Studio adds 10 copies, the odds window lists 11 weapons
adding up to 100%, and with the policy forced to restricted the premium crate is gone.

## Cosmetics

| | |
|---|---|
| Runs on | Server, Client, Global · both maps |
| Exposes | `I.Cosmetics` (server), `I.G_Cosmetics` (both: skin and emote rows) |
| Guis | `Skins` (widget), `EmoteShop` (widget), the emote row in `Loadout`, the emote wheel in `MatchHud` |
| Saves | `Profile.Cosmetics` (equipped skin); owned skins and emotes are Inventory items |
| Data | `Data/Skins/<SkinId>.lua`, `Data/Emotes/<EmoteId>.lua` |

Worm skins and emotes ([[Currencies & crates#Skin crate]], [[Emotes]]).

- `Cosmetics_Equip (skinId)`: owned (Classic is always owned). `GetSkin(player)` → skin id and whether it is shiny,
  for the match server.
- `Cosmetics_BuyEmote (emoteId)` (RemoteFunction): the player's level is at least the emote's, takes the coins, adds
  the item.
- `Cosmetics_PlayEmote (emoteId)`: owned, `EMOTE_COOLDOWN` 5 s since the last one; fires `Cosmetics_EmotePlayed
  (userId, emoteId)` to everyone in the server. On a match server the worm plays it (any turn, also while out); in
  the lobby the emote shows over the player's name in the party panel.
- Level skins (Prisoner 25, FBI Agent 50, Wizard 100) are granted by `Progression`; the VIP skin by the VIP pass's
  reward.
- **Client:** the skins widget (owned skins in viewports, copies toward shiny, Equip), the emote shop (price, level
  needed, Buy), the emote row and wheel.

**Done when:** equipping the Pirate skin in the lobby shows the Pirate worm in the next Studio match; an emote bought
at the right level plays once per 5 seconds.

## Progression

| | |
|---|---|
| Runs on | Server, Client · both maps |
| Exposes | `I.Progression` (server: `AddXP(player, amount)`, `GetLevel(player)`) |
| Uses | `I.Statistic` (`XP`), `I.Inventory`, `I.Notify`, `I.Replicator` |

XP and levels ([[Levels & XP]]).

- XP is the `XP` statistic. Level is worked out from total XP: going from level *n* to *n + 1* costs `100 + 4 × n`, up
  to level 100 (29,700 XP). Replicator `Progression.Level`; the `Level` attribute on the `Player` (others see it: the
  waiting room, worm tags); a `Level` value in the player list (`I.Leaderstats`).
- On a level up: publishes `Progression_LevelUp`, grants a level reward (`LEVEL_REWARDS`: 25 Prisoner, 50 FBI Agent,
  100 Wizard), and the client shows a toast.

**Done when:** `I.Progression.AddXP(player, 3600)` from the command bar makes the player level 25 with the Prisoner
skin owned.

## Shop

| | |
|---|---|
| Runs on | Server, Client · both maps (the windows only on the Lobby map) |
| Exposes | `I.Shop` (server: `IsVip(player)`, `CanClaimVipCrate(player)`, `ClaimVipCrate(player)`) |
| Guis | `Shop` (widget), `Currency` (the coins and diamonds bar) |
| Saves | `Profile.Shop` (the day of the last free VIP crate) |
| Uses | `I.Marketplace`, `I.G_Marketplace`, `I.Currency`, `I.Inventory` |

Robux purchases ([[Currencies & crates#Diamonds]], [[Currencies & crates#Game passes]]). The purchases themselves are
ume's Marketplace module; this module adds the game's rewards and windows.

- **Diamond packs** are developer products in `src/global_data/Marketplace/Products.lua`; each `Reward` adds its
  diamonds (`I.Currency.Add`) and returns a string for the purchase log. Marketplace grants each receipt once and
  only after the save.
- **Game passes** in `GamePasses.lua`: `Slot4`, `Slot5` (read by `Loadout`), `DoubleCoins` (read by `MatchRewards`),
  `VIP` (`SingleReward` adds the VIP skin).
- **VIP:** writes the `Vip` attribute on the `Player` (gold name on worm tags, the VIP tag in chat through
  `TextChatService.OnIncomingMessage` on the client), and one free skin crate per UTC day (`CanClaimVipCrate`,
  claimed through `Crates_Open … "VipDaily"`).
- **Prices are read live** (`I.G_Marketplace.GetProductPrice`), never written in code, so regional pricing and price
  tests work.
- **Client:** the shop widget (5 diamond packs, 4 game passes with every benefit listed; buying calls Marketplace's
  prompt remote), and the currency bar at the top of the lobby (`Currency_Slot` labels for coins and diamonds, a +
  beside diamonds that opens the shop).

**Done when:** in Studio, `marketplace gift gamepass` VIP gives the VIP skin and a gold name; a test purchase of the
Handful adds 250 diamonds once (checked in a published test place).

## Tutorial

| | |
|---|---|
| Runs on | Server, Client · both maps |
| Exposes | `I.Tutorial` (server: `IsMatchDone(player)`, `IsDone(player)`) |
| Guis | `TutorialHint` (pointer arrow and bubble) |
| Saves | `Profile.Tutorial` |

The first-time flow ([[Lobby#First time playing]]).

1. **Tutorial match** (match server, `Kind = "Tutorial"`, Picnic Plains, 1v1 against the tutorial bot): hints in
   order: walk, jump, aim and fire (each shown when the step before is done), the bot's turn, "two hits knock it out".
   At the end `MatchDone = true`; then back to the lobby.
2. **Lobby:** 100 coins and the **tutorial crate** card (a fixed crate: always the Grenade and the Shotgun, so it is
   not random); a pointer to it; opening it.
3. **Equip:** a pointer to the loadout; done when both are equipped (`Tutorial_Step "Equipped"`). `Done = true`.

`Tutorial_Step (step)` lets the client report steps the server can't see (the hint closed, a panel opened); the
server checks what it can (owned items, loadout) itself.

**Done when:** a fresh profile in a published test lands in the tutorial match, comes back with 100 coins, opens the
tutorial crate and equips both weapons, and never sees the tutorial again.

## CharacterPark

`src/modules/Utils/CharacterPark`, Server, both maps. Worms aren't avatars, but ume spawns each player's avatar once
([[Architecture#Players' own characters]]). On `I.G_Player.OnCharacterAdded` it anchors the root part, hides the
avatar and keeps it at `BaseSpawn` (under the lobby floor, behind the arena). Name the framework change it works around
to the user: a per-map switch for ume's `INITIAL_CHARACTER_AUTO_LOAD`.

## VoiceChat

`src/modules/Utils/VoiceChat`, Server and Client, both maps. With no avatars near the camera, Roblox's default
spatial voice would be silent. With `VoiceChatService.EnableDefaultVoice` off, the server gives each player an
`AudioDeviceInput`, and each client wires every other player's input to one `AudioDeviceOutput` (non-spatial, the
whole server hears everyone, as a match screen's voice button expects). The match screen's voice button is Roblox's own
mic toggle. Check it in a published server: voice doesn't run in Studio.

## Analytics

`src/modules/Utils/Analytics`, Server, both maps. Roblox's `AnalyticsService` from Topics, so no other module calls
it: the onboarding funnel (`Tutorial` steps, first public match), economy events for every coin and diamond source and
sink (`Currency_Changed` with `ServerUpdate` on for both currencies, labelled by what caused it), and custom events
(matches started and finished, by kind and mode). Purely additive; skip it if time is short.

## Existing modules to change

The game owns everything in `src/modules/`; `src/modules_ume/`, `src/libs/` and `src/core/` (except `configs/`) are
the framework's and stay as they are.

| Module | Change |
|---|---|
| `2_Currency` | `CURRENCIES`: replace `Cash` with `Coins` and `Diamonds` (default `"0"`, `ServerUpdate` on for Analytics, icons from the team's art) |
| `1_Inventory` | `CATEGORIES`: `Weapon`, `Utility`, `Skin`, `Emote`. One item file per weapon, utility, skin and emote in `Data/Items/<Category>/` (the loader reads subfolders; ids are file names, unique across folders). Replace `Example.lua` |
| `Settings` | Add a `Gameplay` section with two switches: `DamageNumbers` and `CameraFollowsShot`, both on. Keep `Master` (the code multiplies by it) |
| `TopBar_Controller` | Remove the BackpackPlus button (the module is off). Lobby: Settings and Shop. The match adds its own buttons from `MatchHud` |
| `0_Console` | Remove the BackpackPlus binds (bumpers, D-pad up and down); keep its hints. The game's pad controls are bound by `WormControl` and `MatchHud` |
| `Core_Controller` | `ENABLED_CORE_GUIS`: chat and player list; off: Roblox's emotes menu, backpack, health |
| `Leaderstats_Controller` | `STATS`: `Wins` (it reads only statistics and currencies; `Progression` writes `Level` itself through `I.Leaderstats`) |
| `BGM_Controller` | Music names: `Music_Lobby` (the cartoon military march), `Music_Match`; ambience off |
| `Favorite_Controller`, `SoftShutdown`, `Notify`, `WidgetManager`, `HoverInfo`, `Rarity`, `Utils`, `Interact` | Used as they are |
| `src/global_data/` | `Statistic/Statistic.lua` (XP, MatchesPlayed, Wins, Knockouts, DamageDealt), `Marketplace/Products.lua` and `GamePasses.lua`, `Sound/SoundsList.lua` and `SoundGroupsList.lua`, `Haptic/Preset.lua`, `Team/Teams.lua` stays empty (teams are made per match). Rows: [[Data & networking#Global data]] |
| `configs/place_loader.lua`, `configs/general.lua` | The map rows ([[Architecture#Place loader config]]); `GameVersion` |

::navbox{from="build"}
