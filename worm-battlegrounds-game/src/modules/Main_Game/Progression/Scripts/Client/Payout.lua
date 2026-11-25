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

--[[ General ]]

local moduleGui: ScreenGui

--[[ Diamonds ]]

--[[
	The diamonds flying into the diamonds slot, made on the first payout, how many the payout threw and how many are
	still on their way
]]
local diamonds = nil --- @type UIEmitter_Instance?
local thrown: number = 0
local inFlight: number = 0

--[[
	What the diamonds counters show while they land (every gui's diamonds label holds there, whatever the Currency
	module writes, from Hold until the last diamond lands), the held labels, and what each landing diamond adds
]]
local shown = nil --- @type BigNum?
local holding = {} --- @type { [TextLabel]: RBXScriptConnection }
local perDiamond = {} --- @type { string }

--[[ Vignette ]]

--[[
	The PotionVignette gui and its four edges, tinted gem blue around a bought pack's payout, whether the payout has it
	now, and its edges' breathing tweens
]]
local vignette: ScreenGui
local edges = {} --- @type { Frame }
local owningVignette: boolean = false
local breathing = {} --- @type { Tween }

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

--- @class Progression_Client_Payout
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI["LevelPlate"]
	elems["Replay"] = moduleGui:FindFirstChild("U_Replay") --- @type Frame
	elems["Gain"] = elems["Replay"]:FindFirstChild("S_Gain") --- @type Frame
	elems["GainScale"] = elems["Gain"]:FindFirstChild("S_GainScale") --- @type UIScale
	elems["GainText"] = elems["Gain"]:FindFirstChild("S_GainText") --- @type TextLabel
	elems["GainIcon"] = elems["Gain"]:FindFirstChild("S_GainIcon") --- @type ImageLabel
	elems["Particles"] = elems["Replay"]:FindFirstChild("S_Particles") --- @type Frame

	-- The potion vignette's edges, borrowed for a bought pack (the lobby has no potions)
	vignette = I.UserInterface.UI["PotionVignette"]
	for _index: number, edge: Instance in ipairs(vignette:FindFirstChild("U_Vignette", true):GetChildren()) do
		if edge:IsA("Frame") then
			table.insert(edges, edge)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Holds the diamonds slot at what the player had before a payout of `amount` (the server paid it already), from the
	moment the lobby knows of it until its diamonds land, so the slot never shows the new total early; every other gui's
	diamonds counter (the shop's, the crates screen's) holds with it. `before`, when given, is the count to hold at
	(what the slot showed before a purchase, whether or not the new total has reached this screen yet).
]]
function Module.Hold(amount: string, before: string?)
	--[[ Checks ]]

	-- Check if there are diamonds to hold back and the counters aren't held yet
	if amount == "0" or next(holding) then
		return
	end

	--[[ Holding ]]

	shown = if before then I.BN.new(before) else I.BN.new(I.Currency.Get("Diamonds")) - I.BN.new(amount)
	for _index: number, label: TextLabel in ipairs(Module._getCounters()) do
		label.Text = I.BN.DynamicFormat(`{shown}`, 16, ",")
		holding[label] = label:GetPropertyChangedSignal("Text"):Connect(function()
			local text: string = I.BN.DynamicFormat(`{shown}`, 16, ",")
			if label.Text ~= text then
				label.Text = text
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Lets the diamonds counters show the player's diamonds again: the end of a payout, or of a replay that failed part
	way.
]]
function Module.Release()
	--[[ Checks ]]

	-- Check if the counters are held
	if not next(holding) then
		return
	end

	--[[ Releasing ]]

	for label: TextLabel, connection: RBXScriptConnection in pairs(holding) do
		connection:Disconnect()
		label.Text = I.BN.DynamicFormat(I.Currency.Get("Diamonds"), 16, ",")
	end
	table.clear(holding)
	inFlight = 0
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays the diamonds a player's matches paid since the lobby last showed them, as Brawl Stars plays trophies:
	"+amount" pops up over their snail on the stage, then a diamond for every DIAMONDS_PER_ICON (up to DIAMOND_ICONS_MAX)
	bursts out of it with Diamond_Burst and streams into the diamonds slot, which counts up as each one lands. A bought
	pack passes `look`: its own count of diamonds, the pop's sound and a fanfare as the last one lands. Returns once the
	last diamond has landed.
]]
--- @param look Progression_PayoutLook?
function Module.Play(amount: string, look)
	--[[ Checks ]]

	-- Check if there are diamonds to show and a diamonds slot to show them in
	local slot: TextLabel? = Module._getSlot()
	if amount == "0" or not slot then
		return
	end

	--[[ Local Variables ]]

	local amountBN = I.BN.new(amount)
	local count: number = if look then look.Icons else math.clamp(math.ceil((I.Number.ToNumberOr(amount, 0)) / _settings.DIAMONDS_PER_ICON), 1, _settings.DIAMOND_ICONS_MAX)
	local origin: Vector2 = Module._getOrigin()

	--[[ Popping Up ]]

	elems["Replay"].Visible = true
	elems["GainText"].Text = `+{I.BN.DynamicFormat(amount, 16, ",")}`
	elems["GainIcon"].Image = I.G_Currency.GetCurrencyIcon("Diamonds") or ""
	elems["Gain"].Position = UDim2.fromOffset(origin.X - elems["Replay"].AbsolutePosition.X, origin.Y - elems["Replay"].AbsolutePosition.Y)
	elems["Gain"].Visible = true
	elems["GainScale"].Scale = 0
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["GainScale"], _settings.DIAMOND_POP_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()
	I.Sound.Play({ Name = if look then look.PopSound else "Xp_Line", SoundGroup = "UI" })
	Module.Hold(amount)
	task.wait(_settings.DIAMOND_BURST_DELAY)

	--[[ Splitting ]]

	-- Every diamond carries an even share, the first ones one more until the remainder is gone
	local quotientBN = I.BN.new()
	local remainderBN = I.BN.new()
	I.BN.Div(amountBN, I.BN.new(`{count}`), quotientBN, remainderBN)
	local extra: number = I.Number.ToNumberOr(`{remainderBN}`, 0)
	table.clear(perDiamond)
	for index: number = 1, count do
		table.insert(perDiamond, if index <= extra then `{quotientBN + I.BN.new("1")}` else `{quotientBN}`)
	end
	thrown = count
	inFlight = count

	--[[ Bursting ]]

	Module._ensureEmitter(slot)
	I.Sound.Play({ Name = "Diamond_Burst", SoundGroup = "UI" })
	diamonds:Emit(count, origin)
	local started: number = os.clock()
	while inFlight > 0 and os.clock() - started < _settings.DIAMOND_FLIGHT_TIMEOUT do
		task.wait()
	end

	--[[ Closing ]]

	-- A bought pack lands on its fanfare
	if look then
		I.Sound.Play({ Name = look.LandSound, SoundGroup = "UI" })
	end
	Module.Release()
	local Hide_TweenGoal = { Scale = 0 }
	local Hide_Tween: Tween = I.S.TweenService:Create(elems["GainScale"], _settings.DIAMOND_HIDE_TWEENINFO, Hide_TweenGoal)
	Hide_Tween:Play()
	task.wait(_settings.DIAMOND_HIDE_TWEENINFO.Time)
	elems["Gain"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Set Vignette

--[[
	Fades the potion vignette in around a bought pack's payout, gem blue and breathing softly, or flashes it once and
	fades it out. Leaves it alone while a potion shows it.
]]
function Module.SetVignette(on: boolean)
	--[[ Checks ]]

	-- Check if the vignette is free (a potion's isn't the payout's to take) or already as asked
	if (on and vignette.Enabled) or (not on and not owningVignette) then
		return
	end

	--[[ Stopping ]]

	for _index: number, tween: Tween in ipairs(breathing) do
		tween:Cancel()
	end
	table.clear(breathing)

	--[[ Fading In ]]

	if on then
		owningVignette = true
		for _index: number, edge: Frame in ipairs(edges) do
			edge.BackgroundColor3 = _settings.PURCHASE_VIGNETTE_COLOR
			edge.BackgroundTransparency = 1
		end
		vignette.Enabled = true
		for _index: number, edge: Frame in ipairs(edges) do
			local In_TweenGoal = { BackgroundTransparency = _settings.PURCHASE_VIGNETTE_BREATH[1] }
			local In_Tween: Tween = I.S.TweenService:Create(edge, _settings.PURCHASE_VIGNETTE_IN_TWEENINFO, In_TweenGoal)
			In_Tween:Play()

			-- Then it breathes between its two strengths until the diamonds land
			local Breathe_TweenGoal = { BackgroundTransparency = _settings.PURCHASE_VIGNETTE_BREATH[2] }
			local Breathe_Tween: Tween = I.S.TweenService:Create(edge, _settings.PURCHASE_VIGNETTE_BREATH_TWEENINFO, Breathe_TweenGoal)
			table.insert(breathing, Breathe_Tween)
			In_Tween.Completed:Once(function(state: Enum.PlaybackState)
				if state == Enum.PlaybackState.Completed and table.find(breathing, Breathe_Tween) then
					Breathe_Tween:Play()
				end
			end)
		end
		return
	end

	--[[ Fading Out ]]

	-- A flash as the last diamond lands, then gone
	for _index: number, edge: Frame in ipairs(edges) do
		local Flash_TweenGoal = { BackgroundTransparency = 0 }
		local Flash_Tween: Tween = I.S.TweenService:Create(edge, _settings.PURCHASE_VIGNETTE_FLASH_TWEENINFO, Flash_TweenGoal)
		Flash_Tween:Play()
	end
	task.wait(_settings.PURCHASE_VIGNETTE_FLASH_TWEENINFO.Time)
	for _index: number, edge: Frame in ipairs(edges) do
		local Out_TweenGoal = { BackgroundTransparency = 1 }
		local Out_Tween: Tween = I.S.TweenService:Create(edge, _settings.PURCHASE_VIGNETTE_OUT_TWEENINFO, Out_TweenGoal)
		Out_Tween:Play()
	end
	task.wait(_settings.PURCHASE_VIGNETTE_OUT_TWEENINFO.Time)
	vignette.Enabled = false
	owningVignette = false
end

--%%%%%%%%%%%%%%%%%%%% Ensure Emitter

--[[
	Makes the flying diamonds' emitter the first time: diamonds thrown up and out of the snail, hanging a moment, then
	pulled into the diamonds slot, each landing adding its share there with a clink that climbs in pitch (Diamond_Collect).
]]
function Module._ensureEmitter(slot: TextLabel)
	--[[ Checks ]]

	-- Check if it's made already
	if diamonds then
		return
	end

	--[[ Local Variables ]]

	local unit: number = math.max(0.1, math.min(moduleGui.AbsoluteSize.X / 1920, moduleGui.AbsoluteSize.Y / 1080))
	local size: number = _settings.DIAMOND_ICON_SIZE * unit

	--[[ Creating ]]

	diamonds = I.UIEmitter.new({
		Parent = elems["Particles"],
		Container = elems["Particles"],
		Texture = I.G_Currency.GetCurrencyIcon("Diamonds") or "",
		Rate = 0,
		SizeSpace = "Offset",
		AspectRatio = 1,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.1, size * 1.2),
			NumberSequenceKeypoint.new(0.2, size),
			NumberSequenceKeypoint.new(0.9, size),
			NumberSequenceKeypoint.new(1, size * 0.6),
		}),
		Lifetime = NumberRange.new(1.6, 2.1),
		InitialVelocity = function(_spawnAbsolutePoint: Vector2): Vector2
			local angle: number = math.rad(I.Random.Float(-165, -15))
			return Vector2.new(math.cos(angle), math.sin(angle)) * I.Random.Float(420, 760) * unit
		end,
		Drag = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(0.25, 0.5),
			NumberSequenceKeypoint.new(1, 0.05),
		}),
		Rotation = NumberRange.new(-20, 20),
		RotationSpeed = NumberRange.new(-2, 2),
		AttractTo = slot,
		AttractAfter = NumberRange.new(0.35, 0.65),
		AttractStrength = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0),
			NumberSequenceKeypoint.new(0.4, 3200),
			NumberSequenceKeypoint.new(1, 12000),
		}),
		AttractMaxSpeed = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 800),
			NumberSequenceKeypoint.new(0.5, 2600),
			NumberSequenceKeypoint.new(1, 4800),
		}),
		AttractArriveRadius = 40 * unit,
		AttractStopOnArrive = true,
		AttractDestroyOnArrive = true,
		AttractOnArrive = function(_particle: GuiObject)
			Module._onLanded()
		end,
		CullOffscreen = false,
		ZIndex = 10,
	})
