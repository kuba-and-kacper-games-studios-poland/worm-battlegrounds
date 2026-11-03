--- @alias Scaling_ScalarKind "FishDepth" | "PlayerDepth"
--- @alias Scaling_ValueInput number | string | ((context: Scaling_Context) -> (number | string))
--- @alias Scaling_RoundingType "None" | "Floor" | "Ceil" | "Round"

--- @class Scaling_Context
--- @field Level number?
--- @field Rarity string?
--- @field Difficulty number?
--- @field Depth string?
--- @field Size string?
--- @field Mutation string?
local _scaling_Context = {}

--- @class Scaling_ScalarDefinition
--- @field Input string?
--- @field Kind Scaling_ScalarKind?
--- @field Values { [string]: number }?
--- @field Value Scaling_ValueInput?
--- @field Default number?
local _scaling_ScalarDefinition = {}

--- @class Scaling_PieceDefinition
--- @field At number
--- @field Value Scaling_ValueInput
local _scaling_PieceDefinition = {}

--- @class Scaling_BandDefinition
--- @field FirstLevel number
--- @field Base Scaling_ValueInput
local _scaling_BandDefinition = {}

--- @class Scaling_ValueDefinition
---
--- # Curve #
---
--- @field Curve string | ((context: Scaling_Context) -> (number | string))
---
--- # Formula #
---
--- @field Input string?
--- @field Base Scaling_ValueInput?
--- @field Growth Scaling_ValueInput?
--- @field Exponent Scaling_ValueInput?
--- @field Add Scaling_ValueInput?
--- @field Mul Scaling_ValueInput?
--- @field Scalars { [string]: Scaling_ScalarDefinition | Scaling_ValueInput }?
---
--- # Bounds #
---
--- @field Min Scaling_ValueInput?
--- @field Max Scaling_ValueInput?
--- @field SoftCap Scaling_ValueInput?
--- @field SoftCapPower Scaling_ValueInput?
---
--- # Segments #
---
--- @field Pieces { Scaling_PieceDefinition }?
--- @field Bands { Scaling_BandDefinition }?
---
--- # Output #
---
--- @field Precision number?
--- @field Round Scaling_RoundingType?
local _scaling_ValueDefinition = {}

--- @class Scaling_Result
---
--- # Output #
---
--- @field Value string
--- @field RawValue string
--- @field Curve string
---
--- # Input #
---
--- @field InputValue number
---
--- # Calculated Values #
---
--- @field BaseValue number | string
--- @field GrowthValue number | string
--- @field ExponentValue number | string
--- @field AddValue number | string
--- @field MultiplierValue number | string
--- @field ScalarValue number | string
---
--- # Formatting #
---
--- @field Precision number
--- @field Round Scaling_RoundingType
---
--- # Context #
---
--- @field Context Scaling_Context
--- @field Definition Scaling_ValueDefinition
local _scaling_Result = {}
