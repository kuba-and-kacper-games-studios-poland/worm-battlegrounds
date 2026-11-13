--%%%%%%%%%%%%%%%%%%%% Brain

--- @class Bots_Genome
---
--- # Shots #
---
--- @field EnemyDamage number
--- @field Knockout number
--- @field Focus number
--- @field Grudge number
--- @field Pressure number
---
--- # Care #
---
--- @field AllyDamage number
--- @field AllyKnockout number
--- @field SelfDamage number
--- @field SelfKnockout number
--- @field Ammo number
---
--- # Position #
---
--- @field Walk number
--- @field Jetpack number
--- @field Edge number
--- @field Footing number
--- @field Low number
--- @field Height number
--- @field Cover number
--- @field Exposure number
--- @field Crowd number
--- @field Threat number
---
--- # Utilities #
---
--- @field HealBelow number
local _bots_Genome = {}

--- @class Bots_Skill
---
--- # Hand #
---
--- @field AimNoise number
--- @field PowerNoise number
--- @field WindRead number
--- @field Ranging number
--- @field RangingMin number
---
--- # Thinking #
---
--- @field Spots number
--- @field Targets number
--- @field Finalists number
--- @field AimPoints number
--- @field MapSense number
--- @field Choice number
--- @field AirShots number
--- @field Hunt number
local _bots_Skill = {}

--%%%%%%%%%%%%%%%%%%%% View

--- @class Bots_Snail
---
--- # General #
---
--- @field Id string
--- @field Model Model
--- @field Team number
--- @field IsBot boolean
---
--- # State #
---
--- @field Position Vector3
--- @field Health number
local _bots_Snail = {}

--- @class Bots_View
---
--- # General #
---
--- @field Self Bots_Snail
--- @field Snails { Bots_Snail }
---
--- # Turn #
---
--- @field Wind number
--- @field Round number
--- @field Stamina number
--- @field Uses { [string]: number }
--- @field LastAttacker string?
local _bots_View = {}

--- @class Bots_Spot
---
--- # General #
---
--- @field Position Vector3
--- @field Walk number
--- @field Fly boolean
--- @field Air boolean
--- @field Cruise number?
---
--- # Features #
---
--- @field Edge number
--- @field Footing number
--- @field Low number
--- @field Cover number
--- @field Pond number
--- @field Height number
--- @field Exposure number
--- @field Crowd number
--- @field Threat number
local _bots_Spot = {}

--%%%%%%%%%%%%%%%%%%%% Plans

--- @class Bots_Plan
---
--- # General #
---
--- @field ItemId string
--- @field TargetId string
--- @field Spot Bots_Spot
---
--- # Aim #
---
--- @field Angle number
--- @field Power number
--- @field Target Vector3?
---
--- # Result #
---
--- @field Score number
--- @field Outcome Bots_Outcome
local _bots_Plan = {}

--- @class Bots_Blast
---
--- # General #
---
--- @field Center Vector3
--- @field Radius number
---
--- # Damage #
---
--- @field DamageMax number
--- @field DamageEdge number
--- @field Knockback string
local _bots_Blast = {}

--- @class Bots_Strike
---
--- # General #
---
--- @field Id string
--- @field Damage number
--- @field Velocity Vector3
local _bots_Strike = {}

--- @class Bots_Shot
---
--- # Where #
---
--- @field Landed Vector3
--- @field Blasts { Bots_Blast }
--- @field Strikes { Bots_Strike }
local _bots_Shot = {}

--- @class Bots_Effect
---
--- # General #
---
--- @field Id string
--- @field Damage number
---
--- # Thrown #
---
--- @field Position Vector3
--- @field Out boolean
local _bots_Effect = {}

--- @class Bots_Outcome
---
--- # Shot #
---
--- @field Shot Bots_Shot
--- @field Effects { [string]: Bots_Effect }
local _bots_Outcome = {}

--%%%%%%%%%%%%%%%%%%%% Memory

--- @class Bots_Ranging
---
--- # General #
---
--- @field TargetId string
--- @field From Vector3
--- @field Shots number
local _bots_Ranging = {}

--%%%%%%%%%%%%%%%%%%%% Training

--- @class Bots_TrainOptions
---
--- # General #
---
--- @field Difficulty string
--- @field Seed number
---
--- # Genomes #
---
--- @field Start Bots_Genome?
--- @field Baseline Bots_Genome?
---
--- # Evolution #
---
--- @field Generations number
--- @field Population number
--- @field MatchesPerGeneration number
--- @field ExamMatches number
--- @field Elites number
--- @field MutationRate number
--- @field MutationSize number
---
--- # Matches #
---
--- @field MaxRounds number
--- @field Maps { string }?
--- @field Log boolean
local _bots_TrainOptions = {}

--- @class Bots_Seat
---
--- # General #
---
--- @field Id string
--- @field Team number
--- @field Genome Bots_Genome
--- @field Skill Bots_Skill
--- @field Loadout { string }
---
--- # State #
---
--- @field Model Model
--- @field Health number
--- @field Uses { [string]: number }
--- @field Cooldowns { [string]: number }
--- @field LastAttacker string?
--- @field Ranging Bots_Ranging?
--- @field Out boolean
---
--- # Result #
---
--- @field OutTurn number
--- @field Dealt number
--- @field Friendly number
local _bots_Seat = {}

--- @class Bots_Stats
---
--- # Matches #
---
--- @field Matches number
--- @field Turns number
---
--- # Shots #
---
--- @field Shots number
--- @field Hits number
--- @field Friendly number
--- @field Damage number
--- @field Knockouts number
--- @field Thrown number
--- @field Weapons { [string]: number }
---
--- # Utilities #
---
--- @field Moves number
--- @field Jetpacks number
--- @field Air number
--- @field Heals number
local _bots_Stats = {}
