--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Snails_Server_Bodies
local Flight = require(script.Parent:FindFirstChild("Flight")) --- @type Snails_Server_Flight
local Hazards = require(script.Parent:FindFirstChild("Hazards")) --- @type Snails_Server_Hazards

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

--- @class Snails_Server_Drag
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Drag

--[[
	**SERVER** |
	Moves a snail one frame toward a point at a speed (studs per second), as a black hole draws it in: on the ground it
	slides along it, in the air (or right under or over the point) it drifts straight there, and once within `reach` it
	sticks, held still where it is until Release. A snail flying a throw finishes it first. Returns whether it's stuck.
]]
--- @return boolean
function Module.Drag(participantId: string, toward: Vector3, speed: number, deltaTime: number, reach: number)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play and not flying a throw
	if not model or not model:GetAttribute("Alive") or Flight.IsFlying(model) then
		return false
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local offset: Vector3 = Vector3.new(toward.X - root.Position.X, toward.Y - root.Position.Y, 0)

	--[[ Sticking ]]

	if offset.Magnitude <= reach then
		Module._hold(root)
		return true
	end

	--[[ Sliding ]]

	-- Along the ground while the point is off to a side
	if not root.Anchored and math.abs(offset.X) > reach and Hazards.IsGrounded(root.Position) then
		root:FindFirstChild("Walk").Enabled = false
		root.AssemblyLinearVelocity = Vector3.new(math.sign(offset.X) * speed, math.min(root.AssemblyLinearVelocity.Y, 0), 0)
		return false
	end

	--[[ Drifting ]]

	Module._hold(root)
	local step: number = math.min(speed * deltaTime, offset.Magnitude)
	root.CFrame = CFrame.new(root.Position + offset.Unit * step) * root.CFrame.Rotation

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	**SERVER** |
	Lets go of a snail Drag held: its ball is back on Roblox physics, server-owned, at rest, and falls from there.
]]
function Module.Release(participantId: string)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if it's a held snail still in play (a knocked-out one stays anchored as its ghost)
	if not model or not model:GetAttribute("Alive") or Flight.IsFlying(model) or not model.PrimaryPart.Anchored then
		return
	end

	--[[ Applying ]]

	local root: BasePart = model.PrimaryPart
	root.Anchored = false
	root.AssemblyLinearVelocity = Vector3.zero
	root:SetNetworkOwner(nil)
end

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Anchors a snail's ball where it is, at rest, so the server moves it by hand.
]]
function Module._hold(root: BasePart)
	--[[ Applying ]]

	if root.Anchored then
		return
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.Anchored = true
	root:FindFirstChild("Walk").Enabled = false
end

return Module
