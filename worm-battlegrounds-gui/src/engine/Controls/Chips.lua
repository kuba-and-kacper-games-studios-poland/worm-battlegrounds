--[[
	Created By: 	Nari
]]

local _localName: string = "Chips"

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

--- @class UmeGui_Controls_Chips
local Module = {

	--[[ Schema ]]

	Params = {
		Options = "table",
		Value = "string?",
		Add = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local options = table.clone(node.Options) --- @type { string }
	local value: string? = node.Value
	local itemActions = {} --- @type { [string]: { any } }
	local pills = {} --- @type { [string]: UmeGui_Handle }

	--[[ Building ]]

	local row: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	local list: UIListLayout = ctx.List(row, "Horizontal", style.Gap)
	list.Wraps = true
	list.VerticalAlignment = Enum.VerticalAlignment.Center

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = row,
		Changed = ctx.Signal.new(),
		AddClicked = ctx.Signal.new(),
		ItemAction = ctx.Signal.new(),
	}

	--%%%%%%%%%%%%%%%%%%%% Build Pills

	--[[
		Replaces the pills with one per option, the + button last.
	]]
	local function buildPills()
		--[[ Clearing ]]

		--- @param pill UmeGui_Handle
		for _option: string, pill in pairs(pills) do
			pill.Instance:Destroy()
		end
		table.clear(pills)

		--[[ Pills ]]

		for index: number, option: string in ipairs(options) do
			local pill = ctx.Build({ Control = "Button", Text = option, AutoWidth = true, Selected = option == value, Style = style.ChipStyle }, row) --- @type UmeGui_Handle
			pill.Instance.Name = option
			pill.Instance.LayoutOrder = index
			pills[option] = pill

			if ctx.Interactive then
				ctx.Connect(pill.Clicked, function()
					handle.Set(option)
					handle.Changed:Fire(option)
				end)
				ctx.Connect(pill.Button.MouseButton2Click, function()
					local actions = itemActions[option] --- @type { any }?

					-- Options without actions have no context menu
					if not actions or #actions == 0 then
						return
					end

					ctx.ContextMenu(actions, function(actionId: string)
						handle.ItemAction:Fire(option, actionId)
					end)
				end)
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Selects an option (nil selects none) without firing Changed.
	]]
	function handle.Set(option: string?)
		--[[ Applying ]]

		value = option

		--- @param pill UmeGui_Handle
		for pillOption: string, pill in pairs(pills) do
			pill.SetSelected(pillOption == value)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the selected option.
	]]
	--- @return string?
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Set Options

	--[[
		Replaces the options; the pills are only rebuilt when the list changed.
	]]
	--- @param newOptions { string }
	function handle.SetOptions(newOptions)
		--[[ Checks ]]

		-- Skip when the pills already match
		if table.concat(newOptions, "\0") == table.concat(options, "\0") then
			return
		end

		--[[ Applying ]]

		options = table.clone(newOptions)
		buildPills()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Item Actions

	--[[
		Gives options their right-click actions, by option name; options left out have none.
	]]
	--- @param actions { [string]: { any } }
	function handle.SetItemActions(actions)
		itemActions = table.clone(actions)
	end

	--[[ Pills ]]

	buildPills()

	--[[ Add Button ]]

	if node.Add then
		local add = ctx.Build({ Control = "IconButton", Icon = "plus-large", Style = style.AddStyle }, row) --- @type UmeGui_Handle
		add.Instance.Name = "Add"
		-- Always after the last pill, however many there are
		add.Instance.LayoutOrder = 1000000000
		ctx.Connect(add.Clicked, function()
			handle.AddClicked:Fire()
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
