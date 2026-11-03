--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "GlobalLeaderboard_Controller"

--- @type GlobalLeaderboard_Controller_Settings
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

--- @class GlobalLeaderboard_Controller_S_Leaderboard : Component
--- @field Instance Model | ScreenGui
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field LeaderboardName string
--- @field Scope string | nil
--- @field IsAscending boolean
--- @field PageSize number
--- @field DataDisplayType string
--- @field ConvertValue boolean
--- @field IsPlayerLeaderboards boolean
---
--- # Elements #
---
--- @field Container Frame | ScrollingFrame
--- @field PlacePrefabs { Frame }
--- @field PlaceIconsContainer Instance?
--- @field PlaceIcons { [number]: Instance }
---
--- # State #
---
--- @field WarnName string
--- @field ClonedPrefabs { Frame }
--- @field StoreUpdated boolean
--- @field WarnedMissingData boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Initialization ]]

	self.ClonedPrefabs = {}

	self:GetAttributes()
	if not self.LeaderboardName then
		return
	end

	self:GetElements()
	if not self.Container or not self.PlacePrefabs or #self.PlacePrefabs == 0 then
		return
	end

	self:CreateConnections()

	--[[ Initial Update ]]

	self:Update()
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
	Getting and storing key attributes.
]]
function Component:GetAttributes()
	--[[ DataStore ]]

	self.LeaderboardName = self.Instance:GetAttribute("GLC_LeaderboardName")
	self.Scope = self.Instance:GetAttribute("GLC_Scope")
	self.IsAscending = self.Instance:GetAttribute("GLC_IsAscending") == true
	self.PageSize = self.Instance:GetAttribute("GLC_PageSize") or 50

	if self.LeaderboardName == "" then
		self.LeaderboardName = nil
	end
	if self.Scope == "" then
		self.Scope = nil
	end

	--[[ Display ]]

	self.DataDisplayType = self.Instance:GetAttribute("GLC_DataDisplayType") or "Standard"
	self.ConvertValue = self.Instance:GetAttribute("GLC_ConvertValue") == true

	--[[ Other ]]

	self.IsPlayerLeaderboards = self.Instance:GetAttribute("GLC_IsPlayerLeaderboards") == true
	self.WarnName = self.Scope and `{self.LeaderboardName}::{self.Scope}` or self.LeaderboardName

	--[[ Checks ]]

	if not self.LeaderboardName or type(self.LeaderboardName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (GLC_LeaderboardName) attribute type. Expected (string), got ({self.LeaderboardName}: {typeof(self.LeaderboardName)})! -`, self.Instance)
		self.LeaderboardName = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	--[[ Container ]]

	self.Container = self.Instance:FindFirstChild("S_Container", true) --- @type Frame | ScrollingFrame
	if not self.Container then
		warn(`[{_localName}::{script.Name}]: (S_Container) is missing for the ({self.Instance}) Instance! -`, self.Instance)
		return
	end

	--[[ Place Prefabs ]]

	self:StorePlacePrefabs()

	if not self.PlacePrefabs or #self.PlacePrefabs == 0 then
		warn(`[{_localName}::{script.Name}]: No Place_* prefabs under (S_Container); cannot render leaderboard ({self.WarnName}). -`, self.Instance)
	end

	--[[ Place Icons ]]

	self:StorePlaceIcons()
end

--%%%%%%%%%%%%%%%%%%%% Store Place Prefabs

--[[
	Stores all place prefabs under the container.
]]
function Component:StorePlacePrefabs()
	if not self.Container then
		return
	end

	--[[ Storing ]]

	self.PlacePrefabs = {}

	for count = 1, self.PageSize do
		local placePrefab: GuiObject = self.Container:FindFirstChild(`Place_{count}`)

		if placePrefab and placePrefab:IsA("GuiObject") then
			placePrefab.Visible = false
			table.insert(self.PlacePrefabs, placePrefab)
		else
			break
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Store Place Icons

--[[
	Stores all place icons under S_PlaceIcons.
]]
function Component:StorePlaceIcons()
	--[[ Storing ]]

	self.PlaceIcons = {}
	self.PlaceIconsContainer = self.Instance:FindFirstChild("S_PlaceIcons", true)

	if not self.PlaceIconsContainer then
		return
	end

	for count = 1, self.PageSize do
		local placeIcon: Instance = self.PlaceIconsContainer:FindFirstChild(`Place_{count}`)

		if placeIcon then
			self.PlaceIcons[count] = placeIcon

			local userIcon: ImageLabel = placeIcon:FindFirstChild("S_UserIcon", true)
			if not userIcon or not userIcon:IsA("ImageLabel") then
				warn(`[{_localName}::{script.Name}]: (S_UserIcon) is missing for ({placeIcon}) on leaderboard ({self.WarnName}). -`, self.Instance)
			end
		else
			break
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for leaderboard updates.
]]
function Component:CreateConnections()
	--[[ Leaderboard Updated ]]

	table.insert(
		self.Connections,
		I.Topic.Subscribe("GlobalLeaderboard_Updated", function(storeFullId: string)
			--[[ Checks ]]

			local resolvedName: string = self:GetResolvedName()

			-- Skip updates of other stores
			if storeFullId ~= (if self.Scope then `{resolvedName}::{self.Scope}` else resolvedName) then
				return
			end

			--[[ Updating ]]

			self.StoreUpdated = true
			self:Update()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Updates leaderboard with new data.
]]
function Component:Update()
	--[[ Updating ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		--%%%%%%%%%%%%%%%%%%%% Data

		--[[ Getting Read Options ]]

		-- A tracked statistic's page is cached only with its registered page size and order
		local leaderboardName: string = self:GetResolvedName()
		local trackedStatistic = _settings.TRACKED_STATISTICS[leaderboardName] --- @type GlobalLeaderboard_Controller_TrackedStatistic?
		local readIsAscending: boolean = if trackedStatistic then trackedStatistic.IsAscending else self.IsAscending
		local readPageSize: number = if trackedStatistic then trackedStatistic.PageSize else self.PageSize

		--[[ Getting Data ]]

		--- @type { GlobalLeaderboard_PageData }?
		local data = I.GlobalLeaderboard.GetItems(leaderboardName, self.Scope, readIsAscending, readPageSize, true, false, true, true)

		-- Hide every row when no page is cached for this read
		if not data then
			-- Warn once when the store updated but no page is cached for this read
			if self.StoreUpdated and not self.WarnedMissingData then
				self.WarnedMissingData = true
				warn(`[{_localName}::{script.Name}]: No cached page for ({self.WarnName}) with page size ({readPageSize}) and ascending ({readIsAscending}); match the store's registration! -`, self.Instance)
			end

			-- Hiding all cloned prefabs
			for _, cloned in ipairs(self.ClonedPrefabs) do
				cloned.Visible = false
			end

			self:UpdatePlaceIcons(nil)
			return
		end

		--%%%%%%%%%%%%%%%%%%%% Updating

		local shownCount: number = math.min(#data, self.PageSize)

		for index: number = 1, shownCount do
			--[[ Getting Player Info ]]

			local entryData = data[index] --- @type GlobalLeaderboard_PageData
			local playerId: number = entryData["key"]

			--[[ Updating Places ]]

			local placeSuccess: boolean
			local placeResult: any | string?
			placeSuccess, placeResult = pcall(function()
				--%%%%%%%%%%%%%%%%%%%% Cloning

				local cloned: Frame

				if self.ClonedPrefabs[index] then
					cloned = self.ClonedPrefabs[index]
				else
					cloned = self.PlacePrefabs[math.clamp(index, 1, #self.PlacePrefabs)]:Clone()
					cloned.LayoutOrder = index
					cloned.Parent = self.Container
					table.insert(self.ClonedPrefabs, index, cloned)
				end

				-- Show rows that a shorter page hid before
				cloned.Visible = true

				--%%%%%%%%%%%%%%%%%%%% Getting Value

				local value: number = entryData["value"]
				if self.ConvertValue then
					value = value ~= 0 and (1.0000000001 ^ value) or 0
				end

				--%%%%%%%%%%%%%%%%%%%% Updating Info

				do
					-- Place Text
					local placeText: TextLabel = cloned:FindFirstChild("S_PlaceText", true)
					if placeText and placeText:IsA("TextLabel") then
						placeText.Text = `#{index}`
					end

					-- Value Text
					local valueText: TextLabel = cloned:FindFirstChild("S_ValueText", true)
					if valueText and valueText:IsA("TextLabel") then
						valueText.Text = I.GlobalLeaderboard_Controller.ConvertValue(value, self.DataDisplayType)
					end

					-- PlayerName Text
					local nameText: TextLabel = cloned:FindFirstChild("S_NameText", true)
					if nameText and nameText:IsA("TextLabel") then
						if self.IsPlayerLeaderboards then
							task.spawn(function()
								local playerName: string | nil = I.GlobalLeaderboard_Controller.GetPlayerName(playerId)
								nameText.Text = playerName or "..."
							end)
						else
							nameText.Text = `{playerId}`
						end
					end

					-- Flag Text
					local flagText: TextLabel = cloned:FindFirstChild("S_FlagText", true)
					if flagText and flagText:IsA("TextLabel") then
						if self.IsPlayerLeaderboards then
							task.spawn(function()
								--- @type Country_CountryData
								local countryData = I.GlobalLeaderboard_Controller.GetPlayerCountryData(playerId)
								flagText.Text = countryData and countryData.Emoji or "?"
							end)
						else
							flagText.Text = "?"
						end
					end

					-- Avatar Image
					local avatarImage: ImageLabel = cloned:FindFirstChild("S_AvatarImage", true)
					if avatarImage and avatarImage:IsA("ImageLabel") then
						avatarImage.Image = `rbxthumb://type=AvatarHeadShot&id={playerId}&w=150&h=150`
					end
				end
			end)

			--[[ Updating Error ]]

			if not placeSuccess then
				warn(`[{_localName}::{script.Name}]: Failed to update Leaderboard for ({self.WarnName}) for place ({index})! - {placeResult} -`, self.Instance)
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Clearing Extra Places

		for index: number = shownCount + 1, #self.ClonedPrefabs do
			local cloned: Frame = self.ClonedPrefabs[index]
			if cloned then
				cloned.Visible = false
			end
		end

		self:UpdatePlaceIcons(data)
	end)

	--[[ Error ]]

	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to update Leaderboard for ({self.WarnName})! - {result} -`, self.Instance)
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Place Icons

--[[
	Updates S_UserIcon images for stored place icons.
]]
--- @param data { GlobalLeaderboard_PageData }?
function Component:UpdatePlaceIcons(data)
	--[[ Checks ]]

	-- Skip boards without place icons
	if not self.PlaceIcons then
		return
	end

	--[[ Updating ]]

	for placeIndex: number, placeInstance: Instance in ipairs(self.PlaceIcons) do
		local userIcon: ImageLabel = placeInstance:FindFirstChild("S_UserIcon", true)
		if userIcon and userIcon:IsA("ImageLabel") then
			--- @type GlobalLeaderboard_PageData?
			local entryData = data and data[placeIndex]
			local playerId: string? = entryData and entryData["key"]
			local numericId: number? = tonumber(playerId)

			if not numericId or numericId <= 0 then
				userIcon.Image = ""
			else
				userIcon.Image = `rbxthumb://type=AvatarHeadShot&id={numericId}&w=150&h=150`
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Resolved Name

--[[
	Returns `GLC_LeaderboardName` with `{day}`, `{week}` and `{month}` filled in from today's UTC date.
]]
--- @return string
function Component:GetResolvedName()
	--[[ Local Variables ]]

	local today = os.date("!*t") --- @type Date_DateTable
	local leaderboardName: string = self.LeaderboardName

	--[[ Resolving ]]

	leaderboardName = leaderboardName:gsub("{day}", tostring(today.yday))
	leaderboardName = leaderboardName:gsub("{week}", tostring(math.ceil(today.yday / 7)))
	leaderboardName = leaderboardName:gsub("{month}", tostring(today.month))

	--[[ Returning ]]

	return leaderboardName
end

return Component
