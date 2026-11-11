--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Atmosphere_Client_Effects
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a Vfx prefab once at a spot, as `I.Vfx.Play` does, after painting every emitter in `color`, adding `pull` to
	their acceleration and scaling their EmitCount by `countShare`. Returns the copy, nil when the prefab is missing.
]]
--- @return BasePart?
function Module.Play(name: string, position: Vector3, parent: Instance, scale: number?, color: Color3?, pull: Vector3?, countShare: number?)
	--[[ Data ]]

	local prefab: BasePart? = I.Vfx.Get(name)
	if not prefab then
		return nil
	end

	--[[ Building ]]

	local copy: BasePart = prefab:Clone()
	copy.Name = name
	copy.CFrame = CFrame.new(position) * prefab.CFrame.Rotation

	--[[ Painting ]]

	for _index: number, emitter: Instance in ipairs(copy:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end
		local count: number? = emitter:GetAttribute("EmitCount")
		if color then
			emitter.Color = ColorSequence.new(color)
		end
		if pull then
			emitter.Acceleration += pull
		end
		if countShare and count and count > 0 then
			emitter:SetAttribute("EmitCount", math.max(1, math.round(count * countShare)))
		end
	end
	copy.Parent = parent

	--[[ Emitting ]]

	local seconds: number = I.Vfx.Emit(copy, scale)
	task.delay(seconds + _settings.CLEANUP_MARGIN, function()
		copy:Destroy()
	end)

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is On Screen

--[[
	Whether a point is in the camera's view, so an effect nobody would see isn't played.
]]
--- @return boolean
function Module.IsOnScreen(position: Vector3)
	--[[ Local Variables ]]

	local _viewport: Vector3
	local onScreen: boolean
	_viewport, onScreen = I.S.Workspace.CurrentCamera:WorldToViewportPoint(position)

	--[[ Returning ]]

	return onScreen
end

return Module
