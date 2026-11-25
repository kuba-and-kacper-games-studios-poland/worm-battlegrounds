# Progression

Levels from XP, the lobby's diamonds payout and XP replay after a match, and the prestige frames.

XP is the `XP` statistic; the level is worked out from it, up to `MAX_LEVEL`. Reaching level L takes
`LEVEL_BASE_XP × (L − 1) + LEVEL_STEP_XP × (L − 1) × L / 2` XP in total. MatchRewards adds XP after a match, line by
line (playing, a win, knockouts), and queues those lines for the lobby. A level up shows a toast, updates the Level
leaderstat and gives the item `LEVEL_REWARDS` names for that level (none for now: the level skins aren't in the game
yet, 2026-11-25).

**Weapon rewards** (the owner, 2026-11-24: crates never drop the starter weapons, "the pros at 90 level have the golden
bazooka"): levels open the starter weapons' looks, `WEAPON_REWARDS`: Shiny Grenade (10), Shiny Shotgun (20), Shiny
Bazooka (30), Golden Grenade (60), Golden Shotgun (75), Golden Bazooka (90). Nothing is given or saved: a weapon is the
best look its levels opened (`I.G_Progression.GetWeaponVariant`) or its copies made it, which Loadout reads for the
match (`GetMatchLoadout`, the Bazooka's too), its cards and the picker, so a player already past a level has its look.
Both deal +5% damage (Golden is gold as well), and the unlock says so. An admin can also give a player any weapon's
or utility's look by hand (the `progression` command's `weapon_look` and `golden_weapons`): saved in the profile
(`Progression.Variants`), written on the Player (`WeaponVariants`), and worn beside the level's
(`I.G_Progression.GetPlayerWeaponVariant`, the better of the two).

At rest the lobby shows the level by the diamonds (the owner's pick, 2026-11-25): the `LevelPlate` gui's `U_Rest`, a
copy of the replay's thin bar under it (as wide as the diamonds plate and its +), its fill and a small rank crest on its
left end both painted in the tier's colours by
`I.G_Progression.ApplyFrame`, written whenever the level or XP changes and hidden while the replay plays. The level
also stands on each stage snail's nameplate (Lobby's `Stage`). The `LevelPlate` gui's stage (`U_Plate`) is hidden and only pops up in the middle for the replay.

When the player comes back from a match (or the tutorial) that paid diamonds or gave XP, the lobby plays it back once.
First the **diamonds** (`Scripts/Client/Payout.lua`, the owner, 2026-11-24: "like Brawl Stars with the trophies"; coins
until 2026-11-25): the `Currency` gui's diamonds slot holds the count from before the payout from the moment the lobby
knows of it, "+amount" with the diamond pops up over the player's snail on the stage (`I.Lobby.GetStageSnail`; the
screen's middle when they have none), then one diamond per `DIAMONDS_PER_ICON` (at least one, at most
`DIAMOND_ICONS_MAX`) bursts out of it and flies into the slot, which counts up by each diamond's share as it lands, with a tick that climbs in pitch. **Bought diamonds play the same way** once the shop closes
(`PlayPurchase`, the owner, 2026-11-25: "make it satisfying - add like fanfares… a blue gem vignette"): the Shop module
holds every diamonds counter (the shop's own too) at the count from before the first pack (`HoldPurchase`) and hands over every pack bought while the
shop was open; more diamonds fly for a bigger pack (`PURCHASE_ICONS_*`), "+amount" pops with the gift's sound
(`PURCHASE_POP_SOUND`), the last landing sounds the level-up fanfare (`PURCHASE_LAND_SOUND`), and the screen's edges
breathe gem blue meanwhile (the `PotionVignette` gui, borrowed: the lobby has no potions, and it's left alone while
a potion shows it), flashing as the diamonds land. It waits for a replay that's playing and for the lobby to show, and
a replay waiting meanwhile plays after it. Then the **XP**, when there is some (the owner, 2026-11-25:
"needs to feel like leveling up in a high end competition"): the lobby's panels and the stage's nameplates make way
(`I.Lobby.SetTakeover`), the lobby darkens (`REPLAY_DIM`) and the stage pops up in the middle: the rank crest (the
level in a dark middle, a rim in the prestige tier's colours with a light sweeping it) on rays and a glow in the tier's
colour, richer each tier (`REPLAY_TIER_LOOKS`: no rays at Rookie, both ray layers and twice the stars at Mythic), a pip
per tier lit up to the player's and the tier's name, the XP bar (thin and sharp, its fill in the tier's own colours
through `I.G_Progression.ApplyFrame`, so it shines from Gold and turns at Mythic) with the next reward's card at its end
(the weapon's, skin's or emote's picture, or the player's own face in the frame the level opens, tagged NEXT), and the
XP as tiles along the bottom, each with its picture (`XP_ICONS`), its XP ("+100 XP") and what it was for. Each tile pops in with a chime and fills the bar with
rising ticks and sparks flying into it; every level-up bursts with stars, punches the crest into the new level
(`CREST_PUNCH`), slams LEVEL UP! across it, flashes white and pops the tier's name on a new rank (`RANK_FLASH`, with
its own sting), and turns the card UNLOCKED! when the level opened it (`REWARD_POP`); then the stage shrinks away and
the lobby comes back. A level that opens a weapon's look then plays its **unlock** (`Scripts/Client/Unlock.lua`,
even while skipping): the lobby goes dark, the level's diamond pops up and charges (rattling, swelling, light flying
into it), flashes open into the weapon's card (its model turning, gilded when Golden, in the Shiny foil or the Golden
rim) on turning rays with a burst of stars, SHINY! or GOLDEN! slams in, then "Golden Bazooka unlocked", what it does
in a match ("+5% damage…") and TAP TO CONTINUE, which waits for a tap. A tap, click or A skips the XP. The client then tells the server,
which forgets the replay.

