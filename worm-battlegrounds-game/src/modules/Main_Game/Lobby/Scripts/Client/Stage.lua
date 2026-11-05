--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local worldFolder: Folder
local cosmeticsRep: Folder?

--[[ Stage ]]

local cameraMarker: BasePart
local wormMarker: BasePart

-- The player's worm on the stage, and whether the camera is held on the stage
local worm: Model?
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
	--[[ Elements ]]

	-- Place content and the server's folder, both there before the lobby shows
	local stage: Model = I.Dirs.UmeWorkspace:WaitForChild(_settings.STAGE_NAME)
	worldFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	cameraMarker = stage:FindFirstChild(_settings.CAMERA_MARKER, true)
	wormMarker = stage:FindFirstChild(_settings.WORM_MARKER, true)

	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshCamera)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	Module._refreshCamera()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Cosmetics folder, so the worm on the stage wears the equipped skin.
]]
function Module._connectReplicator()
	--[[ Data ]]

	cosmeticsRep = I.Replicator.GetFolder("Cosmetics")

	--[[ Connections ]]

	if cosmeticsRep then
		cosmeticsRep:GetAttributeChangedSignal("EquippedSkin"):Connect(Module._buildWorm)
	end
	Module._buildWorm()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build Worm

--[[
	Stands the player's worm, in the equipped skin, on the stage's worm marker, replacing the one there.
]]
function Module._buildWorm()
	--[[ Data ]]

	local skinId: string = cosmeticsRep and cosmeticsRep:GetAttribute("EquippedSkin") or I.Settings["Cosmetics"].DEFAULT_SKIN
	local skin = I.G_Cosmetics.GetSkin(skinId) --- @type Cosmetics_SkinData?
	local skins: Folder = I.Dirs.Assets:FindFirstChild("Skins")

	-- shortcut: a skin without its own model stands as the default worm, as the Skins window shows it
	local source: Instance? = skin and skins:FindFirstChild(skin.Model) or skins:FindFirstChild(I.Settings["Worms"].DEFAULT_SKIN)
	if not source or not source:IsA("Model") then
		return
	end

	--[[ Clearing ]]

	if worm then
		worm:Destroy()
	end

	--[[ Building ]]

	worm = source:Clone()
	for _index: number, part: Instance in ipairs(worm:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end
	worm:PivotTo(wormMarker.CFrame)
	worm.Parent = worldFolder
end

--%%%%%%%%%%%%%%%%%%%% Refresh Camera

--[[
	Holds the camera on the stage while the player is in the lobby, and lets the match's camera have it during a match
	(the Studio map plays both on one server).
]]
function Module._refreshCamera()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")

	--[[ Checks ]]

	-- Skip when nothing changes
	if inLobby == holding then
		return
	end

	--[[ Applying ]]

	holding = inLobby
	if holding then
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
	camera.FieldOfView = _settings.STAGE_FOV
end

return Module
