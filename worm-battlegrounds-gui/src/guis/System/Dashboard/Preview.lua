--[[
	Created By: 	Nari
]]

local _localName: string = "DashboardPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local CommandBar: ModuleScript = script.Parent.Parent:FindFirstChild("CommandBar")
local Window = require(CommandBar:FindFirstChild("Window")) --- @type UmeGui_Guis_System_CommandBar_Window
local Rail = require(script.Parent:FindFirstChild("Rail")) --- @type UmeGui_Guis_System_Dashboard_Rail
local Examples = require(script.Parent:FindFirstChild("Examples")) --- @type UmeGui_Guis_System_Dashboard_Examples

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local StudioService: StudioService = game:GetService("StudioService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Window ]]

-- The smallest size a resize leaves the dashboard (CommandBar/Window.lua drags and resizes it)
local MIN_SIZE: Vector2 = Vector2.new(600, 360)

--[[ Colors ]]

-- What lights picked and switched-on parts (the System look's white)
local ACCENT_COLOR: Color3 = Color3.fromRGB(255, 255, 255)

-- A stats value's color in a player's panel
local VALUE_COLOR: Color3 = Color3.fromRGB(230, 230, 234)

--[[ State ]]

-- What the dashboard shows, kept across rebuilds (Rail.lua's State): the viewer's own panel first
--- @type UmeGui_Guis_System_Dashboard_State
local state = { Kind = "Player", Player = 1, Module = 1 }

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

--- @class UmeGui_Guis_System_Dashboard_Preview
local Module = {

	--[[ Settings ]]

	-- How many example players are on the server
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Players", Label = "Players", Value = 6, Min = 1, Max = #Examples.Players, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Makes the dashboard a window (its header drags it and its edges and corners resize it), and builds its rail with
	the example players and modules (Rail.lua): every player's page is a panel too (their perks, actions and items),
	shown the same way as a module's.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Elements ]]

	local view = preview.View --- @type UmeGui_View
	local panel: Frame = view:Get("U_Dashboard").Instance

	--[[ Window ]]

	Window.Bind(panel, MIN_SIZE)

	--[[ Players ]]

	local players = {} --- @type { { [string]: any } }

	--- @param example { [string]: any }
	for index: number, example in ipairs(Examples.Players) do
		-- Only as many as the Players setting says
		if index > preview.Values.S_Players then
			break
		end
		local player = table.clone(example) --- @type { [string]: any }
		player.Headshot = Module._getHeadshot(example)
		table.insert(players, player)
	end
	state.Player = math.min(state.Player, #players)

	--[[ Building ]]

	--- @type UmeGui_Guis_System_Dashboard_Context
	local ctx = {
		View = view,
		Accent = ACCENT_COLOR,
		Players = players,
		Modules = Examples.Modules,
		State = state,
		GetPlayerPanel = function(index: number)
			return Module._getPlayerPanel(players[index])
		end,
		Refresh = function() end,
	}

	-- Each press rebuilds the dashboard with the new state
	ctx.Refresh = function()
		Rail.Build(ctx)
	end
	Rail.Build(ctx)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Player Panel

--[[
	Returns a player's page as a panel (Panels.lua's shape): their round headshot, name, @username and stats, then
	their perks as switches (kept per player, under the panel's id), the actions, and the items to give them.
]]
--- @param player { [string]: any }
--- @return UmeGui_Guis_System_Dashboard_Panel
function Module._getPlayerPanel(player)
	--[[ Local Variables ]]

	local value: string = `<font color="#{VALUE_COLOR:ToHex()}">%s</font>`
	local perks = {} --- @type { UmeGui_Guis_System_Dashboard_Block }
	local actions = {} --- @type { UmeGui_Guis_System_Dashboard_Block }

	--[[ Blocks ]]

	--- @param perk string
	for index: number, perk in ipairs(Examples.Perks) do
		table.insert(perks, { Type = "Toggle", Id = `Perk{index}`, Text = perk })
	end

	--- @param action { [string]: any }
	for index: number, action in ipairs(Examples.Actions) do
		table.insert(actions, { Type = "Button", Id = `Action{index}`, Text = action.Text, Danger = action.Danger })
	end

	--[[ Returning ]]

	return {
		Id = `Player/{player.Username}`,
		Name = player.DisplayName,
		Description = `@{player.Username}`,
		Icon = player.Headshot,
		Color = Color3.fromRGB(40, 40, 44),
		Round = true,
		Stats = `Coins {string.format(value, Module._getNumberText(player.Coins))}   ·   Level {string.format(value, tostring(player.Level))}   ·   Here {string.format(value, `{player.Minutes} min`)}`,
		Sections = {
			{ Title = "Perks", Blocks = perks },
			{ Title = "Actions", Blocks = actions },
			{ Title = "Give", Blocks = { { Type = "Give", Id = "Give", Text = "Give", Items = Examples.Items } } },
		},
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Headshot

--[[
	Returns an example player's headshot image: the Studio user's for the viewer, none for a UserId of 0.
]]
--- @param example { [string]: any }
--- @return string
function Module._getHeadshot(example)
	--[[ Local Variables ]]

	local userId: number = example.UserId

	-- The viewer is the Studio user, when Studio says who that is
	if example.You then
		local success: boolean
		local result: any | string?
		success, result = pcall(StudioService.GetUserId, StudioService)
		userId = if success then result else 0
	end

	--[[ Returning ]]

	return if userId > 0 then `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150` else ""
end

--%%%%%%%%%%%%%%%%%%%% Get Number Text

--[[
	Returns a whole number with commas between its thousands (1250 → "1,250").
]]
--- @return string
function Module._getNumberText(number: number)
	--[[ Local Variables ]]

	local text: string = tostring(math.floor(number))

	--[[ Formatting ]]

	-- Put a comma before each group of three digits, from the right
	while true do
		local count: number
		text, count = string.gsub(text, "^(-?%d+)(%d%d%d)", "%1,%2")
		if count == 0 then
			break
		end
	end

	--[[ Returning ]]

	return text
end

return Module
