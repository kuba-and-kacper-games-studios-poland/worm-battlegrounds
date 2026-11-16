--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local DragHelper = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Drag")) --- @type Snails_Drag
local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Snails_Server_Bodies
local Flight = require(script.Parent:FindFirstChild("Flight")) --- @type Snails_Server_Flight
local Hazards = require(script.Parent:FindFirstChild("Hazards")) --- @type Snails_Server_Hazards

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The balls sliding toward a black hole since their last frame, so a slide a step stopped is seen
local sliding = {} --- @type { [BasePart]: boolean }

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
	slides along it while the point is about level (less than DRAG_SLIDE_MAX_RISE above) and nothing holds it back; in
	the air, right under or over the point, with the point higher up or once a step or wall stops its slide, it drifts
	straight there, and once within `reach` it sticks, held still where it is until Release. A snail flying a throw finishes it first. The drift is a straight
	path written on the snail (its Drag attributes, easing in over DRAG_EASE), so every screen draws the same smooth
	drift (the Drag handler) instead of the anchored ball's replicated steps. Returns whether it's stuck.
]]
--- @return boolean
function Module.Drag(participantId: string, toward: Vector3, speed: number, _deltaTime: number, reach: number)
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

	-- Along the ground while the point is off to a side and about level with it; one higher up lifts it into the air
	local stuck: boolean = sliding[root] == true and math.abs(root.AssemblyLinearVelocity.X) < speed * _settings.DRAG_SLIDE_STUCK
	if not root.Anchored and not stuck and math.abs(offset.X) > reach and offset.Y < _settings.DRAG_SLIDE_MAX_RISE and Hazards.IsGrounded(root.Position) then
		sliding[root] = true
		root:FindFirstChild("Walk").Enabled = false
		root.AssemblyLinearVelocity = Vector3.new(math.sign(offset.X) * speed, math.min(root.AssemblyLinearVelocity.Y, 0), 0)
		return false
	end

	--[[ Drifting ]]

	sliding[root] = nil
	Module._hold(root)
	local target: Vector3 = Vector3.new(toward.X, toward.Y, root.Position.Z)
	if model:GetAttribute("DragTo") ~= target then
		model:SetAttribute("DragFrom", root.Position)
		model:SetAttribute("DragTo", target)
		model:SetAttribute("DragSpeed", speed)
		model:SetAttribute("DragReach", reach)
		model:SetAttribute("DragEase", _settings.DRAG_EASE)
		model:SetAttribute("DragStart", I.S.Workspace:GetServerTimeNow())
	end
	local position: Vector3 = DragHelper.GetPosition(model, I.S.Workspace:GetServerTimeNow()) or root.Position
	root.CFrame = CFrame.new(position) * root.CFrame.Rotation

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

	-- Check if it's a snail
	if not model then
		return
	end

	--[[ Clearing ]]

	sliding[model.PrimaryPart] = nil
	for _index: number, attribute: string in ipairs({ "DragStart", "DragFrom", "DragTo", "DragSpeed", "DragReach", "DragEase" }) do
		model:SetAttribute(attribute, nil)
	end

	--[[ Checks ]]

	-- Check if it's a held snail still in play (a knocked-out one stays anchored as its ghost)
	if not model:GetAttribute("Alive") or Flight.IsFlying(model) or not model.PrimaryPart.Anchored then
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
