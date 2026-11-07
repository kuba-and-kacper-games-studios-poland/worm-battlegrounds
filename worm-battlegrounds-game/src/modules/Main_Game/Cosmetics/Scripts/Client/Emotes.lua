--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local worldFolder: Folder

-- Whether the lobby's emote row shows its emotes, or only the smiley and +
local rowOpen: boolean = true

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

--- @class Cosmetics_Client_Emotes
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local hud: ScreenGui = I.UserInterface.UI[_settings.MATCH_HUD_GUI_NAME]
	elems["Row"] = I.UserInterface.UI[_settings.LOADOUT_GUI_NAME]:FindFirstChild("U_Emotes", true) --- @type ScrollingFrame
	elems["Smiley"] = elems["Row"]:FindFirstChild("S_Smiley") --- @type Frame
	elems["EmoteButton"] = hud:FindFirstChild("U_EmoteButton", true) --- @type Frame
	elems["Wheel"] = hud:FindFirstChild("U_EmoteWheel", true) --- @type Frame
	elems["Party"] = I.UserInterface.UI[_settings.PARTY_GUI_NAME]:FindFirstChild("U_Members", true) --- @type ScrollingFrame
	prefabs["Emote"] = elems["Row"]:FindFirstChild("PREFAB | Emote") --- @type Frame
	prefabs["WheelEmote"] = elems["Wheel"]:FindFirstChild("PREFAB | WheelEmote") --- @type Frame
	worldFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Applying ]]

	elems["Wheel"].Visible = false

	--[[ Connections ]]

	I.Interact.OnPress(elems["Smiley"]:FindFirstChild("Button"), function()
		rowOpen = not rowOpen
		Module._refresh()
	end)
	I.Interact.OnPress(elems["EmoteButton"]:FindFirstChild("Button"), function()
		elems["Wheel"].Visible = not elems["Wheel"].Visible
	end)
	I.S.UserInputService.InputBegan:Connect(Module._onInput)
	elems["EmoteButton"]:GetPropertyChangedSignal("Visible"):Connect(function()
		if not elems["EmoteButton"].Visible then
			elems["Wheel"].Visible = false
		end
	end)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.Network.Fired("Cosmetics_EmotePlayed", Module._onEmotePlayed)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws the owned emotes twice: in the lobby's emote row (while it's open), and around the match's emote wheel.
]]
function Module._refresh()
	--[[ Clearing ]]

	for _index: number, holder: Instance in ipairs({ elems["Row"], elems["Wheel"] }) do
		for _childIndex: number, child: Instance in ipairs(holder:GetChildren()) do
			if child:IsA("Frame") and child.Name:sub(1, 6) == "Emote_" then
				child:Destroy()
			end
		end
	end

	--[[ Local Variables ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	local owned = {} --- @type { string }
	for itemId: string, _quantity: string in pairs(standard) do
		if I.G_Cosmetics.GetEmotes()[itemId] then
			table.insert(owned, itemId)
		end
	end
	table.sort(owned)

	--[[ Building ]]

	for index: number, emoteId: string in ipairs(owned) do
		local angle: number = math.rad(index / #owned * 360 - 90)
		local rowEmote: Frame = Module._makeEmote(prefabs["Emote"], emoteId)
		rowEmote.LayoutOrder = index
		rowEmote.Visible = rowOpen
		rowEmote.Parent = elems["Row"]
		local wheelEmote: Frame = Module._makeEmote(prefabs["WheelEmote"], emoteId)
		wheelEmote.Position = UDim2.fromScale(0.5 + math.cos(angle) * _settings.WHEEL_RADIUS, 0.5 + math.sin(angle) * _settings.WHEEL_RADIUS)
		wheelEmote.Visible = true
		wheelEmote.Parent = elems["Wheel"]
	end
end

--%%%%%%%%%%%%%%%%%%%% Make Emote

--[[
	Clones an emote card from a prefab, named after its emote, that plays it when pressed.
]]
--- @return Frame
function Module._makeEmote(prefab: Instance, emoteId: string)
	--[[ Data ]]

	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?

	--[[ Cloning ]]

	local card: Frame = prefab:Clone()
	card.Name = emoteId

	--[[ Texts ]]

	card:FindFirstChild("S_Icon", true).Image = if item then item.IconId else ""
	card:FindFirstChild("S_Name", true).Text = if item then item.Name else emoteId
	card:FindFirstChild("S_Info", true).Text = ""

	--[[ Connections ]]

	I.Interact.OnPress(card:FindFirstChild("Button"), function()
		elems["Wheel"].Visible = false
		I.Network.Fire("Cosmetics_PlayEmote", emoteId)
	end)

	--[[ Returning ]]

	return card
end

--%%%%%%%%%%%%%%%%%%%% On Input

--[[
	Closes the emote wheel when the player clicks or taps anywhere but a button (the world, the wheel's gaps).
]]
function Module._onInput(input: InputObject, gameProcessed: boolean)
	--[[ Checks ]]

	-- Check if the wheel is open and a button didn't take the press
	if not elems["Wheel"].Visible or gameProcessed then
		return
	end

	-- Check if it's a click or a tap
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	--[[ Closing ]]

	elems["Wheel"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% On Emote Played

--[[
	Shows a played emote's name over the player's snail in a match, or beside their name in the lobby's party list.
]]
function Module._onEmotePlayed(userId: number, emoteId: string)
	--[[ Data ]]

	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?
	local snails: Instance? = I.Dirs.UmeWorkspace:FindFirstChild("Snails")
	local snail: Instance? = snails and snails:FindFirstChild(`P_{userId}`)
	local member: Instance? = elems["Party"]:FindFirstChild(tostring(userId))
	if not item then
		return
	end

	--[[ Building ]]

	-- shortcut: a plain label stands in for the emote's animation and voice line; play AnimationId once they exist
	local label: TextLabel = I.Create("TextLabel")({
		Name = "Emote",
		Text = `{item.Name}!`,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 0,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})
	if snail and snail:FindFirstChild("Root") then
		local billboard: BillboardGui = I.Create("BillboardGui")({
			Name = `Emote_{userId}`,
			Adornee = snail:FindFirstChild("Root"),
			Size = UDim2.fromScale(6, 1.5),
			StudsOffset = Vector3.new(0, 5, 0),
			AlwaysOnTop = true,
			Parent = worldFolder,
		})
		label.Parent = billboard
		I.S.Debris:AddItem(billboard, _settings.EMOTE_SECONDS)
	elseif member then
		label.Size = UDim2.fromScale(0.4, 0.6)
		label.Position = UDim2.fromScale(0.58, 0.2)
		label.Parent = member
		I.S.Debris:AddItem(label, _settings.EMOTE_SECONDS)
	else
		label:Destroy()
	end
end

return Module
