--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "GlobalLeaderboard_Controller"

--- @type GlobalLeaderboard_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Id used for a placeholder dummy.
local placeholderDummyId = 2

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

--- @class GlobalLeaderboard_Controller_S_Dummy : Component
--- @field Instance Model
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field LeaderboardName string
--- @field Scope string | nil
--- @field IsAscending boolean
--- @field PageSize number
--- @field PlaceId number
--- @field DataDisplayType string
--- @field ConvertValue boolean
--- @field IsR15 boolean
--- @field DummyScale number
--- @field InsertPlaceholderDummy boolean
---
--- # Elements #
---
--- @field InfoGui BillboardGui?
---
--- # State #
---
--- @field WarnName string
--- @field Dummy Model
--- @field CurrentPlayerId number?
--- @field UpdateState boolean
--- @field QueueUpdate boolean
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

	self:GetAttributes()
	if not self.LeaderboardName then
		return
	end

	self:GetElements()
	self:CreateConnections()

	--[[ Initial Update ]]

	task.delay(0.5, function()
		self:Update()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	-- Remove the statue rig
	if self.Dummy then
		self.Dummy:Destroy()
		self.Dummy = nil
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
	self.PlaceId = self.Instance:GetAttribute("GLC_PlaceId") or 1

	if self.LeaderboardName == "" then
		self.LeaderboardName = nil
	end
	if self.Scope == "" then
		self.Scope = nil
	end

	--[[ Display ]]

	self.DataDisplayType = self.Instance:GetAttribute("GLC_DataDisplayType") or "Standard"
	self.ConvertValue = self.Instance:GetAttribute("GLC_ConvertValue") == true

	--[[ Dummy ]]

	self.IsR15 = self.Instance:GetAttribute("GLC_IsR15") == true
	self.DummyScale = self.Instance:GetAttribute("GLC_DummyScale") or 1
	self.InsertPlaceholderDummy = self.Instance:GetAttribute("GLC_InsertPlaceholderDummy") == true

	--[[ Other ]]

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
	self.InfoGui = self.Instance:FindFirstChild("S_InfoGui", true) --- @type BillboardGui?
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for dummy updates.
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
	Creates new dummy to match current player in that spot.
]]
function Component:Update()
	--[[ Checks ]]

	-- Skip once the component was destroyed
	if self._destroyed then
		return
	end

	-- Set function to run again after the current one ends
	if self.UpdateState then
		self.QueueUpdate = true
		return
	end
	self.UpdateState = true

	--[[ Updating ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		--%%%%%%%%%%%%%%%%%%%% Data

		local createDummy: boolean = false

		--[[ Getting Read Options ]]

		-- A tracked statistic's page is cached only with its registered page size and order
		local leaderboardName: string = self:GetResolvedName()
		local trackedStatistic = _settings.TRACKED_STATISTICS[leaderboardName] --- @type GlobalLeaderboard_Controller_TrackedStatistic?
		local readIsAscending: boolean = if trackedStatistic then trackedStatistic.IsAscending else self.IsAscending
		local readPageSize: number = if trackedStatistic then trackedStatistic.PageSize else self.PageSize

		--[[ Getting Data ]]

		--- @type { GlobalLeaderboard_PageData }?
		local data = I.GlobalLeaderboard.GetItems(leaderboardName, self.Scope, readIsAscending, readPageSize, true, false, true, true)

		-- Warn once when the store updated but no page is cached for this read
		if not data and self.StoreUpdated and not self.WarnedMissingData then
			self.WarnedMissingData = true
			warn(`[{_localName}::{script.Name}]: No cached page for ({self.WarnName}) with page size ({readPageSize}) and ascending ({readIsAscending}); match the store's registration! -`, self.Instance)
		end

		local playerId: number = data and data[self.PlaceId] and data[self.PlaceId]["key"]
		local value: number = data and data[self.PlaceId] and data[self.PlaceId]["value"]

		if self.ConvertValue and value then
			value = value ~= 0 and (1.0000000001 ^ value) or 0
		end

		-- Fixing negative PlayerId (Studio Testing Sessions)
		if not tonumber(playerId) or tonumber(playerId) <= 0 then
			playerId = placeholderDummyId
		end

		--%%%%%%%%%%%%%%%%%%%% Missing Data

		if not data or not data[self.PlaceId] then
			if self.InsertPlaceholderDummy then
				-- Create dummy if enabled
				createDummy = true
			else
				-- Hiding Info Gui
				if self.InfoGui then
					self.InfoGui.Enabled = false
				end

				-- Destroy current dummy and forget its player so a later update rebuilds it
				if self.Dummy then
					self.Dummy:Destroy()
					self.Dummy = nil
				end
				self.CurrentPlayerId = nil

				return
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Updating Dummy

		do
			--[[ Local Variables ]]

			local differentPlayer: boolean = playerId and playerId ~= self.CurrentPlayerId
			local differentDummy: boolean = createDummy and placeholderDummyId ~= self.CurrentPlayerId

			--[[ Checks ]]

			if differentPlayer or differentDummy then
				--[[ Clearing Previous ]]

				-- Forget the player until the new rig is in place, so a failure retries on the next update
				self.CurrentPlayerId = nil

				if self.Dummy then
					self.Dummy:Destroy()
					self.Dummy = nil
				end

				--%%%%%%%%%%%%%%%%%%%% Creating Dummy

				--[[ Creating Dummy ]]

				local createSuccess: boolean
				local createResult: any | string?
				createSuccess, createResult = pcall(function()
					local humDesc: HumanoidDescription = Players:GetHumanoidDescriptionFromUserIdAsync(playerId)
					return Players:CreateHumanoidModelFromDescriptionAsync(humDesc, self.IsR15 and Enum.HumanoidRigType.R15 or Enum.HumanoidRigType.R6)
				end)

				-- Stop when the avatar couldn't be fetched or built
				if not createSuccess or not createResult then
					warn(`[{_localName}::{script.Name}]: Failed while creating Dummy for ({self.WarnName}) for place ({self.PlaceId})! - {createResult} -`, self.Instance)
					return
				end

				-- Drop the new rig when the component was destroyed while it was built
				if self._destroyed then
					createResult:Destroy()
					return
				end

				-- Saving
				local newDummy: Model = createResult
				self.Dummy = newDummy

				--[[ Getting Elements ]]

				local humanoid: Humanoid = newDummy:FindFirstChildOfClass("Humanoid")
				local rootPart: BasePart = newDummy:FindFirstChild("HumanoidRootPart")

				--%%%%%%%%%%%%%%%%%%%% Updating Dummy

				--[[ Properties ]]

				newDummy.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
				humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

				--[[ Scale ]]

				newDummy:ScaleTo(self.DummyScale)

				--[[ Moving ]]

				rootPart.Anchored = true
				task.spawn(function()
					task.wait() -- Wait before moving for model bounding box to update
					I.World.MoveModelToPosition(newDummy, self.Instance:GetPivot())
				end)

				-- Parenting
				newDummy.Parent = self.Instance
				self.CurrentPlayerId = playerId

				--[[ Client Animation ]]

				self.Dummy:SetAttribute("GLC_Client_AnimationId", tonumber(self.Instance:GetAttribute("GLC_Client_AnimationId")) or 0)
				self.Dummy:AddTag("GLC_Dummy")
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Updating Info

		do
			--[[ Info Gui ]]

			if self.InfoGui then
				self.InfoGui.Enabled = createDummy == false
			end

			--[[ Updating Info ]]

			if playerId and value and self.InfoGui then
				-- Place Text
				local placeText: TextLabel = self.InfoGui:FindFirstChild("S_PlaceText", true)
				if placeText and placeText:IsA("TextLabel") then
					placeText.Text = `#{self.PlaceId}`
				end

				-- Value Text
				local valueText: TextLabel = self.InfoGui:FindFirstChild("S_ValueText", true)
				if valueText and valueText:IsA("TextLabel") then
					valueText.Text = I.GlobalLeaderboard_Controller.ConvertValue(value, self.DataDisplayType)
				end

				-- PlayerName Text
				local nameText: TextLabel = self.InfoGui:FindFirstChild("S_NameText", true)
				if nameText and nameText:IsA("TextLabel") then
					task.spawn(function()
						local playerName: string | nil = I.GlobalLeaderboard_Controller.GetPlayerName(playerId)
						nameText.Text = playerName or "..."
					end)
				end

				-- Flag Text
				local flagText: TextLabel = self.InfoGui:FindFirstChild("S_FlagText", true)
				if flagText and flagText:IsA("TextLabel") then
					task.spawn(function()
						--- @type Country_CountryData
						local countryData = I.GlobalLeaderboard_Controller.GetPlayerCountryData(playerId)
						flagText.Text = countryData and countryData.Emoji or "?"
					end)
				end

				-- Avatar Image
				local avatarImage: ImageLabel = self.InfoGui:FindFirstChild("S_AvatarImage", true)
				if avatarImage and avatarImage:IsA("ImageLabel") then
					avatarImage.Image = `rbxthumb://type=AvatarHeadShot&id={playerId}&w=150&h=150`
				end
			end
		end
	end)

	--[[ Error ]]

	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to update Dummy for ({self.WarnName}) for place ({self.PlaceId})! - {result} -`, self.Instance)

		-- Destroy the rig and forget its player so the next update rebuilds it
		if self.Dummy then
			self.Dummy:Destroy()
			self.Dummy = nil
		end
		self.CurrentPlayerId = nil
	end

	--[[ Finishing ]]

	-- Updating state
	self.UpdateState = false

	-- Running update again
	if self.QueueUpdate then
		self.QueueUpdate = false
		self:Update()
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
