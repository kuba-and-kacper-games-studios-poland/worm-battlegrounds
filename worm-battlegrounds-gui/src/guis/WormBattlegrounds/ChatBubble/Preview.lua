--[[
	Created By: 	HungryN00B
]]

local _localName: string = "ChatBubblePreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TextService: TextService = game:GetService("TextService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Messages as a player sends them, the oldest first
local MESSAGES = { "gg", "Nice shot! That bazooka went right over the hill", "Watch the wind" } --- @type { string }

-- The widest a bubble's text gets before it wraps, and the room scaled text needs past its measure, as ChatBubbles' settings
local TEXT_MAX_WIDTH: number = 170
local TEXT_ROOM: number = 1.06

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

--- @class UmeGui_Guis_WormBattlegrounds_ChatBubble_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Bubbles", Label = "Messages", Value = 3, Min = 1, Max = 3, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Stacks the last messages as ChatBubbles does: each bubble sized to its text, the newest at the bottom with the
	tail.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local count: number = preview.Values.S_Bubbles
	local bubbles = preview.Fill("PREFAB | Bubble", count) --- @type { UmeGui_Subview }

	--[[ Bubbles ]]

	--- @param bubble UmeGui_Subview
	for index: number, bubble in ipairs(bubbles) do
		--[[ Elements ]]

		local root: Frame = bubble.Root.Instance
		local body: Frame = bubble:Get("S_Body").Instance
		local text: TextLabel = bubble:Get("S_Text").Instance

		--[[ Local Variables ]]

		local newest: boolean = index == count
		local padding: UIPadding = text:FindFirstChildOfClass("UIPadding")
		local stroke: number = body:FindFirstChildOfClass("UIStroke").Thickness
		local below: number = if newest then -body.Position.Y.Offset else stroke
		local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
		params.Text = MESSAGES[#MESSAGES - count + index]
		params.Font = text.FontFace
		params.Size = text.TextSize
		params.Width = TEXT_MAX_WIDTH
		params.RichText = true
		local bounds: Vector2 = TextService:GetTextBoundsAsync(params)
		local width: number = math.ceil(bounds.X * TEXT_ROOM) + padding.PaddingLeft.Offset + padding.PaddingRight.Offset
		local height: number = math.ceil(bounds.Y * TEXT_ROOM) + padding.PaddingTop.Offset + padding.PaddingBottom.Offset

		--[[ Applying ]]

		text.Text = params.Text
		body.Size = UDim2.fromOffset(width, height)
		body.Position = UDim2.new(0.5, 0, 1, -below)
		root.Size = UDim2.fromOffset(width + stroke * 2, height + stroke + below)
		root.LayoutOrder = index
		bubble:Get("S_Tail").Instance.Visible = newest
		bubble:Get("S_Joint").Instance.Visible = newest
	end
end

return Module
