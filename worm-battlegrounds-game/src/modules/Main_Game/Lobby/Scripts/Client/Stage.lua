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

-- The look each member's stage weapon wears ("Shiny", "Golden", or "" for none), from their level
local snailLooks = {} --- @type { [Player]: string }

-- Where the top middle of each member's snail is from its RootPart, measured before it holds the weapon (its nameplate
-- stands there)
local snailTops = {} --- @type { [Player]: Vector3 }

-- The pose each member played last, so a new pick is another one, and the members the poses were picked for
local lastPoses = {} --- @type { [Player]: string }
local posedFor: string = ""

--[[ Labels ]]

-- The "+" bubble over each empty pod, by pod, in the player's PlayerGui so it can be pressed
local inviteBubbles = {} --- @type { [number]: BillboardGui }

-- Whether the nameplates and bubbles show (they hide behind a full-screen window), and which bubbles are wanted
local labelsShown: boolean = true
local bubblesWanted = {} --- @type { [number]: boolean }

--[[ Camera ]]

-- Whether the camera is held on the stage, where it eases to, and where the ease is (never read off the camera)
local holding: boolean = false
local cameraTarget: CFrame? = nil
local heldCFrame: CFrame = CFrame.identity

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
	Restands the members when a player joins or leaves a party, or changes their snail's outfit, and relabels their
	snail when their level changes (and gives it a new snail when their level or an admin changes its weapon's look).
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player:GetAttributeChangedSignal("PartyId"):Connect(Module._refreshSnails)
	player:GetAttributeChangedSignal("Outfit"):Connect(Module._refreshSnails)
	player:GetAttributeChangedSignal("Level"):Connect(function()
		Module._label(player)
		Module._rearm(player)
	end)
	player:GetAttributeChangedSignal("WeaponVariants"):Connect(function()
		Module._rearm(player)
	end)
	player:GetAttributeChangedSignal("WeaponLooks"):Connect(function()
		Module._rearm(player)
	end)
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Labels Shown

--[[
	Shows or hides the stage's nameplates and "+" bubbles: they hide while a full-screen window covers the lobby, so
	they don't float blurred behind it.
]]
function Module.SetLabelsShown(shown: boolean)
	--[[ Checks ]]

	-- Check if it changes
	if shown == labelsShown then
		return
	end

	--[[ Applying ]]

	labelsShown = shown
	for player: Player in pairs(snails) do
		Module._label(player)
	end
	for index: number, bubble: BillboardGui in pairs(inviteBubbles) do
		bubble.Enabled = shown and bubblesWanted[index] == true
	end
end

--%%%%%%%%%%%%%%%%%%%% Rearm

--[[
	Gives a member a new snail when their weapon's look changed (their level, or an admin's gift).
]]
function Module._rearm(player: Player)
	--[[ Checks ]]

	-- Check if they stand on the stage holding another look
	if not snails[player] or snailLooks[player] == Module._getWeaponLook(player) then
		return
	end

	--[[ Refreshing ]]

	-- Forgetting its outfit makes the refresh dress it again and stand it on its pod
	snailSkins[player] = nil
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Snails

