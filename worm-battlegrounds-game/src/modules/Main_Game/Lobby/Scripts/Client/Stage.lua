--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Stage ]]

local worldFolder: Folder
local cameraMarker: BasePart

-- Where each pod's snail stands, the player's pod first
local snailMarkers = {} --- @type { BasePart }

--[[ Snails ]]

-- Each party member's snail on the stage, and the skin it wears
local snails = {} --- @type { [Player]: Model }
local snailSkins = {} --- @type { [Player]: string }

-- Whether the camera is held on the stage
local holding: boolean = false

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

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshCamera)
	I.S.Players.PlayerAdded:Connect(Module._watchPlayer)
	I.S.Players.PlayerRemoving:Connect(function()
		task.defer(Module._refreshSnails)
	end)
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		Module._watchPlayer(player)
	end

	--[[ Starting ]]

	-- The server's world folder may arrive after this client starts, so the stage waits for it on its own thread
	task.spawn(Module._setUp)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Set Up

--[[
	Builds this screen's copy of the stage from its prefab, finds its camera marker and each pod's snail marker, then
	holds the camera there and stands the party on the pods.
]]
function Module._setUp()
	--[[ Building ]]

	worldFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	local stage: Model = I.Dirs.Assets:FindFirstChild(_localName):FindFirstChild(_settings.STAGE_PREFAB):Clone()
	stage.Name = "Stage"
	stage.Parent = worldFolder

	--[[ Elements ]]

	local pods: Folder = stage:FindFirstChild(_settings.PODS_FOLDER)
	cameraMarker = stage:FindFirstChild(_settings.CAMERA_MARKER, true)

	--[[ Pods ]]

	for index: number = 1, #pods:GetChildren() do
		table.insert(snailMarkers, pods:FindFirstChild(`{_settings.POD_PREFIX}{index}`):FindFirstChild(_settings.SNAIL_MARKER))
	end

	--[[ Showing ]]

	Module._refreshCamera()
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%% Watch Player

--[[
	Restands the party when a player joins or leaves a party, or changes skin.
]]
function Module._watchPlayer(player: Player)
	--[[ Connections ]]

	player:GetAttributeChangedSignal("PartyId"):Connect(Module._refreshSnails)
	player:GetAttributeChangedSignal("EquippedSkin"):Connect(Module._refreshSnails)
	Module._refreshSnails()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Snails

--[[
	Stands the player on the first pod and the rest of their party on the next ones, each in their equipped skin, and
	takes away the snails of players who left.
]]
function Module._refreshSnails()
	--[[ Checks ]]

	-- Skip until the stage has arrived
	if #snailMarkers == 0 then
		return
	end

	--[[ Local Variables ]]

	local members = Module._getMembers() --- @type { Player }

	--[[ Clearing ]]

	for player: Player, model: Model in pairs(snails) do
		if not table.find(members, player) then
			model:Destroy()
			snails[player] = nil
			snailSkins[player] = nil
		end
	end

	--[[ Placing ]]

	for index: number, player: Player in ipairs(members) do
		local skinId: string = player:GetAttribute("EquippedSkin") or I.Settings["Cosmetics"].DEFAULT_SKIN
		if snailSkins[player] ~= skinId then
			Module._dress(player, skinId)
		end
		if snails[player] then
			snails[player]:PivotTo(snailMarkers[index].CFrame)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Gives a member's snail the model of a skin (the default snail's when the skin has none of its own), replacing the
	one they had.
]]
function Module._dress(player: Player, skinId: string)
	--[[ Data ]]

	local skins: Folder = I.Dirs.Assets:FindFirstChild("Skins")
	local skin = I.G_Cosmetics.GetSkin(skinId) --- @type Cosmetics_SkinData?
	local fallback = I.G_Cosmetics.GetSkin(I.Settings["Cosmetics"].DEFAULT_SKIN) --- @type Cosmetics_SkinData

	-- shortcut: a skin without its own model stands as the default snail, as the Skins window shows it
	local source: Instance? = skin and skins:FindFirstChild(skin.Model) or skins:FindFirstChild(fallback.Model)
	if not source or not source:IsA("Model") then
		return
	end

	--[[ Clearing ]]

	if snails[player] then
		snails[player]:Destroy()
	end

	--[[ Building ]]

	local model: Model = source:Clone()
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

	--[[ Saving ]]

	snails[player] = model
	snailSkins[player] = skinId
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

		-- After Roblox's camera scripts each frame, so nothing moves it off the stage
		I.S.RunService:BindToRenderStep("Lobby_Stage", Enum.RenderPriority.Camera.Value + 1, Module._holdCamera)
	else
		I.S.RunService:UnbindFromRenderStep("Lobby_Stage")
		I.S.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

--%%%%%%%%%%%%%%%%%%%% Hold Camera

--[[
	Puts the camera on the stage's camera marker, looking along its front.
]]
function Module._holdCamera()
	--[[ Applying ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraMarker.CFrame
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Members

--[[
	Returns who stands on the stage: the player, then the rest of their party in this server by user id, as many as
	there are pods.
]]
--- @return { Player }
function Module._getMembers()
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local partyId: string? = localPlayer:GetAttribute("PartyId")
	local members = {} --- @type { Player }

	--[[ Members ]]

	if partyId then
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			if player ~= localPlayer and player:GetAttribute("PartyId") == partyId then
				table.insert(members, player)
			end
		end
	end
	table.sort(members, function(first: Player, second: Player)
		return first.UserId < second.UserId
	end)
	table.insert(members, 1, localPlayer)

	--[[ Returning ]]

	return { table.unpack(members, 1, math.min(#members, #snailMarkers)) }
end

return Module
