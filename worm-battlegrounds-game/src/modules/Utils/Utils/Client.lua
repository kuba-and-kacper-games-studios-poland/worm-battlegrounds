--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ButtonPress = require(_scripts:FindFirstChild("ButtonPress")) --- @type Utils_ButtonPress
local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility
local ImageSliceScaler = require(_scripts:FindFirstChild("ImageSliceScaler")) --- @type Utils_ImageSliceScaler
local MarketplaceCache = require(_scripts:FindFirstChild("MarketplaceCache")) --- @type Utils_MarketplaceCache
local UIStrokeScaler = require(_scripts:FindFirstChild("UIStrokeScaler")) --- @type Utils_UIStrokeScaler
local UIStrokeScaler_Billboard = require(_scripts:FindFirstChild("UIStrokeScaler_Billboard")) --- @type Utils_UIStrokeScaler_Billboard

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
	------ INITIALIZATION ------
	----------------------------

	--[[ Scalers ]]

	UIStrokeScaler.Init()
	UIStrokeScaler_Billboard.Init()
	ImageSliceScaler.Init()

	--[[ Marketplace ]]

	MarketplaceCache.Init()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Component

	--[[ Button ]]

	I.Component.Register("Utils_ButtonKey", _components.Button.ButtonKey)
	I.Component.Register("Utils_ButtonScale", _components.Button.ButtonScale)
	I.Component.Register("Utils_ButtonSound", _components.Button.ButtonSound)
	I.Component.Register("Utils_ButtonTransform", _components.Button.ButtonTransform)

	--[[ Marketplace ]]

	I.Component.RegisterOnLoaded("Utils_PriceTag", _components.Marketplace.PriceTag)
	I.Component.RegisterOnLoaded("Utils_VisibleOnMarketplace", _components.Marketplace.VisibleOnMarketplace)

	--[[ Platform ]]

	I.Component.Register("Utils_HideOnPlatform", _components.Platform.HideOnPlatform)
	I.Component.Register("Utils_PlatformScale", _components.Platform.PlatformScale)
	I.Component.Register("Utils_PlatformSize", _components.Platform.PlatformSize)

	--[[ Scaler ]]

	-- Utils_UIStroke, Utils_UIStroke-Billboard and Utils_SlicedImage run in the scaler scripts
	I.Component.Register("Utils_UIGrid", _components.Scaler.UIGrid)
	I.Component.Register("Utils_UITextSizeConstraint", _components.Scaler.UITextSizeConstraint)

	--[[ Visual ]]

	I.Component.Register("Utils_LetterText", _components.Visual.LetterText)
	I.Component.Register("Utils_Motion", _components.Visual.Motion)
	I.Component.Register("Utils_TextShine", _components.Visual.TextShine)
	I.Component.Register("Utils_UIGradientMove", _components.Visual.UIGradientMove)
	I.Component.Register("Utils_UIHover", _components.Visual.UIHover)
	I.Component.Register("Utils_UIShake", _components.Visual.UIShake)
	I.Component.Register("Utils_UISpin", _components.Visual.UISpin)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Utils = {

		--[[ Control ]]

		PressKey = ButtonPress.PressKey,
		PlayPress = ButtonPress.PlayPress,
		ConnectPress = ButtonPress.Connect,

		--[[ Methods ]]

		IsGuiShown = GuiVisibility.IsShown,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
