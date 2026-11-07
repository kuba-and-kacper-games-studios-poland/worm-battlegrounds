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
local arenaFolder: Folder

-- The DropMarker billboard's holder (PREFAB | DropMarker) in Assets.Match
local templates: Folder

-- The markers shown during the drop, by participant id
local markers = {} --- @type { [string]: BasePart }

--- @type OverlapParams
local terrainParams = OverlapParams.new()

--[[ Picking ]]

local picking: boolean = false
local pick: Vector2 = Vector2.zero
local stick: Vector2 = Vector2.zero

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
	arenaFolder = I.Dirs.UmeWorkspace:WaitForChild("Arena")
	templates = I.Dirs.Assets:FindFirstChild(_localName)
	terrainParams.FilterType = Enum.RaycastFilterType.Include

	--[[ Connections ]]

	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.UserInputService.InputBegan:Connect(Module._onInputBegan)
	I.S.UserInputService.TouchTap:Connect(Module._onTouchTap)
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
	pick = if mine then Vector2.new(mine:GetAttribute("DropX") or 0, mine:GetAttribute("DropY") or 0) else Vector2.zero
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Moves the local player's spot under the mouse, and remembers the left stick's lean.
]]
function Module._onInputChanged(input: InputObject)
	--[[ Checks ]]

	-- Check if the drop is running
	if not picking then
		return
	end

	--[[ Applying ]]

	if input.KeyCode == Enum.KeyCode.Thumbstick1 then
		stick = if input.Position.Magnitude > 0.2 then Vector2.new(input.Position.X, input.Position.Y) else Vector2.zero
	elseif input.UserInputType == Enum.UserInputType.MouseMovement then
		pick = Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y))
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Began

--[[
	Places the spot on a left click or the gamepad's A button.
]]
function Module._onInputBegan(input: InputObject, gameProcessed: boolean)
	--[[ Checks ]]

	-- Check if the drop is running and the press isn't on a gui
	if not picking or gameProcessed then
		return
	end

	--[[ Placing ]]

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonA then
		Module._place()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Touch Tap

--[[
	Places the spot where a finger taps; a drag pans the camera instead.
]]
--- @param positions { Vector2 }
function Module._onTouchTap(positions, gameProcessed: boolean)
	--[[ Checks ]]

	-- Check if the drop is running and the tap isn't on a gui
	if not picking or gameProcessed then
		return
	end

	--[[ Placing ]]

	pick = Module._getPlanePoint(positions[1])
	Module._place()
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Sends the picked spot to the server when a snail fits there; the server checks it again.
]]
function Module._place()
	--[[ Checks ]]

	-- Check if a snail fits on the spot
	if not Module._isFree(pick) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Match_PickDrop", pick.X, pick.Y)
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	While the drop runs: moves the spot with the stick and keeps a marker over every participant's spot. The local
	player's marker follows their pick until they place it, faded where a snail doesn't fit; others' are faded until
	they place theirs.
]]
function Module._update(deltaTime: number)
	--[[ Checks ]]

	-- Check if the drop is running
	if not picking then
		return
	end

	--[[ Picking ]]

	pick = Vector2.new(
		math.clamp(pick.X + stick.X * _settings.DROP_STICK_SPEED * deltaTime, matchFolder:GetAttribute("DropMinX") or 0, matchFolder:GetAttribute("DropMaxX") or 0),
		math.clamp(pick.Y + stick.Y * _settings.DROP_STICK_SPEED * deltaTime, matchFolder:GetAttribute("DropMinY") or 0, matchFolder:GetAttribute("DropMaxY") or 0)
	)

	--[[ Markers ]]

	local myId: string = I.Match.GetMyParticipantId()
	for _index: number, entry: Instance in ipairs(matchFolder:FindFirstChild("Participants"):GetChildren()) do
		local placedSpot: boolean = entry:GetAttribute("Placed") == true
		local following: boolean = entry.Name == myId and not placedSpot
		local x: number? = if following then pick.X else entry:GetAttribute("DropX")
		local y: number? = if following then pick.Y else entry:GetAttribute("DropY")
		if x and y then
			local marker: BasePart = markers[entry.Name] or Module._createMarker(entry)
			local solid: boolean = if following then Module._isFree(pick) else placedSpot
			marker.Position = Vector3.new(x, y, 0)
			marker:FindFirstChild("S_Pin", true).ImageTransparency = if solid then 0 else 0.6
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
	local marker: BillboardGui = templates:FindFirstChild("U_DropMarker", true):Clone()

	--[[ Elements ]]

	local nameLabel: TextLabel = marker:FindFirstChild("S_Name", true)
	local pin: ImageLabel = marker:FindFirstChild("S_Pin", true)

	--[[ Applying ]]

	marker.Name = "DropMarker"
	marker.Adornee = part
	marker.AlwaysOnTop = true
	marker.SizeOffset = Vector2.new(0, 0.5)
	nameLabel.Text = entry:GetAttribute("DisplayName")
	nameLabel.TextColor3 = entry:GetAttribute("Color")
	pin.ImageColor3 = entry:GetAttribute("Color")
	I.ScreenScale.AddBillboard(marker)
	marker.Parent = part

	--[[ Saving ]]

	markers[entry.Name] = part
	return part
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Plane Point

--[[
	Returns where on the arena's plane (Z = 0) a point of the screen is.
]]
--- @return Vector2
function Module._getPlanePoint(screenPoint: Vector2)
	--[[ Local Variables ]]

	local ray: Ray = I.S.Workspace.CurrentCamera:ScreenPointToRay(screenPoint.X, screenPoint.Y)

	--[[ Checks ]]

	-- Check if the ray crosses the plane (the camera looks along -Z, so it always should)
	if math.abs(ray.Direction.Z) < 1e-4 then
		return pick
	end

	--[[ Returning ]]

	local hit: Vector3 = ray.Origin + ray.Direction * (-ray.Origin.Z / ray.Direction.Z)
	return Vector2.new(hit.X, hit.Y)
end

--%%%%%%%%%%%%%%%%%%%% Is Free

--[[
	Returns whether a snail fits on a spot as this client sees the arena: touching no terrain and out of liquid, inside
	the play area. The server's I.Arena.IsFree decides.
]]
--- @return boolean
function Module._isFree(spot: Vector2)
	--[[ Data ]]

	local terrain: Instance? = arenaFolder:FindFirstChild("Terrain")
	local liquid: Instance? = arenaFolder:FindFirstChild("Liquid")

	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local position: Vector3 = Vector3.new(spot.X, spot.Y, 0)

	--[[ Checks ]]

	-- Check if the ball is inside the play area
	if spot.X - radius < (matchFolder:GetAttribute("DropMinX") or 0) or spot.X + radius > (matchFolder:GetAttribute("DropMaxX") or 0) then
		return false
	end
	if spot.Y - radius < (matchFolder:GetAttribute("DropMinY") or 0) or spot.Y + radius > (matchFolder:GetAttribute("DropMaxY") or 0) then
		return false
	end

	-- Check if the spot is out of every liquid block (they block no queries, so their boxes are read)
	for _index: number, block: Instance in ipairs(if liquid then liquid:GetChildren() else {}) do
		local inside: Vector3 = block.CFrame:PointToObjectSpace(position)
		if math.abs(inside.X) <= block.Size.X / 2 and math.abs(inside.Y) <= block.Size.Y / 2 then
			return false
		end
	end

	--[[ Returning ]]

	terrainParams.FilterDescendantsInstances = if terrain then { terrain } else {}
	return #I.S.Workspace:GetPartBoundsInRadius(position, radius, terrainParams) == 0
end

return Module
