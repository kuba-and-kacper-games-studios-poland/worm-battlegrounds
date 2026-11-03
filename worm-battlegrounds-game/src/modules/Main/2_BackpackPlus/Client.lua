--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")
local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Slot = require(_scripts:FindFirstChild("Client"):FindFirstChild("Slot")) --- @type BackpackPlus_Client_Slot
local Toolbar = require(_scripts:FindFirstChild("Client"):FindFirstChild("Toolbar")) --- @type BackpackPlus_Client_Toolbar
local Filter = require(_scripts:FindFirstChild("Client"):FindFirstChild("Filter")) --- @type BackpackPlus_Client_Filter
local Favorite = require(_scripts:FindFirstChild("Client"):FindFirstChild("Favorite")) --- @type BackpackPlus_Client_Favorite
local Backpack = require(_scripts:FindFirstChild("Client"):FindFirstChild("Backpack")) --- @type BackpackPlus_Client_Backpack
local Lock = require(_scripts:FindFirstChild("Client"):FindFirstChild("Lock")) --- @type BackpackPlus_Client_Lock
local Reserve = require(_scripts:FindFirstChild("Client"):FindFirstChild("Reserve")) --- @type BackpackPlus_Client_Reserve
local HoverInfo = require(_scripts:FindFirstChild("Client"):FindFirstChild("HoverInfo")) --- @type BackpackPlus_Client_HoverInfo

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }

--[[ Created ]]

local createdSlots = {
	BySlot = {}, --- @type { [Frame]: BackpackPlus_SlotData }
	ByTool = {}, --- @type { [Tool]: BackpackPlus_SlotData }
}

--[[ Toolbar ]]

local toolbarSlots = {} --- @type { Frame }
local equippedSlots = {} --- @type { BackpackPlus_SlotData }

--[[ Other ]]

local characterConnections: { RBXScriptConnection } = {}

--%%%%%%%%%%%%%%%%%%%% Shared

--- @type BackpackPlus_ClientContext
local BackpackPlus = {

	--[[ Slot ]]

	CreatedSlots = createdSlots,
	LastLayoutOrder = 0,

	--[[ Toolbar ]]

	ToolbarSlots = toolbarSlots,
	EquippedSlots = equippedSlots,
	ToolbarSlotCount = _settings.TOOLBAR_SLOTS[I.Platform.Current] or _settings.TOOLBAR_SLOTS["Default"],
	ToolbarServerLoaded = false,
	PendingToolbarSlots = {},
	ReservedSlots = {},

	--[[ Lock ]]

	IsLocked = false,

	--[[ Favorite ]]

	IsFavoriteMode = false,

	--[[ Client ]]

	CurrentlyEquipped = nil,
}

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
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	--[[ Display Types ]]

	Module._loadDisplayTypes()

	--[[ Shared ]]

	Slot.Init(BackpackPlus)
	Toolbar.Init(BackpackPlus)
	Filter.Init(BackpackPlus)
	Favorite.Init(BackpackPlus)
	Backpack.Init(BackpackPlus)
	Lock.Init(BackpackPlus)
	Reserve.Init(BackpackPlus)
	HoverInfo.Init(BackpackPlus)

	--[[ Character Connections ]]

	I.G_Player.OnCharacterAdded(I.Priority.Default, Module._connectCharacter)
	I.G_Player.OnCharacterAdded(I.Priority.Default, function(character: Model)
		task.delay(_settings.TOOLBAR_FILL_DELAY, function()
			-- Skipping when the character was replaced during the delay
			if I.Env.LocalPlayer.Character ~= character then
				return
			end

			Toolbar._loadToolbarFromServer()
		end)
	end)
	I.G_Player.OnCharacterRemoving(I.Priority.Default, Toolbar._resetToolbarState)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	--%%%%%%%%%%%%%%%%%%%% General

	I.Topic.Register("BackpackPlus_FilterSet", { "string", { Type = "string", Optional = true } })
	I.Topic.Register("BackpackPlus_FavoriteModeChanged", { "boolean" })
	I.Topic.Register("BackpackPlus_ToolbarSizeChanged", {})

	--%%%%%%%%%%%%%%%%%%%% Tool

	I.Topic.Subscribe("Tool_Added", function(tool: Tool, _toolUUID: string)
		Slot._addItem(tool)
	end)
	I.Topic.Subscribe("Tool_Removed", function(tool: Tool, _toolUUID: string)
		Slot._removeItem(tool)
	end)

	I.Topic.Subscribe("Tool_Equipped", function(tool: Tool)
		Slot._updateEquippedTool()
		BackpackPlus.CurrentlyEquipped = tool
	end)
	I.Topic.Subscribe("Tool_Unequipped", function(_tool: Tool)
		Slot._updateEquippedTool()
		BackpackPlus.CurrentlyEquipped = nil
	end)

	--%%%%%%%%%%%%%%%%%%%% Platform

	I.Topic.Subscribe("Platform_Changed", function(_platform: string)
		Toolbar._applyToolbarSlotCount()
	end)

	--- @Component
	I.Component.RegisterOnLoaded("BackpackPlus_Slot", _components.Slot)
	I.Component.RegisterOnLoaded("BackpackPlus_Slot_ViewportMotion", _components.Slot_ViewportMotion)
	I.Component.RegisterOnLoaded("BackpackPlus_FilterButton", _components.FilterButton)
	I.Component.RegisterOnLoaded("BackpackPlus_FavoriteButton", _components.FavoriteButton)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.BackpackPlus = {

		--[[ Control ]]

		Toggle = Backpack.Toggle,

		-- Slot
		ToggleItem = Slot.ToggleItem,
		Unequip = Slot.Unequip,
		ToggleItemAtSlot = Toolbar.ToggleItemAtSlot,
		CycleToolbar = Toolbar.CycleToolbar,
		DropSlot = Slot.DropSlot,

		-- Toolbar
		ReloadToolbar = Toolbar.ReloadToolbar,

		-- Lock
		SetLock = Lock.SetLock,
		ClearLock = Lock.ClearLock,

		-- Reserve
		ReserveToolbarSlot = Reserve.ReserveToolbarSlot,
		ClearToolbarReservation = Reserve.ClearToolbarReservation,
		IsToolReservationLocked = Reserve.IsToolReservationLocked,
		IsSlotReservationLocked = Reserve.IsSlotReservationLocked,

		-- Filter
		SetFilter = Filter.SetFilter,
		ClearFilter = Filter.ClearFilter,
		CycleCategory = Filter.CycleCategory,

		-- Favorite
		SetFavoriteMode = Favorite.SetFavoriteMode,
		ToggleFavoriteMode = Favorite.ToggleFavoriteMode,
		ToggleSlotFavorite = Favorite.ToggleSlotFavorite,

		--[[ Methods ]]

		GetState = Backpack.GetState,
		IsLocked = Lock.IsLocked,
		IsFavoriteMode = Favorite.IsFavoriteMode,

		-- Internal
		_getSlotSize = Toolbar._getSlotSize,
		_getSlotAbsoluteSize = Toolbar._getSlotAbsoluteSize,
	}

	----------------------------
	-------- POST-INIT ---------
	----------------------------

	-- Setup
	Slot._createViewportCamera()
	Toolbar._createToolbarItemSlots()
	Toolbar._applyToolbarSlotCount()

	-- Connections
	Module._createConnections()
	Module._connectSearchBar()
	Toolbar._connectSizeChanges()

	-- Display
	Backpack._updateDisplay()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Hover Info ]]

	HoverInfo.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements
]]
function Module._getElements()
	local backpackGui: ScreenGui = I.UserInterface.UI["BackpackPlus"]
	local backpack: Frame = backpackGui:FindFirstChild("U_Backpack", true)

	--[[ General ]]

	elems["SearchBar"] = backpack:FindFirstChild("S_SearchBar", true) --- @type TextBox