Prestige frames are tiers of a player's level (`FRAME_TIERS`): Rookie (1), Bronze (5), Silver (15), Gold (25), Emerald
(50), Diamond (75), Mythic (100). Each is a set of rim colours; Gold and up sweep a light across the rim every few
seconds, and Mythic's colours spin round. `I.G_Progression.ApplyFrame` paints any UIGradient (on a stroke picture or a
fill) in a level's tier; the party cards and the plate use it.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Progression` |
| Runs on | Server, client and both (Global) · both maps; the payout and the replay play in the lobby only |
| Exposes | `I.Progression` (server; on the client the bought diamonds' payout), `I.G_Progression` (both) |
| Uses | `I.G_Arsenal` (the unlock's weapon, its picture and model), `I.Statistic`, `I.Leaderstats`, `I.Inventory`, `I.Notify`, `I.Replicator`, `I.AdminPanel_CommandBar`, `I.G_Cosmetics`, `I.G_Inventory`, `I.UIEmitter`, `I.Sound`, `I.Utils`, `I.BN`; on the client `I.Lobby` (`GetStageSnail`, `SetTakeover`), `I.Currency`, `I.G_Currency` (the diamond's icon), the `Currency` gui's diamonds slot, the `PotionVignette` gui (the bought diamonds' vignette), `I.Number`, `I.Random` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Adding XP, the level, rewards, publishing, the saved replay and the diamonds added to it |
| `Client.lua` | The lobby's replay: the diamonds first (`Payout`), then the XP on the level plate |
| `Scripts/Client/Unlock.lua` | A level's weapon unlock on the `LevelPlate` gui's `U_Unlock`: `Play(level)` plays it (the charge, the flash, the card, the title, the lines, rising sparkles: `UNLOCK_*`) and returns once the player taps it away; the weapon's model is `I.G_Arsenal.GetModel`'s, gilded as Combat gilds a held Golden one (Combat doesn't run in the lobby: `UNLOCK_GILD*`) |
| `Scripts/Client/Payout.lua` | The diamonds payout: `Hold(amount, before?)` keeps every diamonds counter on the screens (each gui's TextLabel whose `Currency_Name` is `Diamonds`: the `Currency` gui's slot, the shop's and the crates screen's) at the count before the payout, whatever the Currency module writes, until the diamonds land, each counting up as they do; `Play(amount)` pops "+amount" over the player's stage snail (the `LevelPlate` gui's `S_Gain`, `S_GainScale`, `S_GainText`, `S_GainIcon`), splits the amount evenly over the diamonds (a bought pack's `look`, a `Progression_PayoutLook`, gives their count and the pop and landing sounds) (the first ones one more until the remainder is gone), throws them with an `I.UIEmitter` (made on the first payout, its diamonds pulled into the slot) and returns once the last has landed or after `DIAMOND_FLIGHT_TIMEOUT`; `SetVignette(on)` fades the `PotionVignette` gui's edges in gem blue and breathing, or flashes and fades them out (`PURCHASE_VIGNETTE_*`) |
| `Global.lua` | Prestige frames (`ApplyFrame`, `GetTier`, the shine and spin), the next unlock and the weapon rewards' looks (`GetWeaponVariant`) |
| `Settings.lua` | `Progression_Settings`: what both sides read (level rewards, frames, the plate, the replay and the diamonds payout) |
| `ServerSettings.lua` | `Progression_ServerSettings`, under a server name so clients never get the level curve |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `progression` command |
| `_meta/_types.lua` | `Progression_Progress`, `Progression_XpLine`, `Progression_Replay`, `Progression_WeaponReward`, `Progression_UnlockLook`, `Progression_Tier`, `Progression_ReplayTierLook`, `Progression_RewardLook` |

## API

### Server: `I.Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `AddXP(player, amount: number)` | `number, boolean` | Adds XP; returns the level and whether it went up |
| `AddLevels(player, levels: number)` | `number, boolean` | Adds the XP those levels take (to `MAX_LEVEL` at most), through `AddXP`, so their rewards and toast come too; returns the level and whether it went up |
| `SetReplay(player, replay: Progression_Replay)` | | Saves the XP lines, level before and after, and fills in each level's cost on the way (`Costs`), for the lobby to play back; replicates it |
| `SetWeaponVariant(player, itemId: string, variant: string?)` | `boolean` | Gives a player a weapon's or utility's look by hand (`"Shiny"`, `"Golden"`, or nil to take it away), saves it and writes `WeaponVariants`; false for an item that isn't a weapon or utility, or an unknown look |
| `AddReplayDiamonds(player, amount: string)` | | Adds diamonds the player earned outside the lobby (a match, the tutorial) to the replay's `Diamonds` (making a replay with no XP lines when none waits), so the lobby plays them flying in; `"0"` does nothing |
| `GetLevel(player)` | `number` | The player's level |
| `GetProgress(player)` | `Progression_Progress` | The level, the XP into it and the XP it takes (0 at `MAX_LEVEL`) |
| `GetReplay(player)` | `Progression_Replay?` | The XP and diamonds replay still waiting, or nil |
| `GetGivenVariants(player)` | `{ [string]: string }` | The looks an admin gave the player, by item id |

### Client: `I.Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `HoldPurchase(amount: string, before: string?)` | | Holds the diamonds slot at `before` (or the diamonds less `amount`) until the bought diamonds play; the Shop module calls it as a pack is paid for |
| `PlayPurchase(amount: string)` | | Plays bought diamonds after `PURCHASE_DELAY`, once no replay plays and the lobby shows; amounts passed while one waits or plays join it or play next |

### Both: `I.G_Progression`

| Function | Returns | What it does |
| --- | --- | --- |
| `ApplyFrame(gradient: UIGradient, level: number, holdStill: boolean?)` | | Paints the gradient in the level's tier; on clients a tier that shines or spins keeps moving while the gradient is shown, but a `holdStill` one (a bar: the XP bars) never spins, its colours staying left to right |
| `GetTier(level: number)` | `Progression_Tier` | The highest tier the level has unlocked |
| `GetNextUnlock(level: number)` | `string?, number?` | What the next level with an unlock opens ("Silver frame", "Dance emote", "Prisoner skin", "Shiny Grenade", joined with "and"), and that level; nil at the top |
| `GetWeaponVariant(itemId: string, level: number)` | `string?` | The best look the level has opened for a weapon (`WEAPON_REWARDS`): `"Golden"`, `"Shiny"` or nil |
| `GetPlayerWeaponVariant(player: Player, itemId: string)` | `string?` | The best look a player has for a weapon or utility apart from its copies: their level's or an admin's. The server reads their profile, a client the `Level` and `WeaponVariants` Player attributes. Loadout (the match, the cards, the picker) and the lobby stage read it |

## Network

### Server

**Topics**

- `Progression_LevelUp @ (player: Player, level: number)`

**Receive: RemoteEvents**

- `Progression_ReplaySeen @ (player: Player)`: the lobby played the replay; the server forgets it.

The level and the replay travel in the Replicator and a Player attribute.

## Data

| Where | Key | What |
| --- | --- | --- |
| Statistic | `XP` | Total XP (saved by the Statistic module) |
| Profile `Progression` | `Replay` | The replay the lobby hasn't played, a JSON `Progression_Replay` ("" when none): its XP `Lines`, `Before`, `After`, `Costs`, and `Diamonds` (the diamonds paid since, an integer string; absent when none; `Coins` until 2026-11-25), so it survives the teleport back |
| Replicator `Progression` | `Level`, `XPIntoLevel`, `XPForLevel` | The plate and the bars |
| Replicator `Progression` | `Replay` | The saved replay's JSON |
| Profile `Progression` | `Variants` | The weapon looks an admin gave, `{ [itemId]: "Shiny" \| "Golden" }` (`{}` until one is given) |
| Player attribute | `Level` | Seen by other players (the lobby stage's nameplates, match roster, frames) |
| Player attribute | `WeaponVariants` | The same looks as JSON, for every screen (the player's loadout, their snail's weapon on others' lobby stages) |
| Leaderstats | `Level` | The player list |

## Settings

`ServerSettings.lua`:

| Key | Default | What |
| --- | --- | --- |
| `MAX_LEVEL` | `100` | The highest level |
| `LEVEL_BASE_XP`, `LEVEL_STEP_XP` | `100`, `4` | Level 2 takes 104 XP, and each level 4 more than the one before |

`Settings.lua`:

| Key | Default | What |
| --- | --- | --- |
| `LEVEL_REWARDS` | none (25 Prisoner, 50 FBI Agent and 100 Wizard until 2026-11-25) | The item given on reaching a level; only items in the game |
| `WEAPON_REWARDS` | 10 Shiny Grenade, 20 Shiny Shotgun, 30 Shiny Bazooka, 60 Golden Grenade, 75 Golden Shotgun, 90 Golden Bazooka | The starter weapons' looks levels open (`Progression_WeaponReward`: `Item`, `Variant`, the unlock's `Line`) |
| `UNLOCK_LOOKS` | Shiny (pearly pink), Golden (gold) | Each variant's unlock colours (`Accent`, `Rays`, `Gradient`, `Tag`, `Particles`) and the title's `Sound` (`Reveal_Shiny`, `Variant_Golden`) |
| `UNLOCK_MODEL_YAW`, `UNLOCK_MODEL_FOV`, `UNLOCK_MODEL_DISTANCE` | `60`, `30`, `1.75` | The weapon's model on the card: its turn when placed, the camera's field of view and distance (times its longest side) |
| `UNLOCK_GILD`, `UNLOCK_GILD_COVER`, `UNLOCK_GILD_GROW` | dark and bright gold, `0.3`, `1.02` | Combat's Golden look (`VARIANT_LOOKS.Golden`), copied since Combat doesn't run in the lobby |
| `UNLOCK_CHARGE_SECONDS`, `UNLOCK_RATTLE_DEGREES` | `1.3`, `12` | The diamond's charge, and its rattle at the end |
| `UNLOCK_SHADE`, `UNLOCK_RAYS`, `UNLOCK_RAYS_BACK`, `UNLOCK_GLOW` | `0.12`, `0.45`, `0.78`, `0.3` | How see-through the dark, rays and glow rest once the card is in |
| `UNLOCK_STARS`, `UNLOCK_SPARKS`, `UNLOCK_SPARKLE_RATE` | `80`, `36`, `14` | The burst's stars and sparks, and sparkles a second round the card |
| `UNLOCK_POP_TWEENINFO`, `UNLOCK_CARD_TWEENINFO`, `UNLOCK_SLAM_TWEENINFO`, `UNLOCK_FADE_TWEENINFO`, `UNLOCK_FLASH_TWEENINFO` | Back 0.45 s, Back 0.52 s, Back 0.32 s, Quad 0.4 s, Quad 0.7 s | The unlock's pops, the card, the title's slam, the fades and the flash |
| `FRAME_TIERS` | Rookie 1, Bronze 5, Silver 15, Gold 25, Emerald 50, Diamond 75, Mythic 100 | Each tier's name, level, rim colours, `Shine` and `Spin` |
| `FRAME_SHINE_SECONDS`, `FRAME_SHINE_PAUSE` | `1.2`, `2` | A shining rim's light sweep, then the pause before the next |
| `FRAME_SPIN_SPEED` | `120` | Degrees a second Mythic's colours turn |
| `REPLAY_SCALE` | `1` | How big the stage pops up in the middle during the replay (its place and size there are the gui's) |
| `PLATE_TWEENINFO`, `PLATE_BACK_TWEENINFO` | Back 0.55 s, Quad 0.5 s | The stage popping up and shrinking away |
| `REPLAY_DIM` | `0.62` | How dark the lobby gets behind the replay |
| `REPLAY_TIER_LOOKS` | one row per `FRAME_TIERS` tier | How each tier dresses the crest: how see-through its rays, back rays and glow are (1 hides them) and how many times `REPLAY_STARS` a level-up throws, from Rookie (no rays) to Mythic |
| `PIP_OFF_COLOR` | 70, 72, 92 | A rank pip not reached yet |
| `CREST_PUNCH`, `RANK_FLASH` | `1.22`, `0.35` | How big the crest punches in on a level-up, how white a new rank flashes |
| `LEVEL_UP_TWEENINFO`, `RANK_FLASH_TWEENINFO` | Back 0.4 s, Quad 0.7 s | LEVEL UP! and a new rank's name slamming in, and the flash fading |
| `REWARD_COLOR`, `REWARD_TAG_NEXT`, `REWARD_TAG_UNLOCKED`, `REWARD_POP` | gold, grey, gold, `1.35` | The next reward's card: the glow behind a skin or an emote, the tag's colours while it waits and once reached, and how big it pops when reached |
| `TRACK_X` | `0.45` | Where the bar's middle stands across the stage while the card shows at its end (0.5 without one) |
| `REST_FILL_START` | `0.14` | The share of the bar under the diamonds the crest covers: its fill starts there |
| `XP_ICONS` | Played: the gamepad glyph, Win: the crown badge, Knockouts: the crosshair glyph | Each XP tile's picture, by its line's `Key` |
| `REPLAY_DELAY` | `1.2` | Seconds after the lobby shows before the replay starts |
| `REPLAY_LINE_GAP`, `REPLAY_FILL_SECONDS` | `0.35`, `0.9` | Between lines, and the longest a line takes to fill the bar |
| `REPLAY_TICKS`, `REPLAY_TICK_PITCH` | `14`, `0.9` to `1.6` | Ticks per line, their pitch from empty to full |
| `REPLAY_LEVEL_HOLD`, `REPLAY_END_HOLD` | `1.6`, `1.2` | How long a level-up and the end hold |
| `FRAME_UNLOCK_LEAD` | `0.5` | The new frame's sting swells this long before its hit, where the burst lands |
| `REPLAY_TEXTURES`, `REPLAY_SPARKS`, `REPLAY_STARS`, `REPLAY_COLORS` | the crates' spark and star, `10`, `60`, gold, white, orange | The replay's particles |
| `DIAMONDS_PER_ICON`, `DIAMOND_ICONS_MAX`, `DIAMOND_ICON_SIZE` | `5`, `30`, `46` | The payout: one flying diamond per this many diamonds, at most this many, each this many pixels on a 1920 × 1080 screen |
| `DIAMOND_BURST_DELAY`, `DIAMOND_FLIGHT_TIMEOUT` | `0.55`, `4` | Seconds "+amount" shows over the snail before the diamonds burst out, and the most the flight may take |
| `DIAMOND_TICK_CLIMB` | `0.6` | How far the landing diamonds' tick climbs in pitch, from the first to the last |
| `DIAMOND_POP_TWEENINFO`, `DIAMOND_HIDE_TWEENINFO` | Back 0.4 s, Quad In 0.25 s | "+amount" popping up and away |
| `PURCHASE_ICONS_PER_ROOT`, `PURCHASE_ICONS_MIN`, `PURCHASE_ICONS_MAX` | `1.25`, `20`, `64` | Bought diamonds: this times the amount's square root fly, between the two (250: 20, 1,000: 40, 2,500: 63) |
| `PURCHASE_DELAY` | `0.35` | Seconds after the shop closes before they play |
| `PURCHASE_POP_SOUND`, `PURCHASE_LAND_SOUND` | `"Free_Claim"`, `"Level_Up"` | The gift's pop with "+amount", the fanfare as the last lands |
| `PURCHASE_VIGNETTE_COLOR`, `PURCHASE_VIGNETTE_BREATH` | gem blue 60, 140, 255; `0.1`, `0.45` | The vignette's tint and the edges' `BackgroundTransparency` it breathes between |
| `PURCHASE_VIGNETTE_IN_TWEENINFO`, `…_BREATH_TWEENINFO`, `…_FLASH_TWEENINFO`, `…_OUT_TWEENINFO` | Sine 0.4 s; Sine InOut 0.7 s, repeating both ways; Quad 0.12 s; Sine In 0.9 s | Fading in, breathing, the landing's flash and fading out |

Sounds: `Xp_Line` (also "+amount" popping up), `Xp_Tick`, `Level_Up`, `Frame_Unlock` (SoundsList), `Diamond_Burst`
as the diamonds burst out and `Diamond_Collect` for each landing diamond, its pitch climbing (`DIAMOND_TICK_CLIMB`). The weapon unlock: `Crate_GoldHit` (the diamond), `Crate_Shake`
(its charge), `Crate_Land` (the flash), `Reveal_Shiny` or `Variant_Golden` (the title) and `Button_Click` (the tap).

## Commands

`progression` (server, level 255):

| Subcommand | Arguments |
| --- | --- |
| `weapon_look` | `player`, `itemId` (any weapon or utility), `look` (`Golden`, `Shiny` or `None`, which takes the given look away). Tells the player "You got the Golden Bazooka!" |
| `golden_weapons` | `player`: the Golden look for every `WEAPON_REWARDS` weapon (Bazooka, Grenade, Shotgun) at once |
| `add_level` | `player`, `levels` (a whole number above 0). Queues the levels for the lobby's replay ("Levels added", the star tile), so their level-ups and weapon unlocks play back as after a match |
| `match_xp` | `player`, `levels` (a whole number, 0 or more). Plays a match's XP as after a round: takes the player up that many levels and 40% into the next, split into a match's lines (Match played, Victory, 3 knockouts), and queues the replay |
