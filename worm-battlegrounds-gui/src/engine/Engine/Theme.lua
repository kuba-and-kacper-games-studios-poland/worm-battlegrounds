--[[
	Created By: 	Nari
]]

local _localName: string = "Theme"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Themes: Folder = script.Parent.Parent:FindFirstChild("Themes")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Style = require(script.Parent:FindFirstChild("Style")) --- @type UmeGui_Engine_Style

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local resolvedThemes = {} --- @type { [string]: UmeGui_Theme }

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

--- @class UmeGui_Engine_Theme
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the resolved theme, loading it and its base the first time.
]]
--- @return UmeGui_Theme
function Module.Get(themeName: string)
	--[[ Checks ]]

	-- Reuse a theme that was already resolved
	if resolvedThemes[themeName] then
		return resolvedThemes[themeName]
	end

	--[[ Data ]]

	local themeModule: Instance? = Themes:FindFirstChild(themeName)

	-- Check if the theme exists
	if not themeModule or not themeModule:IsA("ModuleScript") then
		error(`[{_localName}]: Theme ({themeName}) does not exist in Themes!`, 0)
	end

	local definition = require(themeModule) --- @type UmeGui_ThemeDefinition
	local base = if definition.Extends then Module.Get(definition.Extends) else nil --- @type UmeGui_Theme?

	--[[ Styles ]]

	local styles = {} --- @type { [string]: { [string]: UmeGui_Style } }
	local stylesFolder: Instance? = themeModule:FindFirstChild("Styles")
	if stylesFolder then
		for _index: number, styleModule: Instance in ipairs(stylesFolder:GetChildren()) do
			-- Skip anything that is not a style module
			if not styleModule:IsA("ModuleScript") then
				continue
			end

			styles[styleModule.Name] = require(styleModule)
		end
	end

	--[[ Controls ]]

	-- The theme's own Controls folder is searched first, then its base's, then the shared Controls folder
	local controls = {} --- @type { Instance }
	local controlsFolder: Instance? = themeModule:FindFirstChild("Controls")
	if controlsFolder then
		table.insert(controls, controlsFolder)
	end
	for _index: number, folder: Instance in ipairs(base and base.Controls or {}) do
		table.insert(controls, folder)
	end

	--[[ Gamepad ]]

	-- The theme's own gamepad icons, else its base's
	local gamepadModule: Instance? = themeModule:FindFirstChild("Gamepad")
	local gamepad = if gamepadModule and gamepadModule:IsA("ModuleScript") then require(gamepadModule) else base and base.Gamepad --- @type UmeGui_Gamepad?

	--[[ Merging ]]

	local theme = { --- @type UmeGui_Theme
		Name = themeName,
		Tokens = Style.Merge(base and base.Tokens, definition.Tokens),
		Styles = Style.Merge(base and base.Styles, styles),
		Controls = controls,
		Gamepad = gamepad,
	}

	--[[ Saving ]]

	resolvedThemes[themeName] = theme

	--[[ Returning ]]

	return theme
end

--%%%%%%%%%%%%%%%%%%%% Get Names

--[[
	Returns the names of every theme folder.
]]
--- @return { string }
function Module.GetNames()
	--[[ Local Variables ]]

	local names = {} --- @type { string }

	--[[ Finding ]]

	for _index: number, themeModule: Instance in ipairs(Themes:GetChildren()) do
		if themeModule:IsA("ModuleScript") then
			table.insert(names, themeModule.Name)
		end
	end

	--[[ Returning ]]

	table.sort(names)
	return names
end

return Module
