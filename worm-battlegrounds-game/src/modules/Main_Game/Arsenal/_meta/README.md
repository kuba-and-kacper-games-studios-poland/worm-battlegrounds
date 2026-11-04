# Arsenal

The weapon and utility rows: every number Combat and the guis read (damage, blast radius, knockback, uses, cooldown,
speeds and each kind's own fields). It's data only, on both sides.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Arsenal` |
| Runs on | Global · both maps |
| Exposes | `I.G_Arsenal` (both) |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Loads the rows; damage by distance and knockback lookups |
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
