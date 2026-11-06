--[[
	Created By: 	Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The place's own loading screen, which plays on a join from the website, not on a teleport between the game's places
local LOADING_SCREEN_NAME: string = "LoadingScreen"

-- The marker ume puts on the player once their client started (place_loader config's `_clientStatusBoolName`)
local CLIENT_STARTED_NAME: string = "__Ume_ClientStarted"

-- How the teleport card slides off the screen once this server is ready
local WIPE_TWEENINFO: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

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
local backdrop: Frame = card:FindFirstChild("U_Backdrop")

backdrop.Position = UDim2.fromScale(0.5, 0.5)
card.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()

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

--[[ Hiding ]]

local Wipe_TweenGoal = { Position = UDim2.fromScale(0.5, 1.5) }
local Wipe_Tween: Tween = TweenService:Create(backdrop, WIPE_TWEENINFO, Wipe_TweenGoal)
Wipe_Tween:Play()
Wipe_Tween.Completed:Wait()
card:Destroy()
