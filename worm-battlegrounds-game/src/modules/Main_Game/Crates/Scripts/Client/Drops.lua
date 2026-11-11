--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Crates_Client_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

-- The big card's place on the screen (the result's S_CardSlot), as a share of it
local CARD_CENTRE: Vector2 = Vector2.new(0.5, 0.39)

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

--- @class Crates_Client_Drops
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Open"] = moduleGui:FindFirstChild("U_Open", true) --- @type Frame
	elems["Swallow"] = elems["Open"]:FindFirstChild("S_Swallow") --- @type UIScale
	elems["Result"] = moduleGui:FindFirstChild("U_Result", true) --- @type Frame
	elems["Disk"] = elems["Result"]:FindFirstChild("S_Disk", true) --- @type ImageLabel
	elems["Core"] = elems["Result"]:FindFirstChild("S_Core", true) --- @type ImageLabel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a legendary's own drop from its gold card, and has show bring in the big card (with its entrance and mood)
	at the drop's moment: the black hole, the variety grenade's party, the skeleton's graveyard, low gravity's float,
	or the plain legendary reveal for a legendary with no drop of its own. Yields until the card is in.
]]
function Module.Play(drop: string?, fromCard: Frame, show: (entrance: string, mood: string?) -> ())
	--[[ Playing ]]

	if drop == "BlackHole" then
		Module._blackHole(fromCard, show)
	elseif drop == "Variety" then
		Module._variety(fromCard, show)
	elseif drop == "Skeleton" then
		Module._skeleton(fromCard, show)
	elseif drop == "LowGravity" then
		Module._lowGravity(fromCard, show)
	else
		I.Sound.Play({ Name = "Reveal_Legendary", SoundGroup = "SFX" })
		elems["Open"].Visible = false
		show("Pop")
		task.wait(0.9)
	end
end

--%%%%%%%%%%%%%%%%%%%% Black Hole

