--[[
	Created By: 	Nari
]]

local _localName: string = "DashboardRail"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Panels = require(script.Parent:FindFirstChild("Panels")) --- @type UmeGui_Guis_System_Dashboard_Panels

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Types ]]

-- A gui folder can't hold a _meta/_types.lua (GetGuiNames would list it as a gui), so the shapes live here

--- @class UmeGui_Guis_System_Dashboard_State
---
--- # General #
---
--- @field Kind "Search" | "Player" | "Module"
--- @field Player number
--- @field Module number
---
--- # Search #
---
--- @field Query string?
local _state = {}

--- @class UmeGui_Guis_System_Dashboard_Context
---
--- # General #
---
--- @field View UmeGui_View
--- @field Accent Color3
---
--- # Data #
---
--- @field Players { { [string]: any } }
--- @field Modules { UmeGui_Guis_System_Dashboard_Panel }
--- @field State UmeGui_Guis_System_Dashboard_State
---
--- # Callbacks #
---
--- @field GetPlayerPanel (index: number) -> UmeGui_Guis_System_Dashboard_Panel
--- @field Refresh () -> ()
local _context = {}

--[[ Sizes ]]

-- The width of the player list beside the rail
local LIST_WIDTH: number = 220

--[[ Search ]]

-- The search button's icon at the top of the rail (the System theme's magnifying-glass), and its color
local SEARCH_ICON: string = "rbxassetid://70531937773504"
local SEARCH_ICON_COLOR: Color3 = Color3.fromRGB(200, 200, 206)

--[[ State ]]

-- What the last build made (to destroy on the next), and the connections made to it
local built = {} --- @type { UmeGui_Subview }
local connections = {} --- @type { RBXScriptConnection }

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

--- @class UmeGui_Guis_System_Dashboard_Rail
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds the dashboard's body, after removing the last build: a rail of icons down the left edge (search first, then
	the players, then each module). Search opens the search page beside the rail; the players' icon opens their list,
	with the picked player's panel beside it; a module's icon shows its panel across the rest.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
function Module.Build(ctx)
	--[[ Elements ]]

	local body: Frame = ctx.View:Get("U_Dashboard", "S_Body").Instance

	--[[ Cleaning ]]

	Module.Clear()

	--[[ Local Variables ]]

	local kind: string = ctx.State.Kind
	local rail = Module._build(ctx, "PREFAB | Rail", body) --- @type UmeGui_Subview
	local railWidth: number = rail.Root.Instance.Size.X.Offset

	--[[ Rail ]]

	local search = Module._railButton(ctx, rail.Root.Instance, "Search", SEARCH_ICON, nil, false, kind == "Search", 1, function()
		Module._select(ctx, "Search", nil)
	end) --- @type UmeGui_Subview
	local searchIcon: ImageLabel = search:Get("S_Icon").Instance
	searchIcon.BackgroundTransparency = 1
	searchIcon.ImageColor3 = SEARCH_ICON_COLOR
	searchIcon.Size = UDim2.fromOffset(20, 20)

	Module._railButton(ctx, rail.Root.Instance, "Players", ctx.Players[1].Headshot, nil, true, kind == "Player", 2, function()
		Module._select(ctx, "Player", nil)
	end)
	local gap = Module._build(ctx, "PREFAB | Divider", rail.Root.Instance) --- @type UmeGui_Subview
	gap.Root.Instance.Size = UDim2.fromOffset(24, 1)
	gap.Root.Instance.LayoutOrder = 3

	--- @param panel UmeGui_Guis_System_Dashboard_Panel
	for index: number, panel in ipairs(ctx.Modules) do
		Module._railButton(ctx, rail.Root.Instance, panel.Name, panel.Icon, panel.Color, false, kind == "Module" and ctx.State.Module == index, index + 3, function()
			Module._select(ctx, "Module", index)
		end)
	end

	Module._divider(ctx, body, UDim2.fromOffset(railWidth, 0), UDim2.new(0, 1, 1, 0))

	--[[ Body ]]

	local left: number = railWidth + 1

	-- The search page takes the whole width
	if kind == "Search" then
		Module._launcher(ctx, body, UDim2.fromOffset(left, 0), UDim2.new(1, -left, 1, 0))
		return
	end

	-- The players' list sits beside the rail; a module's panel takes the whole width
	if kind == "Player" then
		local column = Module._build(ctx, "PREFAB | ListColumn", body) --- @type UmeGui_Subview
		column.Root.Instance.Position = UDim2.fromOffset(left, 0)
		column.Root.Instance.Size = UDim2.new(0, LIST_WIDTH, 1, 0)
		column:Get("S_Search").Instance.PlaceholderText = "Search players"
		Module._search(column:Get("S_Search").Instance, column:Get("S_Empty").Instance, Module._playerRows(ctx, column:Get("S_List").Instance))
		Module._divider(ctx, body, UDim2.fromOffset(left + LIST_WIDTH, 0), UDim2.new(0, 1, 1, 0))
		left += LIST_WIDTH + 1
	end
	Module._content(ctx, body, UDim2.fromOffset(left, 0), UDim2.new(1, -left, 1, 0))
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes what the last build made and the panel in it, and disconnects everything made for them.
]]
function Module.Clear()
	--[[ Cleaning ]]

	Panels.Clear()

	--- @param connection RBXScriptConnection
	for _index: number, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)

	--- @param subview UmeGui_Subview
	for _index: number, subview in ipairs(built) do
		subview:Destroy()
	end
	table.clear(built)
