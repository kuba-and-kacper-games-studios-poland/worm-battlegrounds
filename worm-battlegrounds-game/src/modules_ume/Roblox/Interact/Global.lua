--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type { [string]: Interact_Mapping }
local allMappings = {}
for _index: number, mappingsModule: Instance in ipairs(I.Dirs.GlobalData.Interact.Mappings:GetChildren()) do
	if mappingsModule:IsA("ModuleScript") then
		allMappings[mappingsModule.Name] = require(mappingsModule)
	end
end

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

	I.Interact = {

		--[[ Control ]]

		CreatePrompt = Module.CreatePrompt,

		--[[ Methods ]]

		GetMappings = Module.GetMappings,
		GetGamepadImage = Module.GetGamepadImage,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Prompt

--[[
	Returns a tagged `ProximityPrompt` with the given style, drawn with the given input mappings (Default when none).
]]
--- @return ProximityPrompt
function Module.CreatePrompt(style: string, mappings: string?, activationDistance: number?, actionText: string?, objectText: string?)
	--[[ Creating Prompt ]]

	local prompt: ProximityPrompt = Instance.new("ProximityPrompt")
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = tonumber(activationDistance) or 10

	--[[ Prompt Style ]]

	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt:SetAttribute("Interact_Style", `{style}`)
	prompt:SetAttribute("Interact_Mappings", mappings or "")
	prompt:AddTag("Interact_Prompt")

	--[[ Text ]]

	prompt.ActionText = `{actionText or ""}`
	prompt.ObjectText = `{objectText or ""}`

	--[[ Returning ]]

	return prompt
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Mappings

--[[
	Returns the input mappings with that name, or Default when the name is empty.
]]
--- @return Interact_Mapping
function Module.GetMappings(mappingsName: string?)
	--[[ Checks ]]

	-- Check if a name is given
	if not mappingsName or mappingsName == "" then
		return allMappings["Default"]
	end

	-- Check if the mappings exist
	if not allMappings[mappingsName] then
		warn(`[{_localName}::{script.Name}]: Mappings ({mappingsName}) are missing - using Default.`)
		return allMappings["Default"]
	end

	--[[ Returning ]]

	return allMappings[mappingsName]
end

--%%%%%%%%%%%%%%%%%%%% Get Gamepad Image

--[[
	Returns a gamepad button's image from the mappings: on a PlayStation pad its PlayStation image when the mappings
	have one, otherwise its Xbox (or shared) image.
]]
--- @param mappings Interact_Mapping
--- @return string?
function Module.GetGamepadImage(mappings, keyCode: Enum.KeyCode)
	--[[ Local Variables ]]

	local playStationImage: string? = nil

	-- PlayStation pads show their own image when the mappings have one
	if Module._isPlayStationPad() then
		playStationImage = mappings.PlayStationButtonImage[keyCode]
	end

	--[[ Returning ]]

	return playStationImage or mappings.GamepadButtonImage[keyCode]
end

--%%%%%%%%%%%%%%%%%%%% Is PlayStation Pad

--[[
	Returns whether the player's gamepad is a PlayStation one: Roblox then names ButtonA "ButtonCross".
]]
--- @return boolean
function Module._isPlayStationPad()
	return I.S.UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
