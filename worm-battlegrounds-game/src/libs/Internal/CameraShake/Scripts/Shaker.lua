--[[
	Created By:     voidsky
	Edited By:      Nari
]]

local _localName = "CameraShake"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = game:GetService("RunService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_FADE_TIME: number = 0.1
local REVERT_PRIORITY: number = Enum.RenderPriority.Camera.Value - 1
local APPLY_PRIORITY: number = Enum.RenderPriority.Camera.Value + 1
local RENDER_NAME_PREFIX: string = "CameraShake_Shaker_"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Shake = require(script.Parent:FindFirstChild("Shake"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local nextShakerId: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Compose Shake CFrame

--[[
	Combines position and rotation (degrees, applied yaw then pitch and roll) offsets into one CFrame.
]]
--- @return CFrame
local function composeShakeCFrame(positionOffset: Vector3, rotationOffset: Vector3)
	return CFrame.new(positionOffset) * CFrame.Angles(0, math.rad(rotationOffset.Y), 0) * CFrame.Angles(math.rad(rotationOffset.X), 0, math.rad(rotationOffset.Z))
end

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

local Shaker = {}
Shaker.__index = Shaker

--%%%%%%%%%%%%%%%%%%%% New

--[[
	**CLIENT** |
	Creates a shaker for a camera. The render loop only runs while shakes are active.
]]
--- @return CameraShake_Shaker
function Shaker.new(camera: Camera)
	--[[ Checks ]]

	assert(typeof(camera) == "Instance" and camera:IsA("Camera"), `[{_localName}::{script.Name}]: Parameter #1 to Shaker.new must be a Camera; got {typeof(camera)}`)

	--[[ Returning ]]

	nextShakerId += 1

	--- @type CameraShake_Shaker
	local self = setmetatable({
		_camera = camera,
		_shakes = {},
		_renderName = RENDER_NAME_PREFIX .. tostring(nextShakerId),
		_bound = false,
		_destroyed = false,

		_baseCFrame = nil,
		_appliedCFrame = nil,
	}, Shaker)

	return self
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Starts a sustained shake with a fade-in and returns its handle.
]]
--- @param config CameraShake_Config
--- @return CameraShake_Shake
function Shaker:Play(config, fadeTime: number?)
	--[[ Checks ]]

	assert(not self._destroyed, `[{_localName}::{script.Name}]: Shaker is destroyed!`)
	assert(type(config) == "table", `[{_localName}::{script.Name}]: Parameter #1 to Shaker:Play must be a table; got {typeof(config)}`)
	assert(type(fadeTime) == "number" or fadeTime == nil, `[{_localName}::{script.Name}]: Parameter #2 to Shaker:Play must be a number or nil; got {typeof(fadeTime)}`)

	--[[ Playing ]]

	--- @type CameraShake_Shake
	local shake = Shake.new(config)
	shake:Play(fadeTime or DEFAULT_FADE_TIME)

	--[[ Saving ]]

	table.insert(self._shakes, shake)
	self:_bind()

	--[[ Returning ]]

	return shake
end

--%%%%%%%%%%%%%%%%%%%% Play Once

--[[
	Starts a shake that fades in, holds for `duration`, then fades out, and returns its handle.
]]
--- @param config CameraShake_Config
--- @return CameraShake_Shake
function Shaker:PlayOnce(config, duration: number, fadeInTime: number?, fadeOutTime: number?)
	--[[ Checks ]]

	assert(not self._destroyed, `[{_localName}::{script.Name}]: Shaker is destroyed!`)
	assert(type(config) == "table", `[{_localName}::{script.Name}]: Parameter #1 to Shaker:PlayOnce must be a table; got {typeof(config)}`)
	assert(type(duration) == "number", `[{_localName}::{script.Name}]: Parameter #2 to Shaker:PlayOnce must be a number; got {typeof(duration)}`)

	--[[ Playing ]]

	--- @type CameraShake_Shake
	local shake = Shake.new(config)
	shake:PlayOnce(duration, fadeInTime or DEFAULT_FADE_TIME, fadeOutTime or DEFAULT_FADE_TIME)

	--[[ Saving ]]

	table.insert(self._shakes, shake)
	self:_bind()

	--[[ Returning ]]

	return shake
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	Fades out one shake owned by this shaker, or every shake when none is passed.
]]
--- @param shake CameraShake_Shake?
function Shaker:Stop(shake, fadeTime: number?)
	--[[ Checks ]]

	assert(not self._destroyed, `[{_localName}::{script.Name}]: Shaker is destroyed!`)

	-- Stop every shake when none is passed
	if shake == nil then
		self:StopAll(fadeTime)
		return
	end

	-- Skip handles this shaker does not own
	if not table.find(self._shakes, shake) then
		return
	end

	--[[ Stopping ]]

	shake:Stop(fadeTime or DEFAULT_FADE_TIME)
