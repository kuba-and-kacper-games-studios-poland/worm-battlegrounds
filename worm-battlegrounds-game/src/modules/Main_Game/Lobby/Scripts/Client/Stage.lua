--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Stage ]]

local worldFolder: Folder
local stage: Model
local cameraMarker: BasePart

-- The stage's own pods (the party's) and the custom lobby's eight, only one set standing in the stage at a time
local partyPods: Folder
local customPods: Model

-- Where each pod's snail stands, the player's pod first: the party's, the custom lobby's, and the set in use
local partyMarkers = {} --- @type { BasePart }
local customMarkers = {} --- @type { BasePart }
local snailMarkers = {} --- @type { BasePart }

--[[ Snails ]]

-- Each member's snail on the stage, the outfit it wears, how far it's lifted to keep its feet on its pod, and its pose
local snails = {} --- @type { [Player]: Model }
local snailSkins = {} --- @type { [Player]: string }
local snailLifts = {} --- @type { [Player]: number }
local snailPoses = {} --- @type { [Player]: AnimationTrack }

-- The pose each member played last, so a new pick is another one, and the members the poses were picked for
local lastPoses = {} --- @type { [Player]: string }
local posedFor: string = ""

--[[ Camera ]]

-- Whether the camera is held on the stage, and where it eases to
local holding: boolean = false
local cameraTarget: CFrame? = nil

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

--- @class Lobby_Client_Stage
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._onInMatch)
	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(function()
		task.defer(Module._refreshSnails)
	end)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end
	I.Topic.Subscribe("MatchBoard_RoomChanged", Module._refreshSnails)

	--[[ Starting ]]

	-- The server's world folder may arrive after this client starts, so the stage waits for it on its own thread
	task.spawn(Module._setUp)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Set Up

--[[
	Builds this screen's copy of the stage from its prefab, with the custom lobby's pods on its pivot (put away until a
	custom lobby needs them), finds its camera marker and each pod's snail marker, then holds the camera there and
	stands the members on the pods.
]]
function Module._setUp()
	--[[ Building ]]

	worldFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	local assets: Folder = I.Dirs.Assets:FindFirstChild(_localName)
	stage = assets:FindFirstChild(_settings.STAGE_PREFAB):Clone()
	stage.Name = "Stage"
	stage.Parent = worldFolder
	customPods = assets:FindFirstChild(_settings.CUSTOM_PODS_PREFAB):Clone()
	customPods.Name = "CustomPods"
	customPods:PivotTo(stage:GetPivot())

	--[[ Elements ]]

	partyPods = stage:FindFirstChild(_settings.PODS_FOLDER)
	cameraMarker = stage:FindFirstChild(_settings.CAMERA_MARKER, true)

	--[[ Pods ]]

	--- @param markers { BasePart }
	for pods: Instance, markers in pairs({ [partyPods] = partyMarkers, [customPods:FindFirstChild(_settings.PODS_FOLDER)] = customMarkers }) do
		for index: number = 1, #pods:GetChildren() do
			table.insert(markers, pods:FindFirstChild(`{_settings.POD_PREFIX}{index}`):FindFirstChild(_settings.SNAIL_MARKER))
		end
	end
	snailMarkers = partyMarkers

	--[[ Showing ]]

	Module._refreshCamera()
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Restands the members when a player joins or leaves a party, or changes their snail's outfit.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player:GetAttributeChangedSignal("PartyId"):Connect(Module._refreshSnails)
	player:GetAttributeChangedSignal("Outfit"):Connect(Module._refreshSnails)
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Snails

--[[
	Stands the player on the first pod and the rest of their party, or of their custom lobby on its own eight pods, on
	the next ones, each in their snail's outfit holding the stage's weapon, and takes away the snails of players who
	left. Each snail strikes a new pose when the members changed, and the camera frames them.
]]
function Module._refreshSnails()
	--[[ Checks ]]

	-- Skip until the stage has arrived
	if #partyMarkers == 0 then
		return
	end

	--[[ Pods ]]

	local custom: boolean = I.MatchBoard.GetCustomRoom() ~= nil
	snailMarkers = if custom then customMarkers else partyMarkers
	partyPods.Parent = if custom then nil else stage
	customPods.Parent = if custom then stage else nil

	--[[ Local Variables ]]

	local members = Module._getMembers(custom) --- @type { Player }
	local memberIds = {} --- @type { string }

	--[[ Clearing ]]

	for player: Player, model: Model in pairs(snails) do
		if not table.find(members, player) then
			model:Destroy()
			snails[player] = nil
			snailSkins[player] = nil
			snailLifts[player] = nil
			snailPoses[player] = nil
		end
	end

	--[[ Placing ]]

	for index: number, player: Player in ipairs(members) do
		local outfit: string = player:GetAttribute("Outfit") or ""
		if snailSkins[player] ~= outfit then
			Module._dress(player, outfit)
		end
		if snails[player] then
			snails[player]:PivotTo(snailMarkers[index].CFrame + Vector3.yAxis * snailLifts[player])
		end
		table.insert(memberIds, tostring(player.UserId))
	end

	--[[ Posing ]]

	-- New members, a member gone or the pods swapped: everyone strikes a new pose
	local key: string = `{custom}:{table.concat(memberIds, ",")}`
	if key ~= posedFor then
		posedFor = key
		Module._poseAll()
	end

	--[[ Camera ]]

	cameraTarget = if custom then Module._getFitCFrame() else cameraMarker.CFrame
