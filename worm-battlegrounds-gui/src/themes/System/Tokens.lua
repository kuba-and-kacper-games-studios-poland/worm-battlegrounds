--[[
	Created By: 	Nari
]]

--- @class UmeGui_Themes_System_Tokens
local _tokens = {

	--[[ Palette ]]

	-- Color tokens per mode. Styles name these; controls never hold colors.
	Palette = {
		Night = {
			Background = Color3.fromRGB(21, 21, 21),
			Surface = Color3.fromRGB(30, 30, 30),
			SurfaceHover = Color3.fromRGB(40, 40, 40),
			SurfacePressed = Color3.fromRGB(50, 50, 50),

			Border = Color3.fromRGB(56, 56, 56),
			-- Outlines are a soft light grey in Night, never pure white, so they stay calm against the background
			BorderStrong = Color3.fromRGB(225, 225, 225),

			Text = Color3.fromRGB(238, 238, 238),
			TextDim = Color3.fromRGB(150, 150, 150),
			TextMuted = Color3.fromRGB(100, 100, 100),

			-- Light fills match the outlines; hover and press dim them
			Inverse = Color3.fromRGB(225, 225, 225),
			InverseHover = Color3.fromRGB(207, 207, 207),
			InversePressed = Color3.fromRGB(189, 189, 189),
			InverseText = Color3.fromRGB(22, 22, 22),

			Track = Color3.fromRGB(64, 64, 64),
			Knob = Color3.fromRGB(12, 12, 12),
			KnobStroke = Color3.fromRGB(225, 225, 225),

			Accent = Color3.fromRGB(255, 255, 255),
			Success = Color3.fromRGB(96, 214, 140),
			Danger = Color3.fromRGB(240, 84, 84),
			Warning = Color3.fromRGB(240, 180, 80),
			-- Hearts of favorite items
			Favorite = Color3.fromRGB(236, 92, 120),

			Overlay = Color3.fromRGB(0, 0, 0),
			-- Soft light behind previews (images on asset tiles): glows white in Night
			Glow = Color3.fromRGB(255, 255, 255),
		},
		Light = {
			Background = Color3.fromRGB(244, 244, 244),
			Surface = Color3.fromRGB(255, 255, 255),
			SurfaceHover = Color3.fromRGB(232, 232, 232),
			SurfacePressed = Color3.fromRGB(220, 220, 220),

			Border = Color3.fromRGB(214, 214, 214),
			BorderStrong = Color3.fromRGB(10, 12, 15),

			Text = Color3.fromRGB(10, 12, 15),
			TextDim = Color3.fromRGB(108, 108, 108),
			TextMuted = Color3.fromRGB(160, 160, 160),

			-- One blue-tinted dark for outlines, text, fills and slider strokes; hover lightens it, press deepens it
			Inverse = Color3.fromRGB(10, 12, 15),
			InverseHover = Color3.fromRGB(38, 42, 50),
			InversePressed = Color3.fromRGB(4, 5, 7),
			InverseText = Color3.fromRGB(250, 250, 250),

			Track = Color3.fromRGB(210, 210, 210),
			Knob = Color3.fromRGB(255, 255, 255),
			KnobStroke = Color3.fromRGB(10, 12, 15),

			Accent = Color3.fromRGB(10, 12, 15),
			Success = Color3.fromRGB(28, 150, 80),
			Danger = Color3.fromRGB(208, 52, 52),
			Warning = Color3.fromRGB(196, 128, 20),
			Favorite = Color3.fromRGB(214, 58, 96),

			Overlay = Color3.fromRGB(0, 0, 0),
			-- A dark shadow in Light
			Glow = Color3.fromRGB(0, 0, 0),
		},
	},

	-- Color sets a Swatches or ColorPicker can name instead of listing colors
	Swatches = {
		Warm = {
			Color3.fromRGB(250, 232, 200),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(250, 204, 150),
			Color3.fromRGB(246, 158, 92),
			Color3.fromRGB(200, 220, 250),
			Color3.fromRGB(140, 240, 200),
			Color3.fromRGB(246, 170, 210),
			Color3.fromRGB(190, 160, 250),
		},
		Basic = {
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(163, 162, 165),
			Color3.fromRGB(27, 42, 53),
			Color3.fromRGB(255, 89, 39),
			Color3.fromRGB(255, 207, 77),
			Color3.fromRGB(76, 186, 108),
			Color3.fromRGB(52, 172, 240),
			Color3.fromRGB(170, 85, 255),
		},
	},

	--[[ Text ]]

	-- Only three weights: SemiBold for small text, Bold for body and buttons, ExtraBold for titles
	Font = {
		Hint = { Family = "rbxasset://fonts/families/BuilderSans.json", Weight = "SemiBold" },
		Body = { Family = "rbxasset://fonts/families/BuilderSans.json", Weight = "Bold" },
		Title = { Family = "rbxasset://fonts/families/BuilderSans.json", Weight = "ExtraBold" },
	},
	TextSize = {
		Caption = 11,
		Small = 12,
		Body = 14,
		Heading = 15,
		Title = 17,
		-- Glyphs on icon buttons (−, +, ×)
		Icon = 20,
		-- Icon images (Icons) next to text, and on small icon buttons
		Symbol = 16,
		SymbolSmall = 14,
	},

	--[[ Icons ]]

	-- Icon images by name, white on transparent and tinted by the control (art set icons/ume-gui). The
	-- names are the Builder Icons names the guis used before, so `Icon = "trash-can"` keeps working
	Icons = {
		["arrow-down-to-line"] = "rbxassetid://89413654138091",
		["arrow-spin-clockwise"] = "rbxassetid://100964253605633",
		["arrow-spin-counter-clockwise"] = "rbxassetid://86395617916006",
		["arrow-up-from-line"] = "rbxassetid://120962159945868",
		["chart-pie"] = "rbxassetid://96956382398786",
		["check"] = "rbxassetid://113706180203474",
		["chevron-small-down"] = "rbxassetid://140486626021039",
		["chevron-small-right"] = "rbxassetid://112284420447223",
		["circle-person"] = "rbxassetid://129623105387698",
		["clock"] = "rbxassetid://110630934188022",
		["cloud"] = "rbxassetid://121541460733326",
		["cursor-arrow"] = "rbxassetid://110704403466384",
		["dual-arrows-vertical"] = "rbxassetid://75122268597041",
		["eye"] = "rbxassetid://86392025737029",
		["eye-slash"] = "rbxassetid://73508493822300",
		["file-box"] = "rbxassetid://106943076349886",
		["floppy-disk"] = "rbxassetid://114112325895527",
		["folders"] = "rbxassetid://133372866451761",
		["four-squares-grid"] = "rbxassetid://106773010918989",
		["frame-corners"] = "rbxassetid://110010190341490",
		["gear"] = "rbxassetid://123765846716976",
		["grid"] = "rbxassetid://135383049275331",
		["heart"] = "rbxassetid://124494336641499",
		["heart-filled"] = "rbxassetid://92023041368445",
		["list-bulleted"] = "rbxassetid://126370991584414",
		["lock-closed"] = "rbxassetid://96865589460306",
		["magnifying-glass"] = "rbxassetid://70531937773504",
		["minus"] = "rbxassetid://74370212348230",
		["pencil"] = "rbxassetid://81709470867149",
		["pencil-square"] = "rbxassetid://130681240231516",
		["person"] = "rbxassetid://106385574298472",
		["photo-camera"] = "rbxassetid://109297033404014",
		["plus-large"] = "rbxassetid://88988754297825",
		["sun"] = "rbxassetid://81113637288972",
		["tag"] = "rbxassetid://106045865633826",
		["trash-can"] = "rbxassetid://127560007125150",
		["two-arrows-down-and-up-to-center"] = "rbxassetid://109737684971781",
		["x"] = "rbxassetid://76936488196808",
	},

	--[[ Shape ]]

	Radius = {
		None = 0,
		Small = 4,
		Control = 6,
		Card = 6,
		Window = 8,
	},
	Size = {
		Row = 26,
		RowSmall = 22,
		Control = 34,
		ControlSmall = 28,
		IconButton = 26,
		IconButtonSmall = 20,
		Header = 34,
		Title = 44,
		-- Logo image before a header's title
		Logo = 22,
		Grip = 16,

		Track = 3,
		Bar = 12,
		Knob = 18,
		ToggleWidth = 40,
		ToggleHeight = 22,
		Swatch = 30,
		-- Checkbox of a CheckItem
		Check = 16,
		CheckSmall = 12,
		Chip = 36,

		WindowWidth = 380,
		WindowHeight = 680,
		Menu = 220,
	},
	Spacing = {
		None = 0,
		XS = 4,
		S = 6,
		M = 10,
		L = 14,
		XL = 18,

		-- Gap between buttons side by side, wide enough for their outlines
		Buttons = 8,
	},
	Stroke = {
		None = 0,
		Thin = 1,
		-- Outlines on containers, buttons and knobs
		Thick = 1.5,
	},

	--[[ Motion ]]

	-- Tween durations in seconds
	Motion = {
		Fast = 0.08,
		Default = 0.14,
		Slow = 0.22,
	},
}

return _tokens
