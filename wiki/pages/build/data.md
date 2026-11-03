---
title: "Data & networking"
summary: "What Worm Battlegrounds saves for each player, the data rows for weapons, crates, skins, emotes and maps, the global data, and every remote, Topic and replicated value."
icon: tag
status: active
order: 5
type: "Plan"
tags: [build]
suggestions:
  - id: weapon-sheet
    text: "Worm Battlegrounds' weapon and utility numbers (damage, blast radius, knockback, uses, cooldowns) live in Lua data files in the Arsenal module. Put them in a wiki data sheet the team can tune in the app, exported straight into those Lua files when the owner asks, so tuning after playtests needs no code edits?"
    options: [Yes, Later, No]
  - id: data-version
    text: "Worm Battlegrounds saves loadouts, cosmetics and tutorial progress in each player's profile. Add a profile data version number from the first release, so a later change to a saved key (like renaming an item id) can be fixed for every old profile in one place when it loads?"
    options: [Yes, No]
---

The data side of [[Match modules]] and [[Lobby & meta modules]]. Numbers players see stay on the game pages
([[Arsenal]], [[Currencies & crates]], [[Levels & XP]], [[Emotes]]); this page says where each one goes in code.
ume's rules apply: the profile template in each module's entry script is the only shape of saved data (no classes for
it), amounts are integer strings with `I.BN` math, and data rows live in `<Module>/Data/` with their shape in
`_meta/_types.lua`.

## Saved for each player

One ProfileStore profile, shared by both maps. Each module adds its key to `I.Player.ProfileTemplate` in its `Init`.

| Key | Owner | Shape | Notes |
|---|---|---|---|
| `Currency.Currencies.Coins`, `.Diamonds` | `2_Currency` | `{ Amount, TotalEarned, TotalSpent, HighestOwned }` | Existing module, new currencies |
| `Inventory.Standard[itemId]` | `1_Inventory` | Copies owned, an integer string | Weapons, utilities, skins, emotes. 10 copies = shiny |
| `Statistic.Standard` | ume's Statistic | `XP`, `MatchesPlayed`, `Wins`, `Knockouts`, `DamageDealt`, `Playtime` | Rows in `src/global_data/Statistic/Statistic.lua` |
| `Loadout` | `Loadout` | `{ Slots = { itemId or "" ×5 }, CoinSlots = { [4] = false, [5] = false } }` | New players: all empty |
| `Cosmetics` | `Cosmetics` | `{ EquippedSkin = "Skin_Classic" }` | |
| `Tutorial` | `Tutorial` | `{ MatchDone = false, CrateOpened = false, Done = false }` | |
| `Match` | `Match` | `{ Rejoin = false or { PlaceId, AccessCode, Until } }` | Written by a match server when a player drops; read and cleared by the lobby |
| `Shop` | `Shop` | `{ VipCrateDay = 0 }` | UTC day number of the last free VIP crate |
| `Settings` | `Settings` (existing) | Volumes and switches | Adds `DamageNumbers`, `CameraFollowsShot` |
| `Marketplace` | ume's Marketplace | Claimed rewards, receipts, purchase log | Existing |

## Item ids

Every weapon, utility, skin and emote is an Inventory item (`Data/Items/<Category>/<Id>.lua`: `Name`, `IconId`,
`Rarity`, `Category`). Ids are PascalCase, unique, never renamed once players own them.

| Category | Ids |
|---|---|
| `Weapon` | `Grenade`, `Shotgun`, `Uzi`, `SpiderBomb`, `ClusterBomb`, `Dynamite`, `BaseballBat`, `HomingMissile`, `BlackHoleGrenade`, `VarietyGrenade`, `Minigun`, `OnePunch`, `SpartanSpear` (the `Bazooka` is an Arsenal row only: always owned, never in the inventory) |
| `Utility` | `Jetpack`, `SpeedPotion`, `Parachute`, `Bandage`, `Medkit`, `LowGravityPotion` |
| `Skin` | `Skin_Classic`, `Skin_Soldier`, `Skin_Pirate`, `Skin_Cowboy`, `Skin_Ninja`, `Skin_Knight`, `Skin_Clown`, `Skin_Robot`, `Skin_Devil`, `Skin_Skeleton`, `Skin_Prisoner`, `Skin_FbiAgent`, `Skin_Wizard`, `Skin_Vip` |
| `Emote` | `Emote_Wave`, `Emote_ThumbsUp`, `Emote_Laugh`, `Emote_Dance`, `Emote_Flex`, `Emote_Taunt`, `Emote_Cry`, `Emote_Backflip`, `Emote_VictoryTrumpet` |

