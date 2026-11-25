--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: any }

-- How many intros have played, so a later one's fade never hides an earlier one's leftovers by mistake
local plays: number = 0

-- The gold sparks the slam throws and the camera's shaker, made the first time
local sparks = nil --- @type UIEmitter_Instance?
local shaker = nil --- @type any

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

--- @class MatchHud_Client_BattleIntro
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Intro"] = gui:FindFirstChild("U_BattleIntro") --- @type Frame
	elems["Vignette"] = {
		elems["Intro"]:FindFirstChild("S_VignetteTop"),
		elems["Intro"]:FindFirstChild("S_VignetteBottom"),
		elems["Intro"]:FindFirstChild("S_VignetteLeft"),
		elems["Intro"]:FindFirstChild("S_VignetteRight"),
	} --- @type { Frame }
	elems["Flash"] = elems["Intro"]:FindFirstChild("S_Flash") --- @type Frame
	elems["Ready"] = elems["Intro"]:FindFirstChild("S_Ready") --- @type Frame
	elems["ReadyScale"] = elems["Ready"]:FindFirstChild("S_ReadyScale") --- @type UIScale
	elems["ReadyText"] = elems["Ready"]:FindFirstChild("S_ReadyText") --- @type TextLabel
	elems["ReadyLine"] = elems["Ready"]:FindFirstChild("S_ReadyLine") --- @type Frame
	elems["Slam"] = elems["Intro"]:FindFirstChild("S_Slam") --- @type Frame
	elems["SlamScale"] = elems["Slam"]:FindFirstChild("S_SlamScale") --- @type UIScale
	elems["SlamTop"] = elems["Slam"]:FindFirstChild("S_SlamTop") --- @type TextLabel
	elems["SlamMain"] = elems["Slam"]:FindFirstChild("S_SlamMain") --- @type TextLabel
	elems["MainScale"] = elems["SlamMain"]:FindFirstChild("S_MainScale") --- @type UIScale
	elems["Shock"] = elems["Slam"]:FindFirstChild("S_Shock") --- @type Frame
	elems["Streak"] = elems["Slam"]:FindFirstChild("S_Streak") --- @type Frame
	elems["Gui"] = gui

	--[[ Connections ]]

	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	Plays the round's intro in two beats: GET READY as the snails drop in (Landing), the slam as they've all landed
	(Battle); anything else clears it. Only for a player in the match: on the Studio map a match goes on beside the
	lobby, and its intro shook the lobby's camera (2026-11-24).
]]
function Module._onPhaseChanged(phase: string)
	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		elems["Intro"].Visible = false
		return
	end

	--[[ Playing ]]

	if phase == "Landing" then
		Module._getReady()
	elseif phase == "Battle" then
		Module._slam()
	elseif phase ~= "Turn" and phase ~= "Flight" and phase ~= "Settle" then
		elems["Intro"].Visible = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Ready

--[[
	The first beat, as the snails drop in: the screen's edges darken, GET READY fades in letter-spaced over a gold line
	that draws out from the middle, under the drop-in build (Match_DropIn).
]]
function Module._getReady()
	--[[ Local Variables ]]

	plays += 1

	--[[ Resetting ]]

	Module._coverScreen()
	elems["Intro"].Visible = true
	elems["Slam"].Visible = false
	elems["Flash"].BackgroundTransparency = 1
	elems["ReadyText"].TextTransparency = 1
	elems["ReadyText"].UIStroke.Transparency = 1
	elems["ReadyLine"].Size = UDim2.fromScale(0, elems["ReadyLine"].Size.Y.Scale)
	elems["ReadyScale"].Scale = _settings.INTRO_READY_START_SCALE
	for _index: number, edge: Frame in ipairs(elems["Vignette"]) do
		edge.BackgroundTransparency = 1
	end

	--[[ Showing ]]

	for _index: number, edge: Frame in ipairs(elems["Vignette"]) do
		Module._tween(edge, _settings.INTRO_VIGNETTE_TWEENINFO, { BackgroundTransparency = _settings.INTRO_VIGNETTE_TRANSPARENCY })
	end
	Module._tween(elems["ReadyText"], _settings.INTRO_READY_TWEENINFO, { TextTransparency = 0 })
	Module._tween(elems["ReadyText"].UIStroke, _settings.INTRO_READY_TWEENINFO, { Transparency = 0 })
	Module._tween(elems["ReadyScale"], _settings.INTRO_READY_TWEENINFO, { Scale = 1 })
	Module._tween(elems["ReadyLine"], _settings.INTRO_LINE_TWEENINFO, { Size = UDim2.fromScale(1, elems["ReadyLine"].Size.Y.Scale) })
	I.Sound.Play({ Name = "Match_DropIn", SoundGroup = "SFX" })
end

--%%%%%%%%%%%%%%%%%%%% Slam

