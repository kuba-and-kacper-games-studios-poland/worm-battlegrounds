--[[
	Created By: 	Nari
]]

local _localName: string = "CommandBarPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Window = require(script.Parent:FindFirstChild("Window")) --- @type UmeGui_Guis_System_CommandBar_Window

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Outputs ]]

-- Example output lines, written as ume's Command module prints them: a dimmed timestamp, then the command's alias in
-- its OutputCommand green (OutputError red when it failed) and ">>" before the result, or a dimmed line on its own.
-- The timestamps start at FIRST_TIME (seconds into the day) and move on by TIME_STEP a line
--- @type { { [string]: any } }
local OUTPUTS = {
	{ Message = "Type help to list the commands." },
	{ Alias = "help", Success = true, Message = "give, grow, tp, speed, reset, kick" },
	{ Alias = "give", Success = true, Message = "Gave Nari 500 coins" },
	{ Alias = "give", Success = true, Message = "Gave 250 Cash to builderman" },
	{ Alias = "tp", Success = false, Message = 'No player named "Bob"' },
	{ Alias = "speed", Success = true, Message = "WalkSpeed set to 32" },
}
local FIRST_TIME: number = 14 * 3600 + 2 * 60 + 7
local TIME_STEP: number = 5.473
local COMMAND_COLOR: string = "rgb(65,225,65)"
local ERROR_COLOR: string = "rgb(255,50,50)"

--[[ Window ]]

-- The smallest size a resize leaves the console (Window.lua drags and resizes it)
local MIN_SIZE: Vector2 = Vector2.new(360, 150)

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

--- @class UmeGui_Guis_System_CommandBar_Preview
local Module = {

	--[[ Settings ]]

	-- How many example lines the output shows
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Outputs", Label = "Outputs", Value = 6, Min = 0, Max = 18, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Wires the console as the game should drive it (the header drags it, the edge and corner handles resize it), then
	fills the output with example lines and hides the empty autocomplete box.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Elements ]]

	local console: Frame = preview.View:Get("U_CommandBar").Instance

	--[[ Binding ]]

	Window.Bind(console, MIN_SIZE)

	--[[ Outputs ]]

	Module._fillOutputs(preview)

	--[[ Suggestions ]]

	-- Hide the empty autocomplete box, as Command does until something is typed, so it covers no output line
	preview.View:Get("U_CommandBar", "S_SuggestionsContainer").Instance.Visible = false
	preview.View:Get("U_CommandBar", "S_SuggestionsContainerBackground").Instance.Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Fill Outputs

--[[
	Fills the output with the Outputs setting's number of example lines: OUTPUTS' first line, then its commands in turn.
	Scrolls it to the newest one, as the Command module does.
]]
--- @param preview UmeGui_Preview
function Module._fillOutputs(preview)
	--[[ Elements ]]

	local output: ScrollingFrame = preview.View:Get("U_CommandBar", "S_OutputScrollingFrame").Instance

	--[[ Building ]]

	local lines = preview.Fill("PREFAB | OutputFrame", preview.Values.S_Outputs, output) --- @type { UmeGui_Subview }

	--- @param line UmeGui_Subview
	for index: number, line in ipairs(lines) do
		--[[ Local Variables ]]

		-- The first line once, then the commands in turn
		local example = OUTPUTS[if index == 1 then 1 else (index - 2) % (#OUTPUTS - 1) + 2] --- @type { [string]: any }
		local frame: Frame = line.Root.Instance
		local outputText: TextLabel = frame:FindFirstChild("OutputText")
		local time: number = FIRST_TIME + (index - 1) * TIME_STEP
		local stamp: string = string.format("%02d:%02d:%02d.%03d", time // 3600, time // 60 % 60, time // 1 % 60, time % 1 * 1000 // 1)
		local text: string = `<font transparency="0.5">{stamp}</font> `

		--[[ Formatting ]]

		if example.Alias then
			text ..= `<font color="{if example.Success then COMMAND_COLOR else ERROR_COLOR}">{example.Alias}</font> &gt;&gt; {example.Message}`
		else
			text ..= `<font transparency="0.5">{example.Message}</font>`
		end

		--[[ Applying ]]

		outputText.Text = text
		frame.LayoutOrder = index
	end

	--[[ Scrolling ]]

	output.CanvasPosition = Vector2.new(0, output.AbsoluteCanvasSize.Y)
end

return Module
