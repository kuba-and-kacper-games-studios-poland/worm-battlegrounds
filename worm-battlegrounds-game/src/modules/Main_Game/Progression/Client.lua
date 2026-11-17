--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: any }
local prefabs = {} --- @type { [string]: any }

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder

--[[ Replay ]]

-- Whether the replay is playing, and whether the player tapped to skip the rest of it
local replaying: boolean = false
local skipping: boolean = false

-- The sparks flying from each XP line into the bar, and the stars a level-up throws, made on the first replay
local sparks = nil --- @type UIEmitter_Instance?
local stars = nil --- @type UIEmitter_Instance?

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

	Module._getElements()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.OnLoaded(I.Priority.Default, Module._connectReplicator)
	moduleGui:GetPropertyChangedSignal("Enabled"):Connect(Module._tryReplay)
	I.S.UserInputService.InputBegan:Connect(Module._onInput)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the plate's and the replay's elements in the LevelPlate gui.
]]
function Module._getElements()
	--[[ General ]]

	moduleGui = I.UserInterface.UI["LevelPlate"]
	elems["Plate"] = moduleGui:FindFirstChild("U_Plate") --- @type Frame
	elems["Pop"] = elems["Plate"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["Diamond"] = elems["Plate"]:FindFirstChild("S_Diamond", true) --- @type Frame
	elems["TierGradient"] = elems["Diamond"]:FindFirstChild("S_TierGradient") --- @type UIGradient
	elems["LevelNum"] = elems["Plate"]:FindFirstChild("S_LevelNum", true) --- @type TextLabel
	elems["Title"] = elems["Plate"]:FindFirstChild("S_Title") --- @type TextLabel
	elems["Xp"] = elems["Plate"]:FindFirstChild("S_Xp") --- @type TextLabel
	elems["Fill"] = elems["Plate"]:FindFirstChild("S_Fill", true) --- @type Frame
	elems["Head"] = elems["Plate"]:FindFirstChild("S_Head", true) --- @type ImageLabel
	elems["Next"] = elems["Plate"]:FindFirstChild("S_Next") --- @type TextLabel
	elems["Replay"] = moduleGui:FindFirstChild("U_Replay") --- @type Frame
	elems["Dim"] = elems["Replay"]:FindFirstChild("S_Dim") --- @type Frame
	elems["Lines"] = elems["Replay"]:FindFirstChild("S_Lines") --- @type Frame
	elems["LevelUpScale"] = elems["Replay"]:FindFirstChild("S_LevelUpScale", true) --- @type UIScale
	elems["RewardText"] = elems["Replay"]:FindFirstChild("S_RewardText", true) --- @type TextLabel
	elems["RewardScale"] = elems["Replay"]:FindFirstChild("S_RewardScale", true) --- @type UIScale
	elems["Particles"] = elems["Replay"]:FindFirstChild("S_Particles") --- @type Frame

	--[[ Prefab ]]

	prefabs["XpLine"] = elems["Replay"]:FindFirstChild("PREFAB | XpLine") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's level and any XP replay waiting in their Progression folder.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)

	--[[ Connections ]]

	moduleRep.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Replay" then
			Module._tryReplay()
		elseif not replaying then
			Module._showCurrent()
		end
	end)

	--[[ Applying ]]

	Module._showCurrent()
	Module._tryReplay()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Current

--[[
	Shows the player's level as it is now on the plate.
]]
function Module._showCurrent()
	--[[ Checks ]]

	-- Check if the level has arrived
	if not moduleRep or not moduleRep:GetAttribute("Level") then
		return
	end

	--[[ Applying ]]

	Module._showLevel(moduleRep:GetAttribute("Level"), moduleRep:GetAttribute("XPIntoLevel") or 0, moduleRep:GetAttribute("XPForLevel") or 0)
end

--%%%%%%%%%%%%%%%%%%%% Show Level

--[[
	Writes a level and the XP into it on the plate: the diamond in its frame tier, the title, the XP, the bar and the
	next unlock.
]]
function Module._showLevel(level: number, into: number, cost: number)
	--[[ Local Variables ]]

	local nextText: string?
	local nextLevel: number?
	nextText, nextLevel = I.G_Progression.GetNextUnlock(level)

	--[[ Applying ]]

	I.G_Progression.ApplyFrame(elems["TierGradient"], level)
	elems["LevelNum"].Text = tostring(level)
	elems["Title"].Text = `Level {level}`
	elems["Xp"].Text = if cost > 0 then `{math.floor(into)} / {cost} XP` else "Max level"
	elems["Fill"].Size = UDim2.fromScale(if cost > 0 then math.clamp(into / cost, 0, 1) else 1, 1)
	elems["Head"].Position = UDim2.fromScale(elems["Fill"].Size.X.Scale, 0.5)
	elems["Next"].Text = if nextText then `Next unlock: {nextText} at level {nextLevel}` else "Every unlock is yours"
