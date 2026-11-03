--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "HideOnPlay"

--- @type HideOnPlay_Settings
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

--- @class HideOnPlay_CommandBar_Global
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the commands that show or hide this side's tagged helpers in a running game.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Show

	--[[
		Shows every instance with this side's hide tag.
	]]
	--- @return boolean
	--- @return string
	local function show()
		--[[ Data ]]

		local tagName: string = _settings.HIDE_TAGS[I.Env.Key]
		local tagged = I.S.CollectionService:GetTagged(tagName) --- @type { Instance }

		--[[ Showing ]]

		I.HideOnPlay.Show(tagged)

		--[[ Returning ]]

		return true, `Showed $|cr$|{#tagged}#| ({tagName}) instances`
	end

	--%%%%%%%%%%%%%%%%%%%% Hide

	--[[
		Hides every instance with this side's hide tag again.
	]]
	--- @return boolean
	--- @return string
	local function hide()
		--[[ Data ]]

		local tagName: string = _settings.HIDE_TAGS[I.Env.Key]
		local tagged = I.S.CollectionService:GetTagged(tagName) --- @type { Instance }

		--[[ Hiding ]]

		I.HideOnPlay.Hide(tagged)

		--[[ Returning ]]

		return true, `Hid $|cr$|{#tagged}#| ({tagName}) instances`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	--- @type { Command_CommandSetupTable }
	local variants = {
		{
			Aliases = { "show" },
			PermissionLevel = 255,
			Callback = show,
		},
		{
			Aliases = { "hide" },
			PermissionLevel = 255,
			Callback = hide,
		},
	}

	--[[ Client ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("HideOnPlay_Client", {
			Aliases = { "hide_on_play" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end

	--[[ Server ]]

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("HideOnPlay_Server", {
			Aliases = { "s_hide_on_play" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
