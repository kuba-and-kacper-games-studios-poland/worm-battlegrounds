# Arsenal

The weapon and utility rows: every number Combat and the guis read (damage, blast radius, knockback, uses, cooldown,
speeds and each kind's own fields), and the weapons' models, cached at start on both sides.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Arsenal` |
| Runs on | Global · both maps |
| Exposes | `I.G_Arsenal` (both) |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Loads the rows and caches the models; damage by distance, knockback and model lookups |
| `Settings.lua` | `Arsenal_Settings` |
| `Data/Weapons/<ItemId>.lua` | `Arsenal_WeaponData`: Bazooka, Grenade, Shotgun, Uzi, Baseball Bat, Dynamite, Spartan Spear, Cluster Bomb, Spider Bomb, Minigun, Homing Missile, One Punch, Variety Grenade, Black Hole Grenade |
| `Data/Utilities/<ItemId>.lua` | `Arsenal_UtilityData`: Bandage, Medkit, Jetpack, Speed Potion, Parachute, Low Gravity Potion |
| `_meta/_types.lua` | The row classes |

## API

### Global: `I.G_Arsenal`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(itemId: string)` | row or nil | A weapon's or utility's row; warns when missing |
| `GetAll()` | `{ [string]: row }` | Every row |
| `GetDamage(itemId: string, distance: number, isShiny: boolean?)` | `number` | Damage at a distance from the blast's centre, from `DamageMax` to `DamageEdge`; shiny items ×`SHINY_DAMAGE_MULTIPLIER` |
| `GetKnockback(class: string)` | `number` | Knockback speed for a class name |
| `GetModel(itemId: string)` | `Model?` | The weapon's model (clone it), from `Assets/Arsenal/Models`; warns and returns nil when it has none |
| `HasModel(itemId: string)` | `boolean` | Whether the weapon has a model, without a warning (the loadout bar shows the model when there's no icon) |
| `GetProjectileModel(itemId: string)` | `Model?` | What its shot flies as: its model in `Assets/Arsenal/Projectiles`, else `GetModel` |
| `IsWeapon(itemId)` / `IsUtility(itemId)` | `boolean` | Which kind of row it is |

## Data

A weapon row: `Name`, `Icon`, `Kind` (Rocket, Bouncer, Crawler, Homing, Roller, Hitscan, Melee), `Aim` (Arc,
Straight, Melee, Target, Feet), `Wind`, `DamageMax`, `DamageEdge`, `BlastRadius`, `Knockback`, `Uses` (−1 unlimited),
`Cooldown` (turns), then the kind's fields (`MinSpeed`, `MaxSpeed`, `Fuse`, `Elasticity`, `Bomblets`, `Snails`,
`Pellets`, `Spread`, `Range`, `CrawlTime`, `LockDelay`, `RollSpeed`, `Reach`, `Lift`, …). A utility row: `Name`,
`Icon`, `Effect` (Heal, Jetpack, Speed, Parachute, LowGravity), `Amount`, `ShinyAmount`, `Uses`. The numbers are the
wiki's Arsenal page.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `SHINY_DAMAGE_MULTIPLIER` | `1.05` | Extra damage from a shiny weapon |
| `KNOCKBACK` | Small 20, Medium 45, High 70, VeryHigh 95, Extreme 130 | Knockback speed by class |

## In the place

Models are authored in `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/`, which the Utils module moves into
`ReplicatedStorage.Ume.Assets` (`I.Dirs.Assets`) when the game starts. Each is a Model named after its weapon row, with
a `RootPart` (its PrimaryPart: anchored, hidden at start) the mesh parts are welded to; the meshes don't collide, query
or touch and are massless. The model faces +X from its RootPart, as worms do, and sits at the grip of a held weapon
or the centre of a thrown one. The loadout bar shows a weapon's model in its box when the weapon has no icon picture; Combat's clients
put it in the active worm's hands and fly each shot as `GetProjectileModel` (the Bazooka's rocket as the homing
missile's missile until it has its own).

| Instance | What |
| --- | --- |
| `Assets/Arsenal/Models/<WeaponId>` | Bazooka, Shotgun, Uzi, HomingMissile (the launcher): held, RootPart at the grip. Grenade, Dynamite, ClusterBomb, SpiderBomb, BlackHoleGrenade: thrown, RootPart at the centre |
| `Assets/Arsenal/Projectiles/<WeaponId>` | HomingMissile (the missile, nose along +X) |

Still without a model: Baseball Bat, Minigun, One Punch, Spartan Spear, Variety Grenade.
