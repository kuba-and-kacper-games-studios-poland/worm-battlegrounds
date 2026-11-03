--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Rarity"

--- @type Rarity_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Rarity Order ]]

--- @type { [string]: number }
local rarityIndexes = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._normalizeRarityWeights()
	Module._buildRarityIndexes()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Rarity = {

		--[[ Control ]]

		ApplyLook = Module.ApplyLook,

		--[[ Methods ]]

		GetRarities = Module.GetRarities,
		GetRarityIndex = Module.GetRarityIndex,
		GetRaritiesWeights = Module.GetRaritiesWeights,
		GetRarityWeight = Module.GetRarityWeight,
		GetRarityIcon = Module.GetRarityIcon,
		GetGradient = Module.GetGradient,
		GetGradientRotation = Module.GetGradientRotation,
		GetAddGradientMove = Module.GetAddGradientMove,
		GetLook = Module.GetLook,
		GetTier = Module.GetTier,

		GetChances = Module.GetChances,
		GetRandomWeighted = Module.GetRandomWeighted,
		GetRandomRarity = Module.GetRandomRarity,

		IsRarer = Module.IsRarer,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Normalize Rarity Weights

--[[
	Normalizes Min and Max weights of all rarities separately to total 1.
]]
function Module._normalizeRarityWeights()
	--[[ Getting Total Weights ]]

	local totalWeightMin: number = 0
	local totalWeightMax: number = 0

	--- @param range Rarity_WeightRange
	for _rarityName: string, range in pairs(_settings.RARITY_WEIGHTS) do
		totalWeightMin += range.Min
		totalWeightMax += range.Max
	end

	--[[ Normalizing ]]

	--- @param range Rarity_WeightRange
	for _rarityName: string, range in pairs(_settings.RARITY_WEIGHTS) do
		range.Min /= totalWeightMin
		range.Max /= totalWeightMax
	end
end

--%%%%%%%%%%%%%%%%%%%% Build Rarity Indexes

--[[
	Stores each rarity's position in `RARITY_NAMES`, from 1 for the most common.
]]
function Module._buildRarityIndexes()
	--[[ Saving ]]

	for index: number, rarityName: string in ipairs(_settings.RARITY_NAMES) do
		rarityIndexes[rarityName] = index
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply Look

--[[
	Writes a rarity on a label in its look (`RARITY_LOOKS`): its text, font, gradient and outline, and on `glow` (a
	copy of the label behind it) its base colour, shown only for rarities with a glow. The label needs a UIGradient
	and a UIStroke, the glow a UIStroke. An unknown rarity leaves them as they are.
]]
function Module.ApplyLook(label: TextLabel, glow: TextLabel?, rarityName: string)
	--[[ Data ]]

	local look = Module.GetLook(rarityName) --- @type Rarity_Look?

	--[[ Checks ]]

	-- Check if the rarity has a look (GetLook warned)
	if not look then
		return
	end

	--[[ Label ]]

	local gradient: UIGradient = label:FindFirstChildOfClass("UIGradient")
	local stroke: UIStroke = label:FindFirstChildOfClass("UIStroke")
	local keypoints = {} --- @type { ColorSequenceKeypoint }

	for index: number, color: Color3 in ipairs(look.Colors) do
		table.insert(keypoints, ColorSequenceKeypoint.new((index - 1) / math.max(#look.Colors - 1, 1), color))
	end

	label.Text = look.Text
	label.FontFace = look.Font
	gradient.Color = ColorSequence.new(keypoints)
	stroke.Color = look.Stroke

	--[[ Glow ]]

	-- Skip labels without a glow copy
	if not glow then
		return
	end

	local glowStroke: UIStroke = glow:FindFirstChildOfClass("UIStroke")
	glow.Text = look.Text
	glow.FontFace = look.Font
	glow.TextColor3 = look.Base
	glow.Visible = look.Glow
	glowStroke.Color = look.Base
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Rarities

--[[
	Returns copy of Rarity names table.
]]
--- @return { string }
function Module.GetRarities()
	return I.Table.DeepCopy(_settings.RARITY_NAMES)
end

--%%%%%%%%%%%%%%%%%%%% Get Rarity Index

--[[
	Returns the rarity's position in `RARITY_NAMES`; a higher index is rarer.
]]
--- @return number?
function Module.GetRarityIndex(rarityName: string)
	--[[ Checks ]]

	-- Check if the rarity exists
	if not rarityIndexes[rarityName] then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return rarityIndexes[rarityName]
end

--%%%%%%%%%%%%%%%%%%%% Get Rarities Weights

--[[
	Returns copy of Rarity weight ranges table.
]]
--- @return { [string]: Rarity_WeightRange }
function Module.GetRaritiesWeights()
	return I.Table.DeepCopy(_settings.RARITY_WEIGHTS)
end

--%%%%%%%%%%%%%%%%%%%% Get Rarity Weight

--[[
	Returns weight range for the given rarity name.
]]
--- @return Rarity_WeightRange?
function Module.GetRarityWeight(rarityName: string)
	--[[ Checks ]]

	--- @type Rarity_WeightRange?
	local range = _settings.RARITY_WEIGHTS[rarityName]
	if not range then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return range
end

--%%%%%%%%%%%%%%%%%%%% Get Rarity Icon

--[[
	Returns icon asset id for the given rarity name.
]]
--- @return string?
function Module.GetRarityIcon(rarityName: string)
	--[[ Checks ]]

	local icon: string? = _settings.RARITY_ICONS[rarityName]
	if not icon then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return icon
end

--%%%%%%%%%%%%%%%%%%%% Get Gradient

--[[
	Returns gradient style for the given rarity name.
]]
--- @return Rarity_GradientStyle?
function Module.GetGradient(rarityName: string)
	--[[ Checks ]]

	--- @type Rarity_GradientStyle?
	local style = _settings.RARITY_GRADIENTS[rarityName]
	if not style then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return style
end

--%%%%%%%%%%%%%%%%%%%% Get Gradient Rotation

--[[
	Returns UIGradient rotation for the given rarity name.
]]
--- @return number?
function Module.GetGradientRotation(rarityName: string)
	--[[ Checks ]]

	--- @type Rarity_GradientStyle?
	local style = _settings.RARITY_GRADIENTS[rarityName]
	if not style then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return style.Rotation
end

--%%%%%%%%%%%%%%%%%%%% Get Add Gradient Move

--[[
	Returns whether Utils_UIGradientMove should be added for the given rarity name.
]]
--- @return boolean
function Module.GetAddGradientMove(rarityName: string)
	--[[ Checks ]]

	--- @type Rarity_GradientStyle?
	local style = _settings.RARITY_GRADIENTS[rarityName]
	if not style then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) is missing!`)
		return false
	end

	--[[ Returning ]]

	return style.AddGradientMove == true
end

--%%%%%%%%%%%%%%%%%%%% Get Look

--[[
	Returns how the rarity is written on a label (`RARITY_LOOKS`).
]]
--- @return Rarity_Look?
function Module.GetLook(rarityName: string)
	--[[ Checks ]]

	-- Check if the rarity has a look
	if not _settings.RARITY_LOOKS[rarityName] then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) has no look!`)
		return nil
	end

	--[[ Returning ]]

	return _settings.RARITY_LOOKS[rarityName]
end

--%%%%%%%%%%%%%%%%%%%% Get Tier

--[[
	Returns a rarity's tier: its place in `RARITY_NAMES`, Common being 1.
]]
--- @return number?
function Module.GetTier(rarityName: string)
	--[[ Local Variables ]]

	local tier: number? = table.find(_settings.RARITY_NAMES, rarityName)

	--[[ Checks ]]

	-- Check if the rarity has a tier
	if not tier then
		warn(`[{_localName}::{script.Name}]: Rarity ({rarityName}) has no tier!`)
		return nil
	end

	--[[ Returning ]]

	return tier
end

--%%%%%%%%%%%%%%%%%%%% Get Chances

--[[
	Returns each name's chance (0-1) at that luck: the exact odds `GetRandomWeighted` rolls with.
	`names` and `weightTable` default to `RARITY_NAMES` and `RARITY_WEIGHTS`.
]]
--- @param names { string }?
--- @param weightTable { [string]: Rarity_WeightRange }?
--- @return { [string]: number }
function Module.GetChances(names, weightTable, luck: number?)
	return Module._computeChances(names or _settings.RARITY_NAMES, weightTable or _settings.RARITY_WEIGHTS, luck)
end

--%%%%%%%%%%%%%%%%%%%% Get Random Weighted

--[[
	Returns a random name. Luck (0-1000) lerps each weight from Min toward Max before rolling.
]]
--- @param names { string }
--- @param weightTable { [string]: Rarity_WeightRange }
--- @return string
function Module.GetRandomWeighted(names, weightTable, luck: number?)
	--[[ Checks ]]

	-- Check if there is anything to roll
	if #names == 0 then
		return names[1]
	end

	--[[ Chances ]]

	--- @type { [string]: number }
	local chances = Module._computeChances(names, weightTable, luck)

	--[[ Roll ]]

	local randomWeight: number = I.Random.Float(0, 1)

	for _, name: string in ipairs(names) do
		local weight: number? = chances[name]

		-- Skip names without a chance
		if weight == nil then
			continue
		end

		-- Pick this name when the roll falls inside its chance
		if weight >= randomWeight then
			return name
		else
			randomWeight -= weight
		end
	end

	--[[ Returning ]]

	return names[1]
end

--%%%%%%%%%%%%%%%%%%%% Get Random Rarity

--[[
	Returns a random rarity. Luck (0-1000) lerps each weight from Min toward Max before rolling.
]]
--- @return string
function Module.GetRandomRarity(luck: number?)
	return Module.GetRandomWeighted(_settings.RARITY_NAMES, _settings.RARITY_WEIGHTS, luck)
end

--%%%%%%%%%%%%%%%%%%%% Is Rarer

--[[
	Returns whether `rarityA` comes after `rarityB` in `RARITY_NAMES`. An unknown rarity warns and returns false.
]]
--- @return boolean
function Module.IsRarer(rarityA: string, rarityB: string)
	--[[ Data ]]

	local indexA: number? = Module.GetRarityIndex(rarityA)
	local indexB: number? = Module.GetRarityIndex(rarityB)

	--[[ Checks ]]

	-- Check if both rarities exist
	if not indexA or not indexB then
		return false
	end

	--[[ Returning ]]

	return indexA > indexB
end

--%%%%%%%%%%%%%%%%%%%% Compute Chances

--[[
	Lerps each name's weight from Min toward Max by luck (0-1000), then normalises the weights to total 1.
	Names without a weight range are left out; the result is empty when the weights total 0.
]]
--- @param names { string }
--- @param weightTable { [string]: Rarity_WeightRange }
--- @return { [string]: number }
function Module._computeChances(names, weightTable, luck: number?)
	--[[ Lerp Weights ]]

	local t: number = math.clamp((luck or 0) / 1000, 0, 1)
	local chances = {} --- @type { [string]: number }
	local totalWeight: number = 0

	for _, name: string in ipairs(names) do
		--- @type Rarity_WeightRange?
		local range = weightTable[name]

		-- Skip names without a weight range
		if range == nil then
			continue
		end

		local weight: number = range.Min + (range.Max - range.Min) * t
		chances[name] = weight
		totalWeight += weight
	end

	--[[ Checks ]]

	-- Return no chances when the weights total 0
	if totalWeight <= 0 then
		return {}
	end

	--[[ Normalize ]]

	for name: string, weight: number in pairs(chances) do
		chances[name] = weight / totalWeight
	end

	--[[ Returning ]]

	return chances
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
