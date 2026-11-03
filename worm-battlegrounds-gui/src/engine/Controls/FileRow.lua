--[[
	Created By: 	Nari
]]

local _localName: string = "FileRow"

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

--- @class UmeGui_Controls_FileRow
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Subtext = "string?",
		Status = "string?",
		StatusTone = "string?",
		Added = "number?",
		Removed = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local statusTone: any = node.StatusTone or style.Status
	local iconSize: number = ctx.Number("TextSize", style.IconSize)

	--%%%%%%%%%%%%%%%%%%%% Fixed Text

	--[[
		Creates a text label at its token size that never shrinks: its box grows with the text instead.
	]]
	--- @return TextLabel
	local function fixedText(name: string, order: number, parent: Instance, font: any, textSize: any, color: any)
		--[[ Building ]]

		local label: TextLabel = ctx.Create("TextLabel", {
			Name = name,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = order,
			Text = "",
			Parent = parent,
		})
		ctx.Text(label, font, textSize, color)
		local constraint: UITextSizeConstraint = label:FindFirstChildOfClass("UITextSizeConstraint")
		constraint.MinTextSize = constraint.MaxTextSize

		--[[ Returning ]]

		return label
	end

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	local row: Frame = surface.Content
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(surface.Background, style.Radius)
	ctx.Padding(row, style.Padding)
	ctx.List(row, "Horizontal", style.Gap)

	-- Image before the texts, shown by SetIcon
	local icon: ImageLabel = ctx.Create("ImageLabel", {
		Name = "Icon",
		LayoutOrder = 0,
		Size = UDim2.fromOffset(iconSize, iconSize),
		Visible = false,
		Parent = row,
	})

	-- Name over its path, wrapping
	local texts: Frame = ctx.Create("Frame", {
		Name = "Texts",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 0),
		Parent = row,
	})
	ctx.List(texts, "Vertical", "None")
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = texts })

	local title: TextLabel = fixedText("Title", 0, texts, style.Font, style.TextSize, style.Text)
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.Size = UDim2.fromScale(1, 0)
	title.TextWrapped = true
	title.Text = node.Text

	local subtitle: TextLabel = fixedText("Subtext", 1, texts, style.SubFont, style.SubSize, style.Subtext)
	subtitle.AutomaticSize = Enum.AutomaticSize.Y
	subtitle.Size = UDim2.fromScale(1, 0)
	subtitle.TextWrapped = true
	subtitle.Text = node.Subtext or ""
	subtitle.Visible = node.Subtext ~= nil and node.Subtext ~= ""

	-- Lines added and removed
	local added: TextLabel = fixedText("Added", 2, row, style.CountFont, style.CountSize, style.Added)
	local removed: TextLabel = fixedText("Removed", 3, row, style.CountFont, style.CountSize, style.Removed)

	-- Status badge: the tone's text on a faint fill of the same tone
	local badge: Frame = ctx.Create("Frame", {
		Name = "Badge",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = style.BadgeTransparency,
		LayoutOrder = 4,
		Parent = row,
	})
	ctx.Corner(badge, style.BadgeRadius)
	ctx.Padding(badge, style.BadgePaddingY, style.BadgePaddingX)
	local status: TextLabel = fixedText("Status", 0, badge, style.StatusFont, style.StatusSize, statusTone)

	--%%%%%%%%%%%%%%%%%%%% Paint Status

	--[[
		Colors the badge and its text with the current tone.
	]]
	local function paintStatus()
		--[[ Applying ]]

		local color: Color3 = ctx.ResolveColor(statusTone)
		status.TextColor3 = color
		badge.BackgroundColor3 = color
	end

	--[[ Theme ]]

	paintStatus()
	ctx.Refresh(paintStatus)

	--[[ Handle ]]

	local handle = { Instance = surface.Root } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the name.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Subtext

	--[[
		Replaces the path under the name; empty hides it.
	]]
	function handle.SetSubtext(text: string)
		subtitle.Text = text
		subtitle.Visible = text ~= ""
	end

	--%%%%%%%%%%%%%%%%%%%% Set Status

	--[[
		Shows the badge with a text, optionally recolored with a palette token ("Success", "Danger", …); nil hides it.
	]]
	function handle.SetStatus(text: string?, tone: string?)
		--[[ Applying ]]

		status.Text = text or ""
		badge.Visible = text ~= nil and text ~= ""
		statusTone = tone or style.Status
		paintStatus()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Counts

	--[[
		Shows how many lines the file adds and removes. A count of 0 or nil is hidden.
	]]
	function handle.SetCounts(addedCount: number?, removedCount: number?)
		--[[ Applying ]]

		added.Text = `+{addedCount or 0}`
		added.Visible = (addedCount or 0) > 0
		removed.Text = `−{removedCount or 0}`
		removed.Visible = (removedCount or 0) > 0
	end

	--%%%%%%%%%%%%%%%%%%%% Set Icon

	--[[
		Shows an image before the name, optionally a sprite from a sheet (`rectOffset`, `rectSize`), or hides it with nil.
	]]
	function handle.SetIcon(image: string?, rectOffset: Vector2?, rectSize: Vector2?)
		--[[ Applying ]]

		icon.Image = image or ""
		icon.ImageRectOffset = rectOffset or Vector2.zero
		icon.ImageRectSize = rectSize or Vector2.zero
		icon.Visible = image ~= nil
	end

	--[[ Starting Values ]]

	handle.SetStatus(node.Status, node.StatusTone)
	handle.SetCounts(node.Added, node.Removed)

	--[[ Returning ]]

	return handle
end

return Module