end

--%%%%%%%%%%%%%%%%%%%% On Landed

--[[
	One diamond reached the diamonds slot: the held counters count its share up, with a clink higher than the last.
]]
function Module._onLanded()
	--[[ Checks ]]

	-- Check if a payout is still counting
	if inFlight <= 0 or not shown then
		return
	end

	--[[ Counting ]]

	local share: string = table.remove(perDiamond, 1) or "0"
	shown = shown + I.BN.new(share)
	for label: TextLabel in pairs(holding) do
		label.Text = I.BN.DynamicFormat(`{shown}`, 16, ",")
	end
	inFlight -= 1

	--[[ Playing ]]

	local pitch: number = 1 + (thrown - inFlight) / thrown * _settings.DIAMOND_TICK_CLIMB
	I.Sound.Play({ Name = "Diamond_Collect", SoundGroup = "UI", Volume = 0.6, PitchMin = pitch, PitchMax = pitch })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Slot

--[[
	Returns the lobby's diamonds slot: the Currency gui's label that shows the player's Diamonds.
]]
--- @return TextLabel?
function Module._getSlot()
	--[[ Finding ]]

	for _index: number, label: Instance in ipairs(I.UserInterface.UI["Currency"]:GetDescendants()) do
		if label:IsA("TextLabel") and label:GetAttribute("Currency_Name") == "Diamonds" then
			return label
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Counters