end

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Gives a member a snail wearing an outfit (the Outfit attribute's text) and holding the stage's weapon, both scaled
	up for the stage, replacing the one they had.
]]
function Module._dress(player: Player, outfit: string)
	--[[ Data ]]

	local model: Model? = I.G_Cosmetics.BuildSnail(I.G_Cosmetics.GetOutfit(outfit))
	if not model then
		return
	end

	--[[ Clearing ]]

	if snails[player] then
		snails[player]:Destroy()
	end

	--[[ Scaling ]]

	-- Bigger on the stage; scaled about its pivot, it would sink by what grew under the pivot, so it's lifted that much
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	local underPivot: number = model:GetPivot().Position.Y - (box.Position.Y - size.Y / 2)
	model:ScaleTo(model:GetScale() * _settings.STAGE_SNAIL_SCALE)

	--[[ Building ]]

	for _index: number, part: Instance in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			-- The rest of the rig hangs from the RootPart by Motor6Ds, which its animations move
			part.Anchored = part == model.PrimaryPart
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end
	end
	model.Name = player.Name
	model.Parent = worldFolder
	I.SnailRig.SetMotion(model, "Idle")

	--[[ Weapon ]]

	local weapon: Model = I.G_Arsenal.GetModel(_settings.STAGE_WEAPON):Clone()
	weapon:ScaleTo(weapon:GetScale() * _settings.STAGE_SNAIL_SCALE * _settings.STAGE_WEAPON_SCALE)
	I.SnailRig.Hold(model, _settings.STAGE_WEAPON, weapon)
	weapon.Parent = model

	--[[ Saving ]]

	snails[player] = model
	snailSkins[player] = outfit
	snailLifts[player] = underPivot * (_settings.STAGE_SNAIL_SCALE - 1)
	snailPoses[player] = nil
	Module._pose(player)
end

--%%%%%%%%%%%%%%%%%%%% Pose All

--[[
	Has every snail on the stage strike a new pose.
]]
function Module._poseAll()
	--[[ Posing ]]

	for player: Player in pairs(snails) do
		Module._pose(player)
	end
end

--%%%%%%%%%%%%%%%%%%%% Pose

