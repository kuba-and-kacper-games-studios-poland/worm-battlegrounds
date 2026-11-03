--- @type Lighting_LightingProperties
local _data = {
	["Lighting"] = {

		--[[ Appearance ]]

		Ambient = "Color3",
		Brightness = "number",
		ColorShift_Bottom = "Color3",
		ColorShift_Top = "Color3",
		EnvironmentDiffuseScale = "number",
		EnvironmentSpecularScale = "number",
		GlobalShadows = "boolean",
		OutdoorAmbient = "Color3",
		ShadowSoftness = "number",

		--[[ Data ]]

		ClockTime = "number",
		GeographicLatitude = "number",

		--[[ Exposure ]]

		ExposureCompensation = "number",

		--[[ Fog ]]

		FogColor = "Color3",
		FogEnd = "number",
		FogStart = "number",
	},
	["Atmosphere"] = {

		--[[ Appearance ]]

		Density = "number",
		Offset = "number",

		--[[ State ]]

		Color = "Color3",
		Decay = "Color3",
		Glare = "number",
		Haze = "number",
	},
	["Sky"] = {

		--[[ Appearance ]]

		CelestialBodiesShown = "boolean",
		StarCount = "number",

		--[[ Sun ]]

		SunAngularSize = "number",
		SunTextureId = "string",

		--[[ Moon ]]

		MoonAngularSize = "number",
		MoonTextureId = "string",

		--[[ Skybox ]]

		SkyboxOrientation = "Vector3",

		SkyboxUp = "string",
		SkyboxDn = "string",

		SkyboxBk = "string",
		SkyboxFt = "string",
		SkyboxLf = "string",
		SkyboxRt = "string",
	},
	["BloomEffect"] = {

		--[[ State ]]

		Enabled = "boolean",
		Intensity = "number",
		Size = "number",
		Threshold = "number",
	},
	["BlurEffect"] = {

		--[[ State ]]

		Enabled = "boolean",
		Size = "number",
	},
	["ColorCorrectionEffect"] = {

		--[[ State ]]

		Enabled = "boolean",
		Brightness = "number",
		Contrast = "number",
		Saturation = "number",
		TintColor = "Color3",
	},
	["DepthOfFieldEffect"] = {

		--[[ State ]]

		Enabled = "boolean",
		FarIntensity = "number",
		FocusDistance = "number",
		InFocusRadius = "number",
		NearIntensity = "number",
	},
	["SunRaysEffect"] = {

		--[[ State ]]

		Enabled = "boolean",
		Intensity = "number",
		Spread = "number",
	},
}
return _data
