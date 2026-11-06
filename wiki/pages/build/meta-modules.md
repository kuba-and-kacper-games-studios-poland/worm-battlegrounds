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

The modules that run in the **lobby** (the `Lobby` map, in the lobby place), and the ones both maps share: player
data, economy, cosmetics and travel. They live in `src/modules/Main_Game/` (and a few small ones in
`src/modules/Utils/`). All are built (phases P8 to P12 of the [[Roadmap]]); **each module's `_meta/README.md` is the
source of truth** for its full API, remotes, settings and place setup. What players see: [[Lobby]],
[[Loadout & inventory]], [[Currencies & crates]], [[Levels & XP]], [[Emotes]]. How the servers connect:
[[Architecture#Travel between servers]].

## Lobby

| | |
|---|---|
| Runs on | Server, Client · Lobby map, Studio map |
| Guis | `Lobby` (the logo, the Crates and Skins buttons, the tutorial's arrow layer) |
| Saves | `Profile.Match` (read and cleared here, written by the match server) |

The lobby screen's frame, its 3D stage, and the routing when a player arrives.

- **On join (server):**
  1. A reserved server that booted the `Lobby` map (an expired match entry) sends everyone to a public lobby.
  2. Tutorial match not played (`I.Tutorial.IsMatchDone` false) → the tutorial match on Picnic Plains against the
     `Tutorial` bot. In Studio, where nothing saves, it marks the match played instead, unless the Workspace attribute
     `StudioTutorial` is true.
  3. `Match.Rejoin` still fresh → `Lobby_RejoinOffer (secondsLeft)`; the client asks "Rejoin your match?"; yes →
     `Lobby_Rejoin` → `I.TeleportToServer` with the access code and the card "Back to your match…". Cleared either way.
- **Client:** turns the lobby guis on (`LOBBY_GUIS`: `Lobby`, `MatchBoard`, `Party`, `Loadout`, `Currency`) except
  while the player is in a match (`InMatch`), and holds the camera on the **stage** (`Stage.lua`): the persistent Model
  `LobbyStage` (in `ServerStorage.Ume.PlaceLoader_Workspace/Lobby`, 400 studs up and 1200 out along Z) with its
  `Camera` and `Worm` markers. The player's worm stands on the `Worm` marker in its `EquippedSkin` (built into
  `Workspace.Ume.Lobby`), and the camera sets the `FOV` buff's base to `STAGE_FOV` 40 (45 with a window open).

**Placeholders:** the stage and the gold "WORM BATTLEGROUNDS" text logo, until the owner's art exists.

**Done when:** a fresh Studio profile with the tutorial marked done sees the worm on its podium and every panel; with
a fake `Match.Rejoin` written from the command bar, the next join asks to rejoin.

## MatchBoard

| | |
|---|---|
| Runs on | Server, Client · Lobby map, Studio map |
| Exposes | `I.MatchBoard` (server: `Launch`, `GetMap`) |
| Guis | `MatchBoard` (the play panel), `CustomLobby` |
| World | `ReplicatedStorage.Ume.MatchBoard` (one `Configuration` per row) |

The lobby's way into matches: one panel at the bottom, laid out like RoWorld's ([[Lobby#Bottom: play]]). Rows are
**per lobby server** ([[Architecture]] suggests sharing them later).

| Handler | Does |
|---|---|
| `Scripts/Server/Rows.lua` | Keeps one public row per mode on the board at all times (`PUBLIC_ROWS`: Deathmatch 4, Duo 4, Trio 6, Quads 8). A row's `ROW_SECONDS` 30 timer starts when its first player joins; it starts when full, when the timer ends (bots at `PUBLIC_DIFFICULTY` Medium fill every empty seat) or when `VOTE_FRACTION` 2/3 vote. A started row is replaced by a fresh one of its mode. Joining (`MatchBoard_Join`) is for leaders, for the whole party; a party bigger than a team can't join a team row |
| `Scripts/Server/Custom.lua` | Custom rooms: `MatchBoard_CreateCustom (mapId, mode, size)`, `_InviteCustom`, `_InviteAnswer`, `_StartCustom` (the owner, 2 or more), `_LeaveCustom`. A room is a row only its members see |
| `Scripts/Server/Launch.lua` | `MatchBoard_PlaySolo (difficulty)` (refused in a party of 2+), `MatchBoard_PlayParty (difficulty)` (the leader of a party of 2+; `Easy`, `Medium`, `Hard` or `None`: `PARTY_BOTS_PER_PLAYER` 1 bot per member, up to `PARTY_MAX_SIZE` 8 worms), and `Launch`: teams (parties kept together), the metadata ([[Architecture#Match metadata]]), the card (`I.Transition.SetDestination`: "Heading to <map>…") and `I.Teleport` to `MATCH_PLACE_ID`. On the Studio map it hands the match to `I.Match.Host` instead |
| `Scripts/Client/Board.lua` | The panel: the welcome line, Play solo (Play with party in a party) and Custom, the public cards (mode name from `MODE_NAMES`, `1 / 6`, the countdown from `EndsAt`, Join), and the waiting room in the panel's place (the match line, the countdown, `1 / 4 players`, the names, Vote to start, Leave match) |
| `Scripts/Client/Setup.lua` | The solo or party setup in the panel's place: the difficulties (`DIFFICULTY_TEXT`; No bots for a party), what it pays (`REWARD_TEXT`), Start, Back |
| `Scripts/Client/Custom.lua` | The `CustomLobby` window: map cards, Deathmatch or Teams, 2 to 8 players, invites, Start |

**Maps:** `MAPS` names every arena with its sizes and `Thumbnail` (all empty for now); `MAP_POOL` (`PicnicPlains`,
`Desert`) is what rows and lobbies pick from. A size no map in the pool is made for plays on any map in it.

**Settings** (besides the above): `MATCH_PLACE_ID` (118265066788984, Arena), `TELEPORT_GUI`, `STUDIO_MAP`,
`SOLO_DIFFICULTIES` (`Easy`, `Medium`, `Hard`; the middle label is asked on [[Lobby]]), `TEAM_SIZES`, the selected and
tile colours.

**Not used any more:** the `SoloSetup` and `PlayModes` windows (still in the gui folder) and the quick Play.

**Done when:** in Studio the panel shows four cards; joining Trios alone starts after 30 s as the player and 2 bots
against 3 bots.

## Party

| | |
|---|---|
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server: `Leave`, `GetParty`, `GetMembers`, `IsLeader`) |
| Guis | `Party` (the tab and panel), `PartyInvite`, `PartyInvited` (widgets) |

Parties of up to `MAX_PARTY` 4 in the same lobby server.

- `Party_Invite (target)` → the target gets `Party_Invited (fromUserId)`; `Party_Answer (fromUserId, accept)`;
  `Party_Leave`; `Party_Kick (target)` (leader only). An invite stays open `INVITE_SECONDS` 30. A player is in one
  party; the leader leaving passes the lead on; a party left with one player ends.
- State is two attributes on each `Player`, written by the server: `PartyId`, `PartyLeader`. Everyone's panel draws
  from them.
- **Client:** the panel under its tab ("PARTY 2/4", open on PC and console, folded on phones and tablets by
  `I.Platform.Current`, opened by a press); **Invite players** opens `PartyInvite` (everyone here not in a party,
  Invite → Sent, Invite friends, a line when there's nobody); an invited player gets `PartyInvited` (the inviter's
  avatar, Join party, No thanks; closing it lets the invite run out). **Invite friends** opens Roblox's own invite
  prompt (`I.Friends`). Loadout and MatchBoard export at `DisplayOrder` −1, so the opened panel draws over them.

**Unsure:** the invite windows weren't tried with two players yet.

**Done when:** in a two-player test, player 1 invites player 2 from the list, player 2 joins from the invite window,
both panels list both; player 1 joins a row and player 2 is in it too.

## Loadout

| | |
|---|---|
| Runs on | Server, Client · both maps (the panel only in the lobby) |
| Exposes | `I.Loadout` (server: `Set`, `UnlockSlot`, `GetUnlocked`, `GetMatchLoadout`) |
| Guis | `Loadout` (the slim bar), `LoadoutPicker` (widget) |
| Saves | `Profile.Loadout` |

The 3–5 slots a player takes into a match ([[Loadout & inventory]]).

- `Loadout_Set (slot, itemId?)`: the slot is open, the item an owned weapon or utility (`SLOT_CATEGORIES`), not the
  Bazooka, and not in another slot; nil empties it.
- `Loadout_UnlockSlot (slot)` (RemoteFunction): slot 4 for 2,500 coins, slot 5 for 6,000 once slot 4 is open
  (`SLOT_PRICES`). The `Slot4` and `Slot5` game passes open them too (`SLOT_PASSES`).
- `GetMatchLoadout(player)` → the items in open slots and which are shiny (10 copies), for the match server.
- Replicator `Loadout`: `Slot1`…`Slot5`, `Unlocked`.
- **Client:** the bar (the Bazooka and the slots; an empty slot's `EMPTY_ICON` +, a filled slot's name in its rarity's
  colour, the next locked slot only its price, "2500 coins"); the picker (owned items as tiles with rarity, uses,
  cooldown and copies toward shiny); the emote row above it is drawn by `Cosmetics`.

**Done when:** equipping two items and rejoining keeps them; equipping the same item twice is refused; opening slot 4
with coins takes 2,500 and opens the box.

## Crates

| | |
|---|---|
| Runs on | Server, Client, Global · Lobby map |
| Exposes | `I.Crates` (server: `Open`), `I.G_Crates` (both: `Get`, `GetAll`) |
| Guis | `Crates` (a WidgetManager window), `CrateOpen`, `CrateOdds`; the Lobby gui's Crates button and badge |
| Data | `Data/Crates/<CrateId>.lua` ([[Data & networking#Crates]]) |

Buying and opening crates ([[Currencies & crates#Crates]]).

- `Crates_Open (crateId, count, payWith)` (RemoteFunction; `count` 1 or 10, `payWith` `Coins`, `Diamonds` or
  `VipDaily`): the crate takes that currency, **diamond prices are refused while the player's policy restricts paid
  random items** (fail closed, `PAID_CURRENCIES`), the price is taken, each crate rolls from its odds, one copy per
  result, and the results come back with each item's copies and whether it just turned shiny (10 copies). Topic
  `Crates_Opened`.
- The server checks at start that each odds table adds up to 100. Measured in Studio: 20,000 weapon-crate rolls
  matched the odds within half a percent.
- **Client:** the window (two crates to a row, currency tabs in the kit's selected and slate skins, Open, Open 10,
  Details), the `CrateOdds` list, the `CrateOpen` reveal (a `SHAKE_SECONDS` 1.2 shake, then the result tile, or 10, in
  its rarity's frame). The **badge** on the lobby's Crates button: `BADGE_FREE` "FREE" while the tutorial crate or
  VIP's daily crate waits, else how many of the cheapest coin crate the coins open, `9+` past `BADGE_MAX` 9, hidden at
  none.
- **Prices are labels, never fake discounts** (Roblox bans crossed-out prices and endless discounts since April 2026;
  see the open suggestion on [[Currencies & crates]]).

**Not built:** the reveal's burst effect, and a longer reveal for rarer results. The Skip button is the open
suggestion `crate-skip`.

**Done when:** opening 10 weapon crates with 900 coins in Studio adds 10 copies, the odds window lists 11 weapons
adding up to 100%, and with the policy forced to restricted the premium crate is gone.

## Cosmetics

| | |
|---|---|
| Runs on | Server, Client, Global · both maps |
| Exposes | `I.Cosmetics` (server: `Equip`, `BuyEmote`, `PlayEmote`, `GetSkin`), `I.G_Cosmetics` (both: skin and emote rows) |
| Guis | `Skins`, `EmoteShop` (widgets), the emote row in `Loadout`, the emote wheel in `MatchHud` |
| Saves | `Profile.Cosmetics` (`EquippedSkin`); owned skins and emotes are Inventory items |

Worm skins and emotes ([[Currencies & crates#Skin crate]], [[Emotes]]).

- Every player gets `STARTER_ITEMS` (`Skin_Classic`, `Emote_Wave`) on first join.
- `Cosmetics_Equip (skinId)`; `Cosmetics_BuyEmote (emoteId)` (RemoteFunction: level high enough, coins taken);
  `Cosmetics_PlayEmote (emoteId)`: owned, `EMOTE_COOLDOWN` 5 s, then `Cosmetics_EmotePlayed (userId, emoteId)` to
  everyone. Replicator `Cosmetics.EquippedSkin`.
- **Client:** the Skins window (opened from the lobby's Skins button: owned skins in 3D previews, copies toward
  shiny, Equip), the emote shop, the lobby's emote row, and the match's emote wheel (`Emotes.lua`), which closes on a
  pick, the smiley, a click or tap that isn't on a button, and when the smiley hides.

**Placeholders:** every skin shows the Classic worm until its model exists, and an emote shows its name over the worm
for `EMOTE_SECONDS` 2.5 (or beside the name in the party list) instead of an animation and voice line.

**Done when:** equipping a skin in the lobby shows it on the stage and in the next Studio match (once it has a model);
an emote bought at the right level plays once per 5 seconds.

## Progression

| | |
|---|---|
| Runs on | Server · both maps |
| Exposes | `I.Progression` (`AddXP(player, amount)`, `GetLevel(player)`) |

XP and levels ([[Levels & XP]]). XP is the `XP` statistic. Reaching level L takes `100 × (L − 1) + 4 × (L − 1) × L / 2`
XP (level 2 at 104, level 100 at 29,700), up to `MAX_LEVEL` 100. Replicator `Progression` (`Level`, `XPIntoLevel`,
`XPForLevel`), the `Level` Player attribute (party list, worm tags), and `Level` in the player list. A level up
publishes `Progression_LevelUp`, shows a toast and gives `LEVEL_REWARDS` (25 Prisoner, 50 FBI Agent, 100 Wizard).

**Done when:** `I.Progression.AddXP(player, 3600)` from the command bar makes the player level 25 with the Prisoner
skin owned.

## Shop

| | |
|---|---|
| Runs on | Server, Client · every map |
| Exposes | `I.Shop` (server: `IsVip`, `CanClaimVipCrate`, `ClaimVipCrate`) |
| Guis | `Shop` (widget), opened by the `Currency` bar's + |
| Saves | `Profile.Shop` (`VipCrateDay`) |

Robux purchases ([[Currencies & crates#Diamonds]], [[Currencies & crates#Game passes]]). The purchases themselves are
ume's Marketplace module; this module adds the game's rewards and window.

- **Diamond packs** (`PACKS`, developer products in `src/global_data/Marketplace/Products.lua`): Handful 250, Pouch
  500, Bag 1,000, Chest 1,500, Vault 2,500. **Game passes** (`PASSES`, `GamePasses.lua`): VIP, Double Coins, Slot 4,
  Slot 5. Prices are read live; an owned pass reads OWNED.
- **VIP:** the `Vip` Player attribute (copied to the worm: a gold name), `VIP_CHAT_TAG` `[VIP]` through
  `TextChatService.OnIncomingMessage`, the VIP skin, and one free skin crate per UTC day (Replicator
  `Shop.VipCrateReady`, claimed through `Crates_Open … "VipDaily"`).
- The lobby's top bar has no Shop button: only the currency bar's + opens it.

**Owner gate:** every product and pass id is 0 until the owner creates them in the Creator Hub; with id 0 the shop
shows "-" for the price.

**Done when:** in a published test, each pass and one diamond pack work once each, and the purchase log shows the pack.

## Tutorial

| | |
|---|---|
| Runs on | Server, Client · every map |
| Exposes | `I.Tutorial` (server: `CompleteMatch`, `IsMatchDone`, `IsDone`, `CanOpenCrate`) |
| Guis | `TutorialHint` (the bubble), the `Lobby` gui's arrow |
| Saves | `Profile.Tutorial` (`MatchDone`, `CrateOpened`, `Done`) |

The first-time flow ([[Lobby#First time playing]]).

1. **Tutorial match** (`Kind = "Tutorial"`, Picnic Plains, 1v1 against the tutorial bot): `HINTS` in order (Walk,
   Jump, Fire: "Point the crosshair at the bot, then hold to charge and let go to fire", BotTurn, Finish), moving on
   only on the player's own shots (`MatchHints.lua`), since the bot may play first. The match ends with
   `CompleteMatch`: `MatchDone` and `MATCH_COINS` 100. Leaving early counts too (Match's `SendToLobby`).
2. **Lobby:** the Crates button's badge reads FREE; the hidden tutorial crate (100 coins, always the Grenade and the
   Shotgun) opens once.
3. **Equip:** a hint and an arrow over the loadout (`LobbyHints.lua`) until both are in it (`Tutorial_Step "Equipped"`,
   checked by the server). `Done = true`.

**Open:** whether the tutorial should always let the player go first.

**Done when:** a fresh profile in a published test lands in the tutorial match, comes back with 100 coins, opens the
tutorial crate and equips both weapons, and never sees the tutorial again.

## Transition

`src/modules/Main_Game/Transition`, Server and Client, both maps. The teleport card between the lobby and a match
([[Architecture#Travel between servers]]). `I.Transition.SetDestination(players, text, image)` (server) sends
`Transition_Destination (text, image)` right before a teleport; the client fills the `TeleportGui` card (`S_Text`,
`S_Image` when there's a picture), slides it down (`WIPE_TWEENINFO` 0.4 s) and hands Roblox a copy to show through the
teleport. On arrival `src/replicated_first/Transition.client.lua` puts the copy up at once, removes the place's
loading screen for that join, waits until the player's client has started and slides it off. Callers: MatchBoard's
`Launch`, Match's `SendToLobby`, Lobby's rejoin. **Unsure:** the rejoin card wasn't tried yet, and map thumbnails are
empty, so the card shows only text.

## CharacterPark

`src/modules/Utils/CharacterPark`, Server, both maps. Worms aren't avatars, but ume spawns each player's avatar once
([[Architecture#Players' own characters]]). It anchors the avatar at `PARK_POSITION` 0, −60, 0 as soon as it spawns
and hides it, its name, and the clothes, hats and face that load later (`I.HideOnPlay`). The framework change it
works around: a per-map switch for ume's `INITIAL_CHARACTER_AUTO_LOAD`.

## VoiceChat

`src/modules/Utils/VoiceChat`, Server and Client, both maps. With no avatars near the camera, Roblox's default
spatial voice would be silent. With `VoiceChatService.EnableDefaultVoice` off in the place, the server gives each
player an `AudioDeviceInput`, and each client wires every other player's input to one `AudioDeviceOutput`
(non-spatial: the whole server hears everyone). The match screen's voice button is Roblox's own mic toggle. Check it
in a published server: voice doesn't run in Studio.

## Analytics

`src/modules/Utils/Analytics`, Server, both maps. **Not built yet.** Roblox's `AnalyticsService` from Topics, so no
other module calls it: the onboarding funnel (`Tutorial` steps, first public match), economy events for every coin and
diamond source and sink (`Currency_Changed` with `ServerUpdate` on for both currencies), and custom events (matches
started and finished, by kind and mode). The two places already let Roblox's own analytics count the lobby and the
matches apart.

## Existing modules to change

The game owns everything in `src/modules/`; `src/modules_ume/`, `src/libs/` and `src/core/` (except `configs/`) are
the framework's and stay as they are.

| Module | Change |
|---|---|
| `2_Currency` | `CURRENCIES`: `Coins` and `Diamonds` (Cash is gone). The game's `Currency` gui gives each count its own UIScale for `Currency_Slot`, and writes amounts from 10,000 short (`Currency_ShortFrom`) |
| `1_Inventory` | `CATEGORIES`: `Weapon`, `Utility`, `Skin`, `Emote`, `Other`. One item file per weapon, utility, skin and emote in `Data/Items/<Category>/` |
| `Settings` | A `Gameplay` section with `DamageNumbers` and `CameraFollowsShot`, both on |
| `TopBar_Controller` | No BackpackPlus button. The lobby keeps only Settings; the match adds Leave and Music from `MatchHud` |
| `0_Console` | No BackpackPlus binds; its hints stay. The game's pad controls are bound by `WormControl` and `MatchHud` |
| `WidgetManager` | Unchanged: an open window adds `FOV_INCREASE` 5 to the `FOV` buff behind its blur, which the lobby stage and MatchCamera now set the base of |
| `Core_Controller` | `ENABLED_CORE_GUIS`: chat and player list; off: Roblox's emotes menu, backpack, health |
| `Leaderstats_Controller` | `STATS`: `Wins` (`Progression` writes `Level` itself) |
| `BGM_Controller` | Music names: `Music_Lobby` (the cartoon military march), `Music_Match`; no music uploaded yet |
| `src/global_data/` | `Statistic/Statistic.lua` (XP, MatchesPlayed, Wins, Knockouts, DamageDealt), `Marketplace/Products.lua` and `GamePasses.lua` (ids 0), `Haptic/Preset.lua` (`Combat_Fire`, `Combat_BlastSmall`, `Combat_BlastBig`, `Combat_Hurt`); sounds not yet. Rows: [[Data & networking#Global data]] |
| `configs/place_loader.lua`, `configs/general.lua` | The two places and four maps ([[Architecture#Place loader config]]); `GameVersion` |
| `Utils` (new): `ScreenScale`, `TextCase` | Panels and world labels sized to the screen; the kit's capitals kept on text code writes ([[Guis]]) |

::navbox{from="build"}