end

--%%%%%%%%%%%%%%%%%%%% Stop All

--[[
	Fades out every shake on this shaker.
]]
function Shaker:StopAll(fadeTime: number?)
	--[[ Checks ]]

	assert(not self._destroyed, `[{_localName}::{script.Name}]: Shaker is destroyed!`)

	--[[ Stopping ]]

	--- @param shake CameraShake_Shake
	for _index: number, shake in ipairs(self._shakes) do
		shake:Stop(fadeTime or DEFAULT_FADE_TIME)
	end
end

--%%%%%%%%%%%%%%%%%%%% Destroy

--[[
	Stops every shake, restores the camera, and unbinds the render loop. The shaker cannot be reused.
]]
function Shaker:Destroy()
	--[[ Checks ]]

	-- Skip shakers that were already destroyed
	if self._destroyed then
		return
	end

	--[[ Cleanup ]]

	self._destroyed = true
	self:_unbind()

	table.clear(self._shakes)
	self._camera = nil
end

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Binds the revert and apply render steps around the camera update.
]]
function Shaker:_bind()
	--[[ Checks ]]

	-- Skip when already bound or destroyed
	if self._bound or self._destroyed then
		return
	end

	--[[ Binding ]]

	RunService:BindToRenderStep(`{self._renderName}_Revert`, REVERT_PRIORITY, function()
		self:_revert()
	end)

	RunService:BindToRenderStep(self._renderName, APPLY_PRIORITY, function(deltaTime: number)
		self:_update(deltaTime)
	end)

	self._bound = true
end

--%%%%%%%%%%%%%%%%%%%% Unbind

--[[
	Unbinds the render steps and removes the last applied offset from the camera.
]]
function Shaker:_unbind()
	--[[ Checks ]]

	-- Skip when not bound
	if not self._bound then
		return
	end

	--[[ Unbinding ]]

	RunService:UnbindFromRenderStep(`{self._renderName}_Revert`)
	RunService:UnbindFromRenderStep(self._renderName)

	self._bound = false
	self:_revert()
end

--%%%%%%%%%%%%%%%%%%%% Revert

--[[
	Restores the camera to its unshaken CFrame when nothing else moved it since the last shake frame.
	This keeps cameras that are not rewritten every frame (Scriptable) from drifting.
]]
function Shaker:_revert()
	--[[ Checks ]]

	local camera: Camera? = self._camera

	-- Skip when there is no applied offset to remove
	if not camera or not self._appliedCFrame then
		return
	end

	--[[ Reverting ]]

	if camera.CFrame == self._appliedCFrame then
		camera.CFrame = self._baseCFrame
	end

	self._appliedCFrame = nil
	self._baseCFrame = nil
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Advances every shake and applies the combined offset to the camera.
]]
function Shaker:_update(deltaTime: number)
	--[[ Checks ]]

	local camera: Camera? = self._camera

	-- Destroy the shaker when its camera is gone
	if not camera or not camera.Parent then
		self:Destroy()
		return
	end

	--[[ Accumulating ]]

	local positionOffset: Vector3 = Vector3.zero
	local rotationOffset: Vector3 = Vector3.zero
	local shakes = self._shakes --- @type { CameraShake_Shake }

	for index: number = #shakes, 1, -1 do
		local shake = shakes[index] --- @type CameraShake_Shake
		local offset: Vector3 = shake:Update(deltaTime)

		positionOffset += offset * shake.PositionInfluence
		rotationOffset += offset * shake.RotationInfluence

		if not shake:IsActive() then
			table.remove(shakes, index)
		end
	end

	--[[ Checks ]]

	-- Unbind once every shake has finished
	if #shakes == 0 then
		self:_unbind()
		return
	end

	--[[ Applying ]]

	local baseCFrame: CFrame = camera.CFrame
	local appliedCFrame: CFrame = baseCFrame * composeShakeCFrame(positionOffset, rotationOffset)

	camera.CFrame = appliedCFrame
	self._baseCFrame = baseCFrame
	self._appliedCFrame = appliedCFrame
end

return Shaker
