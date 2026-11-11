--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Transition"

--- @type Transition_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Where the next teleport goes, as the server last said, and the card showing it
local destinationText: string? = nil
local destinationImage: string = ""
local card: ScreenGui? = nil

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

	I.Network.Fired("Transition_Destination", Module._onDestination)
	I.S.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui").ChildAdded:Connect(Module._onGuiAdded)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Checks ]]

	-- Check if the player came by teleport, with the card the arrival script slides off once this client started
	if not I.S.TeleportService:GetArrivingTeleportGui() then
		return
	end

	--[[ Playing ]]

	I.Sound.Play({ Name = "Teleport_In", SoundGroup = "UI" })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Destination

--[[
	Keeps where the next teleport goes, and writes it on the card when it already shows.
]]
function Module._onDestination(text: string, image: string)
	--[[ Saving ]]

	destinationText = text
	destinationImage = image

	--[[ Applying ]]

	if card then
		Module._fill(card)
		Module._handOver(card)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Gui Added

--[[
	Slides the teleport card over the screen with its whoosh (Teleport_Out) when a teleport clones it in, and hands
	Roblox a copy to show through the teleport, which the next server's arrival script takes over
	(`src/replicated_first/Transition`).
]]
function Module._onGuiAdded(gui: Instance)
	--[[ Checks ]]

	-- Skip every gui but the teleport card
	if gui.Name ~= _settings.GUI_NAME or not gui:IsA("ScreenGui") then
		return
	end

	--[[ Local Variables ]]

	local backdrop: Frame = gui:FindFirstChild("U_Backdrop")

	--[[ Applying ]]

	card = gui
	Module._fill(gui)
	gui.Destroying:Once(function()
		card = nil
	end)

	--[[ Teleport Gui ]]

	Module._handOver(gui)

	--[[ Animating ]]

	backdrop.Position = UDim2.fromScale(0.5, -0.5)
	local Wipe_TweenGoal = { Position = UDim2.fromScale(0.5, 0.5) }
	local Wipe_Tween: Tween = I.S.TweenService:Create(backdrop, _settings.WIPE_TWEENINFO, Wipe_TweenGoal)
	Wipe_Tween:Play()
	I.Sound.Play({ Name = "Teleport_Out", SoundGroup = "UI" })
end

--%%%%%%%%%%%%%%%%%%%% Hand Over

--[[
	Gives Roblox a copy of the card, fully on the screen, to show while it teleports and to hand to the next server.
]]
function Module._handOver(gui: ScreenGui)
	--[[ Building ]]

	local copy: ScreenGui = gui:Clone()
	local backdrop: Frame = copy:FindFirstChild("U_Backdrop")
	backdrop.Position = UDim2.fromScale(0.5, 0.5)

	--[[ Applying ]]

	I.S.TeleportService:SetTeleportGui(copy)
end

--%%%%%%%%%%%%%%%%%%%% Fill

--[[
	Writes the destination on a teleport card; without one it keeps the card's own text.
]]
function Module._fill(gui: ScreenGui)
	--[[ Elements ]]

	local text: TextLabel = gui:FindFirstChild("S_Text", true)
	local image: ImageLabel = gui:FindFirstChild("S_Image", true)

	--[[ Texts ]]

	if destinationText then
		text.Text = destinationText
	end

	--[[ Picture ]]

	image.Image = destinationImage
	image.Visible = destinationImage ~= ""
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
