--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Leaderstats_Controller"

--- @type Leaderstats_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { Leaderstats_Controller_Stat }
local stats = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--- @type { [string]: (player: Player, key: string) -> string? }
local valueSources = {
	["Statistic"] = function(player: Player, key: string)
		return I.Statistic.Get(player, key)
	end,
	["Currency"] = function(player: Player, key: string)
		return I.Currency.Get(player, key)
	end,
}

--- @type { [string]: (value: string) -> string }
local valueFormats = {
	["Time"] = function(value: string)
		return I.Time.FormatClean(tonumber(value), {
			[1] = "Dtd HHlh",
			[2] = "HHth MMlm",
			[3] = "MMtm SSls",
			[4] = "SSts",
		})
	end,
	["Number"] = function(value: string)
		return I.BN.AbbreviationConvertFormatted(value, 2)
	end,
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

	Module._cacheStats()

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._addValues)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._createUpdateLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Cache Stats

--[[
	Keeps the `STATS` rows whose `Source` and `Format` exist, and warns about the others.
]]
function Module._cacheStats()
	--[[ Caching ]]

	--- @param stat Leaderstats_Controller_Stat
	for _, stat in ipairs(_settings.STATS) do
		-- Skip rows with an unknown source or format
		if not valueSources[stat.Source] or not valueFormats[stat.Format] then
			warn(`[{_localName}::{script.Name}]: Leaderstat ({stat.Name}) has an unknown Source ({stat.Source}) or Format ({stat.Format})!`)
			continue
		end

		table.insert(stats, stat)
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Update Loop

--[[
	Creates loop that updates the leaderstats for all players.
]]
function Module._createUpdateLoop()
	I.DoEvery.Get(5):Connect(function()
		for _, player: Player in ipairs(Players:GetPlayers()) do
			pcall(function()
				Module._updateForPlayer(player)
			end)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Add Values

--[[
	Adds every leaderstat for a joining player.
]]
function Module._addValues(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Adding ]]

	--- @param stat Leaderstats_Controller_Stat
	for _, stat in ipairs(stats) do
		I.Leaderstats.AddValue(player, stat.Name, "-", "StringValue", stat.Priority)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Update For Player

--[[
	Updates leaderstats values for the player.
]]
function Module._updateForPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Updating ]]

	--- @param stat Leaderstats_Controller_Stat
	for _, stat in ipairs(stats) do
		local value: string? = valueSources[stat.Source](player, stat.Key)

		-- Skip values the source doesn't have
		if not value then
			continue
		end

		I.Leaderstats.SetValue(player, stat.Name, valueFormats[stat.Format](value))
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