--[[
	The second beat, as the snails have all landed: GET READY goes, a white flash, THE BATTLE over a huge gold BEGINS!
	slams in tilted from INTRO_SLAM_START_SCALE with a gold shockwave ring, a streak of light and a spark burst, the hit
	(Match_BattleBegins), a jolt of the camera, a tap on a phone or pad and the camera punching in on the player's snail;
	it holds, then zooms out and fades with the vignette.
]]
function Module._slam()
	--[[ Local Variables ]]

	plays += 1
	local play: number = plays

	--[[ Ready Out ]]

	Module._coverScreen()
	elems["Intro"].Visible = true
	Module._tween(elems["ReadyText"], _settings.INTRO_OUT_TWEENINFO, { TextTransparency = 1 })
	Module._tween(elems["ReadyText"].UIStroke, _settings.INTRO_OUT_TWEENINFO, { Transparency = 1 })
	Module._tween(elems["ReadyLine"], _settings.INTRO_OUT_TWEENINFO, { Size = UDim2.fromScale(0, elems["ReadyLine"].Size.Y.Scale) })
	for _index: number, edge: Frame in ipairs(elems["Vignette"]) do
		edge.BackgroundTransparency = _settings.INTRO_VIGNETTE_TRANSPARENCY
	end

	--[[ Slam In ]]

	elems["Flash"].BackgroundTransparency = _settings.INTRO_FLASH_TRANSPARENCY
	Module._tween(elems["Flash"], _settings.INTRO_FLASH_TWEENINFO, { BackgroundTransparency = 1 })
	Module._setSlamTransparency(0)
	local mainSize: number = elems["Gui"].AbsoluteSize.Y * _settings.INTRO_MAIN_TEXT_SHARE
	elems["MainScale"].Scale = mainSize / elems["SlamMain"].TextSize
	elems["SlamMain"].Size = UDim2.fromOffset(elems["SlamMain"].TextBounds.X + 40, elems["SlamMain"].TextSize * 1.15)
	elems["SlamScale"].Scale = _settings.INTRO_SLAM_START_SCALE
	elems["Slam"].Rotation = _settings.INTRO_SLAM_START_ROTATION
	elems["Slam"].Visible = true
	Module._tween(elems["SlamScale"], _settings.INTRO_SLAM_TWEENINFO, { Scale = 1 })
	Module._tween(elems["Slam"], _settings.INTRO_SLAM_TWEENINFO, { Rotation = _settings.INTRO_SLAM_ROTATION })

	--[[ Shockwave ]]

	elems["Shock"].Size = UDim2.fromScale(0.25, 0.25)
	elems["Shock"].UIStroke.Transparency = 0
	Module._tween(elems["Shock"], _settings.INTRO_SHOCK_TWEENINFO, { Size = UDim2.fromScale(_settings.INTRO_SHOCK_SIZE, _settings.INTRO_SHOCK_SIZE) })
	Module._tween(elems["Shock"].UIStroke, _settings.INTRO_SHOCK_TWEENINFO, { Transparency = 1 })
	elems["Streak"].Size = UDim2.fromScale(0, elems["Streak"].Size.Y.Scale)
	elems["Streak"].BackgroundTransparency = 0.1
	Module._tween(elems["Streak"], _settings.INTRO_SHOCK_TWEENINFO, { Size = UDim2.fromScale(_settings.INTRO_STREAK_WIDTH, elems["Streak"].Size.Y.Scale), BackgroundTransparency = 1 })

	--[[ Sparks ]]

	if not sparks then
		sparks = I.UIEmitter.new({
			Parent = elems["Slam"],
			Texture = _settings.INTRO_SPARK_TEXTURE,
			Rate = 0,
			Lifetime = NumberRange.new(0.45, 0.95),
			Velocity = NumberRange.new(320, 760),
			SpreadAngle = 180,
			Drag = 0.45,
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.15, 0.07),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Color = ColorSequence.new(Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 150, 30)),
			ZIndex = 43,
		})
	end
	sparks:Emit(_settings.INTRO_SPARKS)

	--[[ Feel ]]

	I.Sound.Play({ Name = "Match_BattleBegins", SoundGroup = "SFX" })
	if not shaker then
		shaker = I.CameraShake.new(I.S.Workspace.CurrentCamera)
	end
	shaker:PlayOnce({
		Magnitude = _settings.INTRO_SHAKE,
		Roughness = 30,
		PositionInfluence = Vector3.new(0.5, 0.5, 0),
		RotationInfluence = Vector3.new(0, 0, 0.6),
	}, 0.03, 0.01, _settings.INTRO_SHAKE_SETTLE)
	I.Haptic.PlayOnce("Match_YourTurn")
	local mine: Model? = I.Snails.Get(I.Match.GetMyParticipantId() or "")
	if mine then
		I.MatchCamera.PunchIn(mine:GetPivot().Position)
	end

	--[[ Zoom Out ]]

	task.delay(_settings.INTRO_SLAM_TWEENINFO.Time + _settings.INTRO_SLAM_HOLD, function()
		-- A newer intro has the screen
		if play ~= plays then
			return
		end
		Module._tween(elems["SlamScale"], _settings.INTRO_OUT_TWEENINFO, { Scale = _settings.INTRO_SLAM_END_SCALE })
		Module._setSlamTransparency(1)
		for _index: number, edge: Frame in ipairs(elems["Vignette"]) do
			Module._tween(edge, _settings.INTRO_OUT_TWEENINFO, { BackgroundTransparency = 1 })
		end
		task.delay(_settings.INTRO_OUT_TWEENINFO.Time, function()
			if play == plays then
				elems["Intro"].Visible = false
			end
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Set Slam Transparency

--[[
	Shows the slam's two lines at once (0), or fades them and their outlines out (1).
]]
function Module._setSlamTransparency(transparency: number)
	--[[ Applying ]]

	--- @param label TextLabel
	for _index: number, label in ipairs({ elems["SlamTop"], elems["SlamMain"] }) do
		if transparency == 0 then
			label.TextTransparency = 0
			label.UIStroke.Transparency = 0
		else
			Module._tween(label, _settings.INTRO_OUT_TWEENINFO, { TextTransparency = transparency })
			Module._tween(label.UIStroke, _settings.INTRO_OUT_TWEENINFO, { Transparency = transparency })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Cover Screen

--[[
	Stretches the intro over the whole device screen, past the HUD's safe area (Roblox's top bar row and a phone's
	notch sides), and its dark edges and flash INTRO_COVER_BLEED further, so they reach every edge on every screen shape
	instead of stopping in a box (the owner's phone, 2026-11-25).
]]
function Module._coverScreen()
	--[[ Local Variables ]]

	local gui: ScreenGui = elems["Gui"]
	local padding: number = gui:FindFirstChild("U_Inset").PaddingTop.Offset
	local device: Vector2 = I.S.Workspace.CurrentCamera.ViewportSize

	-- The device's top left corner from the gui's area: gui positions always count from under Roblox's inset, so the corner is minus the inset, whatever the gui's ScreenInsets (measured 2026-11-25: an inset-ignoring gui sits at 0, -58)
	local corner: Vector2 = -I.S.GuiService:GetGuiInset() - gui.AbsolutePosition - Vector2.new(0, padding)

	-- A gui over the whole screen (every device but consoles) is the device: on an iPhone the camera's viewport leaves out the notch sides (the owner's capture, 2026-11-25)
	if gui.ScreenInsets == Enum.ScreenInsets.None then
		device = gui.AbsoluteSize
		corner = Vector2.new(0, -padding)
	end
	local middle: Vector2 = corner + device / 2

	--[[ Applying ]]

	elems["Intro"].Position = UDim2.fromOffset(middle.X, middle.Y)
	elems["Intro"].Size = UDim2.fromOffset(device.X, device.Y)

	--[[ Bleeding ]]

	-- Every edge and the flash run INTRO_COVER_BLEED past the screen, solid out there, so a screen edge the gui's area misses (a phone's notch side) is dark too
	local bleed: number = device.X * _settings.INTRO_COVER_BLEED
	local top: Frame = elems["Vignette"][1]
	local bottom: Frame = elems["Vignette"][2]
	local left: Frame = elems["Vignette"][3]
	local right: Frame = elems["Vignette"][4]
	top.Size = UDim2.new(1, bleed * 2, _settings.INTRO_VIGNETTE_DEPTH.Y, bleed)
	top.Position = UDim2.fromOffset(-bleed, -bleed)
	bottom.Size = top.Size
	bottom.Position = UDim2.new(0, -bleed, 1, bleed)
	left.Size = UDim2.new(_settings.INTRO_VIGNETTE_DEPTH.X, bleed, 1, bleed * 2)
	left.Position = UDim2.fromOffset(-bleed, -bleed)
	right.Size = left.Size
	right.Position = UDim2.new(1, bleed, 0, -bleed)
	elems["Flash"].Size = UDim2.new(1, bleed * 2, 1, bleed * 2)
	elems["Flash"].Position = UDim2.fromOffset(-bleed, -bleed)

	-- Each edge's fade starts where the screen does: solid over the bleed
	local acrossShare: number = bleed / (device.Y * _settings.INTRO_VIGNETTE_DEPTH.Y + bleed)
	local sideShare: number = bleed / (device.X * _settings.INTRO_VIGNETTE_DEPTH.X + bleed)
	--- @param edge Frame
	for index: number, edge in ipairs(elems["Vignette"]) do
		local share: number = if index <= 2 then acrossShare else sideShare
		edge.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(share, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Tween

--[[
	Plays one tween on an instance.
]]
--- @param goal { [string]: any }
function Module._tween(instance: Instance, info: TweenInfo, goal)
	--[[ Playing ]]

	local Intro_TweenInfo: TweenInfo = info
	local Intro_TweenGoal = goal
	local Intro_Tween: Tween = I.S.TweenService:Create(instance, Intro_TweenInfo, Intro_TweenGoal)
	Intro_Tween:Play()
end

return Module
