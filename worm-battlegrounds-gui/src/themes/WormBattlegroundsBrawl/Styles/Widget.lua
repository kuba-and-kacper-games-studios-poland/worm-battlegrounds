--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	--[[
		A window in the Hazard plate design: the sea gradient with the diamond pattern inside an orange border, a
		yellow plate tilted out of the top-left corner with the title, the slanted red close on the top-right corner
	]]
	Default = {
		Width = 1000,
		Height = 700,
		-- The window's scale per device (Utils_PlatformScale): the kit is drawn for phones, so smaller on a PC
		PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 },
		Padding = "L",
		Gap = "M",
		Panel = {
			Skin = "wb-skin-border_orange",
			Drop = 10,
			Fill = "Text",
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 74, 90)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(23, 105, 122)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 138, 150)),
			}),
			Inset = 10,
			Radius = 22,
			Pattern = "wb-skin-lattice",
		},

		-- The plate: its picture and size, how far it rises above the window and sits out of its left edge, its lip
		Plate = "wb-skin-banner_hazard",
		PlateWidth = 460,
		PlateHeight = 112,
		PlateRise = 64,
		PlateX = -28,
		PlateLip = 11,
		-- Degrees the plate and the close lean
		Tilt = -3,
		TitleInset = 36,
		Title = "Text",
		TitleFont = "Title",
		TitleSize = "Heading",
		TitleStroke = "Ink",
		TitleStrokeThickness = "Text",
		TitleUpper = true,

		-- The close: its size, how far it sits out of the right edge, its top below the plate's
		CloseWidth = 118,
		CloseHeight = 96,
		CloseOut = 30,
		CloseY = 30,
		CloseStyle = "Close",
	},

	--[[ Sizes ]]

	Small = { Width = 760, Height = 540 },
	-- Large and Screen windows are smaller on phones and tablets, so the plate and window fit a phone's height
	Large = { Width = 1400, Height = 880, PlatformScale = { Utils_MobileScale = 0.8 } },
	-- Fills most of the screen (the shop, a match's results); still fits a 4:3 tablet
	Screen = { Width = 1600, Height = 920, PlatformScale = { Utils_MobileScale = 0.78 } },

	--[[ Colours ]]

	-- Premium offers and VIP
	Royal = {
		Panel = {
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 31, 150)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(102, 72, 210)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(164, 156, 240)),
			}),
		},
	},
	-- Limited events, the Lava map
	Ember = {
		Panel = {
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 22, 12)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(163, 54, 27)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 133, 60)),
			}),
		},
	},
}

return _styles
