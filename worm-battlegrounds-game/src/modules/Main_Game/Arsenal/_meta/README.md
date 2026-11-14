# Arsenal

The weapon and utility rows: every number Combat and the guis read (damage, blast radius, knockback, uses, cooldown,
speeds and each kind's own fields), and the weapons' and utilities' models, cached at start on both sides.

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
| `Data/Weapons/<ItemId>.lua` | `Arsenal_WeaponData`: Bazooka, Grenade, Shotgun, Uzi, Golf Club (`BaseballBat`), Dynamite, Spartan Spear, Cluster Bomb, Spider Bomb, Minigun, Homing Missile, One Punch, Variety Grenade, Black Hole Grenade |
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
| `GetModel(itemId: string)` | `Model?` | The weapon's or utility's model (clone it), from `Assets/Arsenal/Models`; warns and returns nil when it has none |
| `HasModel(itemId: string)` | `boolean` | Whether the weapon or utility has a model, without a warning (the loadout bar shows the model when there's no icon) |
| `GetProjectileModel(shotId: string)` | `Model?` | What a shot flies as: its model in `Assets/Arsenal/Projectiles` (a weapon's, or a burst's shot like `Worm`), else `GetModel` |
| `HasProjectileModel(shotId: string)` | `boolean` | Whether a weapon or a burst's shot has a model of its own in `Projectiles` |
| `IsWeapon(itemId)` / `IsUtility(itemId)` | `boolean` | Which kind of row it is |

## Data

A weapon row: `Name`, `Icon`, `Kind` (Rocket, Bouncer, Crawler, Homing, Roller, Hitscan, Melee), `Aim` (Arc,
Straight, Melee, Target, Feet), `Wind`, `HoldPose` (the snail rig's pose for a gun: `Gun` for the Uzi, `MiniGun`,
`Bazooka` for the Bazooka and the Homing missile, `ShotGun`; a row without one is held in the `Gun` pose and plays no
shot, as `SnailRig`'s README says), `DamageMax`, `DamageEdge`, `BlastRadius`, `Knockback`, `Uses` (−1 unlimited),
`Cooldown` (turns), then the kind's fields (`MinSpeed`, `MaxSpeed`, `Fuse`, `Elasticity`, `Bomblets` (with `Mini`, drawn as small copies of the bomb: the cluster bomb's and the variety grenade's), `Snails`,
`Pellets`, `Spread`, `Range`, `CrawlTime`, `LockDelay`, `HoleTime`, `PullRadius`, `Reach`, `Lift`, …). `Retreat` (Dynamite) keeps
the turn going that many seconds after the weapon is placed, with the stamina bar full again, so the snail can run
before its `Fuse` runs out. A `Feet` weapon with no launch speed (Dynamite) is placed where the snail stands. A utility row: `Name`,
`Icon`, `Effect` (Heal, Jetpack, Speed, Parachute, LowGravity), `Amount`, `ShinyAmount`, `Uses`, and an optional
`Cooldown` (turns between uses, which starts at the first use: the Bandage 3, the Medkit 5). The numbers are the
wiki's Arsenal page.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `SHINY_DAMAGE_MULTIPLIER` | `1.05` | Extra damage from a shiny weapon |
| `KNOCKBACK` | None 0, Small 20, Medium 45, High 70, VeryHigh 95, Extreme 130 | Knockback speed by class (None: the blast doesn't throw, the black hole's) |
| `BURST_SHOTS` | `{ "Worm" }` | Shots a weapon's burst sends out (by projectile part name) that may have a model in `Projectiles` |

## In the place

Models are authored in `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/`, which the Utils module moves into
`ReplicatedStorage.Ume.Assets` (`I.Dirs.Assets`) when the game starts. In Studio they stand in rows left of the
maps, 8 studs apart from X −300 on Z = 0: weapons at Y 14, utilities at Y 7, `Projectiles` at Y 0, in the data's
order (where they stand doesn't matter to the game: every copy is moved to where it's used). Each is a Model named after its weapon or utility row (or, in `Projectiles`, a burst's shot from `BURST_SHOTS`), with
a `RootPart` (its PrimaryPart: anchored, hidden at start) the mesh parts are welded to; the meshes don't collide, query
or touch and are massless. The model faces +X from its RootPart, as snails do, and sits at the grip of a held weapon
or the centre of a thrown one. Each held model's RootPart has a `Muzzle` Attachment where its shot leaves it: the
barrel's tip for a gun (Bazooka, Shotgun, Uzi, HomingMissile), the front of a thrown weapon. A new held or thrown model gets one too. A held gun's RootPart also has a `Grip`
Attachment, where the snail rig's `Handle` holds it (the Handle's −Z is the barrel's way): Uzi, Minigun, Bazooka and
Shotgun from the studio's weapon snails (their weapon in hand, scaled to these meshes), the Homing missile's from the
Bazooka's, and the Golf club's (item id `BaseballBat`, kept so saved inventories still find it) turned so it points
ahead, its head hanging down. A model without one is held at its RootPart. The loadout bar shows an item's model in its box when it has no icon
picture; Combat's clients put a weapon's model in the active snail's hands and fly each shot as `GetProjectileModel`
(the Bazooka's rocket as the homing missile's missile until it has its own); Snails' clients put the Parachute and
Jetpack on a snail while they work (Snails' README → Gear).

| Instance | What |
| --- | --- |
| `Assets/Arsenal/Models/<WeaponId>` | Bazooka, Shotgun, Uzi, HomingMissile (the launcher), Minigun, BaseballBat: held, RootPart at the grip. Grenade, Dynamite, ClusterBomb, SpiderBomb, BlackHoleGrenade, VarietyGrenade, SpartanSpear: thrown, RootPart at the centre. BaseballBat is the golf club (the studio's `gfclub` mesh). The spear and the club carry a Trail (from the studio's effects) between `TrailBottom` and `TrailTip` attachments on their `Body` |
| `Assets/Arsenal/Models/<UtilityId>` | Jetpack, SpeedPotion, LowGravityPotion (the studio's `gravity_potion` mesh), Parachute, Bandage, Medkit: RootPart at the centre, no `Muzzle`. The Jetpack's straps face the RootPart's front (it's worn on the back); the Parachute's harness hangs at its bottom |
| `Assets/Arsenal/Projectiles/<ShotId>` | HomingMissile (the missile, nose along +X); Bazooka (the rocket, 2.2 studs long, nose along +X, a RootPart with the mesh welded on as `Body`, as HomingMissile); Snail (a Variety grenade's snail, its face on the RootPart's right side, which Combat turns to the camera); Dynamite (the placed stick, 4× the held one, RootPart half a stud above its bottom so it stands on the ground) |

Still without a model: One Punch, Low Gravity Potion, and the Cluster bomb's bomblets.