--[[
	Returns every diamonds counter on the player's screens: each gui's label whose `Currency_Name` is `Diamonds`.
]]
--- @return { TextLabel }
function Module._getCounters()
	--[[ Local Variables ]]

	local counters = {} --- @type { TextLabel }

	--[[ Finding ]]

	for _index: number, label: Instance in ipairs(I.S.Players.LocalPlayer.PlayerGui:GetDescendants()) do
		if label:IsA("TextLabel") and label:GetAttribute("Currency_Name") == "Diamonds" then
			table.insert(counters, label)
		end
	end

	--[[ Returning ]]

	return counters
end

--%%%%%%%%%%%%%%%%%%%% Get Origin

--[[
	Returns where the diamonds come from, in the gui's pixels: over the player's snail on the stage (a little over its
	middle), or the middle of the screen when it has none.
]]
--- @return Vector2
function Module._getOrigin()
	--[[ Data ]]

	local snail: Model? = I.Lobby.GetStageSnail(I.S.Players.LocalPlayer)
	if not snail then
		return moduleGui.AbsoluteSize / 2
	end

	--[[ Local Variables ]]

	local box: CFrame
	local size: Vector3
	box, size = snail:GetBoundingBox()
	local point: Vector3 = I.S.Workspace.CurrentCamera:WorldToViewportPoint(box.Position + Vector3.yAxis * size.Y * 0.15)
	local inset: Vector2 = if moduleGui.IgnoreGuiInset then Vector2.zero else I.S.GuiService:GetGuiInset()

	--[[ Returning ]]

	return Vector2.new(point.X, point.Y) - inset
end

return Module
