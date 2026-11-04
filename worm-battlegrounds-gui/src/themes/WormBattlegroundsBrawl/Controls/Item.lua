--[[
	Created By: 	Nari
]]

local _localName: string = "Item"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Theme: Instance = script:FindFirstAncestor("WormBattlegroundsBrawl")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Tokens = require(Theme:FindFirstChild("Tokens")) --- @type UmeGui_Tokens
local ItemStyles = require(Theme:FindFirstChild("Styles"):FindFirstChild("Item")) --- @type { [string]: UmeGui_Style }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The reward styles a reward tile records for game code, which shows a won item's rarity on an exported tile
local RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary" } --- @type { string }

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Item
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Text = "string?",
		Subtext = "string?",
		Image = "string?",
		Screen = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local stageInset: number = ctx.Number("Size", style.StageInset)

	--[[ Building ]]

	-- One thing: on a plain slot when owned, on a framed reward tile (a rarity style) when it's being won
	local parts = ctx.Pressable(UDim2.fromOffset(ctx.Number("Size", style.Width), ctx.Number("Size", style.Height))) --- @type UmeGui_Pressable
	local content: Frame = parts.Content
	parts.Background.BackgroundTransparency = 1
	ctx.Padding(content, style.Padding)
	ctx.List(content, "Vertical", style.Gap).HorizontalAlignment = Enum.HorizontalAlignment.Center
	ctx.Tag(parts.Button, style.Tags)

	ctx.Build({ Control = "Slab", Style = style.Slab }, parts.Background)

	-- One placed on the screen by itself (a hud button) scales with it and per device, as the Box panels do
	if node.Screen then
		ctx.Create("UIScale", { Name = "S_ScreenScale", Parent = parts.Container })
		ctx.Tag(parts.Container, { Utils_PlatformScale = style.PlatformScale })
	end

	--%%%%%%%%%%%%%%%%%%%% Reward

	-- A reward tile's inside: the rarity's stage (a wall and the floor the item stands on), the light behind the best
	if style.Stage ~= "" then
		local stage: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Stage",
			Image = ctx.Icon(style.Stage),
			Position = UDim2.fromOffset(stageInset, stageInset),
			ScaleType = Enum.ScaleType.Stretch,
			Size = UDim2.new(1, -stageInset * 2, 1, -stageInset * 2),
			ZIndex = 2,
			Parent = parts.Background,
		})
		ctx.Corner(stage, style.StageRadius)
	end
	if style.Glow or style.Stage ~= "" then
		local rays: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Rays",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = ctx.Icon("wb-rays"),
			ImageTransparency = style.RaysTransparency,
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(1, 1),
			Visible = style.Glow,
			ZIndex = 3,
			Parent = parts.Background,
		})
		ctx.Color(rays, "ImageColor3", style.GlowColor)
		ctx.Create("UIAspectRatioConstraint", { Parent = rays })

		local glow: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Glow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = ctx.Icon("wb-glow"),
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(0.9, 0.9),
			Visible = style.Glow,
			ZIndex = 3,
			Parent = parts.Background,
		})
		ctx.Color(glow, "ImageColor3", style.GlowColor)
		ctx.Create("UIAspectRatioConstraint", { Parent = glow })
	end

	-- A reward tile records every rarity's look, so game code can show the won item's on the exported tile
	if style.Stage ~= "" then
		for _index: number, rarity: string in ipairs(RARITIES) do
			local look = ItemStyles[rarity] --- @type UmeGui_Style
			parts.Container:SetAttribute(`Kit_{rarity}_Frame`, ctx.Icon(look.Slab.Skin))
			parts.Container:SetAttribute(`Kit_{rarity}_Stage`, ctx.Icon(look.Stage))
			parts.Container:SetAttribute(`Kit_{rarity}_Glow`, look.Glow == true)
			parts.Container:SetAttribute(`Kit_{rarity}_GlowColor`, Tokens.Palette.Night[look.GlowColor])
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Content

	-- The picture takes the height the texts leave free
	local well: Frame = ctx.Create("Frame", {
		Name = "Well",
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Parent = content,
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = well })

	local icon: ImageLabel = ctx.Create("ImageLabel", {
		Name = "S_Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = ctx.Icon(node.Image or style.Image),
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(style.IconScale, style.IconScale),
		Parent = well,
	})
	ctx.Color(icon, "ImageColor3", style.Tint)

	local name: TextLabel = ctx.Create("TextLabel", {
		Name = "S_Name",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, ctx.Number("TextSize", style.TextSize)),
		Text = if style.Upper then string.upper(node.Text or "") else node.Text or "",
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = node.Text ~= nil,
		Parent = content,
	})
	ctx.Text(name, style.Font, style.TextSize, style.Text)
	local nameStroke: UIStroke = ctx.Stroke(name, style.TextStroke, style.TextStrokeThickness)
	nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	local info: TextLabel = ctx.Create("TextLabel", {
		Name = "S_Info",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, ctx.Number("TextSize", style.SubtextSize)),
		Text = node.Subtext or "",
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = node.Subtext ~= nil,
		Parent = content,
	})
	ctx.Text(info, style.SubtextFont, style.SubtextSize, style.Subtext)
	local infoStroke: UIStroke = ctx.Stroke(info, style.TextStroke, style.TextStrokeThickness)
	infoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	-- Badges the gui places over the card (copies, lock, shiny mark, cooldown)
	local overlay: Frame = ctx.Create("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = parts.Button,
	})

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = parts.Button, Slot = overlay, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--[[ Connections ]]

	ctx.Connect(parts.Button.Activated, function()
		handle.Clicked:Fire()
	end)

	--[[ Returning ]]

	return handle
end

return Module
