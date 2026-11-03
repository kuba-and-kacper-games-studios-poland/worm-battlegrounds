--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "FOV_Controller"

--- @type FOV_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local lockState = {} --- @type { [string]: boolean }
local fovTween: Tween?

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module.UpdateCameraFOV()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("Buff_Updated-FOV", function()
		Module.UpdateCameraFOV(true)
	end)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.FOV_Controller = {

		--[[ Control ]]

		SetLock = Module.SetLock,
		ClearLock = Module.ClearLock,

		UpdateCameraFOV = Module.UpdateCameraFOV,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Lock

--[[
	**CLIENT** |
	Locks FOV for `lockName` from being automatically updated.
]]
function Module.SetLock(lockName: string)
	--[[ Locking ]]

	lockState[`{lockName}`] = true

	--[[ Cancelling Tween ]]

	-- Stop a playing tween so it can't overwrite the locked FOV
	if fovTween then
		fovTween:Cancel()
		fovTween = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% clear Lock

--[[
	**CLIENT** |
	Clears FOV lock for `lockName`.
]]
function Module.ClearLock(lockName: string)
	lockState[`{lockName}`] = nil
	Module.UpdateCameraFOV(false)
end

--%%%%%%%%%%%%%%%%%%%% Update Camera FOV

--[[
	**CLIENT** |
	Updates the Camera FOV to match the current amount. 
]]
function Module.UpdateCameraFOV(tween: boolean?)
	--[[ Checks ]]

	-- Return if fov is locked
	if next(lockState) then
		return
	end

	--[[ Getting FOV Amount ]]

	local fovAmount: number = math.clamp(I.Buff.GetSum("FOV") or 70, _settings.MIN_FOV, _settings.MAX_FOV)

	-- Skip when the camera already has that FOV
	if fovAmount == I.Env.Camera.FieldOfView then
		return
	end

	--[[ Cancelling Tween ]]

	-- Stop the previous tween so it can't overwrite the new FOV
	if fovTween then
		fovTween:Cancel()
		fovTween = nil
	end

	--[[ Tweening FOV ]]

	if tween then
		local FOV_TweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local FOV_TweenGoal = { FieldOfView = fovAmount }
		local FOV_Tween: Tween = TweenService:Create(I.Env.Camera, FOV_TweenInfo, FOV_TweenGoal)
		FOV_Tween:Play()

		fovTween = FOV_Tween
	else
		I.Env.Camera.FieldOfView = fovAmount
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
