--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "UserInterface"

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

--- @class UserInterface_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Change Visibility

	--[[
		Tells the player's client to show or hide one of its ScreenGuis, without waiting for an answer.
	]]
	--- @return boolean
	--- @return string
	local function changeVisibility(player: Player, guiName: string, state: boolean)
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return false, `$|cr$|{player.Name}#| has not loaded yet`
		end

		--[[ Sending ]]

		I.Network.Fire("UserInterface_ChangeVisibility", player, guiName, state)

		--[[ Returning ]]

		if state then
			return true, `Showing $|cr$|{player.Name}#|'s $|cr$|{guiName}#| ScreenGui`
		end

		return true, `Hiding $|cr$|{player.Name}#|'s $|cr$|{guiName}#| ScreenGui`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "change_visibility" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "guiName", types = { "string" }, dict = "UserInterface_GuiNames", requireDict = true },
				{ name = "state", types = { "boolean" } },
			},
			Callback = changeVisibility,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("UserInterface_Server", {
		Aliases = { "ui" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