end

--%%%%%%%%%%%%%%%%%%%% Select

--[[
	Picks what the dashboard shows (the players or a module, and which one; nil keeps the current one), then rebuilds
	it.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
function Module._select(ctx, kind: string, index: number?)
	--[[ Saving ]]

	ctx.State.Kind = kind

	-- The index belongs to the kind picked
	if index and kind == "Player" then
		ctx.State.Player = index
	elseif index then
		ctx.State.Module = index
	end

	--[[ Refreshing ]]

	ctx.Refresh()
end

--%%%%%%%%%%%%%%%%%%%% Build Prefab

--[[
	Builds a prefab into a parent and keeps it, so the next build removes it.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
--- @return UmeGui_Subview
function Module._build(ctx, template: string, parent: Instance)
	--[[ Building ]]

	local subview = ctx.View:Build(template, parent) --- @type UmeGui_Subview
	table.insert(built, subview)

	--[[ Returning ]]

	return subview
end

--%%%%%%%%%%%%%%%%%%%% On Activated

--[[
	Runs a callback when a button is pressed, until the next build.
]]
function Module._onActivated(button: GuiButton, callback: () -> ())
	--[[ Connections ]]

	table.insert(connections, button.Activated:Connect(callback))
end

--%%%%%%%%%%%%%%%%%%%% Divider

--[[
	Puts a hairline in the body, 1 px wide or tall as its size says.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
function Module._divider(ctx, parent: Instance, position: UDim2, size: UDim2)
	--[[ Building ]]

	local divider = Module._build(ctx, "PREFAB | Divider", parent) --- @type UmeGui_Subview
	divider.Root.Instance.Position = position
	divider.Root.Instance.Size = size
end

--%%%%%%%%%%%%%%%%%%%% Content

--[[
	Puts a content area in the body and shows the picked player's or module's panel in it (Panels.Show).
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
function Module._content(ctx, parent: Instance, position: UDim2, size: UDim2)
	--[[ Building ]]

	local content = Module._build(ctx, "PREFAB | Content", parent) --- @type UmeGui_Subview
	local frame: ScrollingFrame = content.Root.Instance
	frame.Position = position
	frame.Size = size

	--[[ Showing ]]

	local panel = if ctx.State.Kind == "Player" then ctx.GetPlayerPanel(ctx.State.Player) else ctx.Modules[ctx.State.Module] --- @type UmeGui_Guis_System_Dashboard_Panel
	Panels.Show(ctx.View, frame, panel, ctx.Accent)
end

--%%%%%%%%%%%%%%%%%%%% Rail Button

--[[
	Puts an icon button in the rail: an image (round for the players) or a swatch with the page's initial, filled and
	marked with the accent bar while picked.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
--- @return UmeGui_Subview
function Module._railButton(ctx, rail: Instance, name: string, image: string?, color: Color3?, round: boolean, picked: boolean, order: number, callback: () -> ())
	--[[ Elements ]]

	local subview = Module._build(ctx, "PREFAB | RailButton", rail) --- @type UmeGui_Subview
	local button: ImageButton = subview:Get("S_Button").Instance
	local icon: ImageLabel = subview:Get("S_Icon").Instance
	local bar: Frame = subview:Get("S_SelectedBar").Instance

	--[[ Applying ]]

	icon.Image = image or ""
	icon.BackgroundColor3 = color or Color3.fromRGB(40, 40, 44)
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if round then UDim.new(1, 0) else UDim.new(0, 8)
	Panels.PaintLetter(icon, name)
	button.BackgroundTransparency = if picked then 0.9 else 1
	bar.BackgroundColor3 = ctx.Accent
	bar.Visible = picked
	subview.Root.Instance.LayoutOrder = order
	Module._onActivated(button, callback)

	--[[ Returning ]]

	return subview
end

--%%%%%%%%%%%%%%%%%%%% Launcher

--[[
	Puts the search page in the body: a search box over a group of tiles for the modules and one for the players, like
	icons on a desktop. Typing filters both (and hides a group with nothing left); pressing a tile opens its page. The
	search keeps what was typed while the dashboard is open.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
function Module._launcher(ctx, parent: Instance, position: UDim2, size: UDim2)
	--[[ Elements ]]

	local launcher = Module._build(ctx, "PREFAB | Launcher", parent) --- @type UmeGui_Subview
	local search: TextBox = launcher:Get("S_Search").Instance
	local results: ScrollingFrame = launcher:Get("S_Results").Instance
	launcher.Root.Instance.Position = position
	launcher.Root.Instance.Size = size

	--[[ Local Variables ]]

	local entries = {} --- @type { { [string]: any } }
	local modules = Module._group(ctx, results, "Modules", 1) --- @type UmeGui_Subview
	local players = Module._group(ctx, results, "Players", 2) --- @type UmeGui_Subview

	--[[ Modules ]]

	--- @param panel UmeGui_Guis_System_Dashboard_Panel
	for index: number, panel in ipairs(ctx.Modules) do
		local tile = Module._tile(ctx, modules:Get("S_Blocks").Instance, panel.Name, panel.Icon, panel.Color, false, index, function()
			Module._select(ctx, "Module", index)
		end) --- @type UmeGui_Subview
		table.insert(entries, { Row = tile.Root.Instance, Text = string.lower(`{panel.Name} {panel.Description}`), Group = modules.Root.Instance })
	end

	--[[ Players ]]

	--- @param player { [string]: any }
	for index: number, player in ipairs(ctx.Players) do
		local tile = Module._tile(ctx, players:Get("S_Blocks").Instance, player.DisplayName, player.Headshot, Color3.fromRGB(40, 40, 44), true, index, function()
			Module._select(ctx, "Player", index)
		end) --- @type UmeGui_Subview
		table.insert(entries, { Row = tile.Root.Instance, Text = string.lower(`{player.DisplayName} {player.Username}`), Group = players.Root.Instance })
	end

	--[[ Search ]]

	search.Text = ctx.State.Query or ""
	table.insert(
		connections,
		search:GetPropertyChangedSignal("Text"):Connect(function()
			ctx.State.Query = search.Text
		end)
	)
	Module._search(search, launcher:Get("S_Empty").Instance, entries)
end

--%%%%%%%%%%%%%%%%%%%% Group

--[[
	Puts a titled group in the search page: a PREFAB | Section whose blocks are the group's tiles.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
--- @return UmeGui_Subview
function Module._group(ctx, parent: Instance, title: string, order: number)
	--[[ Building ]]

	local group = Module._build(ctx, "PREFAB | Section", parent) --- @type UmeGui_Subview
	group:Get("S_Title").Instance.Text = string.upper(title)
	group.Root.Instance.LayoutOrder = order

	--[[ Returning ]]

	return group
end

--%%%%%%%%%%%%%%%%%%%% Tile

--[[
	Puts a tile in a search group: an image (round for a player) or a swatch with the page's initial, over its name.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
--- @return UmeGui_Subview
function Module._tile(ctx, parent: Instance, name: string, image: string?, color: Color3?, round: boolean, order: number, callback: () -> ())
	--[[ Elements ]]

	local tile = Module._build(ctx, "PREFAB | LauncherTile", parent) --- @type UmeGui_Subview
	local icon: ImageLabel = tile:Get("S_Icon").Instance

	--[[ Applying ]]

	icon.Image = image or ""
	icon.BackgroundColor3 = color or icon.BackgroundColor3
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if round then UDim.new(1, 0) else UDim.new(0, 14)
	Panels.PaintLetter(icon, name)
	tile:Get("S_Name").Instance.Text = name
	tile.Root.Instance.LayoutOrder = order
	Module._onActivated(tile:Get("S_Button").Instance, callback)

	--[[ Returning ]]

	return tile
end

--%%%%%%%%%%%%%%%%%%%% Player Rows

--[[
	Fills the player list with a row per player, the picked one filled. Pressing a row shows that player. Returns the
	search entries.
]]
--- @param ctx UmeGui_Guis_System_Dashboard_Context
--- @return { { [string]: any } }
function Module._playerRows(ctx, list: Instance)
	--[[ Local Variables ]]

	local entries = {} --- @type { { [string]: any } }

	--[[ Building ]]

	--- @param player { [string]: any }
	for index: number, player in ipairs(ctx.Players) do
		local row = Module._build(ctx, "PREFAB | PlayerRow", list) --- @type UmeGui_Subview
		local bar: Frame = row:Get("S_SelectedBar").Instance
		local picked: boolean = ctx.State.Player == index
		row:Get("S_Headshot").Instance.Image = player.Headshot
		row:Get("S_DisplayName").Instance.Text = player.DisplayName
		row:Get("S_Username").Instance.Text = `@{player.Username}`
		row:Get("S_YouBadge").Instance.Visible = player.You == true
		row.Root.Instance.LayoutOrder = index
		row.Root.Instance.BackgroundTransparency = if picked then 0.9 else 1
		bar.BackgroundColor3 = ctx.Accent
		bar.Visible = picked
		Module._onActivated(row.Root.Instance, function()
			Module._select(ctx, "Player", index)
		end)
		table.insert(entries, { Row = row.Root.Instance, Text = string.lower(`{player.DisplayName} {player.Username}`) })
	end

	--[[ Returning ]]

	return entries
end

--%%%%%%%%%%%%%%%%%%%% Search

--[[
	Wires a search box to its rows: only the rows whose text holds what is typed (any case) show, a group hides with
	all its rows, and the empty line shows when nothing matches.
]]
--- @param entries { { [string]: any } }
function Module._search(search: TextBox, empty: TextLabel, entries)
	--%%%%%%%%%%%%%%%%%%%% Filter

	--[[
		Shows the rows that match the search box's text, the groups with a row showing, and the line that says nothing
		matches.
	]]
	local function filter()
		--[[ Local Variables ]]

		local query: string = string.lower(search.Text)
		local shown = {} --- @type { [Instance]: boolean }
		local count: number = 0

		--[[ Rows ]]

		--- @param entry { [string]: any }
		for _index: number, entry in ipairs(entries) do
			local visible: boolean = query == "" or string.find(entry.Text, query, 1, true) ~= nil
			entry.Row.Visible = visible
			count += if visible then 1 else 0

			-- A group stays while one of its rows shows
			if entry.Group and visible then
				shown[entry.Group] = true
			end
		end

		--[[ Groups ]]

		--- @param entry { [string]: any }
		for _index: number, entry in ipairs(entries) do
			-- Skip rows outside a group
			if not entry.Group then
				continue
			end
			entry.Group.Visible = shown[entry.Group] == true
		end

		--[[ Empty ]]

		empty.Visible = count == 0
	end

	--[[ Connections ]]

	table.insert(connections, search:GetPropertyChangedSignal("Text"):Connect(filter))
	filter()
end

return Module