--[[
	Plays a pose on a member's snail: one of STAGE_POSES that has an animation, at random, never the one they had last,
	looping from a random point, over its held weapon's pose. Nothing changes while no pose has an animation yet.
]]
function Module._pose(player: Player)
	--[[ Data ]]

	local model: Model? = snails[player]
	local animator: Animator? = model and model:FindFirstChildWhichIsA("Animator", true)
	local animations: Folder = I.Dirs.Assets:FindFirstChild("Snails"):FindFirstChild("Animations")

	--[[ Checks ]]

	-- Check if the snail is rigged
	if not animator then
		return
	end

	--[[ Picking ]]

	local choices = {} --- @type { Animation }
	for _index: number, name: string in ipairs(_settings.STAGE_POSES) do
		local animation: Instance? = animations:FindFirstChild(name)
		if animation and animation:IsA("Animation") and animation.AnimationId ~= "" and (name ~= lastPoses[player] or #_settings.STAGE_POSES == 1) then
			table.insert(choices, animation)
		end
	end
	if #choices == 0 then
		return
	end
	local picked: Animation = choices[math.random(#choices)]

	--[[ Playing ]]

	if snailPoses[player] then
		snailPoses[player]:Stop(0.25)
	end
	local track: AnimationTrack = animator:LoadAnimation(picked)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = true
	track:Play(0.25)
	track.TimePosition = math.random() * math.max(track.Length, 0)

	--[[ Saving ]]

	snailPoses[player] = track
	lastPoses[player] = picked.Name
end

--%%%%%%%%%%%%%%%%%%%% On In Match

--[[
	Hands the camera over while the player is in a match, and has the stage strike new poses when they come back.
]]
function Module._onInMatch()
	--[[ Camera ]]

	Module._refreshCamera()

	--[[ Posing ]]

	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		Module._poseAll()
	end
end

--%%%%%%%%%%%%%%%%%%%% Refresh Camera

--[[
	Holds the camera on the stage while the player is in the lobby, and lets the match's camera have it during a match
	(the Studio map plays both on one server).
]]
function Module._refreshCamera()
	--[[ Local Variables ]]

	local inLobby: boolean = cameraMarker ~= nil and not I.S.Players.LocalPlayer:GetAttribute("InMatch")

	--[[ Checks ]]

	-- Skip when nothing changes
	if inLobby == holding then
		return
	end

	--[[ Applying ]]

	holding = inLobby
	if holding then
		-- The FOV buff's base, so an open widget's FOV change still adds to it
		I.Buff.Set("FOV", "Standard", _settings.STAGE_FOV)
		I.S.Workspace.CurrentCamera.CFrame = cameraTarget or cameraMarker.CFrame

		-- After Roblox's camera scripts each frame, so nothing moves it off the stage
		I.S.RunService:BindToRenderStep("Lobby_Stage", Enum.RenderPriority.Camera.Value + 1, Module._holdCamera)
	else
		I.S.RunService:UnbindFromRenderStep("Lobby_Stage")
		I.S.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

--%%%%%%%%%%%%%%%%%%%% Hold Camera

--[[
	Eases the camera to where it frames the stage (its marker, or backed off to fit a custom lobby), looking along the
	marker's front.
]]
function Module._holdCamera(deltaTime: number)
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local target: CFrame = cameraTarget or cameraMarker.CFrame
	local alpha: number = 1 - (1 - _settings.STAGE_CAMERA_EASE) ^ (deltaTime * 60)

	--[[ Applying ]]

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = camera.CFrame:Lerp(target, alpha)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Snail

--[[
	**CLIENT** |
	Returns the snail a player stands as on this screen's stage, or nil when they stand on none.
]]
--- @return Model?
function Module.GetSnail(player: Player)
	return snails[player]
end

--%%%%%%%%%%%%%%%%%%%% Get Members

--[[
	Returns who stands on the stage: the player, then the rest of their custom lobby in its order, or of their party in
	this server by user id, as many as there are pods.
]]
--- @return { Player }
function Module._getMembers(custom: boolean)
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partyId: string? = localPlayer:GetAttribute("PartyId")
	local members = {} --- @type { Player }

	--[[ Members ]]

	if custom then
		local room: Instance = I.MatchBoard.GetCustomRoom()
		local userIds = I.S.HttpService:JSONDecode(room:GetAttribute("Players") or "[]") --- @type { number }
		for _index: number, userId: number in ipairs(userIds) do
			local player: Player? = I.S.Players:GetPlayerByUserId(userId)
			if player and player ~= localPlayer then
				table.insert(members, player)
			end
		end
	elseif partyId then
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			if player ~= localPlayer and player:GetAttribute("PartyId") == partyId then
				table.insert(members, player)
			end
		end
		table.sort(members, function(first: Player, second: Player)
			return first.UserId < second.UserId
		end)
	end
	table.insert(members, 1, localPlayer)

	--[[ Returning ]]

	return { table.unpack(members, 1, math.min(#members, #snailMarkers)) }
end

--%%%%%%%%%%%%%%%%%%%% Get Fit CFrame

--[[
	Returns where the camera frames every snail on the stage: the marker's view, backed off along its look (so it also
	rises) as far as the farthest corner of any snail needs to sit within STAGE_FIT_MARGIN of the screen's edges.
]]
--- @return CFrame
function Module._getFitCFrame()
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local marker: CFrame = cameraMarker.CFrame
	local tanV: number = math.tan(math.rad(_settings.STAGE_FOV / 2)) * _settings.STAGE_FIT_MARGIN
	local aspect: number = camera.ViewportSize.X / math.max(camera.ViewportSize.Y, 1)
	local tanH: number = tanV * aspect
	local back: number = 0

	--[[ Fitting ]]

	for _player: Player, model: Model in pairs(snails) do
		local box: CFrame
		local size: Vector3
		box, size = model:GetBoundingBox()
		for _index: number, corner: Vector3 in ipairs({ Vector3.new(-1, -1, -1), Vector3.new(1, 1, 1), Vector3.new(-1, 1, -1), Vector3.new(1, -1, 1) }) do
			local offset: Vector3 = box:PointToWorldSpace(corner * size / 2) - marker.Position
			local depth: number = offset:Dot(marker.LookVector)
			back = math.max(back, math.abs(offset:Dot(marker.RightVector)) / tanH - depth, math.abs(offset:Dot(marker.UpVector)) / tanV - depth)
		end
	end

	--[[ Returning ]]

	return marker - marker.LookVector * back
end

return Module
