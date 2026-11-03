--[[
	Created By: 	Nari
]]

local _localName: string = "Libs"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Mirror: Folder = script:FindFirstChild("Mirror")
local Utils: Folder = Mirror:FindFirstChild("Utils")
local Components: Folder = Utils:FindFirstChild("Components")
local UtilsScripts: Folder = Utils:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Runtime = require(script:FindFirstChild("Runtime")) --- @type UmeGui_Runtime
local Component = require(script:FindFirstChild("Component")) --- @type UmeGui_Libs_Component
local Sound = require(script:FindFirstChild("Sound")) --- @type UmeGui_Libs_Sound
local Scope = require(script:FindFirstChild("Scope")) --- @type UmeGui_Libs_Scope
local ButtonPress = require(UtilsScripts:FindFirstChild("ButtonPress")) --- @type UmeGui_Utils_ButtonPress

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Registry ]]

-- Framework libraries injected into the Runtime, in the framework's load order
local LIBRARIES = { "Color", "Create", "UIEmitter", "BigNum", "GoodSignal" } --- @type { string }

-- Utils scripts that run on their own tags
local SCRIPTS = { "UIStrokeScaler", "UIStrokeScaler_Billboard", "ImageSliceScaler" } --- @type { string }

-- Tag -> mirrored component, matching the framework's Utils registry
local COMPONENTS = { --- @type { [string]: ModuleScript }
	Utils_ButtonKey = Components.Button.ButtonKey,
	Utils_ButtonScale = Components.Button.ButtonScale,
	Utils_ButtonSound = Components.Button.ButtonSound,
	Utils_ButtonTransform = Components.Button.ButtonTransform,
	Utils_UIGrid = Components.Scaler.UIGrid,
	Utils_UIGradientMove = Components.Visual.UIGradientMove,
	Utils_UIShake = Components.Visual.UIShake,
	Utils_UISpin = Components.Visual.UISpin,
	Utils_UIHover = Components.Visual.UIHover,
	Utils_LetterText = Components.Visual.LetterText,
	Utils_Motion = Components.Visual.Motion,
	Utils_TextShine = Components.Visual.TextShine,
}

--[[ State ]]

local started: boolean = false

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

--- @class UmeGui_Libs
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Sound ]]

	-- Start the sounds again after a Stop; Sound.Init skips while they run
	Sound.Init()
	Runtime.Sound = Sound

	--[[ Checks ]]

	-- Only wire the libraries, scripts and components once
	if started then
		return
	end
	started = true

	--[[ Libraries ]]

	for _index: number, libraryName: string in ipairs(LIBRARIES) do
		require(Mirror:FindFirstChild(libraryName))._injectUme(Runtime)
	end

	--[[ Scripts ]]

	for _index: number, scriptName: string in ipairs(SCRIPTS) do
		require(UtilsScripts:FindFirstChild(scriptName)).Init()
	end

	--[[ Components ]]

	for tag: string, componentModule: ModuleScript in pairs(COMPONENTS) do
		Component.Register(tag, componentModule)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop

function Module.Stop()
	--[[ Sound ]]

	-- Remove the sounds' holder from CoreGui; a later Start or Bind brings them back
	Sound.Stop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Attaches the Utils to tagged instances under a freshly built gui, until the gui is destroyed.
]]
function Module.Bind(root: Instance)
	--[[ Starting ]]

	Module.Start()

	--[[ Binding ]]

	Scope.Add(root)
end

--%%%%%%%%%%%%%%%%%%%% Set Sound Host

--[[
	Plays the Utils' sounds inside a plugin widget (a DockWidgetPluginGui), the only place Studio edit mode plays a
	plugin's sounds; nil goes back to PlayLocalSound.
]]
function Module.SetSoundHost(host: Instance?)
	--[[ Applying ]]

	Sound.SetHost(host)
end

--%%%%%%%%%%%%%%%%%%%% Set Sound Volume

--[[
	Scales the volume of every sound the Utils play from now on, 0 to 1 (1 by default).
]]
function Module.SetSoundVolume(volume: number)
	--[[ Applying ]]

	Sound.SetVolume(volume)
end

--%%%%%%%%%%%%%%%%%%%% Play Press

--[[
	Plays a press on a button in the bound guis, for an input that acted on it without a key of its own: its click look,
	and a moment later the release with its click sound. Runs nothing the button does.
]]
function Module.PlayPress(button: GuiButton)
	--[[ Pressing ]]

	ButtonPress.PlayPress(button)
end

--%%%%%%%%%%%%%%%%%%%% Press Key

--[[
	Presses or releases the button a key belongs to (Utils_ButtonKey) in the bound guis, as ume's Interact does in
	game: the press plays the button's click look, the release lets it go and plays its click sound. Returns whether a
	button took the key.
]]
--- @return boolean
function Module.PressKey(keyCode: Enum.KeyCode, down: boolean)
	--[[ Pressing ]]

	local button: GuiButton? = ButtonPress.PressKey(keyCode, down)

	--[[ Returning ]]

	return button ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Runtime

--[[
	Returns the `I` shim with the injected libraries.
]]
--- @return UmeGui_Runtime
function Module.GetRuntime()
	return Runtime
end

return Module