end

--%%%%%%%%%%%%%%%%%%%% Try Replay

--[[
	Starts the XP replay when one is waiting and the lobby shows, once the teleport card has had time to slide off.
]]
function Module._tryReplay()
	--[[ Checks ]]

	-- Check if a replay waits and the lobby's screens show
	if replaying or not moduleRep or (moduleRep:GetAttribute("Replay") or "") == "" or not moduleGui.Enabled then
		return
	end

	--[[ Playing ]]

	replaying = true
	task.delay(_settings.REPLAY_DELAY, function()
		local success: boolean
		local result: any | string?
		success, result = pcall(Module._playReplay)
		if not success then
			warn(`[{_localName}::{script.Name}]: The XP replay failed! - ({result})`)
		end
		Module._endReplay()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Play Replay

--[[
	Plays what the last matches gave: the plate moves to the middle over a dimmed lobby, each XP line pops in and
	fills the bar with ticks and sparks, and every level-up bursts, flips the level and shows what it opened.
]]
function Module._playReplay()
	--[[ Data ]]

	local replay = I.S.HttpService:JSONDecode(moduleRep:GetAttribute("Replay")) --- @type Progression_Replay

	--[[ Local Variables ]]

	local level: number = replay.Before.Level
	local into: number = replay.Before.Into
	local cost: number = replay.Before.For
	skipping = false

	--[[ Opening ]]

	Module._showLevel(level, into, cost)
	elems["Replay"].Visible = true
	Module._tween(elems["Dim"], _settings.PLATE_TWEENINFO, { BackgroundTransparency = 1 - _settings.REPLAY_DIM })
	Module._tween(elems["Plate"], _settings.PLATE_TWEENINFO, { Position = _settings.REPLAY_POSITION })
	Module._tween(elems["Pop"], _settings.PLATE_TWEENINFO, { Scale = _settings.REPLAY_SCALE })
	Module._wait(_settings.PLATE_TWEENINFO.Time)

	--[[ Lines ]]

	--- @param line Progression_XpLine
	for index: number, line in ipairs(replay.Lines) do
		local row: Frame = Module._addLine(line, index)
		Module._wait(_settings.REPLAY_LINE_GAP)
		Module._emitSparks(row)

		local left: number = line.Amount
		while left > 0 do
			-- One stretch of the bar: up to the end of this level, or what's left of the line
			local room: number = if cost > 0 then cost - into else left
			local gain: number = math.min(left, room)
			Module._fill(level, into, into + gain, cost, gain / line.Amount)
			into += gain
			left -= gain

			if cost > 0 and into >= cost then
				level += 1
				into = 0
				cost = Module._getCost(replay, level)
				Module._levelUp(level)
				Module._showLevel(level, into, cost)
			end
		end
	end

	--[[ Closing ]]

	Module._wait(_settings.REPLAY_END_HOLD)
end

--%%%%%%%%%%%%%%%%%%%% End Replay

--[[
	Closes the replay: the plate flies back to the top, the lobby brightens, the lines go, the plate shows the level as
	it is now, and the server forgets the replay.
]]
function Module._endReplay()
	--[[ Applying ]]

	Module._tween(elems["Dim"], _settings.PLATE_BACK_TWEENINFO, { BackgroundTransparency = 1 })
	Module._tween(elems["Plate"], _settings.PLATE_BACK_TWEENINFO, { Position = _settings.PLATE_POSITION })
	Module._tween(elems["Pop"], _settings.PLATE_BACK_TWEENINFO, { Scale = 1 })
	Module._tween(elems["LevelUpScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	Module._tween(elems["RewardScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	task.wait(_settings.PLATE_BACK_TWEENINFO.Time)

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Lines"]:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	elems["Replay"].Visible = false
	elems["Head"].ImageTransparency = 1

	--[[ Publishing ]]

	I.Network.Fire("Progression_ReplaySeen")
	replaying = false
	skipping = false
	Module._showCurrent()
end

--%%%%%%%%%%%%%%%%%%%% Add Line

--[[
	Pops one XP line in under the plate, with its chime.
]]
--- @param line Progression_XpLine
--- @return Frame
function Module._addLine(line, index: number)
	--[[ Cloning ]]

	local row: Frame = prefabs["XpLine"]:Clone()
	row.Name = "XpLine"
	row.LayoutOrder = index

	--[[ Elements ]]

	local scale: UIScale = row:FindFirstChild("S_Scale")
	local label: TextLabel = row:FindFirstChild("S_Label")
	local amount: TextLabel = row:FindFirstChild("S_Amount")

	--[[ Texts ]]

	label.Text = line.Label
	amount.Text = `+{line.Amount}`

	--[[ Showing ]]

	scale.Scale = 0
	row.Visible = true
	row.Parent = elems["Lines"]
	Module._tween(scale, _settings.PLATE_TWEENINFO, { Scale = 1 })
	I.Sound.Play({ Name = "Xp_Line", SoundGroup = "UI" })

	--[[ Returning ]]

	return row
end

--%%%%%%%%%%%%%%%%%%%% Fill

--[[
	Fills the bar from one amount of XP to another, its glow riding the end, ticking higher as it fills.
]]
function Module._fill(level: number, from: number, to: number, cost: number, share: number)
	--[[ Local Variables ]]

	local seconds: number = if skipping then 0 else math.max(0.15, _settings.REPLAY_FILL_SECONDS * share)
	local ticks: number = math.max(1, math.round(_settings.REPLAY_TICKS * share))
	local fillTo: number = if cost > 0 then to / cost else 1

	--[[ Filling ]]

	elems["Head"].ImageTransparency = 0.1
	local Fill_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Module._tween(elems["Fill"], Fill_TweenInfo, { Size = UDim2.fromScale(fillTo, 1) })
	Module._tween(elems["Head"], Fill_TweenInfo, { Position = UDim2.fromScale(fillTo, 0.5) })

	--[[ Ticking ]]

	for tick: number = 1, ticks do
		local through: number = from + (to - from) * tick / ticks
		local pitch: number = _settings.REPLAY_TICK_PITCH.Min + (_settings.REPLAY_TICK_PITCH.Max - _settings.REPLAY_TICK_PITCH.Min) * (if cost > 0 then through / cost else 1)
		elems["Xp"].Text = if cost > 0 then `{math.floor(through)} / {cost} XP` else "Max level"
		if not skipping then
			I.Sound.Play({ Name = "Xp_Tick", SoundGroup = "UI", PitchMin = pitch, PitchMax = pitch })
		end
		Module._wait(seconds / ticks)
	end
	elems["Title"].Text = `Level {level}`
	elems["Head"].ImageTransparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Level Up

--[[
	Bursts a level-up on the plate: stars, the diamond's punch, LEVEL UP! and what the level opened (a new frame first),
	with its fanfare.
]]
function Module._levelUp(level: number)
	--[[ Local Variables ]]

	local tier = I.G_Progression.GetTier(level) --- @type Progression_Tier
	local newFrame: boolean = tier.Level == level
	local opened: string?
	local openedAt: number?
	opened, openedAt = I.G_Progression.GetNextUnlock(level - 1)

	--[[ Bursting ]]

	-- A new frame's sting swells for FRAME_UNLOCK_LEAD before its hit, so the burst waits for it
	I.Sound.Play({ Name = if newFrame then "Frame_Unlock" else "Level_Up", SoundGroup = "UI" })
	if newFrame then
		Module._wait(_settings.FRAME_UNLOCK_LEAD)
	end
	Module._emitStars()
	elems["LevelUpScale"].Scale = 0
	elems["RewardScale"].Scale = 0
	Module._tween(elems["LevelUpScale"], _settings.PLATE_TWEENINFO, { Scale = 1 })
	Module._tween(elems["Diamond"], TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true), { Rotation = 30 })

	--[[ Reward ]]

	if newFrame then
		elems["RewardText"].Text = `New frame: {tier.Name}`
	elseif opened and openedAt == level then
		elems["RewardText"].Text = `Unlocked: {opened}`
	end
	if newFrame or (opened and openedAt == level) then
		Module._tween(elems["RewardScale"], _settings.PLATE_TWEENINFO, { Scale = 1 })
	end

	--[[ Holding ]]

	Module._wait(_settings.REPLAY_LEVEL_HOLD)
	Module._tween(elems["LevelUpScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	Module._tween(elems["RewardScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	elems["Fill"].Size = UDim2.fromScale(0, 1)
	elems["Head"].Position = UDim2.fromScale(0, 0.5)
end

--%%%%%%%%%%%%%%%%%%%% Emit Sparks

--[[
	Throws a few sparks from an XP line that fly into the bar's end.
]]
function Module._emitSparks(row: Frame)
	--[[ Checks ]]

	-- Check if the player skipped
	if skipping then
		return
	end

	--[[ Building ]]

	local unit: number = Module._getUnit()
	if not sparks then
		sparks = I.UIEmitter.new({
			Parent = elems["Particles"],
			Rate = 0,
			Texture = _settings.REPLAY_TEXTURES.Spark,
			SizeSpace = "Offset",
			AspectRatio = 3,
			Size = NumberSequence.new(34 * unit, 12 * unit),
			Lifetime = NumberRange.new(0.8, 1.2),
			Velocity = NumberRange.new(250 * unit, 600 * unit),
			SpreadAngle = 360,
			FaceMovementDirection = true,
			AttractTo = elems["Head"],
			AttractStrength = 9000 * unit,
			AttractDestroyOnArrive = true,
			Color = _settings.REPLAY_COLORS[1],
			CullOffscreen = false,
		})
	end

	--[[ Emitting ]]

	sparks:Emit(_settings.REPLAY_SPARKS, row.AbsolutePosition + row.AbsoluteSize * Vector2.new(0.85, 0.5))
end

--%%%%%%%%%%%%%%%%%%%% Emit Stars

--[[
	Throws the level-up's stars from the diamond, in the replay's colours.
]]
function Module._emitStars()
	--[[ Checks ]]

	-- Check if the player skipped
	if skipping then
		return
	end

	--[[ Building ]]

	local unit: number = Module._getUnit()
	if not stars then
		stars = I.UIEmitter.new({
			Parent = elems["Particles"],
			Rate = 0,
			Texture = _settings.REPLAY_TEXTURES.Star,
			SizeSpace = "Offset",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 30 * unit, 10 * unit), NumberSequenceKeypoint.new(1, 0) }),
			Lifetime = NumberRange.new(0.6, 1.3),
			Velocity = NumberRange.new(300 * unit, 900 * unit),
			SpreadAngle = 360,
			Drag = 1.8,
			RotationSpeed = NumberRange.new(-120, 120),
			CullOffscreen = false,
		})
	end

	--[[ Emitting ]]

	local center: Vector2 = elems["Diamond"].AbsolutePosition + elems["Diamond"].AbsoluteSize / 2
	for _index: number, color: Color3 in ipairs(_settings.REPLAY_COLORS) do
		stars.Color = color
		stars:Emit(math.round(_settings.REPLAY_STARS / #_settings.REPLAY_COLORS), center)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input

--[[
	A press while the replay plays skips the rest of it (the bar jumps to its end).
]]
function Module._onInput(input: InputObject)
	--[[ Checks ]]

	-- Check if a replay is playing and it's a press
	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA
	if not replaying or not press then
		return
	end

	--[[ Saving ]]

	skipping = true
end

--%%%%%%%%%%%%%%%%%%%% Tween

--[[
	Plays a tween on one instance (instantly while the player skips).
]]
--- @param goal { [string]: any }
function Module._tween(instance: Instance, info: TweenInfo, goal)
	--[[ Playing ]]

	local Step_TweenInfo: TweenInfo = if skipping then TweenInfo.new(0) else info
	local Step_TweenGoal = goal
	local Step_Tween: Tween = I.S.TweenService:Create(instance, Step_TweenInfo, Step_TweenGoal)
	Step_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Wait

--[[
	Waits a number of seconds, or not at all while the player skips.
]]
function Module._wait(seconds: number)
	--[[ Waiting ]]

	if not skipping and seconds > 0 then
		task.wait(seconds)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Cost

--[[
	Returns the XP a level takes, from the replay's costs (the server sends each level's on the way).
]]
--- @param replay Progression_Replay
--- @return number
function Module._getCost(replay, level: number)
	return replay.Costs[level - replay.Before.Level + 1] or replay.After.For
end

--%%%%%%%%%%%%%%%%%%%% Get Unit

--[[
	Returns the screen's size against a 1920 × 1080 one, for particle sizes and speeds.
]]
--- @return number
function Module._getUnit()
	--[[ Local Variables ]]

	local size: Vector2 = moduleGui.AbsoluteSize

	--[[ Returning ]]

	return math.max(0.1, math.min(size.X / 1920, size.Y / 1080))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
