--%%%%%%%%%%%%%%%%%%%% Params

--[[
	Formatting params for `RichText.Format`. Unset fields add no tag.
]]
--- @class RichText_Table
---
--- # Font #
---
--- @field Color string | Color3?
--- @field Size string | number?
--- @field Font_Face string?
--- @field Font_Family string?
--- @field Font_Weight string | number?
--- @field Transparency string | number?
---
--- # Stroke #
---
--- @field Stroke_Color string | Color3?
--- @field Stroke_Thickness string | number?
--- @field Stroke_Transparency string | number?
--- @field Stroke_Joins string?
--- @field Stroke_Sizing string?
---
--- # Mark #
---
--- @field Mark_Color string | Color3?
--- @field Mark_Transparency string | number?
---
--- # Style #
---
--- @field Bold boolean?
--- @field Italic boolean?
--- @field Underline boolean?
--- @field Strikethrough boolean?
--- @field Uppercase boolean?
--- @field Smallcaps boolean?
local _richText_Table = {}