--[[
	The black hole grenade: a black hole opens over the reels, its disk turning, and pulls the whole opening (reels,
	line, title) into it with streaks of light as the screen shakes harder, then implodes in a white flash and rings;
	its disk keeps turning behind the card.
]]
function Module._blackHole(_fromCard: Frame, show: (entrance: string, mood: string?) -> ())
	--[[ Local Variables ]]

	local disk: ImageLabel = elems["Disk"]
	local core: ImageLabel = elems["Core"]
	local open: Frame = elems["Open"]
	local swallow: UIScale = elems["Swallow"]
	local diskSize: UDim2 = disk.Size
	local coreSize: UDim2 = core.Size
	local centre: Vector2 = Module._getPoint()
	local start: number = os.clock()
	local frames: number = _settings.DISK_GRID.X * _settings.DISK_GRID.Y
	local Grow_TweenInfo: TweenInfo = TweenInfo.new(1.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	--[[ Opening ]]

	I.Sound.Play({ Name = "Legend_BlackHole", SoundGroup = "SFX" })
	for _index: number, picture: ImageLabel in ipairs({ disk, core }) do
		local size: UDim2 = picture.Size
		picture.Size = UDim2.fromScale(0, 0)
		picture.ImageTransparency = 0
		picture.Visible = true
		local Grow_TweenGoal = { Size = size }
		local Grow_Tween: Tween = I.S.TweenService:Create(picture, Grow_TweenInfo, Grow_TweenGoal)
		Grow_Tween:Play()
	end

	-- The disk turns from the moment it opens (the result's loop turns it after)
	local spin: RBXScriptConnection = I.S.RunService.RenderStepped:Connect(function()
		local frame: number = math.floor((os.clock() - start) * _settings.DISK_FPS) % frames
		disk.ImageRectOffset = Vector2.new((frame % _settings.DISK_GRID.X) * _settings.DISK_FRAME.X, math.floor(frame / _settings.DISK_GRID.X) * _settings.DISK_FRAME.Y)
	end)

	--[[ Swallowing ]]

	-- The whole opening layer shrinks into the hole, anchored on it
	open.AnchorPoint = CARD_CENTRE
	open.Position = UDim2.fromScale(CARD_CENTRE.X, CARD_CENTRE.Y)
	local Swallow_TweenInfo: TweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local Swallow_TweenGoal = { Scale = 0.12 }
	local Swallow_Tween: Tween = I.S.TweenService:Create(swallow, Swallow_TweenInfo, Swallow_TweenGoal)
	Swallow_Tween:Play()
	local vortices = {} --- @type { UIEmitter_Instance }
	for _index: number, color: Color3 in ipairs({ _settings.VORTEX_COLORS[1], _settings.VORTEX_COLORS[2], Color3.new(1, 1, 1) }) do
		table.insert(vortices, Effects.Stream("Vortex", false, { Color = color, Rate = 80 }))
	end
	Effects.Shake(1.25, 10, true)
	task.wait(1.25)

	--[[ Imploding ]]

	--- @param vortex UIEmitter_Instance
	for _index: number, vortex in ipairs(vortices) do
		vortex:Stop()
	end
	spin:Disconnect()
	local Implode_TweenInfo: TweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	for _index: number, picture: ImageLabel in ipairs({ disk, core }) do
		local Implode_TweenGoal = { Size = UDim2.fromScale(0, 0) }
		local Implode_Tween: Tween = I.S.TweenService:Create(picture, Implode_TweenInfo, Implode_TweenGoal)
		Implode_Tween:Play()
	end
	Effects.Flash(Color3.new(1, 1, 1), 0.95, 0.52)
	Effects.Ring(centre, _settings.VORTEX_COLORS[1], 60, 2200, 0.8)
	Effects.Ring(centre, _settings.VORTEX_COLORS[2], 40, 1400, 0.6)
	for _index: number, color: Color3 in ipairs(_settings.VORTEX_COLORS) do
		Effects.Burst("Sparks", centre, 56, color)
	end

	-- The opening layer goes, and is put back for the next opening
	open.Visible = false
	swallow.Scale = 1
	open.AnchorPoint = Vector2.new(0.5, 0.5)
	open.Position = UDim2.fromScale(0.5, 0.5)
	Effects.Shake(0.42, 16)

	--[[ Revealing ]]

	show("Pop")
	task.wait(0.14)
	core.Visible = false
	core.Size = coreSize
	disk.ImageTransparency = 0.45
	local Settle_TweenInfo: TweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Settle_TweenGoal = { Size = UDim2.fromScale(diskSize.X.Scale * 1.25, diskSize.Y.Scale * 1.25) }
	local Settle_Tween: Tween = I.S.TweenService:Create(disk, Settle_TweenInfo, Settle_TweenGoal)
	Settle_Tween:Play()
	Effects.Stream("Orbit", true)
	task.wait(0.8)
end

--%%%%%%%%%%%%%%%%%%%% Variety

--[[
	The variety grenade: the gold card wobbles and pops into a party, confetti in every colour and bouncing smileys,
	confetti raining after, the rays turning through the rainbow.
]]
function Module._variety(fromCard: Frame, show: (entrance: string, mood: string?) -> ())
	--[[ Wobbling ]]

	I.Sound.Play({ Name = "Legend_Variety", SoundGroup = "SFX" })
	local point: Vector2 = Module._getPoint(fromCard)
	for _index: number, angle: number in ipairs({ -9, 9, -7, 0 }) do
		local Wobble_TweenInfo: TweenInfo = TweenInfo.new(0.095, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local Wobble_TweenGoal = { Rotation = angle }
		local Wobble_Tween: Tween = I.S.TweenService:Create(fromCard, Wobble_TweenInfo, Wobble_TweenGoal)
		Wobble_Tween:Play()
		Wobble_Tween.Completed:Wait()
	end

	--[[ Popping ]]

	elems["Open"].Visible = false
	Effects.Flash(Color3.fromRGB(255, 230, 120), 0.7, 0.6)
	Effects.Confetti(point, 240)
	Effects.Burst("Smileys", point, 16)
	Effects.Ring(point, Color3.fromRGB(255, 224, 102), 60, 1640, 0.6)
	Effects.Shake(0.32, 11)
	for _index: number, color: Color3 in ipairs(_settings.CONFETTI_COLORS) do
		Effects.Stream("Rain", true, { Color = color, Rate = 4 })
	end

	--[[ Revealing ]]

	show("Squash", "Rainbow")
	task.wait(0.9)
end

--%%%%%%%%%%%%%%%%%%%% Skeleton

--[[
	The skeleton skin: two strikes of lightning, the screen gone graveyard green, the card bursting into bones and
	ghostly green flames, which keep burning round the card as it fades in like a ghost.
]]
function Module._skeleton(fromCard: Frame, show: (entrance: string, mood: string?) -> ())
	--[[ Striking ]]

	I.Sound.Play({ Name = "Legend_Skeleton", SoundGroup = "SFX" })
	local point: Vector2 = Module._getPoint(fromCard)
	Effects.Tint(Color3.fromRGB(2, 14, 6), 0.15, 0.2)
	Effects.Flash(Color3.new(1, 1, 1), 1, 0.14)
	task.delay(0.17, Effects.Flash, Color3.fromRGB(230, 255, 233), 0.8, 0.26)
	Effects.Shake(0.38, 13)
	task.wait(0.2)

	--[[ Bursting ]]

	task.delay(0.15, function()
		elems["Open"].Visible = false
	end)
	Effects.Burst("Bones", point, 22)
	Effects.Burst("Flames", point, 60, Color3.fromRGB(90, 255, 140))
	Effects.Stream("Flames", true)
	task.wait(0.35)

	--[[ Revealing ]]

	show("Ghost")
	task.wait(1.2)
end

--%%%%%%%%%%%%%%%%%%%% Low Gravity

--[[
	The low gravity potion: the screen turns violet, the gold card drifts up and away, bubbles rise everywhere, and the
	card floats in from below and keeps bobbing.
]]
function Module._lowGravity(fromCard: Frame, show: (entrance: string, mood: string?) -> ())
	--[[ Drifting ]]

	I.Sound.Play({ Name = "Legend_LowGravity", SoundGroup = "SFX" })
	local point: Vector2 = Module._getPoint(fromCard)
	local lift: number = 160 * Effects.GetUnit()
	Effects.Tint(Color3.fromRGB(20, 8, 60), 0.25, 0.9)
	local Drift_TweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local Drift_TweenGoal = { Position = fromCard.Position - UDim2.fromOffset(0, lift), Rotation = -8 }
	local Drift_Tween: Tween = I.S.TweenService:Create(fromCard, Drift_TweenInfo, Drift_TweenGoal)
	Drift_Tween:Play()
	task.delay(0.6, function()
		elems["Open"].Visible = false
	end)
	Effects.Stream("Bubbles", true)
	Effects.Stream("Bubbles", false, { Rate = 6 })
	task.wait(0.7)

	--[[ Revealing ]]

	Effects.Burst("Bubbles", point - Vector2.new(0, lift), 34)
	show("Float", "Float")
	task.wait(1.7)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Point

--[[
	Returns a card's middle on the screen (absolute pixels), or the big card's place without one.
]]
--- @return Vector2
function Module._getPoint(card: Frame?)
	--[[ Returning ]]

	if card then
		return card.AbsolutePosition + card.AbsoluteSize / 2
	end
	return elems["Result"].AbsolutePosition + elems["Result"].AbsoluteSize * CARD_CENTRE
end

return Module
