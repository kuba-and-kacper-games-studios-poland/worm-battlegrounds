--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "UserInterface"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local StarterGui = I.S.StarterGui

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get UI Folder

--[[
    Finds or creates and returns folder for storing ScreenGuis.
]]
--- @return CanvasGroup
local function getUIFolder()
	local uiFolder: CanvasGroup = I.Dirs.UmeReplicated:FindFirstChild(_localName)

	if not uiFolder then
		uiFolder = I.Create("CanvasGroup")({
			Name = _localName,
			Parent = I.Dirs.UmeReplicated,
		})
	end

	return uiFolder
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
	------ INITIALIZATION ------
	----------------------------

	Module._moveFromStarterGui()
	Module._updateVisibility()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("UserInterface_ChangeVisibility")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Move From StarterGui

--[[
	Moves all instances from the `StarterGui` and saves them in `ReplicatedStorage`.
]]
function Module._moveFromStarterGui()
	local storagefolder: CanvasGroup = getUIFolder()
	for _, elem: Instance in ipairs(StarterGui:GetChildren()) do
		elem.Parent = storagefolder
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Visibility

--[[
	Hides all `ScreenGuis` inside the storage folder except those tagged with `UserInterface_PreventHiding`.
]]
function Module._updateVisibility()
	--%%%%%%%%%%%%%%%%%%%% Update Visibility

	--[[
		ScreenGui is always a leaf: apply visibility here. Only CanvasGroup recurse.
	]]
	local function updateVisibility(elem: Instance)
		--[[ ScreenGui ]]

		if elem:IsA("ScreenGui") then
			elem.Enabled = elem:HasTag("UserInterface_PreventHiding") == true
			return
		end

		--[[ CanvasGroup ]]

		local isContainer: boolean = elem:IsA("Folder") or elem:IsA("CanvasGroup")
		if isContainer then
			for _, loopElem: Instance in ipairs(elem:GetChildren()) do
				updateVisibility(loopElem)
			end

			return
		end
	end

	--[[ Updating ]]

	updateVisibility(getUIFolder())
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
