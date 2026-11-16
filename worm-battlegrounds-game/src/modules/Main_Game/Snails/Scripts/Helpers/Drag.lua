--[[
	Created By: 	HungryN00B
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

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

--- @class Snails_Drag
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Position

--[[
	Returns where a snail drifting into a black hole is at a time on the server's clock, from its Drag attributes: a
	straight drift from DragFrom toward DragTo at DragSpeed, easing in over its first moment, stopping DragReach short of
	it; nil when it isn't drifting.
]]
--- @return Vector3?
function Module.GetPosition(model: Model, time: number)
	--[[ Data ]]

	local from: Vector3? = model:GetAttribute("DragFrom")
	local to: Vector3? = model:GetAttribute("DragTo")
	local started: number? = model:GetAttribute("DragStart")

	--[[ Checks ]]

	-- Check if it's drifting
	if not from or not to or not started then
		return nil
	end

	--[[ Local Variables ]]

	local offset: Vector3 = to - from
	local length: number = math.max(offset.Magnitude - (model:GetAttribute("DragReach") or 0), 0)
	local elapsed: number = math.max(time - started, 0)
	local speed: number = model:GetAttribute("DragSpeed") or 0

	-- It starts slow and speeds up for its first DragEase seconds, as if the hole took hold of it
	local ease: number = model:GetAttribute("DragEase") or 0
	local travelled: number = if elapsed < ease then speed * elapsed * elapsed / (2 * ease) else speed * (elapsed - ease / 2)

	--[[ Returning ]]

	return if length > 0 then from + offset.Unit * math.min(travelled, length) else from
end

return Module
