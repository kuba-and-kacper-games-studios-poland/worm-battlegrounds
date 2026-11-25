--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Transition"

--- @type Transition_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local TransitionMotion = require(game:GetService("ReplicatedFirst"):FindFirstChild("TransitionMotion")) --- @type TransitionMotion

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Where the next teleport goes, as the server last said, and the card showing it
local destination = nil --- @type Transition_Destination?
local card: ScreenGui? = nil
local random: Random = Random.new()

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.Network.Fired("Transition_Destination", Module._onDestination)
	I.S.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui").ChildAdded:Connect(Module._onGuiAdded)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Checks ]]

	-- Check if the player came by teleport, with the card the arrival script takes off once this client started
	if not I.S.TeleportService:GetArrivingTeleportGui() then
		return
	end

	--[[ Playing ]]

	I.Sound.Play({ Name = "Teleport_In", SoundGroup = "UI" })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Destination

--[[
	Keeps where the next teleport goes, and shows it on the card when one is up: a search that found its match whips
	to the map and punches its name in.
]]
--- @param newDestination Transition_Destination
function Module._onDestination(newDestination)
	--[[ Local Variables ]]

	local searching: boolean = destination ~= nil and destination.Pool ~= nil and destination.MapId == nil

	--[[ Saving ]]

	destination = newDestination

	--[[ Applying ]]

	if card then
		Module._fill(card, searching and newDestination.MapId ~= nil)
		Module._handOver(card)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Gui Added

