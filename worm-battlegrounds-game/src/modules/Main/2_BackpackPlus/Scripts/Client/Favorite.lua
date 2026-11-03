--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Favorite ]]

local isFavoriteMode: boolean = false
local favoriteTweens = {} --- @type { [Frame]: { Tween } }

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Lock Id

--[[
	Returns the Inventory lock id for a Tool.
]]
--- @return string?
local function getLockId(tool: Tool)
	local itemUUID = tool:GetAttribute("Inventory_ItemUUID")
	if typeof(itemUUID) == "string" and itemUUID ~= "" then
		return itemUUID
	end

	local itemId = tool:GetAttribute("Inventory_ItemId")
	if typeof(itemId) == "string" and itemId ~= "" then
		return itemId
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Cancel Tweens

--[[
	Cancels in-flight favorite icon tweens for a Slot.
]]
--- @param slotData BackpackPlus_SlotData
local function cancelTweens(slotData)
	local tweens = favoriteTweens[slotData.Slot]
	if not tweens then
		return
	end

	for _: number, tween: Tween in ipairs(tweens) do
		tween:Cancel()
	end

	favoriteTweens[slotData.Slot] = nil
end

--%%%%%%%%%%%%%%%%%%%% Is Locked

--[[
	Returns whether a lock id is currently in client Locked data.
]]
--- @return boolean
local function isLockedId(itemId: string)
	return table.find(I.Inventory.Items.Locked or {}, itemId) ~= nil
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

--- @class BackpackPlus_Client_Favorite
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	ctx.IsFavoriteMode = false
	ctx.ApplyFavoriteSlot = Module._applySlot

	--[[ Locked Data ]]

	I.Topic.Subscribe("Inventory_DataUpdated-Locked", Module._onLockedUpdated)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Favorite Control

--%%%%%%%%%%%%%%%%%%%% Set Favorite Mode

--[[
	**CLIENT** |
	Sets favorite mode and publishes the change.
]]
function Module.SetFavoriteMode(state: boolean)
	--[[ Local Variables ]]

	local newState: boolean = state == true

	--[[ Updating ]]

	if isFavoriteMode == newState then
		return
	end

	isFavoriteMode = newState
	ctx.IsFavoriteMode = newState
	I.Topic.Publish("BackpackPlus_FavoriteModeChanged", newState)
end

--%%%%%%%%%%%%%%%%%%%% Toggle Favorite Mode

--[[
	**CLIENT** |
	Toggles favorite mode on or off.
]]
function Module.ToggleFavoriteMode()
	Module.SetFavoriteMode(not isFavoriteMode)
end

--%%%%%%%%%%%%%%%%%%%% Is Favorite Mode

--[[
	**CLIENT** |
	Returns whether favorite mode is currently active.
]]
--- @return boolean
function Module.IsFavoriteMode()
	return isFavoriteMode == true
end

--%%%%%%%%%%%%%%%%%%%% Toggle Slot Favorite

--[[
	**CLIENT** |
	Sends Inventory_LockSwitch for the Slot's inventory item.
]]
--- @return boolean
function Module.ToggleSlotFavorite(slotFrame: Frame)
	--[[ Checks ]]

	--- @type BackpackPlus_SlotData
	local slotData = ctx.CreatedSlots.BySlot[slotFrame]
	if not slotData then
		return false
	end

	local tool: Tool = slotData.Tool
	if tool:GetAttribute("Inventory_IsInventoryItem") ~= true then
		return false
	end

	local itemId: string? = getLockId(tool)
	if not itemId then
		return false
	end

	--[[ Sending ]]

	task.spawn(function()
		I.Network.Invoke("Inventory_LockSwitch", itemId)
	end)

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Display

--%%%%%%%%%%%%%%%%%%%% Apply Slot

--[[
	Applies favorite icon visibility for a Slot from current Locked data.
]]
--- @param slotData BackpackPlus_SlotData
function Module._applySlot(slotData, animate: boolean?)
	--[[ Elements ]]

	local container: GuiObject? = slotData.Elems["FavoriteIconContainer"]
	local icon: GuiObject? = slotData.Elems["FavoriteIcon"]
	local defaultSize: UDim2? = slotData.Elems["FavoriteIconDefaultSize"]
	if not container or not icon or not defaultSize then
		return
	end

	--[[ State ]]

	local tool: Tool = slotData.Tool
	local itemId: string? = getLockId(tool)
	local isFavorite: boolean = itemId ~= nil and isLockedId(itemId)

	--[[ Updating ]]

	Module._setSlotFavorite(slotData, isFavorite, animate == true)
end

--%%%%%%%%%%%%%%%%%%%% Set Slot Favorite

--[[
	Shows or hides the favorite icon, optionally with a pop tween.
]]
--- @param slotData BackpackPlus_SlotData
function Module._setSlotFavorite(slotData, isFavorite: boolean, animate: boolean)
	--[[ Elements ]]

	local container: GuiObject? = slotData.Elems["FavoriteIconContainer"]
	local icon: GuiObject? = slotData.Elems["FavoriteIcon"]
	local defaultSize: UDim2? = slotData.Elems["FavoriteIconDefaultSize"]
	if not container or not icon or not defaultSize then
		return
	end

	local hiddenSize: UDim2 = UDim2.new()

	--[[ Cancel Existing ]]

	cancelTweens(slotData)

	--[[ Show ]]

	if isFavorite then
		if container.Visible and not animate then
			icon.Size = defaultSize
			icon.Rotation = 0
			return
		end

		if animate then
			icon.Size = hiddenSize
			icon.Rotation = -45
			container.Visible = true

			local showTween: Tween = TweenService:Create(icon, _settings.FAVORITE_ICON_SHOW_TWEEN, {
				Size = defaultSize,
				Rotation = 0,
			})
			favoriteTweens[slotData.Slot] = { showTween }
			showTween:Play()
			return
		end

		icon.Size = defaultSize
		icon.Rotation = 0
		container.Visible = true
		return
	end

	--[[ Hide ]]

	if not container.Visible then
		icon.Size = hiddenSize
		icon.Rotation = -10
		return
	end

	if animate then
		local hideTween: Tween = TweenService:Create(icon, _settings.FAVORITE_ICON_HIDE_TWEEN, {
			Size = hiddenSize,
			Rotation = -10,
		})
		favoriteTweens[slotData.Slot] = { hideTween }

		hideTween.Completed:Connect(function(playbackState: Enum.PlaybackState)
			if playbackState ~= Enum.PlaybackState.Completed then
				return
			end

			if container.Parent then
				container.Visible = false
			end
			favoriteTweens[slotData.Slot] = nil
		end)

		hideTween:Play()
		return
	end

	icon.Size = hiddenSize
	icon.Rotation = -10
	container.Visible = false
end

--%%%%%%%%%%%%%%%%%%%% On Locked Updated

--[[
	Updates Slot favorite icons from Inventory locked-data changes.
]]
function Module._onLockedUpdated(changed: table, initialUpdate: boolean)
	--[[ Initial ]]

	if initialUpdate then
		--- @param slotData BackpackPlus_SlotData
		for _slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
			Module._applySlot(slotData, false)
		end
		return
	end

	--[[ Delta ]]

	--- @param slotData BackpackPlus_SlotData
	for _slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		local itemId: string? = getLockId(slotData.Tool)
		if not itemId or changed[itemId] == nil then
			continue
		end

		Module._setSlotFavorite(slotData, changed[itemId] == true, true)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
