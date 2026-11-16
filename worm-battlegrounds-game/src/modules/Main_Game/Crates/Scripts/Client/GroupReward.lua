--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Panel = require(script.Parent:FindFirstChild("Panel")) --- @type Crates_Client_Panel

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local cratesRep: Folder?

--[[ State ]]

-- Whether the crates screen shows, which the badge sits on
local cratesOpen: boolean = false

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

--- @class Crates_Client_GroupReward
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GROUP_GUI_NAME]
	elems["Button"] = moduleGui:FindFirstChild("U_Button") --- @type ImageButton
	elems["Dialog"] = moduleGui:FindFirstChild("U_Dialog") --- @type Frame
	elems["CrateView"] = elems["Dialog"]:FindFirstChild("S_CrateView", true) --- @type ViewportFrame
	elems["JoinButton"] = elems["Dialog"]:FindFirstChild("S_JoinButton", true) --- @type ImageButton
	elems["Joined"] = elems["Dialog"]:FindFirstChild("S_Joined", true) --- @type TextLabel
	elems["ClaimButton"] = elems["Dialog"]:FindFirstChild("S_ClaimButton", true) --- @type ImageButton
	elems["CloseButton"] = elems["Dialog"]:FindFirstChild("S_CloseButton", true) --- @type ImageButton

	--[[ Building ]]

	Module._buildCrate()

	--[[ Connections ]]

	I.Interact.OnPress(elems["Button"], function()
		elems["Dialog"].Visible = true
		Module._refresh()
	end)
	I.Interact.OnPress(elems["CloseButton"], function()
		elems["Dialog"].Visible = false
	end)
	I.Interact.OnPress(elems["JoinButton"], function()
		I.Group.PromptJoin(_settings.GROUP_NAME)
		Module._refresh()
	end)
	I.Interact.OnPress(elems["ClaimButton"], Module._onClaim)
	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		Module._onWidget(widgetName, true)
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		Module._onWidget(widgetName, false)
	end)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Crate

--[[
	Stands the group's crate (its 3D model) in the dialog's viewport, turned a little toward the camera.
]]
function Module._buildCrate()
	--[[ Data ]]

	local row = I.G_Crates.GetAll()[_settings.GROUP_CRATE] --- @type Crates_CrateData
	local model: Model = I.Dirs.Assets:FindFirstChild("Crates"):FindFirstChild(row.Model):Clone()

	--[[ Building ]]

	local camera: Camera = I.Create("Camera")({ FieldOfView = 30, Parent = elems["CrateView"] })
	local box: CFrame
	local size: Vector3
	model:PivotTo(CFrame.Angles(0, math.rad(-25), 0))
	model.Parent = elems["CrateView"]
	box, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(box.Position + Vector3.new(0, size.Y * 0.35, size.Magnitude * 2.1), box.Position)
	elems["CrateView"].CurrentCamera = camera
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the Crates folder (whether the group's crate was opened) and the player's membership of the group.
]]
function Module._connectReplicator()
	--[[ Data ]]

	cratesRep = I.Replicator.GetFolder(_localName)

	--[[ Connections ]]

	if cratesRep then
		cratesRep.AttributeChanged:Connect(Module._refresh)
	end
	local changed: RBXScriptSignal? = I.Group.GetChangedSignal(_settings.GROUP_NAME)
	if changed then
		changed:Connect(Module._refresh)
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Widget

--[[
	Notes whether the crates screen shows, so the badge shows on it.
]]
function Module._onWidget(widgetName: string, opened: boolean)
	--[[ Checks ]]

	-- Check if it's the crates screen
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Refreshing ]]

	cratesOpen = opened
	if not opened then
		elems["Dialog"].Visible = false
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the gui on the crates screen while the group's crate is unclaimed; in the dialog, JOIN or JOINED by the
	player's membership, and CLAIM lit (the design's green) only once they're in the group.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local claimed: boolean = cratesRep == nil or cratesRep:GetAttribute("GroupCrateClaimed") ~= false
	local member: boolean = I.Group.IsMember(_settings.GROUP_NAME) == true
	local claim: ImageButton = elems["ClaimButton"]

	--[[ Applying ]]

	moduleGui.Enabled = cratesOpen and not claimed
	elems["JoinButton"].Visible = not member
	elems["Joined"].Visible = member
	claim:FindFirstChild("Main", true).ImageColor3 = claim:GetAttribute(if member then "Look_MainColor" else "Look_LockedMainColor")
	claim:FindFirstChild("Stroke", true).ImageColor3 = claim:GetAttribute(if member then "Look_StrokeColor" else "Look_LockedStrokeColor")
end

--%%%%%%%%%%%%%%%%%%%% On Claim

--[[
	CLAIM: once the player is in the group, the dialog closes and the crate opens on the crates screen like a bought
	one; before that, a message asks them to join first.
]]
function Module._onClaim()
	--[[ Checks ]]

	-- Check if the player is in the group
	if I.Group.IsMember(_settings.GROUP_NAME) ~= true then
		I.WidgetManager.ShowMessage(_settings.GROUP_JOIN_FIRST)
		return
	end

	--[[ Opening ]]

	elems["Dialog"].Visible = false
	Panel.ShowTab(_settings.GROUP_CRATE)
	Panel.Open(_settings.GROUP_CRATE, 1, "GroupReward")
end

return Module