--[[
	Stands the player on the first pod and the rest of their party, or of their custom lobby on its own eight pods, on
	the next ones, each in their snail's outfit holding the stage's weapon, and takes away the snails of players who
	left, with a "+" bubble over each pod still free. Each snail strikes a new pose when the members changed, and the
	camera frames them.
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
			snailTops[player] = nil
			snailLooks[player] = nil
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
	Module._refreshInvites(#members, custom)

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
	Gives a member a snail wearing an outfit (the Outfit attribute's text) and holding the stage's weapon in the look
	their level opened for it, both scaled up for the stage, replacing the one they had.
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
	box, size = model:GetBoundingBox()
	snailTops[player] = box.Position + Vector3.yAxis * size.Y / 2 - model.PrimaryPart.Position

	--[[ Weapon ]]

	local weapon: Model = I.G_Arsenal.GetModel(_settings.STAGE_WEAPON):Clone()
	weapon:ScaleTo(weapon:GetScale() * _settings.STAGE_SNAIL_SCALE * _settings.STAGE_WEAPON_SCALE)
	I.SnailRig.Hold(model, _settings.STAGE_WEAPON, weapon)
	weapon.Parent = model
	local look: string = Module._getWeaponLook(player)
	Module._dressWeapon(weapon, look)

	--[[ Saving ]]

	snails[player] = model
	snailSkins[player] = outfit
	snailLooks[player] = look
	snailLifts[player] = underPivot * (_settings.STAGE_SNAIL_SCALE - 1)
	snailPoses[player] = nil
	Module._label(player)
	Module._pose(player)
end

--%%%%%%%%%%%%%%%%%%%% Dress Weapon

--[[
	Dresses a stage weapon in a look (STAGE_WEAPON_LOOKS), as Combat dresses a held one: Golden turns it gold (Arsenal's
	Gild), then a Shiny or Golden one wears a ForceField sheen over each part and an outline. "" leaves it as it is.
]]
function Module._dressWeapon(weapon: Model, lookName: string)
	--[[ Data ]]

	--- @type Lobby_WeaponLook?
	local look = _settings.STAGE_WEAPON_LOOKS[lookName]

	--[[ Checks ]]

	-- Check if the weapon has a look
	if not look then
		return
	end

	--[[ Parts ]]

	-- The parts it shows (its hidden RootPart aside), taken before the look adds its own
	local parts = {} --- @type { BasePart }
	for _index: number, part: Instance in ipairs(weapon:GetDescendants()) do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(parts, part)
		end
	end

	--[[ Gilding ]]

	if look.Gild then
		I.G_Arsenal.Gild(parts, look.Gild[1], look.Gild[2], look.GildCover or 0, _settings.STAGE_COVER_GROW)
	end

	--[[ Sheen ]]

	for _index: number, part: BasePart in ipairs(parts) do
		I.G_Arsenal.MakeCopy(part, look.Sheen, Enum.Material.ForceField, 0, _settings.STAGE_SHEEN_GROW)
	end

	--[[ Outline ]]

	I.Create("Highlight")({
		Adornee = weapon,
		DepthMode = Enum.HighlightDepthMode.Occluded,
		FillTransparency = 1,
		OutlineColor = look.Outline,
		OutlineTransparency = look.OutlineTransparency,
		Parent = weapon,
	})
end

--%%%%%%%%%%%%%%%%%%%% Label

--[[
	Stands the studio's nameplate over the middle of a member's snail (made with the snail, so it goes with it): their level in the
	rank crest in its tier's colours, their display name over their @username, scaled with the stage's snails (NAMEPLATE_SCALE), and smaller over
	the rest of the party than over the player's own (NAMEPLATE_OTHER_SCALE).
]]
function Module._label(player: Player)
	--[[ Data ]]

	local model: Model? = snails[player]
	if not model then
		return
	end

	--[[ Building ]]

	local plate: BillboardGui? = model:FindFirstChild(_settings.NAMEPLATE_NAME)
	if not plate then
		plate = I.Dirs.Assets:FindFirstChild(_localName):FindFirstChild(_settings.NAMEPLATE_NAME, true):Clone()
		local scale: number = _settings.NAMEPLATE_SCALE * (if player == I.S.Players.LocalPlayer then 1 else _settings.NAMEPLATE_OTHER_SCALE)
		plate.Size = UDim2.fromScale(plate.Size.X.Scale * scale, plate.Size.Y.Scale * scale)
		plate.Adornee = model.PrimaryPart
		plate.StudsOffsetWorldSpace = snailTops[player] + Vector3.yAxis * _settings.NAMEPLATE_GAP
		plate.Parent = model
	end

	--[[ Visibility ]]

	plate.Enabled = labelsShown

	--[[ Texts ]]

	local level: number = player:GetAttribute("Level") or 1
	plate:FindFirstChild("S_Level", true).Text = tostring(level)
	plate:FindFirstChild("S_Name", true).Text = player.DisplayName
	plate:FindFirstChild("S_Username", true).Text = `@{player.Name}`

	--[[ Crest ]]

	-- The level's crest in its prestige tier's colours, as the lobby's level bar
	I.G_Progression.ApplyFrame(plate:FindFirstChild("S_LevelGradient", true), level)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Invites

--[[
	Floats a "+" bubble over each pod past the members, up to the places the stage offers (the party's size, or the
	custom lobby's), when the player may invite: no party, its leader, or a custom lobby. Pressing one opens the party
	invite, or the custom lobby's window. None while the player is in a match.
]]
function Module._refreshInvites(memberCount: number, custom: boolean)
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partySettings = I.Settings["Party"] --- @type Party_Settings
	local room: Instance? = I.MatchBoard.GetCustomRoom()
	local places: number = if room then room:GetAttribute("Size") or #snailMarkers else partySettings.MAX_PARTY
	local mayInvite: boolean = custom or not localPlayer:GetAttribute("PartyId") or localPlayer:GetAttribute("PartyLeader") == true
	local free: number = if mayInvite and not localPlayer:GetAttribute("InMatch") then math.min(places, #snailMarkers) else 0
	local template: BillboardGui = I.Dirs.Assets:FindFirstChild(_localName):FindFirstChild(_settings.INVITE_NAME, true)

	--[[ Bubbles ]]

	for index: number = 1, #snailMarkers do
		local bubble: BillboardGui? = inviteBubbles[index]
		local wanted: boolean = index > memberCount and index <= free
		if wanted and not bubble then
			bubble = template:Clone()
			I.Interact.OnPress(bubble:FindFirstChild("U_Invite"), function()
				I.WidgetManager.Open(if I.MatchBoard.GetCustomRoom() then partySettings.CUSTOM_GUI_NAME else partySettings.INVITE_GUI_NAME)
			end)
			bubble.Parent = localPlayer:FindFirstChildOfClass("PlayerGui")
			inviteBubbles[index] = bubble
		end
		bubblesWanted[index] = wanted
		if bubble then
			bubble.Enabled = wanted and labelsShown
			bubble.Adornee = snailMarkers[index]
			bubble.StudsOffsetWorldSpace = Vector3.yAxis * _settings.INVITE_HEIGHT
		end
	end
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
	Hands the camera over while the player is in a match, and has the stage strike new poses when they come back; the
	"+" bubbles hide while they're away.
]]
function Module._onInMatch()
	--[[ Camera ]]

	Module._refreshCamera()

	--[[ Posing ]]

	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		Module._poseAll()
	end

	--[[ Labels ]]

	Module._refreshSnails()
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
		heldCFrame = cameraTarget or cameraMarker.CFrame
		I.S.Workspace.CurrentCamera.CFrame = heldCFrame

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
	marker's front. The ease runs from where it was held, so Roblox moving the camera as the avatar loads never swoops it.
]]
function Module._holdCamera(deltaTime: number)
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local target: CFrame = cameraTarget or cameraMarker.CFrame
	local alpha: number = 1 - (1 - _settings.STAGE_CAMERA_EASE) ^ (deltaTime * 60)

	--[[ Applying ]]

	heldCFrame = heldCFrame:Lerp(target, alpha)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = heldCFrame
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

--%%%%%%%%%%%%%%%%%%%% Get Weapon Look

--[[
	Returns the look a member's stage weapon wears: the one they picked on the loadout's look tab, up to what their
	level opened (Progression's WEAPON_REWARDS) or an admin gave (I.G_Loadout.GetWornLook): "Golden", "Shiny", or ""
	for none.
]]
--- @return string
function Module._getWeaponLook(player: Player)
	--[[ Local Variables ]]

	local look: string = I.G_Loadout.GetWornLook(player, _settings.STAGE_WEAPON)

	--[[ Returning ]]

	return if look == "Normal" then "" else look
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
