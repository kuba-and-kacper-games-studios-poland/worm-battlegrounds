--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local TransitionMotion = require(ReplicatedFirst:FindFirstChild("TransitionMotion")) --- @type TransitionMotion

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The place's own loading screen, which plays on a join from the website, not on a teleport between the game's places
local LOADING_SCREEN_NAME: string = "LoadingScreen"

-- The marker ume puts on the player once their client started (place_loader config's `_clientStatusBoolName`)
local CLIENT_STARTED_NAME: string = "__Ume_ClientStarted"

-- How long the full progress bar shows before the reveal, once this server is ready
local READY_SECONDS: number = 0.3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Drop Loading Screen

--[[
	Removes the place's loading screen, which would play over the teleport card.
]]
local function dropLoadingScreen(child: Instance)
	--[[ Checks ]]

	-- Skip everything but the loading screen
	if child.Name ~= LOADING_SCREEN_NAME or not child:IsA("ScreenGui") then
		return
	end

	--[[ Removing ]]

	child:Destroy()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Arriving

--[[ Checks ]]

-- The teleport card the Transition module handed to Roblox on the server the player came from
local card: ScreenGui? = TeleportService:GetArrivingTeleportGui()
if not card then
	return
end

--[[ Showing ]]

local player: Player = Players.LocalPlayer
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")

card.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- A card from a server before the map scenes has no scene to move; it only waits and goes
local moving: boolean = card:FindFirstChild("U_Scene", true) ~= nil
if moving then
	TransitionMotion.Play(card)
end

-- The loading screen's script may already have moved it into PlayerGui
local loadingAdded: RBXScriptConnection = playerGui.ChildAdded:Connect(dropLoadingScreen)
for _index: number, child: Instance in ipairs(ReplicatedFirst:GetChildren()) do
	dropLoadingScreen(child)
end
for _index: number, child: Instance in ipairs(playerGui:GetChildren()) do
	dropLoadingScreen(child)
end

--[[ Waiting ]]

repeat
	task.wait()
until player.Character and player:FindFirstChild(CLIENT_STARTED_NAME)
loadingAdded:Disconnect()

--[[ Revealing ]]

-- The bar fills, then the camera flies through the scene into the map
if moving then
	card:SetAttribute("Transition_Ready", true)
	task.wait(READY_SECONDS)
	TransitionMotion.Reveal(card)
end
card:Destroy()