end

--%%%%%%%%%%%%%%%%%%%% Load Display Types

--[[
	Requires DisplayType modules into CUSTOM_DISPLAY_UPDATES by file name.
]]
function Module._loadDisplayTypes()
	local displayTypeDir: Folder = _data:FindFirstChild("DisplayType")

	for _, displayTypeModule: Instance in ipairs(displayTypeDir:GetChildren()) do
		--%%%%%%%%%%%%%%%%%%%% Checks

		-- Not a ModuleScript
		if not displayTypeModule:IsA("ModuleScript") then
			continue
		end

		-- Duplicate
		if _settings.CUSTOM_DISPLAY_UPDATES[displayTypeModule.Name] then
			warn(`[{_localName}::{script.Name}]: DisplayType ({displayTypeModule.Name}) is duplicated!`)
			continue
		end

		--%%%%%%%%%%%%%%%%%%%% Requiring

		local success: boolean, result = pcall(function()
			return require(displayTypeModule)
		end)

		-- Require failed
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to require ({displayTypeModule.Name}) DisplayType! - ({result})`)
			continue
		end

		-- Invalid type
		if typeof(result) ~= "function" then
			warn(`[{_localName}::{script.Name}]: DisplayType ({displayTypeModule.Name}) did not return a function!`)
			continue
		end

		--%%%%%%%%%%%%%%%%%%%% Saving

		_settings.CUSTOM_DISPLAY_UPDATES[displayTypeModule.Name] = result
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization - Connections

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creating connections for controlling the Backpack.
]]
function Module._createConnections()
	--[[ Display Update ]]

	I.S.GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		Backpack._updateDisplay()
	end)

	--[[ Input Control ]]

	-- Toggling Backpack
	I.S.ContextActionService:BindAction("Backpack_Toggle", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Input began
		if inputState == Enum.UserInputState.Begin then
			Backpack.Toggle()
			return Enum.ContextActionResult.Sink
		end

		-- Other input states
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.Backquote)

	-- Toggling Toolbar Items
	I.S.UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		--[[ Checks ]]

		-- Game processed
		if gameProcessedEvent then
			return
		end

		-- Not input began
		if input.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		--[[ Toggling ]]

		if _settings.TOOLBAR_KEY_MAPPINGS[input.KeyCode] then
			Toolbar.ToggleItemAtSlot(_settings.TOOLBAR_KEY_MAPPINGS[input.KeyCode])
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Character

--[[
	Creates connections for character changes.
]]
function Module._connectCharacter(character: Model)
	--[[ Clearing Existing ]]

	for _connectionName: string, connection: RBXScriptConnection in pairs(characterConnections) do
		connection:Disconnect()
	end
	table.clear(characterConnections)

	--[[ Health Connection ]]

	task.spawn(function()
		local hum: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
		if hum then
			-- Clearing if connection exists after `WaitForChild`
			if characterConnections["Health"] then
				characterConnections["Health"]:Disconnect()
				characterConnections["Health"] = nil
			end

			-- Creating Connection
			characterConnections["Health"] = hum.HealthChanged:Connect(function()
				-- Resetting the Toolbar on death
				if hum.Health <= 0 then
					Toolbar._resetToolbarState()
				end
			end)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Search Bar

--[[
	Connects search bar.
]]
function Module._connectSearchBar()
	elems["SearchBar"]:GetPropertyChangedSignal("Text"):Connect(function()
		-- Getting Text
		local searchText: string = elems["SearchBar"].Text

		-- Updating Filter
		if searchText == "" then
			Filter.ClearFilter("SearchBar")
		else
			Filter.SetFilter("SearchBar", searchText)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
