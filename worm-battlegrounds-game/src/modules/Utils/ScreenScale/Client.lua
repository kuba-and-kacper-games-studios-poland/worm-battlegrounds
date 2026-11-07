--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "ScreenScale"

--- @type ScreenScale_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Every S_ScreenScale in the game's guis
local scales = {} --- @type { UIScale }

-- The world labels sized with the screen (snail tags, drop markers, damage numbers), each with its S_ScreenScale
local billboards = {} --- @type { [BillboardGui]: UIScale }

-- The screen's scale, set on every S_ScreenScale times its device scale
local screenScale: number = 1

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.ScreenScale = {

		--[[ Control ]]

		AddBillboard = Module.AddBillboard,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	for _index: number, guiName: string in ipairs(_settings.GUIS) do
		local gui: ScreenGui? = I.UserInterface.UI[guiName]
		if not gui then
			continue
		end
		for _index2: number, descendant: Instance in ipairs(gui:GetDescendants()) do
			if descendant.Name == "S_ScreenScale" and descendant:IsA("UIScale") then
				table.insert(scales, descendant)

				-- Utils_PlatformScale sets its device scale straight on the UIScale: put the screen's back on top
				descendant:GetPropertyChangedSignal("Scale"):Connect(function()
					Module._fitScale(descendant)
				end)
			end
		end
	end

	Module._applyScale()
	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Module._applyScale)
	I.Topic.Subscribe("Platform_Changed", Module._applyScale)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Billboard

--[[
	**CLIENT** |
	Sizes a world label with the screen until it's destroyed: a BillboardGui whose root is laid out at its design size
	with an S_ScreenScale, as the game's SnailTag, DropMarker and DamagePop are.
]]
function Module.AddBillboard(billboard: BillboardGui)
	--[[ Saving ]]

	billboards[billboard] = billboard:FindFirstChild("S_ScreenScale", true)

	--[[ Applying ]]

	Module._fitBillboard(billboard, billboards[billboard])

	--[[ Connections ]]

	billboard.Destroying:Once(function()
		billboards[billboard] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%% Apply Scale

--[[
	Scales every panel to the screen: its height over the design height (or its width over the design width on a
	narrower screen), bigger on short Mobile screens.
]]
function Module._applyScale()
	--[[ Local Variables ]]

	local height: number = I.Env.Camera.ViewportSize.Y
	local width: number = I.Env.Camera.ViewportSize.X

	-- A screen narrower than the layout (4:3, 5:4, a tablet) scales by its width, so side-by-side panels still fit
	screenScale = math.min(height / _settings.DESIGN_HEIGHT, width / _settings.DESIGN_WIDTH)

	-- Boost short touch screens; anything else never shrinks below the floor
	if I.Platform.Current == "Mobile" and height < _settings.SMALL_SCREEN then
		screenScale *= _settings.MOBILE_BOOST
	elseif I.Platform.Current ~= "Mobile" then
		screenScale = math.max(screenScale, _settings.MIN_SCALE)
	end

	--[[ Applying ]]

	for _index: number, uiScale: UIScale in ipairs(scales) do
		Module._fitScale(uiScale)
	end
	for billboard: BillboardGui, uiScale: UIScale in pairs(billboards) do
		Module._fitBillboard(billboard, uiScale)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fit Scale

--[[
	Sets one panel's scale: the screen's times its device scale, which Utils_PlatformScale keeps in the UIScale's
	Utils_BaseScale attribute (1 without the tag).
]]
function Module._fitScale(uiScale: UIScale)
	--[[ Local Variables ]]

	local scale: number = screenScale * (uiScale:GetAttribute(_settings.BASE_SCALE_ATTRIBUTE) or 1)

	--[[ Applying ]]

	-- Skip an unchanged scale, so setting it doesn't fire this again
	if math.abs(uiScale.Scale - scale) > 1e-4 then
		uiScale.Scale = scale
	end
end

--%%%%%%%%%%%%%%%%%%%% Fit Billboard

--[[
	Sets one world label to the screen's scale, with no device scale (it stands over the world, not on a panel), and
	its billboard to its root's design size times it.
]]
function Module._fitBillboard(billboard: BillboardGui, uiScale: UIScale)
	--[[ Local Variables ]]

	local root: GuiObject = uiScale.Parent

	--[[ Applying ]]

	uiScale.Scale = screenScale
	billboard.Size = UDim2.fromOffset(root.Size.X.Offset * screenScale, root.Size.Y.Offset * screenScale)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
