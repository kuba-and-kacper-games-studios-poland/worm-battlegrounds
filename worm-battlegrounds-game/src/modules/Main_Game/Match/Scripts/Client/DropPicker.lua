--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ World ]]

local matchFolder: Folder
local templates: Folder

-- The markers shown during the drop, by participant id
local markers = {} --- @type { [string]: BasePart }

--[[ Picking ]]

local picking: boolean = false
local pickX: number = 0
local sentX: number? = nil
local lastSent: number = 0
local stickX: number = 0

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

--- @class Match_Client_DropPicker
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Saving ]]

	matchFolder = folder
	templates = I.Dirs.UmeReplicated:WaitForChild(_localName)

	--[[ Connections ]]

	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.RunService.RenderStepped:Connect(Module._update)
	Module._onPhaseChanged(I.Match.GetPhase())
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	Starts picking (and shows everyone's markers) when the drop begins, and removes the markers when it ends.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Applying ]]

	picking = phase == "Drop"
	if not picking then
		for _id: string, marker: BasePart in pairs(markers) do
			marker:Destroy()
		end
		markers = {}
		return
	end

	--[[ Starting ]]

	local mine: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	pickX = if mine then mine:GetAttribute("DropX") or 0 else 0
	sentX = pickX
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Moves the local player's spot under the mouse or a dragged finger, and remembers the left stick's lean.
]]
function Module._onInputChanged(input: InputObject)
	--[[ Checks ]]

	-- Check if the drop is running
	if not picking then
		return
	end

	--[[ Applying ]]

	if input.KeyCode == Enum.KeyCode.Thumbstick1 then
		stickX = if math.abs(input.Position.X) > 0.2 then input.Position.X else 0
	elseif input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		pickX = Module._getPlaneX(Vector2.new(input.Position.X, input.Position.Y))
	end
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	While the drop runs: moves the spot with the stick, sends it at most ten times a second when it moved, and keeps a
	marker over every participant's spot.
]]
function Module._update(deltaTime: number)
	--[[ Checks ]]

	-- Check if the drop is running
	if not picking then
		return
	end

	--[[ Picking ]]

	local low: number = matchFolder:GetAttribute("DropMinX") or 0
	local high: number = matchFolder:GetAttribute("DropMaxX") or 0
	pickX = math.clamp(pickX + stickX * _settings.DROP_STICK_SPEED * deltaTime, low, high)
	if pickX ~= sentX and os.clock() - lastSent >= 0.1 then
		sentX = pickX
		lastSent = os.clock()
		I.Network.Fire("Match_PickDrop", pickX)
	end

	--[[ Markers ]]

	local height: number = matchFolder:GetAttribute("DropY") or 0
	local myId: string = I.Match.GetMyParticipantId()
	for _index: number, entry: Instance in ipairs(matchFolder:FindFirstChild("Participants"):GetChildren()) do
		local x: number? = if entry.Name == myId then pickX else entry:GetAttribute("DropX")
		if x then
			local marker: BasePart = markers[entry.Name] or Module._createMarker(entry)
			marker.Position = Vector3.new(x, height, 0)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Marker

--[[
	Makes a participant's drop marker: the DropMarker billboard, with their name and colour, on an invisible part.
]]
--- @return BasePart
function Module._createMarker(entry: Instance)
	--[[ Cloning ]]

	local part: Part = I.Create("Part")({
		Name = `Drop_{entry.Name}`,
		Size = Vector3.one,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Parent = matchFolder,
	})
	local marker: BillboardGui = templates:FindFirstChild("DropMarker"):Clone()

	--[[ Elements ]]

	local nameLabel: TextLabel = marker:FindFirstChild("S_Name", true)
	local pin: ImageLabel = marker:FindFirstChild("S_Pin", true)

	--[[ Applying ]]

	marker.Adornee = part
	marker.AlwaysOnTop = true
	marker.SizeOffset = Vector2.new(0, 0.5)
	nameLabel.Text = entry:GetAttribute("DisplayName")
	nameLabel.TextColor3 = entry:GetAttribute("Color")
	pin.ImageColor3 = entry:GetAttribute("Color")
	marker.Parent = part

	--[[ Saving ]]

	markers[entry.Name] = part
	return part
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Plane X

--[[
	Returns where on the arena's plane (Z = 0) a point of the screen is, along X.
]]
--- @return number
function Module._getPlaneX(screenPoint: Vector2)
	--[[ Local Variables ]]

	local ray: Ray = I.S.Workspace.CurrentCamera:ScreenPointToRay(screenPoint.X, screenPoint.Y)

	--[[ Returning ]]

	-- The camera looks along -Z, so the ray always crosses the plane
	if math.abs(ray.Direction.Z) < 1e-4 then
		return pickX
	end
	return (ray.Origin + ray.Direction * (-ray.Origin.Z / ray.Direction.Z)).X
end

return Module
