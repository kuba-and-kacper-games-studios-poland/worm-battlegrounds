--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--- @type Utils_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local MarketplaceCache = require(_scripts:FindFirstChild("MarketplaceCache")) --- @type Utils_MarketplaceCache

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Retries ]]

-- How many times a failed price lookup retries, and the first delay (doubling each time)
local PRICE_RETRIES: number = 5
local PRICE_RETRY_DELAY: number = 5

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

--- @class Utils_PriceTag : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ProductName string
--- @field InfoType Enum.InfoType | string
--- @field ForceGamePassCheck boolean
--- @field CustomGamePassName string
--- @field CustomFormat string
--- @field InsertRobuxIcon boolean
---
--- # State #
---
--- @field IsOwned boolean
--- @field PriceRequest number
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a TextLabel
	if not self.Instance:IsA("TextLabel") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (TextLabel)! -`, self.Instance)
		return
	end

	-- Check if the attributes name a product
	if not self:GetAttributes() then
		return
	end

	--[[ Setup ]]

	self.PriceRequest = 0

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
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the product and display attributes, warning and returning false when they don't name a product.
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

	--[[ Ownership ]]

	self.ForceGamePassCheck = self.Instance:GetAttribute("Utils_ForceGamePassCheck") == true
	self.CustomGamePassName = self.Instance:GetAttribute("Utils_CustomGamePassName") or ""

	-- Check if a forced game pass check names its game pass
	if self.ForceGamePassCheck and self.CustomGamePassName == "" then
		warn(`[{_localName}::{script.Name}]: ({self.Instance}) requires non-empty (Utils_CustomGamePassName) when (Utils_ForceGamePassCheck) is true! -`, self.Instance)
		return false
	end

	--[[ Display ]]

	self.CustomFormat = self.Instance:GetAttribute("Utils_CustomFormat") or ""
	self.InsertRobuxIcon = self.Instance:GetAttribute("Utils_InsertRobuxIcon") ~= false

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Connect Updates

--[[
	Refreshes the label when its product is bought or gifted, when Roblox Plus or group membership changes for
	those custom products, and when `Utils_ProductName` changes.
]]
function Component:ConnectUpdates()
	--[[ Purchases ]]

	-- Follow purchases of a marketplace product
	if self.InfoType ~= "Custom" then
		table.insert(
			self.Connections,
			MarketplaceCache.GetChangedSignal():Connect(function(purchasedName: string, purchasedType: Enum.InfoType)
				local ownedName: string
				local ownedType: Enum.InfoType
				ownedName, ownedType = self:GetOwnershipProduct()

				-- Skip purchases of other products
				if purchasedName ~= ownedName or purchasedType ~= ownedType then
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
	if self.InfoType == "Custom" and self.ProductName == "Group" then
		if I.Started then
			self:ConnectGroupReplicator()
		else
			I.OnLoaded(I.Priority.Default, function()
				self:ConnectGroupReplicator()
			end)
		end
	end

	--[[ Product Name ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_ProductName"):Connect(function()
			local productName: string = self.Instance:GetAttribute("Utils_ProductName") or ""

			-- Skip an emptied product name
			if productName == "" then
				warn(`[{_localName}::{script.Name}]: ({self.Instance}) is missing the (Utils_ProductName) Attribute! -`, self.Instance)
				return
			end

			self.ProductName = productName
			self:Refresh()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Group Replicator

--[[
	Refreshes the label when the player's group membership changes on the Group replicator.
]]
function Component:ConnectGroupReplicator()
	--[[ Checks ]]

	-- Skip a label destroyed while the game loaded
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
	Shows the price of a marketplace product, or the membership text of the custom Group / RobloxPlus products.
]]
function Component:Refresh()
	--[[ Updating ]]

	if self.InfoType ~= "Custom" then
		self:UpdatePrice()
	elseif self.ProductName == "RobloxPlus" then
		self:UpdatePriceRobloxPlus()
	elseif self.ProductName == "Group" then
		self:UpdatePriceGroup()
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Price

--[[
	Shows `OWNED` or the product's current price. A failed lookup retries with a doubling delay, up to
	`PRICE_RETRIES` times.
]]
function Component:UpdatePrice(attempt: number?)
	--[[ Checks ]]

	-- Skip a destroyed label
	if self._destroyed then
		return
	end

	-- Check if the product is listed in the Marketplace data
	if not MarketplaceCache.IsListed(self.ProductName, self.InfoType) then
		warn(`[{_localName}::{script.Name}]: ({self.ProductName}) is not a listed ({self.InfoType.Name})! -`, self.Instance)
		self.Instance.Text = _settings.PRICETAG_MESSAGES.Error
		return
	end

	--[[ Local Variables ]]

	local retries: number = attempt or 0
	local ownedName: string
	local ownedType: Enum.InfoType
	ownedName, ownedType = self:GetOwnershipProduct()

	-- Mark this update as the newest so older retries stop
	self.PriceRequest += 1
	local request: number = self.PriceRequest

	--[[ Ownership ]]

	self.IsOwned = MarketplaceCache.GetOwned(ownedName, ownedType)

	-- Show OWNED instead of a price
	if self.IsOwned then
		self.Instance.Text = _settings.PRICETAG_MESSAGES.Owned
		return
	end

	--[[ Data ]]

	local productPrice: string | number | nil = MarketplaceCache.GetPrice(self.ProductName, self.InfoType, self.InsertRobuxIcon)

	--[[ Retrying ]]

	if not productPrice then
		self.Instance.Text = _settings.PRICETAG_MESSAGES.Error

		-- Stop retrying at the cap
		if retries >= PRICE_RETRIES then
			warn(`[{_localName}::{script.Name}]: Price of ({self.ProductName}) is still missing after {PRICE_RETRIES} retries! -`, self.Instance)
			return
		end

		task.delay(PRICE_RETRY_DELAY * 2 ^ retries, function()
			-- Skip a retry a newer update replaced
			if self.PriceRequest ~= request then
				return
			end

			self:UpdatePrice(retries + 1)
		end)

		return
	end

	--[[ Texts ]]

	-- Show the plain price without a custom format
	if self.CustomFormat == "" then
		self.Instance.Text = `{productPrice}`
		return
	end

	local success: boolean
	local result: any | string?
	success, result = pcall(string.format, self.CustomFormat, productPrice)

	self.Instance.Text = if success then result else `{productPrice}`
end

--%%%%%%%%%%%%%%%%%%%% Update Price Group

--[[
	Shows `OWNED` for a group member, else `JOIN GROUP`.
]]
function Component:UpdatePriceGroup()
	--[[ Checks ]]

	-- Skip a destroyed label
	if self._destroyed then
		return
	end

	--[[ Ownership ]]

	self.IsOwned = I.Network.Invoke("Group_IsMember")

	--[[ Texts ]]

	self.Instance.Text = if self.IsOwned then _settings.PRICETAG_MESSAGES.Owned else _settings.PRICETAG_MESSAGES.Group
end

--%%%%%%%%%%%%%%%%%%%% Update Price Roblox Plus

--[[
	Shows `OWNED` for a Roblox Plus subscriber, else `ROBLOX PLUS`.
]]
function Component:UpdatePriceRobloxPlus()
	--[[ Checks ]]

	-- Skip a destroyed label
	if self._destroyed then
		return
	end

	--[[ Ownership ]]

	self.IsOwned = I.G_Marketplace.PlayerHasRobloxPlus(I.Env.LocalPlayer)

	--[[ Texts ]]

	self.Instance.Text = if self.IsOwned then _settings.PRICETAG_MESSAGES.Owned else _settings.PRICETAG_MESSAGES.RobloxPlus
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ownership Product

--[[
	Returns the product whose ownership shows `OWNED`: the forced game pass with `Utils_ForceGamePassCheck`, else the
	label's product.
]]
--- @return string
--- @return Enum.InfoType
function Component:GetOwnershipProduct()
	--[[ Returning ]]

	if self.ForceGamePassCheck then
		return self.CustomGamePassName, Enum.InfoType.GamePass
	end

	return self.ProductName, self.InfoType
end

return Component
