--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Environment
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Loads all environment variables into the Ume instance.
]]
function _task.Load(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Table containing all environment variables.
	I.Env = {}

	--[[ Getting Current Environment ]]

	local isServer: boolean = I.S.RunService:IsServer() == true
	local isClient: boolean = I.S.RunService:IsClient() == true
	local isStudio: boolean = I.S.RunService:IsStudio() == true

	local envKey: string = if isServer then "Server" else if isClient then "Client" else "Unknown"

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Global

	-- Indicates the current environment in which the script is running.
	--- @type '"Client"' | '"Server"' | '"Unknown"'
	I.Env.Key = envKey

	I.Env.IsServer = isServer --- @type boolean
	I.Env.IsClient = isClient --- @type boolean
	I.Env.IsStudio = isStudio --- @type boolean

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Client

	if isClient then
		-- **CLIENT** | Local player instance.
		--- @type Player
		I.Env.LocalPlayer = I.S.Players.LocalPlayer

		-- **CLIENT** | Local player's mouse.
		--- @type Mouse
		I.Env.Mouse = I.Env.LocalPlayer:GetMouse()

		-- **CLIENT** | Main camera.
		--- @type Camera
		I.Env.Camera = I.S.Workspace:FindFirstChildOfClass("Camera")
		if not I.Env.Camera then
			error(`[Ume::{script.Name}]: Camera not found!`, 2)
		end

		-- **CLIENT** | Local PlayerGui.
		--- @type PlayerGui
		I.Env.PlayerGui = I.Env.LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if not I.Env.PlayerGui then
			error(`[Ume::{script.Name}]: PlayerGui not found!`, 2)
		end
	end
end

return _task
