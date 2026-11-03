--[[
	Created By: 	Nari
]]

local _localName: string = "DashboardExamples"

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

--- @class UmeGui_Guis_System_Dashboard_Examples
local Module = {

	--[[ Players ]]

	-- Example players on the server: the first is the viewer, with the Studio user's headshot; a UserId of 0 has none
	--- @type { { [string]: any } }
	Players = {
		{ DisplayName = "Nari", Username = "nari", UserId = 0, Coins = 1250, Level = 14, Minutes = 42, You = true },
		{ DisplayName = "builderman", Username = "builderman", UserId = 156, Coins = 860, Level = 9, Minutes = 31 },
		{ DisplayName = "Roblox", Username = "Roblox", UserId = 1, Coins = 3400, Level = 31, Minutes = 87 },
		{ DisplayName = "Oakley", Username = "oakley", UserId = 0, Coins = 120, Level = 2, Minutes = 6 },
		{ DisplayName = "Juniper", Username = "juni_per", UserId = 0, Coins = 5020, Level = 48, Minutes = 133 },
		{ DisplayName = "Rowan", Username = "rowan", UserId = 0, Coins = 75, Level = 1, Minutes = 3 },
		{ DisplayName = "Hazel", Username = "hazelnut", UserId = 0, Coins = 640, Level = 7, Minutes = 19 },
		{ DisplayName = "Ash", Username = "ash_gg", UserId = 0, Coins = 2210, Level = 22, Minutes = 58 },
	},

	--[[ Player Panel ]]

	-- What a player's panel holds: perks switched per player, actions (Danger ones can't be undone), and items to give
	-- with their swatch colors
	--- @type { string }
	Perks = { "Fly", "Noclip", "Speed ×2", "Jump ×2", "God mode", "Invisible", "No cooldowns", "Free shop" },
	--- @type { { [string]: any } }
	Actions = {
		{ Text = "Teleport to" },
		{ Text = "Bring" },
		{ Text = "Heal" },
		{ Text = "Respawn" },
		{ Text = "Freeze" },
		{ Text = "Spectate" },
		{ Text = "Reset data", Danger = true },
		{ Text = "Kick", Danger = true },
	},
	--- @type { UmeGui_Guis_System_Dashboard_Item }
	Items = {
		{ Name = "Wooden sword", Color = Color3.fromRGB(122, 86, 56) },
		{ Name = "Iron sword", Color = Color3.fromRGB(176, 182, 192) },
		{ Name = "Golden sword", Color = Color3.fromRGB(232, 184, 48) },
		{ Name = "Health potion", Color = Color3.fromRGB(220, 70, 80) },
		{ Name = "Speed potion", Color = Color3.fromRGB(70, 140, 210) },
		{ Name = "Crate key", Color = Color3.fromRGB(214, 208, 180) },
		{ Name = "Pet egg", Color = Color3.fromRGB(96, 168, 72) },
		{ Name = "Trail", Color = Color3.fromRGB(160, 110, 255) },
		{ Name = "Coins", Color = Color3.fromRGB(250, 204, 60) },
		{ Name = "Gems", Color = Color3.fromRGB(80, 210, 230) },
	},

	--[[ Modules ]]

	-- Example panels, as the game's modules would register them, in the order they register: each sets its own
	-- layout, in sections of blocks (Panels.lua has the shapes)
	--- @type { UmeGui_Guis_System_Dashboard_Panel }
	Modules = {
		{
			Id = "World",
			Name = "World",
			Description = "Time and weather, for everyone",
			Color = Color3.fromRGB(80, 150, 220),
			Sections = {
				{
					Title = "Time",
					Blocks = {
						{ Type = "Choice", Id = "TimeOfDay", Text = "Time of day", Options = { "Dawn", "Day", "Dusk", "Night" }, Value = "Day" },
						{ Type = "Slider", Id = "ClockSpeed", Text = "Clock speed", Min = 0, Max = 10, Step = 0.5, Value = 1, Format = "×{}" },
						{ Type = "Toggle", Id = "FreezeTime", Text = "Freeze time" },
					},
				},
				{
					Title = "Weather",
					Blocks = {
						{ Type = "Choice", Id = "Weather", Text = "Weather", Options = { "Clear", "Rain", "Storm", "Fog" }, Value = "Clear" },
						{ Type = "Toggle", Id = "Wind", Text = "Wind" },
						{ Type = "Toggle", Id = "Clouds", Text = "Clouds", Value = true },
					},
				},
			},
		},
		{
			Id = "Enemies",
			Name = "Enemies",
			Description = "Every enemy on the server",
			Color = Color3.fromRGB(96, 168, 72),
			Sections = {
				{
					Title = "Spawners",
					Blocks = {
						{ Type = "Button", Id = "SpawnAll", Text = "Spawn all" },
						{ Type = "Button", Id = "ClearAll", Text = "Clear all" },
						{ Type = "Button", Id = "Respawn", Text = "Respawn bosses" },
						{ Type = "Toggle", Id = "PauseSpawning", Text = "Pause spawning" },
						{ Type = "Slider", Id = "SpawnSpeed", Text = "Spawn speed", Min = 0.1, Max = 10, Step = 0.1, Value = 1, Format = "×{}" },
					},
				},
				{
					Title = "Spawn",
					Blocks = {
						{ Type = "Input", Id = "SpawnEnemy", Text = "Spawn an enemy", Placeholder = "Enemy id: slime, goblin, bat…", Button = "Spawn" },
						{ Type = "Choice", Id = "Rarity", Text = "Roll luck", Options = { "Normal", "Lucky", "Always best" }, Value = "Normal" },
					},
				},
				{
					Title = "Right now",
					Blocks = {
						{ Type = "Info", Id = "Count", Text = "Enemies on the server", Value = "214" },
						{ Type = "Info", Id = "Bosses", Text = "Bosses", Value = "3" },
						{ Type = "Info", Id = "Defeated", Text = "Defeated today", Value = "1,380" },
					},
				},
			},
		},
		{
			Id = "NPCs",
			Name = "NPCs",
			Description = "The characters in the world",
			Color = Color3.fromRGB(214, 150, 70),
			Sections = {
				{
					Title = "NPCs",
					Blocks = {
						{ Type = "Button", Id = "Spawn", Text = "Spawn NPC" },
						{ Type = "Button", Id = "RemoveAll", Text = "Remove all", Danger = true },
						{ Type = "Toggle", Id = "ShowPaths", Text = "Show paths" },
						{ Type = "Toggle", Id = "Idle", Text = "All idle" },
						{ Type = "Slider", Id = "WalkSpeed", Text = "Walk speed", Min = 0.5, Max = 5, Step = 0.5, Value = 1, Format = "×{}" },
						{ Type = "Info", Id = "Count", Text = "NPCs on the server", Value = "12" },
					},
				},
			},
		},
		{
			Id = "Economy",
			Name = "Economy",
			Description = "Coins, prices and the shop",
			Color = Color3.fromRGB(232, 184, 48),
			Sections = {
				{
					Title = "Coins",
					Blocks = {
						{ Type = "Input", Id = "SetCoins", Text = "Set my coins", Placeholder = "Amount", Button = "Set" },
						{ Type = "Button", Id = "GiveAll", Text = "Give all 1k" },
						{ Type = "Toggle", Id = "DoubleCoins", Text = "Double coins" },
						{ Type = "Info", Id = "Circulation", Text = "Coins on the server", Value = "48,210" },
					},
				},
				{
					Title = "Shop",
					Blocks = {
						{ Type = "Slider", Id = "SellPrice", Text = "Sell prices", Min = 0.5, Max = 3, Step = 0.25, Value = 1, Format = "×{}" },
						{ Type = "Toggle", Id = "FreeShop", Text = "Free shop" },
						{ Type = "Button", Id = "Restock", Text = "Restock now" },
						{ Type = "Button", Id = "ResetPrices", Text = "Reset prices" },
					},
				},
			},
		},
		{
			Id = "Events",
			Name = "Events",
			Description = "Run a server event",
			Color = Color3.fromRGB(160, 110, 255),
			Sections = {
				{
					Title = "Event",
					Blocks = {
						{ Type = "Choice", Id = "Event", Text = "Event", Options = { "Double XP", "Boss rush", "Meteor shower" }, Value = "Double XP" },
						{ Type = "Slider", Id = "Length", Text = "Length", Min = 1, Max = 30, Step = 1, Value = 5, Format = "{} min" },
						{ Type = "Button", Id = "Start", Text = "Start" },
						{ Type = "Button", Id = "Stop", Text = "Stop" },
						{ Type = "Button", Id = "SkipDay", Text = "Skip a day" },
					},
				},
			},
		},
		{
			Id = "Debug",
			Name = "Debug",
			Description = "Shown only to you",
			Color = Color3.fromRGB(128, 128, 134),
			Sections = {
				{
					Title = "Show",
					Blocks = {
						{ Type = "Toggle", Id = "Hitboxes", Text = "Hitboxes" },
						{ Type = "Toggle", Id = "ZoneBounds", Text = "Zone bounds" },
						{ Type = "Toggle", Id = "Stats", Text = "FPS and ping" },
						{ Type = "Toggle", Id = "InstanceIds", Text = "Instance ids" },
					},
				},
				{
					Title = "Data",
					Blocks = {
						{ Type = "Button", Id = "PrintData", Text = "Print my data" },
						{ Type = "Button", Id = "ResetData", Text = "Reset my data", Danger = true },
						{ Type = "Info", Id = "Memory", Text = "Client memory", Value = "812 MB" },
						{ Type = "Info", Id = "Ping", Text = "Ping", Value = "48 ms" },
					},
				},
			},
		},
		{
			Id = "Server",
			Name = "Server",
			Description = "This server only",
			Color = Color3.fromRGB(220, 90, 90),
			Sections = {
				{
					Title = "Players",
					Blocks = {
						{ Type = "Input", Id = "Announce", Text = "Announce", Placeholder = "A message for everyone", Button = "Send" },
						{ Type = "Toggle", Id = "Lock", Text = "Lock server" },
						{ Type = "Button", Id = "KickAll", Text = "Kick all", Danger = true },
						{ Type = "Button", Id = "ShutDown", Text = "Shut down", Danger = true },
					},
				},
				{
					Title = "Right now",
					Blocks = {
						{ Type = "Info", Id = "Players", Text = "Players", Value = "6 / 12" },
						{ Type = "Info", Id = "Uptime", Text = "Up for", Value = "2 h 14 min" },
						{ Type = "Info", Id = "Version", Text = "Version", Value = "0.1 (Studio)" },
					},
				},
			},
		},
	},
}

return Module