New profiles own `Skin_Classic` and `Emote_Wave` (granted on first join; owned forever).

## Arsenal rows

`Arsenal/Data/Weapons/<ItemId>.lua` and `Data/Utilities/<ItemId>.lua`, typed `Arsenal_WeaponData` /
`Arsenal_UtilityData`. Damage, blast radius, uses and cooldowns are the numbers on [[Arsenal]]; this table says how
each weapon is coded.

| Field | What |
|---|---|
| `Kind` | The behavior: `Rocket`, `Bouncer`, `Crawler`, `Homing`, `Roller`, `Hitscan`, `Melee` ([[Match modules#Combat]]) |
| `Aim` | `Arc`, `Straight`, `Melee`, `Target`, `Feet` (how `MatchHud` aims it) |
| `Wind` | Whether wind pushes it |
| `DamageMax`, `DamageEdge`, `BlastRadius`, `Knockback` | Blast damage from center to edge, radius in studs, a knockback class |
| `Uses`, `Cooldown` | Per match (`-1` unlimited), cooldown in own turns |
| `MinSpeed`, `MaxSpeed` | Launch speed at power 0 and 1 |
| Kind extras | `Fuse` (Grenade 3), `Elasticity`, `Pellets` / `Bullets`, `Spread`, `BurstInterval`, `PerBulletDamage`, `Bomblets` (5 × 15, radius 3), `Snails` (4, 8 hits × 5, radius 2), `CrawlTime` (5), `LockDelay` (1), `MaxRollTime`, `ModelName` |

| Weapon | Kind | Aim | Wind | Knockback |
|---|---|---|---|---|
| Bazooka | Rocket | Arc | yes | Medium |
| Grenade | Bouncer (3 s fuse) | Arc | no | Medium |
| Shotgun | Hitscan (5 pellets) | Straight | no | Small |
| Uzi | Hitscan (5-bullet burst) | Straight | no | Small each |
| Spider bomb | Crawler | Arc | no | Medium |
| Cluster bomb | Bouncer (bursts on contact, 5 bomblets) | Arc | yes | Medium |
| Dynamite | Bouncer (bursts on contact) | Arc | no | High |
| Baseball bat | Melee | Melee | no | VeryHigh |
| Homing missile | Homing | Target | until it locks | Medium |
| Black hole grenade | Roller | Feet | no | High |
| Variety grenade | Bouncer, then 4 snails | Arc | no | Medium, snails Small |
| Minigun | Hitscan (20-bullet burst) | Straight | no | Small each |
| One Punch | Melee | Melee | no | Extreme |
| Spartan spear | Rocket (pierces) | Arc | yes | Medium |

Utility rows: `Effect` (`Heal`, `Jetpack`, `Speed`, `Parachute`, `LowGravity`), `Amount` (heal), `ShinyAmount` (the
shiny boosts on [[Currencies & crates#Duplicates and shiny items]]), `Uses`.

`Arsenal/Settings.lua`: `KNOCKBACK` (class → impulse speed: Small 20, Medium 45, High 70, VeryHigh 95, Extreme 130, a
first proposal to tune), `SHINY_DAMAGE_MULTIPLIER` 1.05 (whether shiny keeps a boost is still asked on
[[Currencies & crates]]; set it to 1 if not).

## Crates

`Crates/Data/Crates/<CrateId>.lua`, typed `Crates_CrateData`: `Name`, `Prices` (`{ Coins = { One = "100", Ten =
"900" }, Diamonds = … }`), `Odds` (`{ [itemId] = percent }`, adding up to 100), `Fixed` (a list of items always given:
the tutorial crate), `PaidRandom` (true for the diamond prices: hidden where restricted), `Hidden` (not on the panel:
the tutorial crate).

| Crate id | Prices | Odds |
|---|---|---|
| `Weapon` | 100 coins, 10 for 900 | The weapon crate column on [[Currencies & crates#Drop chances]] |
| `Premium` | 250 diamonds, 10 for 2,250 | The premium crate column |
| `Utility` | 100 coins (900), or 200 diamonds (1,800) | The two utility columns: one odds table per currency (`OddsByCurrency`) |
| `Skin` | 100 coins (900), or 50 diamonds (450) | The skin table, the same for both currencies |
| `Tutorial` | 100 coins | Fixed: `Grenade` and `Shotgun` |

## Skins, emotes and maps

| Rows | Fields |
|---|---|
| `Cosmetics/Data/Skins/<SkinId>.lua` | `Model` (name in `Assets.Skins`), `Source` (`Start`, `Crate`, `Level`, `Vip`), `Animations` (`Idle`, `Walk`, `Jump`, `Fall`, `Aim`, `Hurt` asset ids), `VoiceSet` (sound names) |
| `Cosmetics/Data/Emotes/<EmoteId>.lua` | `Level` (0 = none), `Coins` ("0" for Wave), `AnimationId`, `VoiceSound` |
| `Arena/Data/Maps/<MapId>.lua` | `Name`, `Theme`, `Sizes` (`{ 2, 4, 6 }` or `{ 8 }`), `Thumbnail`, `Backdrop`, `LightingPreset`, `Music`, `Liquid` (`Water`, `Lava` or none) |

Map ids: `RockslideRidge`, `PicnicPlains`, `FluffyFallout`, `LakesideShowdown`, `MoltenSpires`, `TheBigMashup`.

## Global data

| File | Rows |
|---|---|
| `Statistic/Statistic.lua` | `XP` (ClientUpdate), `MatchesPlayed`, `Wins`, `Knockouts`, `DamageDealt` |
| `Marketplace/Products.lua` | `Diamonds_Handful` 250, `Diamonds_Pouch` 500, `Diamonds_Bag` 1,000, `Diamonds_Chest` 1,500, `Diamonds_Vault` 2,500: each `Reward` adds its diamonds and returns `"Diamonds: 250"`. Ids from the Creator Hub |
| `Marketplace/GamePasses.lua` | `Slot4`, `Slot5`, `DoubleCoins`, `VIP` (`SingleReward`: `Skin_Vip`). Ids from the Creator Hub |
| `Sound/SoundsList.lua` | `Explosion_Small`, `Explosion_Medium`, `Explosion_Big`, `BlackHole`, `Splash`, `Sizzle`, `Bounce`, `Shot_Shotgun`, `Shot_Uzi`, `Shot_Minigun`, `Hit_Bat`, `Hit_Punch`, `Spear_Throw`, `Jetpack_Loop`, `Drink`, `Heal`, `Parachute_Open`, `Turn_Start`, `Timer_Tick`, `Crate_Shake`, `Crate_Reveal`, `Coin`, `LevelUp`, `Music_Lobby`, `Music_Match`, worm voice lines (`Voice_Hurt`, `Voice_Taunt`, `Voice_Victory`, one per emote). Uploaded as `.ogg` after PrepKit |
| `Haptic/Preset.lua` | `Explosion_Near`, `Hit_Self` |
| `Lighting` | Presets in the place: `Rocky`, `Grass`, `Clouds`, `Lake`, `Lava`, `Mashup` |

## Remotes

Every remote, by the module that owns it (only the owner calls `Get*`; server inbound schemas start with
`"Player"`). Rate limits are per player.

| Remote | Kind | Direction | Payload | Limit |
|---|---|---|---|---|
| `Match_PickDrop` | Event | client → server | `x: number` | 10/s |
| `Match_Leave` | Event | client → server | — | 1/s |
| `Match_Rematch` | Event | client → server | `vote: boolean` | 2/s |
| `Match_KnockedOut` | Event | server → all | `victimId, cause, killerId?, itemId?` | |
| `Match_Results` | Event | server → player | the player's results table | |
| `Combat_Select` | Event | client → server | `itemId: string` | 10/s |
| `Combat_Fire` | Event | client → server | `itemId: string, angle: number, power: number (0–1), target: Vector3?` | 2/s |
| `Combat_UseUtility` | Event | client → server | `itemId: string` | 2/s |
| `Combat_Detonate` | Event | client → server | — | 2/s |
| `Combat_Aim` | Unreliable | client → server | `angle: number, power: number` | 15/s |
| `Combat_Explosion` | Event | server → all | `position, radius, itemId, shiny` | |
| `Combat_Hit` | Event | server → all | `victimId, damage, position` | |
| `Combat_Tracer` | Event | server → all | `itemId, from, hits: { Vector3 }` | |
| `Cosmetics_Equip` | Event | client → server | `skinId: string` | 2/s |
| `Cosmetics_BuyEmote` | Function | client → server | `emoteId: string` → `boolean` | 2/s |
| `Cosmetics_PlayEmote` | Event | client → server | `emoteId: string` | 1/s |
| `Cosmetics_EmotePlayed` | Event | server → all | `userId, emoteId` | |
| `Loadout_Set` | Event | client → server | `slot: number (1–5), itemId: string?` | 5/s |
| `Loadout_UnlockSlot` | Function | client → server | `slot: number (4–5)` → `boolean` | 1/s |
| `Crates_Open` | Function | client → server | `crateId: string, count: number (1 or 10), payWith: string` → results | 1/s |
| `MatchBoard_Join` | Event | client → server | `rowId: string` | 2/s |
| `MatchBoard_Leave` | Event | client → server | — | 2/s |
| `MatchBoard_Vote` | Event | client → server | — | 2/s |
| `MatchBoard_PlaySolo` | Event | client → server | `difficulty: string` | 1/s |
| `MatchBoard_CreateCustom` | Event | client → server | `mapId: string, mode: string, size: number` | 1/s |
| `MatchBoard_InviteCustom` | Event | client → server | `target: Player` | 2/s |
| `MatchBoard_InviteAnswer` | Event | client → server | `roomId: string, accept: boolean` | 2/s |
| `MatchBoard_StartCustom`, `MatchBoard_LeaveCustom` | Event | client → server | — | 1/s |
| `MatchBoard_Invited` | Event | server → player | `fromUserId, roomId` | |
| `Party_Invite`, `Party_Kick` | Event | client → server | `target: Player` | 2/s |
| `Party_Answer` | Event | client → server | `fromUserId: number, accept: boolean` | 2/s |
| `Party_Leave` | Event | client → server | — | 1/s |
| `Party_Invited` | Event | server → player | `fromUserId` | |
| `Lobby_RejoinOffer` | Event | server → player | `secondsLeft` | |
| `Lobby_Rejoin` | Event | client → server | `accept: boolean` | 1/s |
| `Tutorial_Step` | Event | client → server | `step: string` | 5/s |

Purchases use ume's Marketplace remotes (`Marketplace_PromptProductPurchase`, `Marketplace_PromptGamePassPurchase`);
settings use the Settings module's own.

## Topics

Server Topics other modules subscribe to (each registered by its owner in `Init`):

| Topic | Payload |
|---|---|
| `Match_PhaseChanged` | `phase` |
| `Match_TurnStarted`, `Match_TurnEnded` | `participantId` |
| `Match_ParticipantOut` | `participantId, cause, killerId?, itemId?` |
| `Match_Ended` | `placements, stats, metadata` |
| `Combat_ShotFired` | `participantId, itemId` |
| `Combat_ShotResolved` | `participantId, damageDealt` |
| `Worms_Died` | `participantId, cause, killerId?, itemId?` |
| `Progression_LevelUp` | `player, level` |
| `Crates_Opened` | `player, crateId, results` |

Client Topics: `Match_PhaseChanged`, `Match_TurnStarted`, `Match_MyTurn`, republished by `Match`'s client from the
`Workspace.Ume.Match` attributes.

## Replicated values

| Where | Values |
|---|---|
| `Workspace.Ume.Match` attributes | `Phase`, `Round`, `ActiveId`, `TurnEndsAt`, `Wind`, `SuddenDeath`, `Kind`, `Mode`, `MapId`, `RematchEndsAt`, `RematchVotes` |
| `Workspace.Ume.Arena` attributes | `LiquidLevel`, `LiquidKind` |
| Worm model attributes | `ParticipantId`, `UserId`, `DisplayName`, `Team`, `Color`, `Health`, `MaxHealth`, `Alive`, `Ghost`, `IsBot`, `Facing`, `HeldItem`, `AimAngle`, `Shiny`, `Vip`, `DropX` |
| `Player` attributes | `PartyId`, `PartyLeader`, `Level`, `Vip` |
| Replicator `Match` | `Stamina`, `Uses_<ItemId>`, `Cooldown_<ItemId>` |
| Replicator `Loadout` | `Slot1`…`Slot5`, `Unlocked` |
| Replicator `Progression` | `Level`, `XPIntoLevel`, `XPForLevel` |
| `ReplicatedStorage.Ume.MatchBoard/<RowId>` | The row attributes on [[Lobby & meta modules#MatchBoard]] |

::navbox{from="build"}
