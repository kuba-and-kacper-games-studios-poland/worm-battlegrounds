--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lighting"

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
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	--[[ Events ]]

	I.Network.GetEvent("Lighting_UpdateActiveLighting")
	I.Network.GetEvent("Lighting_SetActivePreset")
	I.Network.GetEvent("Lighting_SetValue")
	I.Network.GetEvent("Lighting_SetValueBulk")
	I.Network.GetEvent("Lighting_ClearValue")
	I.Network.GetEvent("Lighting_ClearValueBulk")

	--[[ Functions ]]

	I.Network.GetFunction("Lighting_UpdateActiveLighting-Return")
	I.Network.GetFunction("Lighting_SetActivePreset-Return")
	I.Network.GetFunction("Lighting_SetValue-Return")
	I.Network.GetFunction("Lighting_SetValueBulk-Return")
	I.Network.GetFunction("Lighting_ClearValue-Return")
	I.Network.GetFunction("Lighting_ClearValueBulk-Return")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Lighting = {

		--[[ Control ]]

		UpdateActiveLighting = Module.UpdateActiveLighting,

		--[[ Set Control ]]

		SetActivePreset = Module.SetActivePreset,

		SetValue = Module.SetValue,
		SetValueBulk = Module.SetValueBulk,

		--[[ Clear Control ]]

		ClearValue = Module.ClearValue,
		ClearValueBulk = Module.ClearValueBulk,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Active Lighting

--[[
	Updates lighting to match currently set one.
	With `invoke`, returns the client's result: `false` when it fails or doesn't answer in time.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @param clockTimeDirection Lighting_ClockTimeDirection?
--- @return boolean?
function Module.UpdateActiveLighting(player: Player, tweenInfo, invoke: boolean?, clockTimeDirection)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_UpdateActiveLighting", player, tweenInfo, clockTimeDirection)
		return nil
	end

	--[[ Returning ]]

	return I.Network.Invoke("Lighting_UpdateActiveLighting-Return", player, tweenInfo, clockTimeDirection) == true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set Control

--%%%%%%%%%%%%%%%%%%%% Set Active Preset

--[[
	Updates active lighting to match the given preset, or the preset effect/property.
	With `invoke`, returns the client's result: `false` when it fails or doesn't answer in time.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean?
function Module.SetActivePreset(player: Player, presetName: string, effectName: string?, propertyName: string?, tweenInfo, updateLighting: boolean?, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_SetActivePreset", player, presetName, effectName, propertyName, tweenInfo, updateLighting)
		return nil
	end

	--[[ Returning ]]

	return I.Network.Invoke("Lighting_SetActivePreset-Return", player, presetName, effectName, propertyName, tweenInfo, updateLighting) == true
end

--%%%%%%%%%%%%%%%%%%%% Set Value

--[[
	Sets value for effect property with additional weight and updates the active lighting.
	With `invoke`, returns the client's result: `false` when it fails or doesn't answer in time.
]]
--- @param valueTable Lighting_ValueTable
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean?
function Module.SetValue(player: Player, effectName: string, propertyName: string, valueTable, tweenInfo, updateLighting: boolean?, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_SetValue", player, effectName, propertyName, valueTable, tweenInfo, updateLighting)
		return nil
	end

	--[[ Returning ]]

	return I.Network.Invoke("Lighting_SetValue-Return", player, effectName, propertyName, valueTable, tweenInfo, updateLighting) == true
end

--%%%%%%%%%%%%%%%%%%%% Set Value Bulk

--[[
	Sets values for effect properties in bulk and then updates the lighting.
	With `invoke`, returns the client's result table: `nil` when it fails or doesn't answer in time.
]]
--- @param valuesTable { { any } }
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return { [string]: boolean }?
function Module.SetValueBulk(player: Player, valuesTable, tweenInfo, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_SetValueBulk", player, valuesTable, tweenInfo)
		return nil
	end

	--[[ Invoking ]]

	local result: any = I.Network.Invoke("Lighting_SetValueBulk-Return", player, valuesTable, tweenInfo)

	--[[ Checks ]]

	-- Check if the client answered with a result table
	if type(result) ~= "table" then
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Clear Control

--%%%%%%%%%%%%%%%%%%%% Clear Value

--[[
	Clears the effect property's layer with the given id (defaults to the weight) and updates the lighting.
	With `invoke`, returns the client's result: `false` when it fails or doesn't answer in time.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean?
function Module.ClearValue(player: Player, effectName: string, propertyName: string, weight: number, tweenInfo, updateLighting: boolean?, invoke: boolean?, id: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_ClearValue", player, effectName, propertyName, weight, tweenInfo, updateLighting, id)
		return nil
	end

	--[[ Returning ]]

	return I.Network.Invoke("Lighting_ClearValue-Return", player, effectName, propertyName, weight, tweenInfo, updateLighting, id) == true
end

--%%%%%%%%%%%%%%%%%%%% Clear Value Bulk

--[[
	Clears values for effect properties under given weight in bulk and updates the lighting.\
	Each row is `{ effectName, propertyName, weight, id? }`, the params of the `ClearValue` function.
	With `invoke`, returns the client's result table: `nil` when it fails or doesn't answer in time.
]]
--- @param valuesTable { { any } }
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return { [string]: boolean }?
function Module.ClearValueBulk(player: Player, valuesTable, tweenInfo, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Firing ]]

	-- Fire when the result isn't needed
	if not invoke then
		I.Network.Fire("Lighting_ClearValueBulk", player, valuesTable, tweenInfo)
		return nil
	end

	--[[ Invoking ]]

	local result: any = I.Network.Invoke("Lighting_ClearValueBulk-Return", player, valuesTable, tweenInfo)

	--[[ Checks ]]

	-- Check if the client answered with a result table
	if type(result) ~= "table" then
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
