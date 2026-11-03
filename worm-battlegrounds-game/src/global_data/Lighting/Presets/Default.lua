--[[
	Preset that is overwritten by the current project lighting settings.
]]
--- @type Lighting_LightingProperties
local _data = {
	["Lighting"] = {

		--[[ Appearance ]]

		Ambient = Color3.fromRGB(70, 70, 70),
		Brightness = 3,
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(0, 0, 0),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		GlobalShadows = true,
		OutdoorAmbient = Color3.fromRGB(70, 70, 70),

		--[[ Data ]]

		ClockTime = 14.5,
		GeographicLatitude = 0,

		--[[ Exposure ]]

		ExposureCompensation = 0,
	},
	["Atmosphere"] = {

		--[[ Appearance ]]

		Density = 0.3,
		Offset = 0.25,

		--[[ State ]]

		Color = Color3.fromRGB(199, 199, 199),
		Decay = Color3.fromRGB(106, 112, 125),
		Glare = 0,
		Haze = 0,
	},
	["Sky"] = {

		--[[ Appearance ]]

		CelestialBodiesShown = true,
		StarCount = 3000,

		--[[ Sun ]]

		SunAngularSize = 11,
		SunTextureId = "rbxassetid://6196665106",

		--[[ Moon ]]

		MoonAngularSize = 11,
		MoonTextureId = "rbxassetid://6444320592",

		--[[ Skybox ]]

		SkyboxOrientation = Vector3.zero,

		SkyboxUp = "rbxassetid://6412503613",
		SkyboxDn = "rbxassetid://6444884785",

		SkyboxBk = "rbxassetid://6444884337",
		SkyboxFt = "rbxassetid://6444884337",
		SkyboxLf = "rbxassetid://6444884337",
		SkyboxRt = "rbxassetid://6444884337",
	},
	["BloomEffect"] = {

		--[[ State ]]

		Enabled = true,
		Intensity = 1,
		Size = 24,
		Threshold = 2,
	},
	["BlurEffect"] = {

		--[[ State ]]

		Enabled = false,
		Size = 0,
	},
	["ColorCorrectionEffect"] = {

		--[[ State ]]

		Enabled = false,
		Brightness = 0,
		Contrast = 0,
		Saturation = 0,
		TintColor = Color3.fromRGB(255, 255, 255),
	},
	["DepthOfFieldEffect"] = {

		--[[ State ]]

		Enabled = false,
		FarIntensity = 0.1,
		FocusDistance = 0.05,
		InFocusRadius = 30,
		NearIntensity = 0.75,
	},
	["SunRaysEffect"] = {

		--[[ State ]]

		Enabled = true,
		Intensity = 0.01,
		Spread = 0.1,
	},
}
return _data
