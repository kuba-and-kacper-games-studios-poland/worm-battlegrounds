--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The frame gradients that shine or spin, by gradient: the tier they show (weak, so a destroyed gui drops out)
local animated = setmetatable({}, { __mode = "k" }) --- @type { [UIGradient]: Progression_Tier }

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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Progression = {

		--[[ Control ]]

		ApplyFrame = Module.ApplyFrame,

		--[[ Methods ]]

		GetTier = Module.GetTier,
		GetNextUnlock = Module.GetNextUnlock,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Frames are drawn by each screen
	if I.Env.IsServer then
		return
	end
	I.S.RunService.RenderStepped:Connect(Module._animate)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply Frame

--[[
	Paints a frame (a UIGradient on a stroke or a fill) in the prestige tier of a level, and keeps a tier that shines
	or spins moving while it's shown.
]]
function Module.ApplyFrame(gradient: UIGradient, level: number)
	--[[ Local Variables ]]

	local tier = Module.GetTier(level) --- @type Progression_Tier

	--[[ Applying ]]

	gradient.Color = Module._getSequence(tier.Colors, nil)
	gradient.Offset = Vector2.zero
	animated[gradient] = if tier.Shine or tier.Spin then tier else nil
end

--%%%%%%%%%%%%%%%%%%%% Animate

--[[
	Moves every shown shining or spinning frame one frame on: a light band sweeping across it every so often, a
	Mythic frame's colours turning round.
]]
function Module._animate(deltaTime: number)
	--[[ Local Variables ]]

	local now: number = os.clock()
	local cycle: number = _settings.FRAME_SHINE_SECONDS + _settings.FRAME_SHINE_PAUSE

	--[[ Animating ]]

	--- @param tier Progression_Tier
	for gradient: UIGradient, tier in pairs(animated) do
		-- Skip a frame nobody sees
		if not gradient.Parent or not I.Utils.IsGuiShown(gradient.Parent) then
			continue
		end

		local sweep: number = (now % cycle) / _settings.FRAME_SHINE_SECONDS
		gradient.Color = Module._getSequence(tier.Colors, if tier.Shine and sweep <= 1 then sweep else nil)
		if tier.Spin then
			gradient.Rotation = (gradient.Rotation + _settings.FRAME_SPIN_SPEED * deltaTime) % 360
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Tier

--[[
	Returns the highest prestige tier a level has unlocked (FRAME_TIERS).
]]
--- @return Progression_Tier
function Module.GetTier(level: number)
	--[[ Local Variables ]]

	local best = _settings.FRAME_TIERS[1] --- @type Progression_Tier

	--[[ Finding ]]

	--- @param tier Progression_Tier
	for _index: number, tier in ipairs(_settings.FRAME_TIERS) do
		if level >= tier.Level then
			best = tier
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Next Unlock

--[[
	Returns the next thing a level opens after this one, and its level: a frame, an emote to buy, or a level skin
	(several at one level are joined). Nil at the top.
]]
--- @return string?, number?
function Module.GetNextUnlock(level: number)
	--[[ Local Variables ]]

	local unlocks = {} --- @type { [number]: { string } }

	--[[ Collecting ]]

	--- @param tier Progression_Tier
	for _index: number, tier in ipairs(_settings.FRAME_TIERS) do
		Module._addUnlock(unlocks, level, tier.Level, `{tier.Name} frame`)
	end
	--- @param row Cosmetics_EmoteData
	for emoteId: string, row in pairs(I.G_Cosmetics.GetEmotes()) do
		Module._addUnlock(unlocks, level, row.Level or 1, `{I.G_Inventory.Items[emoteId].Name} emote`)
	end
	for atLevel: number, itemId: string in pairs(_settings.LEVEL_REWARDS) do
		Module._addUnlock(unlocks, level, atLevel, `{I.G_Inventory.Items[itemId].Name} skin`)
	end

	--[[ Returning ]]

	local nextLevel: number? = nil
	for atLevel: number in pairs(unlocks) do
		if not nextLevel or atLevel < nextLevel then
			nextLevel = atLevel
		end
	end
	if not nextLevel then
		return nil, nil
	end
	table.sort(unlocks[nextLevel])
	return table.concat(unlocks[nextLevel], " and "), nextLevel
end

--%%%%%%%%%%%%%%%%%%%% Add Unlock

--[[
	Notes something a level opens, when that level is still ahead of the player's.
]]
--- @param unlocks { [number]: { string } }
function Module._addUnlock(unlocks, level: number, atLevel: number, text: string)
	--[[ Checks ]]

	-- Check if it's still ahead
	if atLevel <= level then
		return
	end

	--[[ Saving ]]

	unlocks[atLevel] = unlocks[atLevel] or {}
	table.insert(unlocks[atLevel], text)
end

--%%%%%%%%%%%%%%%%%%%% Get Sequence

--[[
	Returns a tier's colours as an even ColorSequence, with a white light band at a point along it when shining (0 to
	1 across).
]]
--- @param colors { Color3 }
--- @return ColorSequence
function Module._getSequence(colors, shineAt: number?)
	--[[ Local Variables ]]

	local steps: number = 10
	local keypoints = {} --- @type { ColorSequenceKeypoint }

	--[[ Building ]]

	for step: number = 0, steps do
		local alpha: number = step / steps
		local scaled: number = alpha * (#colors - 1)
		local index: number = math.min(math.floor(scaled) + 1, #colors - 1)
		local color: Color3 = if #colors == 1 then colors[1] else colors[index]:Lerp(colors[index + 1], scaled - (index - 1))
		if shineAt then
			-- The band is wider than the sweep so it enters and leaves past the ends
			local light: number = math.max(0, 1 - math.abs(alpha - (shineAt * 1.6 - 0.3)) / 0.18)
			color = color:Lerp(Color3.new(1, 1, 1), light * 0.85)
		end
		table.insert(keypoints, ColorSequenceKeypoint.new(alpha, color))
	end

	--[[ Returning ]]

	return ColorSequence.new(keypoints)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
