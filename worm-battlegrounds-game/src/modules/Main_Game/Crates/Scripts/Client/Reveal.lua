--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ State ]]

-- The last crate opened, to open it again
local lastCrate: string = ""
local lastCount: number = 1
local lastPayWith: string = "Coins"

-- Counts reveals, so a newer one stops an older one's shake
local revealId: number = 0

-- Opens a crate again
local openCrate: (crateId: string, count: number, payWith: string) -> ()

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

--- @class Crates_Client_Reveal
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

--- @param opener (crateId: string, count: number, payWith: string) -> ()
function Module.Start(opener)
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.OPEN_GUI_NAME]
	elems["Stage"] = moduleGui:FindFirstChild("U_Stage", true) --- @type Frame
	elems["Crate"] = elems["Stage"]:FindFirstChild("S_Crate", true) --- @type ImageLabel
	elems["Card"] = elems["Stage"]:FindFirstChild("S_Card", true) --- @type Frame
	elems["Cards"] = moduleGui:FindFirstChild("U_Cards", true) --- @type ScrollingFrame
	elems["OpenAgain"] = moduleGui:FindFirstChild("S_OpenAgain", true) --- @type Frame
	prefabs["ResultCard"] = elems["Cards"]:FindFirstChild("PREFAB | ResultCard") --- @type Frame
	openCrate = opener

	--[[ Connections ]]

	I.Interact.OnPress(elems["OpenAgain"]:FindFirstChild("Button"), function()
		openCrate(lastCrate, lastCount, lastPayWith)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Opens the reveal: the crate shakes, then opens on the one item it gave, or on the 10 cards of a 10-pack.
]]
--- @param results { Crates_Result }
function Module.Show(crateId: string, count: number, payWith: string, results)
	--[[ Data ]]

	local row = I.G_Crates.Get(crateId) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Saving ]]

	lastCrate = crateId
	lastCount = count
	lastPayWith = payWith
	revealId += 1
	local thisReveal: number = revealId

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Cards"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["ResultCard"] then
			child:Destroy()
		end
	end

	--[[ Applying ]]

	elems["Stage"].Visible = true
	elems["Cards"].Visible = false
	elems["Card"].Visible = false
	elems["Crate"].Visible = true
	elems["Crate"].Image = row.Picture
	elems["Crate"].Rotation = -_settings.SHAKE_DEGREES
	elems["OpenAgain"].Visible = payWith ~= "VipDaily" and not row.Hidden

	--[[ Opening ]]

	I.WidgetManager.Open(_settings.OPEN_GUI_NAME)

	--[[ Shaking ]]

	-- Four swings each way across SHAKE_SECONDS
	local Shake_TweenInfo: TweenInfo = TweenInfo.new(_settings.SHAKE_SECONDS / 8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true, 0)
	local Shake_TweenGoal = { Rotation = _settings.SHAKE_DEGREES }
	local Shake_Tween: Tween = I.S.TweenService:Create(elems["Crate"], Shake_TweenInfo, Shake_TweenGoal)
	Shake_Tween:Play()

	--[[ Revealing ]]

	task.delay(_settings.SHAKE_SECONDS, function()
		if thisReveal ~= revealId then
			return
		end
		elems["Crate"].Rotation = 0
		if count == 1 then
			elems["Crate"].Visible = false
			elems["Card"].Visible = true
			Module._fillCard(elems["Card"], results[1])
			return
		end
		elems["Stage"].Visible = false
		elems["Cards"].Visible = true
		--- @param result Crates_Result
		for index: number, result in ipairs(results) do
			local card: Frame = prefabs["ResultCard"]:Clone()
			card.Name = `Result{index}`
			card.LayoutOrder = index
			card.Visible = true
			Module._fillCard(card, result)
			card.Parent = elems["Cards"]
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Fill Card

--[[
	Writes one result on a card: the item's picture and name, its rarity and copies, the tile's look for that rarity
	(its frame, stage and light, which the gui kit's reward tile records), and the shiny badge when this copy made it
	shiny.
]]
--- @param result Crates_Result
function Module._fillCard(card: Frame, result)
	--[[ Data ]]

	local item = I.G_Inventory.Items[result.ItemId] --- @type Inventory_ItemData?
	if not item then
		return
	end

	--[[ Elements ]]

	local info: TextLabel = card:FindFirstChild("S_Info", true)
	local face: ImageLabel = card:FindFirstChild("Face", true)
	local rays: ImageLabel = card:FindFirstChild("Rays", true)
	local glow: ImageLabel = card:FindFirstChild("Glow", true)

	--[[ Texts ]]

	card:FindFirstChild("S_Icon", true).Image = item.IconId
	card:FindFirstChild("S_Name", true).Text = item.Name
	info.Text = `{item.Rarity} · {math.min(result.Copies, _settings.SHINY_COPIES)}/{_settings.SHINY_COPIES}`
	info.TextColor3 = I.Rarity.GetLook(item.Rarity).Base

	--[[ Rarity Look ]]

	face.Image = card:GetAttribute(`Kit_{item.Rarity}_Frame`)
	card:FindFirstChild("Stage", true).Image = card:GetAttribute(`Kit_{item.Rarity}_Stage`)
	rays.Visible = card:GetAttribute(`Kit_{item.Rarity}_Glow`)
	glow.Visible = rays.Visible
	rays.ImageColor3 = card:GetAttribute(`Kit_{item.Rarity}_GlowColor`)
	glow.ImageColor3 = rays.ImageColor3

	--[[ Visibility ]]

	card:FindFirstChild("S_Shiny", true).Visible = result.JustShiny
end

return Module
