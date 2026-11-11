--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local snailsFolder: Folder

-- Snails hiding in their shell, thrown and not yet landed, with when they hid (os.clock)
local hidden = {} --- @type { [Model]: number }

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

--- @class Snails_Client_Motion
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Saving ]]

	snailsFolder = folder

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._step)
	I.Network.Fired("Combat_Hit", Module._onHit)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Animates every snail's skin from how its ball moves: it walks while it moves along the ground, hides in its shell
	when it's hit or thrown (faster than HIDE_SPEED and not under its player's control), comes out once it's slower
	than SHOW_SPEED and HIDE_SECONDS have passed, and idles otherwise.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Animating ]]

	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		local skin: Instance? = model:FindFirstChild("Skin")
		local root: BasePart? = model:IsA("Model") and model.PrimaryPart
		if not skin or not root then
			continue
		end

		local velocity: Vector3 = root.AssemblyLinearVelocity
		local speed: number = velocity.Magnitude
		if model:GetAttribute("Ghost") or (speed < _settings.SHOW_SPEED and now - (hidden[model] or 0) >= _settings.HIDE_SECONDS) then
			hidden[model] = nil
		elseif speed > _settings.HIDE_SPEED and not model:GetAttribute("CanMove") then
			hidden[model] = now
		end

		local walking: boolean = math.abs(velocity.X) > _settings.WALK_ANIMATION_SPEED and math.abs(velocity.Y) < _settings.STEP_SOUND_MAX_RISE
		I.SnailRig.SetMotion(skin, if hidden[model] then "Hidden" elseif walking then "Walk" else "Idle")
	end

	--[[ Clearing ]]

	for model: Model, _since: number in pairs(hidden) do
		if not model.Parent then
			hidden[model] = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Hit

--[[
	Pulls a snail into its shell the moment it's hit, before its knockback reaches this screen.
]]
function Module._onHit(participantId: string, damage: number, _position: Vector3, _knockout: boolean?)
	--[[ Data ]]

	local model: Instance? = snailsFolder:FindFirstChild(participantId)

	--[[ Checks ]]

	-- Check if the hit hurt a snail that's here
	if damage <= 0 or not model or not model:IsA("Model") then
		return
	end

	--[[ Hiding ]]

	hidden[model] = os.clock()
end

return Module
