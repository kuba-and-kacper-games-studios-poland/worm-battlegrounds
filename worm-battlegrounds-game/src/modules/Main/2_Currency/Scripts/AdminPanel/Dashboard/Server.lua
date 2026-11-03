--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--- @type Currency_Settings
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

--- @class Currency_Dashboard_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerPanel()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Panel

--[[
	Registers the Currency section of every player's page: how much of each currency they have, and a field per
	currency that adds to it.
]]
function Module._registerPanel()
	--%%%%%%%%%%%%%%%%%%%% Get Add Callback

	--[[
		Returns the callback of one currency's Add field: it adds the typed amount to the page's player.
	]]
	--- @return (admin: Player, values: { [string]: any }, target: Player | nil) -> (boolean, string)
	local function getAddCallback(currencyName: string)
		--[[ Returning ]]

		--- @param values { [string]: any }
		return function(_admin: Player, values, target: Player)
			local amount: string = tostring(values[`Add{currencyName}`] or "")

			-- Report an amount the Currency module doesn't take
			if not I.Currency.Add(target, currencyName, amount) then
				return false, `Couldn't add {amount} {currencyName}`
			end

			return true, `Added {amount} {currencyName} to {target.Name}`
		end
	end

	--[[ Local Variables ]]

	local names = {} --- @type { string }
	local amounts = {} --- @type { AdminPanel_DashboardBlockSetup }
	local adds = {} --- @type { AdminPanel_DashboardBlockSetup }

	--[[ Names ]]

	for currencyName: string, _currencyData: any in pairs(_settings.CURRENCIES) do
		table.insert(names, currencyName)
	end
	table.sort(names)

	--[[ Blocks ]]

	for _index: number, currencyName: string in ipairs(names) do
		table.insert(amounts, {
			Type = "Info",
			Id = currencyName,
			Text = currencyName,
			Value = function(target: Player)
				return I.Currency.Get(target, currencyName) or "?"
			end,
		})

		table.insert(adds, {
			Type = "Input",
			Id = `Add{currencyName}`,
			Text = `Add {currencyName}`,
			Placeholder = "Amount",
			Button = "Add",
			Callback = getAddCallback(currencyName),
		})
	end

	--[[ Registering ]]

	I.AdminPanel_Dashboard.Register("Currency", {
		Name = "Currency",
		Scope = "Player",
		Sections = {
			{ Title = "Currency", Blocks = amounts },
			{ Title = "Add currency", Blocks = adds },
		},
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
