--- @class Console_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Hints

	-- Gui elements with this tag show only on Console, with their gamepad icons swapped to the player's pad
	HINT_TAG = "Console_Hint",

	-- A hint with this attribute set to true stays hidden on Console too, until a module clears it
	HINT_HIDDEN_ATTRIBUTE = "Console_HintHidden",

	--[[
		A hint with this attribute names its row in ACTIONS: every image in it shows that action's first button in
		HINT_STYLE, and every text in it the action's Hint
	]]
	HINT_ACTION_ATTRIBUTE = "Console_Action",

	--[[
		The icon style of GAMEPAD_ICONS an action's hint shows. The game's own glyphs (art/console_glyphs) become a
		style of both pads, "Glyph", once the owner approves and they are uploaded; then this is "Glyph"
	]]
	HINT_STYLE = "Color",

	--%%%%%%%%%%%%%%%%%%%% Actions

	-- The ContextActionService priority of an action that names none: before Roblox's own, as ume/input.md asks
	DEFAULT_PRIORITY = Enum.ContextActionPriority.High.Value,

	--[[
		The game's gamepad scheme: every action, its buttons (Enum.KeyCodes; its hints show the first), its hint text
		and its priority. A module binds its row with I.Console.Bind; a Gui row is pressed by the gui buttons whose
		Utils_GamepadKey is its first button (Interact binds those), and is here for its hints. Start (Menu, Options)
		is Roblox's menu and never bound. Why each button: the module README → Scheme
	]]
	--- @type { [string]: Console_Action }
	ACTIONS = {

		--[[ Match ]]

		Move = { Keys = { Enum.KeyCode.Thumbstick1 }, Hint = "Move" },
		WalkLeft = { Keys = { Enum.KeyCode.DPadLeft }, Hint = "Walk" },
		WalkRight = { Keys = { Enum.KeyCode.DPadRight }, Hint = "Walk" },
		Jump = { Keys = { Enum.KeyCode.ButtonA }, Hint = "Jump, hold to fly" },
		Aim = { Keys = { Enum.KeyCode.Thumbstick2 }, Hint = "Aim" },
		Fire = { Keys = { Enum.KeyCode.ButtonR2 }, Hint = "Charge, let go to fire" },
		CancelAim = { Keys = { Enum.KeyCode.ButtonB }, Hint = "Cancel" },
		WeaponPrevious = { Keys = { Enum.KeyCode.ButtonL1 }, Hint = "Weapon" },
		WeaponNext = { Keys = { Enum.KeyCode.ButtonR1 }, Hint = "Weapon" },
		UseUtility = { Keys = { Enum.KeyCode.ButtonY }, Hint = "Use" },
		CameraPan = { Keys = { Enum.KeyCode.ButtonL2 }, Hint = "Hold: move camera" },
		ZoomIn = { Keys = { Enum.KeyCode.DPadUp }, Hint = "Zoom in" },
		ZoomOut = { Keys = { Enum.KeyCode.DPadDown }, Hint = "Zoom out" },
		Emotes = { Keys = { Enum.KeyCode.ButtonX }, Hint = "Emotes", Gui = true },
		PlaceDrop = { Keys = { Enum.KeyCode.ButtonA }, Hint = "Drop here" },

		--[[ Menus ]]

		Navigate = { Keys = { Enum.KeyCode.ButtonSelect }, Hint = "Menus" },
		Confirm = { Keys = { Enum.KeyCode.ButtonA }, Hint = "Select", Gui = true },
		Back = { Keys = { Enum.KeyCode.ButtonB }, Hint = "Back", Gui = true },
		Decline = { Keys = { Enum.KeyCode.ButtonX }, Hint = "Decline", Gui = true },
		TabPrevious = { Keys = { Enum.KeyCode.ButtonL1 }, Hint = "Tab" },
		TabNext = { Keys = { Enum.KeyCode.ButtonR1 }, Hint = "Tab" },

		--[[ Lobby ]]

		Custom = { Keys = { Enum.KeyCode.ButtonX }, Hint = "Custom", Gui = true },
		Invite = { Keys = { Enum.KeyCode.ButtonY }, Hint = "Invite", Gui = true },
		Style = { Keys = { Enum.KeyCode.ButtonL1 }, Hint = "Style", Gui = true },
		Crates = { Keys = { Enum.KeyCode.ButtonR1 }, Hint = "Crates", Gui = true },
	},

	--%%%%%%%%%%%%%%%%%%%% Selection

	--[[
		How long after B a selection that ends still counts as B backing out: Roblox clears the selection on B before
		any script sees the press
	]]
	BACK_WINDOW = 0.25,

	-- The guis Navigate (View) starts the selection in when no widget, focus or home shows, in order
	--- @type { string }
	NAVIGATION_GUIS = { "MatchBoard", "Lobby", "Loadout", "Party", "MatchHud", "TopBar" },

	--%%%%%%%%%%%%%%%%%%%% Names

	-- What texts call each button on either pad (I.Console.GetButtonName), by Enum.KeyCode name
	--- @type { [string]: { [string]: string } }
	BUTTON_NAMES = {

		--[[ Xbox ]]

		Xbox = {
			ButtonA = "A",
			ButtonB = "B",
			ButtonX = "X",
			ButtonY = "Y",
			ButtonL1 = "LB",
			ButtonR1 = "RB",
			ButtonL2 = "LT",
			ButtonR2 = "RT",
			ButtonL3 = "LS",
			ButtonR3 = "RS",
			Thumbstick1 = "the left stick",
			Thumbstick2 = "the right stick",
			DPadUp = "D-pad up",
			DPadDown = "D-pad down",
			DPadLeft = "D-pad left",
			DPadRight = "D-pad right",
			ButtonSelect = "View",
			ButtonStart = "Menu",
		},

		--[[ PlayStation ]]

		PlayStation = {
			ButtonA = "Cross",
			ButtonB = "Circle",
			ButtonX = "Square",
			ButtonY = "Triangle",
			ButtonL1 = "L1",
			ButtonR1 = "R1",
			ButtonL2 = "L2",
			ButtonR2 = "R2",
			ButtonL3 = "L3",
			ButtonR3 = "R3",
			Thumbstick1 = "the left stick",
			Thumbstick2 = "the right stick",
			DPadUp = "D-pad up",
			DPadDown = "D-pad down",
			DPadLeft = "D-pad left",
			DPadRight = "D-pad right",
			ButtonSelect = "the touchpad",
			ButtonStart = "Options",
		},
	},

	--%%%%%%%%%%%%%%%%%%%% Icons

	--[[
		Gamepad icons by pad, icon style and Enum.KeyCode name: a copy of the System theme's Gamepad.lua in ume-gui, so
		an exported gui's icon can be swapped to the same button and style on the other pad
	]]
	--- @type { [string]: { [string]: { [string]: string } } }
	GAMEPAD_ICONS = {

		--[[ Xbox ]]

		Xbox = {
			Color = {
				ButtonA = "rbxassetid://114652165427862",
				ButtonB = "rbxassetid://117564937183685",
				ButtonX = "rbxassetid://116629055704033",
				ButtonY = "rbxassetid://91351306865428",
				ButtonL1 = "rbxassetid://83675298913757",
				ButtonR1 = "rbxassetid://118989647484332",
				ButtonL2 = "rbxassetid://74718376596673",
				ButtonR2 = "rbxassetid://127037190736029",
				Thumbstick1 = "rbxassetid://116353559482988",
				Thumbstick2 = "rbxassetid://110344390401753",
				ButtonL3 = "rbxassetid://117139107060986",
				ButtonR3 = "rbxassetid://74436002988090",
				DPad = "rbxassetid://135731947971449",
				DPadUp = "rbxassetid://96798501786319",
				DPadRight = "rbxassetid://105876671214516",
				DPadDown = "rbxassetid://118675586273862",
				DPadLeft = "rbxassetid://139408944025549",
				ButtonStart = "rbxassetid://130185520330707",
				ButtonSelect = "rbxassetid://97507744823658",
			},
			ColorThick = {
				ButtonA = "rbxassetid://96386000008631",
				ButtonB = "rbxassetid://130460272434611",
				ButtonX = "rbxassetid://122507607734627",
			},
			White = {
				ButtonA = "rbxassetid://114988336865497",
				ButtonB = "rbxassetid://92252921636068",
				ButtonX = "rbxassetid://138436403635370",
				ButtonY = "rbxassetid://89734222534156",
				ButtonL1 = "rbxassetid://110090601082438",
				ButtonR1 = "rbxassetid://72961571671477",
				ButtonL2 = "rbxassetid://82966149374903",
				ButtonR2 = "rbxassetid://96630690621030",
				Thumbstick1 = "rbxassetid://131409790654147",
				Thumbstick2 = "rbxassetid://110585971411531",
				ButtonL3 = "rbxassetid://131293165822062",
				ButtonR3 = "rbxassetid://83622864515432",
				DPad = "rbxassetid://138947904441816",
				DPadUp = "rbxassetid://132549581537060",
				DPadRight = "rbxassetid://115685744833525",
				DPadDown = "rbxassetid://115263268607261",
				DPadLeft = "rbxassetid://76285402510947",
				ButtonStart = "rbxassetid://86914598527986",
				ButtonSelect = "rbxassetid://100333564317306",
			},
			Bold = {
				ButtonA = "rbxassetid://82321096206580",
				ButtonB = "rbxassetid://92381267474562",
				ButtonX = "rbxassetid://72172604595668",
				ButtonY = "rbxassetid://119086148165705",
				ButtonL1 = "rbxassetid://134286971730495",
				ButtonR1 = "rbxassetid://133582019403287",
				ButtonL2 = "rbxassetid://101664035411747",
				ButtonR2 = "rbxassetid://123009957686240",
				Thumbstick1 = "rbxassetid://99114839824714",
				Thumbstick2 = "rbxassetid://114905075447204",
				ButtonL3 = "rbxassetid://93071858412767",
				ButtonR3 = "rbxassetid://103474592150003",
				DPad = "rbxassetid://86895616846244",
				DPadUp = "rbxassetid://80265840705266",
				DPadRight = "rbxassetid://105908193392083",
				DPadDown = "rbxassetid://117083828903556",
				DPadLeft = "rbxassetid://86450424323009",
				ButtonStart = "rbxassetid://74830851226144",
				ButtonSelect = "rbxassetid://135478896704202",
			},
			BoldWhite = {
				ButtonA = "rbxassetid://117173939590640",
				ButtonB = "rbxassetid://127632919512172",
				ButtonX = "rbxassetid://100810099261653",
				ButtonY = "rbxassetid://118126295709469",
				ButtonL1 = "rbxassetid://108242922432163",
				ButtonR1 = "rbxassetid://114332301559653",
				ButtonL2 = "rbxassetid://107687983077049",
				ButtonR2 = "rbxassetid://89095487148845",
				Thumbstick1 = "rbxassetid://70906340522780",
				Thumbstick2 = "rbxassetid://73577937946051",
				ButtonL3 = "rbxassetid://108818053978991",
				ButtonR3 = "rbxassetid://85800551329343",
				DPad = "rbxassetid://134156255132290",
				DPadUp = "rbxassetid://81924513371320",
				DPadRight = "rbxassetid://125171981236291",
				DPadDown = "rbxassetid://99480206679924",
				DPadLeft = "rbxassetid://91769036669485",
				ButtonStart = "rbxassetid://110657072269026",
				ButtonSelect = "rbxassetid://105014234581408",
			},
			WhiteBorder = {
				ButtonB = "rbxassetid://91247872695106",
			},
		},

		--[[ PlayStation ]]

		PlayStation = {
			Color = {
				ButtonA = "rbxassetid://103808397546820",
				ButtonB = "rbxassetid://79384064016807",
				ButtonX = "rbxassetid://96148882167308",
				ButtonY = "rbxassetid://129803755086531",
				ButtonL1 = "rbxassetid://98027039666736",
				ButtonR1 = "rbxassetid://98457636297834",
				ButtonL2 = "rbxassetid://115566085942403",
				ButtonR2 = "rbxassetid://87038603566518",
				Thumbstick1 = "rbxassetid://116353559482988",
				Thumbstick2 = "rbxassetid://110344390401753",
				ButtonL3 = "rbxassetid://101673222923311",
				ButtonR3 = "rbxassetid://105928192689482",
				DPad = "rbxassetid://135731947971449",
				DPadUp = "rbxassetid://96798501786319",
				DPadRight = "rbxassetid://105876671214516",
				DPadDown = "rbxassetid://118675586273862",
				DPadLeft = "rbxassetid://131228108278697",
				ButtonStart = "rbxassetid://85992981842364",
				ButtonSelect = "rbxassetid://139377076886398",
			},
			ColorThick = {
				ButtonA = "rbxassetid://121598474832607",
				ButtonB = "rbxassetid://78741147640505",
				ButtonX = "rbxassetid://133720323237009",
			},
			White = {
				ButtonA = "rbxassetid://91554338654896",
				ButtonB = "rbxassetid://93723915136952",
				ButtonX = "rbxassetid://111806779727872",
				ButtonY = "rbxassetid://122891964533044",
				ButtonL1 = "rbxassetid://101168157883227",
				ButtonR1 = "rbxassetid://103124386861279",
				ButtonL2 = "rbxassetid://118514954957639",
				ButtonR2 = "rbxassetid://89545860642568",
				Thumbstick1 = "rbxassetid://131409790654147",
				Thumbstick2 = "rbxassetid://110585971411531",
				ButtonL3 = "rbxassetid://129496062822925",
				ButtonR3 = "rbxassetid://107215920303422",
				DPad = "rbxassetid://138947904441816",
				DPadUp = "rbxassetid://132549581537060",
				DPadRight = "rbxassetid://115685744833525",
				DPadDown = "rbxassetid://115263268607261",
				DPadLeft = "rbxassetid://76285402510947",
				ButtonStart = "rbxassetid://116333248893357",
				ButtonSelect = "rbxassetid://116310445938306",
			},
			Bold = {
				ButtonA = "rbxassetid://96467920735443",
				ButtonB = "rbxassetid://102613657367560",
				ButtonX = "rbxassetid://88896022139772",
				ButtonY = "rbxassetid://102493363187439",
				ButtonL1 = "rbxassetid://112718216770609",
				ButtonR1 = "rbxassetid://119312994744930",
				ButtonL2 = "rbxassetid://92452705379877",
				ButtonR2 = "rbxassetid://134440721236316",
				Thumbstick1 = "rbxassetid://99114839824714",
				Thumbstick2 = "rbxassetid://114905075447204",
				ButtonL3 = "rbxassetid://111874801536579",
				ButtonR3 = "rbxassetid://76224142574023",
				DPad = "rbxassetid://86895616846244",
				DPadUp = "rbxassetid://80265840705266",
				DPadRight = "rbxassetid://70502146089986",
				DPadDown = "rbxassetid://117083828903556",
				DPadLeft = "rbxassetid://86450424323009",
				ButtonStart = "rbxassetid://90938917674225",
				ButtonSelect = "rbxassetid://73984496377714",
			},
			BoldWhite = {
				ButtonA = "rbxassetid://122907682080069",
				ButtonB = "rbxassetid://119960371807631",
				ButtonX = "rbxassetid://138755340786050",
				ButtonY = "rbxassetid://79104979668485",
				ButtonL1 = "rbxassetid://118021354927634",
				ButtonR1 = "rbxassetid://105497842621455",
				ButtonL2 = "rbxassetid://135340586417513",
				ButtonR2 = "rbxassetid://113533801369843",
				Thumbstick1 = "rbxassetid://70906340522780",
				Thumbstick2 = "rbxassetid://85679441559601",
				ButtonL3 = "rbxassetid://112872598035443",
				ButtonR3 = "rbxassetid://85209120846267",
				DPad = "rbxassetid://134156255132290",
				DPadUp = "rbxassetid://81924513371320",
				DPadRight = "rbxassetid://125171981236291",
				DPadDown = "rbxassetid://99480206679924",
				DPadLeft = "rbxassetid://91769036669485",
				ButtonStart = "rbxassetid://92061183526373",
				ButtonSelect = "rbxassetid://115607780500811",
			},
			WhiteBorder = {
				ButtonB = "rbxassetid://135551774573894",
			},
		},
	},
}

return _settings
