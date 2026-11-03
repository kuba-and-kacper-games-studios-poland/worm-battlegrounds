--[[
	⣿⣿⣿⣿⣿⣿⠟⠁⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿
	⣿⣿⣿⣿⣿⡏⠂⠂⠂⠂⢙⠛⠙⠛⠻⢿⠟⠁⠂⠂⠸⣿⣿⣿
	⣿⣿⣿⡿⠟⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⣿⣿⣿
	⣿⡿⢋⣴⣤⣀⣀⣀⣀⣠⣤⣾⣷⣤⣀⠂⠂⠂⠂⠂⠂⢿⣿⣿
	⣿⢁⣿⣿⣿⣿⣿⣿⣯⣽⣿⣿⣿⣿⣟⣿⣶⣦⣤⣤⣤⣦⠹⣿
	⡇⣼⣿⣿⣿⣿⣿⢋⣭⠹⣿⣿⣿⣿⠟⡛⢿⣿⣿⣿⣿⣿⣇⢸
	⠁⣿⣿⡟⡛⠛⢿⣄⣂⣴⣿⣿⣿⣿⡀⠉⢠⣿⣿⣿⣿⣿⣿⠂
	⡇⢻⣿⣷⣿⣿⣾⣿⣿⣿⣙⠁⠛⣻⣿⣿⣣⣃⢉⢹⣿⣿⡟⢸
	⣿⡌⢻⣿⣿⣿⣿⣿⣿⣿⣿⣍⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢁⣾
	⣿⡘⠦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣡⣾⣿
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   ______   __        ______  ________  __    __  ________
--  /      \ /  |      /      |/        |/  \  /  |/        |
-- /$$$$$$  |$$ |      $$$$$$/ $$$$$$$$/ $$  \ $$ |$$$$$$$$/
-- $$ |  $$/ $$ |        $$ |  $$ |__    $$$  \$$ |   $$ |
-- $$ |      $$ |        $$ |  $$    |   $$$$  $$ |   $$ |
-- $$ |   __ $$ |        $$ |  $$$$$/    $$ $$ $$ |   $$ |
-- $$ \__/  |$$ |_____  _$$ |_ $$ |_____ $$ |$$$$ |   $$ |
-- $$    $$/ $$       |/ $$   |$$       |$$ | $$$ |   $$ |
--  $$$$$$/  $$$$$$$$/ $$$$$$/ $$$$$$$$/ $$/   $$/    $$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--[[ Services ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--[[ Constants ]]

local ERROR_MESSAGE = "Oops! Something went wrong while loading. Please try again!"

local POINTER_MAX_YIELD = 60 -- Maximum wait time for the pointer object
local VALUE_MAX_YIELD = 60 -- Maximum wait time for the pointer value
local SAFETY_LOADING_DELAY = 0.5 -- Delay to ensure everything has loaded server-side

--[[ Local Variables ]]

local waitUntil: number

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Starting Ume

-- Wait for the game to load
if not game:IsLoaded() then
	game.Loaded:Wait()
end

--[[ Getting Pointers ]]

local UmePointer: ObjectValue? = ReplicatedStorage:FindFirstChild("UmePointer")
local UmeFailedPointer: ObjectValue? = ReplicatedStorage:FindFirstChild("UmeFailedPointer")

--[[ Waiting for Pointers ]]

if not UmePointer or not UmeFailedPointer then
	waitUntil = os.clock() + POINTER_MAX_YIELD

	-- Repeat until found or time runs out
	repeat
		UmePointer = UmePointer or ReplicatedStorage:FindFirstChild("UmePointer")
		UmeFailedPointer = UmeFailedPointer or ReplicatedStorage:FindFirstChild("UmeFailedPointer")

		RunService.Heartbeat:Wait()
	until (UmePointer and UmeFailedPointer) or os.clock() >= waitUntil

	-- Not found - Kick player
	if not UmePointer or not UmeFailedPointer then
		game.Players.LocalPlayer:Kick(ERROR_MESSAGE)
		return
	end
end

--[[ Waiting for Pointers Values ]]

if not UmePointer.Value or not UmeFailedPointer.Value then
	waitUntil = os.clock() + VALUE_MAX_YIELD

	-- Repeat until found or time runs out
	repeat
		RunService.Heartbeat:Wait()
	until (UmePointer.Value and UmeFailedPointer.Value) or os.clock() >= waitUntil

	-- Not found - Kick player
	if not UmePointer.Value or not UmeFailedPointer.Value then
		game.Players.LocalPlayer:Kick(ERROR_MESSAGE)
		return
	end
end

--[[ Safety Delay ]]

waitUntil = os.clock() + SAFETY_LOADING_DELAY
repeat
	RunService.Heartbeat:Wait()
until os.clock() >= waitUntil

--[[ Getting Ume ]]

local Ume = require(UmePointer.Value :: ModuleScript) --- @type Ume
local Failed = require(UmeFailedPointer.Value :: ModuleScript) --- @type Ume_Failed

--%%%%%%%%%%%%%%%%%%%% Starting

local success: boolean, errorMsg: string = pcall(function()
	Ume.Bloom()
end)

--[[ Loading Success/Failed ]]

if success then
	-- Success - Removing Failed Module
	for _, elem: Instance in ipairs({ UmeFailedPointer and UmeFailedPointer.Value, UmeFailedPointer }) do
		elem:Destroy()
	end
else
	-- Failed - Leaving Game
	Failed.Leave(errorMsg)
end
