--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local HideReasons = require(_scripts:FindFirstChild("HideReasons")) --- @type Utils_HideReasons
local MarketplaceCache = require(_scripts:FindFirstChild("MarketplaceCache")) --- @type Utils_MarketplaceCache

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The hide reason this component holds in HideReasons
local HIDE_REASON: string = "Utils_VisibleOnMarketplace"

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

--- @class Utils_VisibleOnMarketplace : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ProductName string
--- @field InfoType Enum.InfoType | string
--- @field ShowIfMissing boolean
--- @field CheckForGroup boolean
---
--- # State #
---
--- @field IsOwned boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the attributes name a product
	if not self:GetAttributes() then
		return
	end

	--[[ Connections ]]

	self:ConnectUpdates()

	--[[ Updating ]]

	self:Refresh()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Forget Hide Reason ]]

	HideReasons.Clear(self.Instance, HIDE_REASON)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the product and visibility attributes, warning and returning false when they don't name a product.
]]
--- @return boolean
function Component:GetAttributes()
	--[[ Product Name ]]

	self.ProductName = self.Instance:GetAttribute("Utils_ProductName") or ""

	-- Check if the product name is set
	if self.ProductName == "" then
		warn(`[{_localName}::{script.Name}]: ({self.Instance}) is missing the (Utils_ProductName) Attribute! -`, self.Instance)
		return false
	end

	--[[ Info Type ]]

	local infoTypeName: string = self.Instance:GetAttribute("Utils_InfoType") or "GamePass"
	self.InfoType = MarketplaceCache.GetInfoType(infoTypeName)

	-- Check if the info type is known
	if not self.InfoType then
		warn(`[{_localName}::{script.Name}]: ({infoTypeName}) is not a valid InfoType! -`, self.Instance)
		return false
	end

	-- Check if a custom product is Group or RobloxPlus
	if self.InfoType == "Custom" and self.ProductName ~= "Group" and self.ProductName ~= "RobloxPlus" then
		warn(`[{_localName}::{script.Name}]: Custom product ({self.ProductName}) must be (Group) or (RobloxPlus)! -`, self.Instance)
		return false
	end

	--[[ Visibility ]]

	self.ShowIfMissing = self.Instance:GetAttribute("Utils_ShowIfMissing") ~= false
	self.CheckForGroup = self.Instance:GetAttribute("Utils_CheckForGroup") == true

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Connect Updates

--[[
	Refreshes the visibility when the product is bought or gifted, and when Roblox Plus or group membership changes
	for the products that depend on them.
]]
function Component:ConnectUpdates()
	--[[ Purchases ]]

	-- Follow purchases of a marketplace product
	if self.InfoType ~= "Custom" then
		table.insert(
			self.Connections,
			MarketplaceCache.GetChangedSignal():Connect(function(purchasedName: string, purchasedType: Enum.InfoType)
				-- Skip purchases of other products
				if purchasedName ~= self.ProductName or purchasedType ~= self.InfoType then
					return
				end

				self:Refresh()
			end)
		)
	end

	--[[ Roblox Plus ]]

	-- Follow the player's Roblox Plus subscription
	if self.InfoType == "Custom" and self.ProductName == "RobloxPlus" then
		table.insert(
			self.Connections,
			I.Network.Fired("Marketplace_RobloxPlusUpdated", function()
				self:Refresh()
			end)
		)
		table.insert(
			self.Connections,
			I.Env.LocalPlayer:GetPropertyChangedSignal("HasRobloxSubscription"):Connect(function()
				self:Refresh()
			end)
		)
	end

	--[[ Group ]]

	-- Follow the player's group membership once the replicator is ready
	if self.CheckForGroup or (self.InfoType == "Custom" and self.ProductName == "Group") then
		if I.Started then
			self:ConnectGroupReplicator()
		else
			I.OnLoaded(I.Priority.Default, function()
				self:ConnectGroupReplicator()
			end)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Group Replicator

--[[
	Refreshes the visibility when the player's group membership changes on the Group replicator.
]]
function Component:ConnectGroupReplicator()
	--[[ Checks ]]

	-- Skip an element destroyed while the game loaded
	if self._destroyed then
		return
	end

	--[[ Connections ]]

	local groupRep: Folder = I.Replicator.GetFolder("Group")

	table.insert(
		self.Connections,
		groupRep:GetAttributeChangedSignal("Default_IsMember"):Connect(function()
			self:Refresh()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows or hides the element from the player's ownership of the product, or membership of the custom Group /
	RobloxPlus products.
]]
function Component:Refresh()
	--[[ Checks ]]

	-- Skip a destroyed component
	if self._destroyed then
		return
	end

	--[[ Ownership ]]

	self.IsOwned = self:IsOwning()

	--[[ Visibility ]]

	local visible: boolean = self.ShowIfMissing == not self.IsOwned

	HideReasons.SetHidden(self.Instance, HIDE_REASON, not visible)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Owning

--[[
	Returns whether the player has the product: owns it (or is in the group with `Utils_CheckForGroup`), is a group
	member for `Group`, or subscribes for `RobloxPlus`.
]]
--- @return boolean
function Component:IsOwning()
	--[[ Custom ]]

	if self.InfoType == "Custom" and self.ProductName == "RobloxPlus" then
		return I.G_Marketplace.PlayerHasRobloxPlus(I.Env.LocalPlayer)
	end

	if self.InfoType == "Custom" and self.ProductName == "Group" then
		return I.Network.Invoke("Group_IsMember") == true
	end

	--[[ Marketplace ]]

	local owned: boolean = MarketplaceCache.GetOwned(self.ProductName, self.InfoType)

	-- Count group membership as owning with Utils_CheckForGroup
	if not owned and self.CheckForGroup then
		owned = I.Network.Invoke("Group_IsMember") == true
	end

	--[[ Returning ]]

	return owned
end

return Component