--[[
	Puts the teleport card up when a teleport clones it in: its scene whips in over the game, its plate rises, and its
	whoosh plays (Teleport_Out). A card that comes while one already shows (the server's `Show` for a Join, then the
	teleport's own) takes over its scene, clock and progress and sits where it is. Roblox gets a fresh copy to hold
	through the teleport for as long as it shows.
]]
function Module._onGuiAdded(gui: Instance)
	--[[ Checks ]]

	-- Skip every gui but the teleport card
	if gui.Name ~= _settings.GUI_NAME or not gui:IsA("ScreenGui") then
		return
	end

	--[[ Local Variables ]]

	local shown: ScreenGui? = card

	--[[ Saving ]]

	card = gui
	gui.Destroying:Once(function()
		if card == gui then
			card = nil
		end
	end)

	--[[ Taking Over ]]

	-- The card already covers the screen: the new one carries on with its scene where it is
	if shown then
		local backdrop: Frame = gui:FindFirstChild("U_Backdrop")
		backdrop:FindFirstChild("U_Scene"):Destroy()
		shown:FindFirstChild("U_Scene", true).Parent = backdrop
		for _index: number, name: string in ipairs({ "Transition_Clock", "Transition_Progress", "Transition_Scene", "Transition_Tip" }) do
			gui:SetAttribute(name, shown:GetAttribute(name))
		end
		Module._fill(gui, false)
		TransitionMotion.Play(gui)
		shown:Destroy()
	else
		Module._fill(gui, false)
		TransitionMotion.Play(gui)
		TransitionMotion.Intro(gui)
		I.Sound.Play({ Name = "Teleport_Out", SoundGroup = "UI" })
	end

	--[[ Keeping Up ]]

	Module._handOver(gui)
	task.spawn(Module._keepUp, gui)
end

--%%%%%%%%%%%%%%%%%%%% Fill

--[[
	Writes the destination on a card in capitals (Roblox carries the card past the TextCase module, so it writes them
	itself), builds the scenes it shows, picks the one up now and paints the plate in its accent colour.
]]
function Module._fill(gui: ScreenGui, found: boolean)
	--[[ Data ]]

	local shown = destination or _settings.DEFAULT_DESTINATION --- @type Transition_Destination

	--[[ Elements ]]

	local plate: Frame = gui:FindFirstChild("U_Plate", true)
	local kicker: TextLabel = plate:FindFirstChild("S_Kicker")
	local title: TextLabel = plate:FindFirstChild("S_Title")
	local info: TextLabel = plate:FindFirstChild("S_Info")
	local modeIcon: ImageLabel = plate:FindFirstChild("S_ModeIcon")
	local tip: TextLabel = plate:FindFirstChild("S_Tip")
	local accented = { plate:FindFirstChild("S_KickerBar"), plate:FindFirstChild("S_TipChip"), plate:FindFirstChild("S_Track"):FindFirstChild("Fill") } --- @type { Frame }

	--[[ Scenes ]]

	local names = if shown.MapId then { shown.MapId } elseif shown.Pool then shown.Pool else { _settings.LOBBY_SCENE } --- @type { string }
	for _index: number, name: string in ipairs(names) do
		Module._buildScene(gui, name)
	end
	local current: string? = gui:GetAttribute("Transition_Scene")
	local scene: string = if shown.MapId then shown.MapId elseif current and table.find(names, current) then current else names[1]
	local searching: boolean = shown.Pool ~= nil and shown.MapId == nil
	gui:SetAttribute("Transition_Scene", scene)
	gui:SetAttribute("Transition_Searching", searching)

	--[[ Texts ]]

	local parts = {} --- @type { string }
	for _index: number, part: string? in ipairs({ shown.Mode, shown.Detail }) do
		if part and part ~= "" then
			table.insert(parts, string.upper(part))
		end
	end
	kicker.Text = string.upper(shown.Kicker)
	title.Text = string.upper(shown.Title)
	info.Text = if #parts == 2 then `{parts[1]}  <font transparency="0.3">·  {parts[2]}</font>` else parts[1] or ""
	modeIcon.Image = shown.ModeIcon or ""
	modeIcon.Visible = shown.ModeIcon ~= nil
	info.Position = UDim2.fromScale(if modeIcon.Visible then 0.084 else 0.054, info.Position.Y.Scale)

	--[[ Tip ]]

	local tipIndex: number = gui:GetAttribute("Transition_Tip") or random:NextInteger(1, #_settings.TIPS)
	gui:SetAttribute("Transition_Tip", tipIndex)
	tip.Text = string.upper(_settings.TIPS[tipIndex])

	--[[ Colours ]]

	-- A search is in the game's yellow; a destination wears its map's accent
	local accent: Color3 = if searching then _settings.DEFAULT_LOOK.Accent else Module._getLook(scene).Accent
	kicker.TextColor3 = accent
	for _index: number, frame: Frame in ipairs(accented) do
		frame.BackgroundColor3 = accent
	end
	for _index: number, dot: Instance in ipairs(plate:FindFirstChild("S_Dots"):GetChildren()) do
		if dot:IsA("Frame") then
			dot.BackgroundColor3 = accent
		end
	end

	--[[ Punch ]]

	if found then
		local titleScale: UIScale = title:FindFirstChild("S_TitleScale")
		titleScale.Scale = _settings.TITLE_PUNCH
		local Punch_TweenGoal = { Scale = 1 }
		local Punch_Tween: Tween = I.S.TweenService:Create(titleScale, _settings.TITLE_PUNCH_TWEENINFO, Punch_TweenGoal)
		Punch_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Build Scene

--[[
	Builds one map's scene on a card, once: its sky, its Atmosphere Parallax rows as layers (the motion places them
	every frame from their attributes) and its weather.
]]
function Module._buildScene(gui: ScreenGui, name: string)
	--[[ Elements ]]

	local scenes: Frame = gui:FindFirstChild("U_Scene", true)

	--[[ Checks ]]

	-- Check if the card already has this scene
	if scenes:FindFirstChild(name) then
		return
	end

	--[[ Data ]]

	local look = Module._getLook(name) --- @type Transition_Look
	local profiles = I.Settings["Atmosphere"].PROFILES --- @type { [string]: Atmosphere_Profile }
	local own = profiles[name] --- @type Atmosphere_Profile?
	local rows = Module._getRows(name) --- @type { Atmosphere_ParallaxRow }

	--[[ Local Variables ]]

	local sky: string = look.Sky or (own and own.Sky and own.Sky.SkyboxFt) or _settings.LOBBY_LOOK.Sky
	local spans = {} --- @type { [number]: number }
	for _index: number, row: Atmosphere_ParallaxRow in ipairs(rows) do
		if row.Image and row.Bottom < _settings.CLOUD_MIN_BOTTOM then
			spans[row.Depth] = (spans[row.Depth] or 0) + row.Width
		end
	end
	local sorted = table.clone(rows) --- @type { Atmosphere_ParallaxRow }
	table.sort(sorted, function(a: Atmosphere_ParallaxRow, b: Atmosphere_ParallaxRow)
		return a.Depth > b.Depth
	end)

	--[[ Building ]]

	local scene: Frame = Instance.new("Frame")
	scene.Name = name
	scene.BackgroundTransparency = 1
	scene.BorderSizePixel = 0
	scene.Size = UDim2.fromScale(1, 1)
	scene.Visible = false
	scene.ZIndex = 1

	local skyLabel: ImageLabel = Instance.new("ImageLabel")
	skyLabel.Name = "Sky"
	skyLabel.BackgroundTransparency = 1
	skyLabel.BorderSizePixel = 0
	skyLabel.Image = sky
	skyLabel.ZIndex = 1
	skyLabel:SetAttribute("L_Kind", "Sky")
	skyLabel:SetAttribute("L_Horizon", look.Horizon)
	skyLabel.Parent = scene

	--- @param row Atmosphere_ParallaxRow
	for index: number, row in ipairs(sorted) do
		local element: GuiObject
		if row.Image then
			local image: ImageLabel = Instance.new("ImageLabel")
			image.BackgroundTransparency = 1
			image.Image = row.Image
			image.ImageTransparency = row.Transparency or 0
			element = image
		else
			local fill: Frame = Instance.new("Frame")
			fill.BackgroundColor3 = row.Color
			element = fill
		end
		local kind: string = if not row.Image then "Fill" elseif row.Bottom >= _settings.CLOUD_MIN_BOTTOM then "Cloud" else "Tile"
		element.Name = kind
		element.BorderSizePixel = 0
		element.ZIndex = index + 1
		element:SetAttribute("L_Kind", kind)
		element:SetAttribute("L_X", row.X)
		element:SetAttribute("L_Bottom", row.Bottom)
		element:SetAttribute("L_Width", row.Width)
		element:SetAttribute("L_Height", row.Height)
		element:SetAttribute("L_Depth", row.Depth)
		element:SetAttribute("L_Span", spans[row.Depth])
		element.Parent = scene
	end

	Module._addWeather(scene, look.Weather, #sorted + 2)
	scene.Parent = scenes
end

--%%%%%%%%%%%%%%%%%%%% Add Weather

--[[
	Scatters a weather's squares through a scene, each at its own depth, speed and phase.
]]
function Module._addWeather(scene: Frame, weather: string, zIndex: number)
	--[[ Data ]]

	local weatherRows = _settings.WEATHER[weather] --- @type { Transition_WeatherRow }

	--[[ Building ]]

	--- @param row Transition_WeatherRow
	for _rowIndex: number, row in ipairs(weatherRows) do
		for _index: number = 1, row.Count do
			local mote: Frame = Instance.new("Frame")
			local transparency: number = random:NextNumber(row.Transparency.Min, row.Transparency.Max)
			mote.Name = "Mote"
			mote.AnchorPoint = Vector2.new(0.5, 0.5)
			mote.BackgroundColor3 = row.Colors[random:NextInteger(1, #row.Colors)]
			mote.BackgroundTransparency = transparency
			mote.BorderSizePixel = 0
			mote.ZIndex = zIndex
			mote:SetAttribute("L_Kind", "Mote")
			mote:SetAttribute("L_Alpha", transparency)
			mote:SetAttribute("M_Depth", random:NextNumber(row.Depth.Min, row.Depth.Max))
			mote:SetAttribute("M_U", random:NextNumber())
			mote:SetAttribute("M_V", random:NextNumber())
			mote:SetAttribute("M_VX", random:NextNumber(row.SpeedX.Min, row.SpeedX.Max))
			mote:SetAttribute("M_VY", random:NextNumber(row.SpeedY.Min, row.SpeedY.Max))
			mote:SetAttribute("M_Size", random:NextNumber(row.Size.Min, row.Size.Max))
			mote:SetAttribute("M_Thick", row.Thick or 0)
			mote:SetAttribute("M_Low", row.Low == true)
			mote:SetAttribute("M_Wobble", row.Wobble)
			mote:SetAttribute("M_Bob", row.Bob)
			mote:SetAttribute("M_Spin", random:NextNumber(-row.Spin, row.Spin))
			mote:SetAttribute("M_Phase", random:NextNumber(0, math.pi * 2))
			mote.Parent = scene
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Keep Up

--[[
	While a card shows: hands Roblox a fresh copy every HANDOVER_SECONDS, changes the tip every TIP_SECONDS, and while
	a match is being found whips to the pool's next map every SEARCH_WHIP_SECONDS.
]]
function Module._keepUp(gui: ScreenGui)
	--[[ Elements ]]

	local tip: TextLabel = gui:FindFirstChild("S_Tip", true)

	--[[ Local Variables ]]

	local handedAt: number = os.clock()
	local tipAt: number = os.clock()
	local whipAt: number = os.clock()

	--[[ Looping ]]

	while card == gui do
		task.wait(0.1)
		local now: number = os.clock()

		-- A fresh copy for Roblox to hold
		if now - handedAt >= _settings.HANDOVER_SECONDS then
			handedAt = now
			Module._handOver(gui)
		end

		-- The next tip
		if now - tipAt >= _settings.TIP_SECONDS then
			tipAt = now
			local tipIndex: number = gui:GetAttribute("Transition_Tip") % #_settings.TIPS + 1
			gui:SetAttribute("Transition_Tip", tipIndex)
			tip.Text = string.upper(_settings.TIPS[tipIndex])
		end

		-- The pool's next map while searching
		local pool = destination and destination.Pool --- @type { string }?
		if gui:GetAttribute("Transition_Searching") and pool and now - whipAt >= _settings.SEARCH_WHIP_SECONDS then
			whipAt = now
			local index: number = table.find(pool, gui:GetAttribute("Transition_Scene")) or 0
			gui:SetAttribute("Transition_Scene", pool[index % #pool + 1])
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Hand Over

--[[
	Gives Roblox a copy of the card, settled as it shows now with only its current scene, to show while it teleports
	and to hand to the next server.
]]
function Module._handOver(gui: ScreenGui)
	--[[ Elements ]]

	local backdrop: Frame = gui:FindFirstChild("U_Backdrop")

	--[[ Building ]]

	local copy: ScreenGui = gui:Clone()
	TransitionMotion.Settle(copy, backdrop.AbsoluteSize)

	--[[ Applying ]]

	I.S.TeleportService:SetTeleportGui(copy)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Look

--[[
	Returns a scene's look: the lobby's, a map's own, or the default.
]]
--- @return Transition_Look
function Module._getLook(name: string)
	--[[ Returning ]]

	if name == _settings.LOBBY_SCENE then
		return _settings.LOBBY_LOOK
	end
	return _settings.LOOKS[name] or _settings.DEFAULT_LOOK
end

--%%%%%%%%%%%%%%%%%%%% Get Rows

--[[
	Returns the Parallax rows a scene draws: its map's own; none for the lobby or a map without them.
]]
--- @return { Atmosphere_ParallaxRow }
function Module._getRows(name: string)
	--[[ Data ]]

	local profile = I.Settings["Atmosphere"].PROFILES[name] --- @type Atmosphere_Profile?

	--[[ Returning ]]

	return if profile and profile.Parallax then profile.Parallax else {}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
