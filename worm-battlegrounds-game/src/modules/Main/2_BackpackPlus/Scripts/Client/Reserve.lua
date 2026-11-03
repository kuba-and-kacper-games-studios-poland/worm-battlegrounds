--[[
	Created By: 	Nari
]]

--- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

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

--- @class BackpackPlus_Client_Reserve
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	ctx.ReservedSlots = {}
	ctx.GetReservedSlotIdForTool = Module.GetReservedSlotIdForTool
	ctx.IsToolbarSlotReserved = Module.IsToolbarSlotReserved
	ctx.IsToolReservationLocked = Module.IsToolReservationLocked
	ctx.DoesToolMatchReservation = Module.DoesToolMatchReservation
	ctx.ApplyReservations = Module._applyReservations
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reserve Toolbar Slot

--[[
	**CLIENT** |
	Reserves a Toolbar slot for Tools matching `match`. Matching Tools snap to the slot and cannot be dragged off.
]]
--- @param match (tool: Tool) -> boolean
function Module.ReserveToolbarSlot(slotId: number, match)
	--[[ Checks ]]

	-- Invalid slot or above the largest Toolbar
	if type(slotId) ~= "number" or slotId < 1 or slotId > _settings.TOOLBAR_SLOTS["Default"] or slotId ~= math.floor(slotId) then
		warn(`[{_localName}::{script.Name}]: ({slotId}) is not a valid Toolbar slot id!`)
		return
	end

	-- Invalid matcher
	if type(match) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Toolbar reservation matcher is not a function!`)
		return
	end

	--[[ Saving ]]

	ctx.ReservedSlots[slotId] = match

	--[[ Applying ]]

	Module._applyReservations()
end

--%%%%%%%%%%%%%%%%%%%% Clear Toolbar Reservation

--[[
	**CLIENT** |
	Drops the reservation on a Toolbar slot. The occupying Tool stays in place.
]]
function Module.ClearToolbarReservation(slotId: number)
	--[[ Checks ]]

	-- Invalid slot
	if type(slotId) ~= "number" then
		return
	end

	--[[ Clearing ]]

	ctx.ReservedSlots[slotId] = nil
end

--%%%%%%%%%%%%%%%%%%%% Apply Reservations

--[[
	Moves matching Tools onto their reserved Toolbar slots.
]]
function Module._applyReservations()
	--[[ Applying ]]

	--- @param slotData BackpackPlus_SlotData
	for _slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		local reservedSlotId: number? = Module.GetReservedSlotIdForTool(slotData.Tool)

		-- Skipping Tools with no reserved Toolbar Slot
		if not reservedSlotId then
			continue
		end

		ctx.DropSlot(slotData.Slot, reservedSlotId)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Toolbar Slot Reserved

--[[
	Returns whether `slotId` currently has a reservation matcher.
]]
--- @return boolean
function Module.IsToolbarSlotReserved(slotId: number)
	--[[ Returning ]]

	return ctx.ReservedSlots[slotId] ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Does Tool Match Reservation

--[[
	Returns whether `tool` matches the reservation matcher on `slotId`.
]]
--- @return boolean
function Module.DoesToolMatchReservation(slotId: number, tool: Tool)
	--[[ Checks ]]

	local match = ctx.ReservedSlots[slotId]
	if not match or not tool then
		return false
	end

	--[[ Returning ]]

	return match(tool) == true
end

--%%%%%%%%%%%%%%%%%%%% Get Reserved Slot Id For Tool

--[[
	Returns the reserved Toolbar slot id that `tool` matches, if any.
]]
--- @return number?
function Module.GetReservedSlotIdForTool(tool: Tool)
	--[[ Checks ]]

	if not tool then
		return nil
	end

	--[[ Finding ]]

	for slotId: number, match in pairs(ctx.ReservedSlots) do
		if match(tool) == true then
			return slotId
		end
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Tool Reservation Locked

--[[
	**CLIENT** |
	Returns whether `tool` is locked to a reserved Toolbar slot.
]]
--- @return boolean
function Module.IsToolReservationLocked(tool: Tool)
	--[[ Returning ]]

	return Module.GetReservedSlotIdForTool(tool) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Slot Reservation Locked

--[[
	**CLIENT** |
	Returns whether the Slot Frame's Tool is locked to a reserved Toolbar slot.
]]
--- @return boolean
function Module.IsSlotReservationLocked(slotFrame: Frame)
	--[[ Data ]]

	--- @type BackpackPlus_SlotData?
	local slotData = ctx.CreatedSlots.BySlot[slotFrame]
	if not slotData then
		return false
	end

	--[[ Returning ]]

	return Module.IsToolReservationLocked(slotData.Tool)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
