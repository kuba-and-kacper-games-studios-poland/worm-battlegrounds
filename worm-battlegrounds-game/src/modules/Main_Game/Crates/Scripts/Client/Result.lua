--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Reel = require(script.Parent:FindFirstChild("Reel")) --- @type Crates_Client_Reel
local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Crates_Client_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ State ]]

-- The result's loop (rays, disk, a floating card) with its moods, and the black hole disk's own size
local resultLoop: RBXScriptConnection? = nil
local floating: boolean = false
local rainbow: boolean = false
local homeDisk: UDim2 = UDim2.new()

-- The big card's place (the result's S_CardSlot), and the seconds before its words come in, by entrance
local CARD_HOME: UDim2 = UDim2.fromScale(0.5, 0.39)

--- @type { [string]: number }
local TEXT_DELAYS = { Fly = 0.42, Pop = 0.6, Squash = 0.7, Ghost = 1.1, Float = 1.3 }

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

--- @class Crates_Client_Result
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Result"] = moduleGui:FindFirstChild("U_Result", true) --- @type Frame
	elems["Glow"] = elems["Result"]:FindFirstChild("S_Glow", true) --- @type ImageLabel
	elems["Rays"] = elems["Result"]:FindFirstChild("S_Rays", true) --- @type ImageLabel
	elems["Disk"] = elems["Result"]:FindFirstChild("S_Disk", true) --- @type ImageLabel
	elems["Core"] = elems["Result"]:FindFirstChild("S_Core", true) --- @type ImageLabel
	elems["Single"] = elems["Result"]:FindFirstChild("U_Single", true) --- @type Frame
	elems["CardSlot"] = elems["Single"]:FindFirstChild("S_CardSlot", true) --- @type CanvasGroup
	elems["Cards"] = elems["Result"]:FindFirstChild("U_Cards", true) --- @type Frame
	elems["Summary"] = elems["Result"]:FindFirstChild("U_Summary", true) --- @type Frame
	prefabs["ResultInfo"] = elems["Cards"]:FindFirstChild("PREFAB | ResultInfo") --- @type Frame
	prefabs["SummaryChip"] = elems["Summary"]:FindFirstChild("PREFAB | SummaryChip") --- @type Frame
	prefabs["RaritySection"] = moduleGui:FindFirstChild("PREFAB | RaritySection", true) --- @type Frame
	homeDisk = elems["Disk"].Size
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Big

--[[
	Shows the big card for a result, coming in one of its entrances (flying out of the reel from a card, popping,
	squashing, fading in like a ghost, or floating up), in its rarity's glow and rays, then its rarity bar, name and
	copies to shiny; a mood keeps the rays turning through the rainbow or the card floating.
]]
--- @param result Crates_Result
function Module.ShowBig(result, entrance: string, from: Frame?, mood: string?)
	--[[ Data ]]

	local item = I.G_Inventory.Items[result.ItemId] --- @type Inventory_ItemData

	--[[ Local Variables ]]

	local single: Frame = elems["Single"]
	local slot: CanvasGroup = elems["CardSlot"]
	local scale: UIScale = slot:FindFirstChild("S_CardScale")
	local color: Color3 = Reel.GetRarityColor(item.Rarity)
	local shown: number = math.min(result.Copies, _settings.SHINY_COPIES)
	local after: number = TEXT_DELAYS[entrance] or 0.6

	--[[ Card ]]

	for _index: number, child: Instance in ipairs(slot:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local card: Frame = Reel.MakeCard(slot, result.ItemId, false, false, UDim2.fromScale(1, 1))
	card:FindFirstChild("S_New", true).Visible = result.Copies == 1
	single.Visible = true

	--[[ Words ]]

	Module._drawRarityBar(single:FindFirstChild("S_RarityBar", true), item.Rarity)
	single:FindFirstChild("S_Name", true).Text = item.Name
	local label: TextLabel = single:FindFirstChild("S_Label", true)
	label.Text = if result.JustShiny then "SHINY!" else `{shown} / {_settings.SHINY_COPIES} copies to shiny`
	label.TextColor3 = if result.JustShiny then Color3.fromRGB(255, 224, 102) else Color3.fromRGB(230, 232, 239)
	local fill: Frame = single:FindFirstChild("S_Fill", true)
	fill.Size = UDim2.fromScale(0, 1)

	--[[ Light ]]

	elems["Glow"].ImageColor3 = color
	elems["Rays"].ImageColor3 = color
	local Light_TweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Glow_TweenGoal = { ImageTransparency = 0.15 }
	local Glow_Tween: Tween = I.S.TweenService:Create(elems["Glow"], Light_TweenInfo, Glow_TweenGoal)
	Glow_Tween:Play()
	local Rays_TweenGoal = { ImageTransparency = _settings.REVEAL_RAYS[item.Rarity] or 1 }
	local Rays_Tween: Tween = I.S.TweenService:Create(elems["Rays"], Light_TweenInfo, Rays_TweenGoal)
	Rays_Tween:Play()
	floating = mood == "Float"
	rainbow = mood == "Rainbow"
	Module._startResultLoop()

	--[[ Entrance ]]

	slot.Position = CARD_HOME
	slot.GroupTransparency = 0
	scale.Scale = 1
	local Enter_TweenInfo: TweenInfo = TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Enter_TweenGoal = { Scale = 1 } --- @type { [string]: any }
	local target: Instance = scale
	if entrance == "Fly" and from then
		local slotCentre: Vector2 = slot.AbsolutePosition + slot.AbsoluteSize / 2
		local fromCentre: Vector2 = from.AbsolutePosition + from.AbsoluteSize / 2
		slot.Position = CARD_HOME + UDim2.fromOffset(fromCentre.X - slotCentre.X, fromCentre.Y - slotCentre.Y)
		scale.Scale = from.AbsoluteSize.X / math.max(1, slot.AbsoluteSize.X)
		local Fly_TweenGoal = { Position = CARD_HOME }
		local Fly_Tween: Tween = I.S.TweenService:Create(slot, Enter_TweenInfo, Fly_TweenGoal)
		Fly_Tween:Play()
	elseif entrance == "Squash" then
		scale.Scale = 0.2
		Enter_TweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	elseif entrance == "Ghost" then
		slot.GroupTransparency = 1
		scale.Scale = 0.96
		Enter_TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		Enter_TweenGoal = { GroupTransparency = 0 }
		target = slot
		local Ghost_TweenGoal = { Scale = 1 }
		local Ghost_Tween: Tween = I.S.TweenService:Create(scale, Enter_TweenInfo, Ghost_TweenGoal)
		Ghost_Tween:Play()
	elseif entrance == "Float" then
		slot.Position = CARD_HOME + UDim2.fromScale(0, 0.3)
		slot.GroupTransparency = 1
		Enter_TweenInfo = TweenInfo.new(1.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Enter_TweenGoal = { Position = CARD_HOME, GroupTransparency = 0 }
		target = slot
	else
		scale.Scale = 0.35
	end
	local Enter_Tween: Tween = I.S.TweenService:Create(target, Enter_TweenInfo, Enter_TweenGoal)
	Enter_Tween:Play()

	--[[ Words In ]]

	for place: number, name: string in ipairs({ "S_RowPop", "S_NamePop", "S_CopiesPop" }) do
		local pop: UIScale = single:FindFirstChild(name, true)
		pop.Scale = 0
		local Words_TweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, after + (place - 1) * 0.12)
		local Words_TweenGoal = { Scale = 1 }
		local Words_Tween: Tween = I.S.TweenService:Create(pop, Words_TweenInfo, Words_TweenGoal)
		Words_Tween:Play()
	end
	local Fill_TweenInfo: TweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, after + 0.45)
	local Fill_TweenGoal = { Size = UDim2.fromScale(shown / _settings.SHINY_COPIES, 1) }
	local Fill_Tween: Tween = I.S.TweenService:Create(fill, Fill_TweenInfo, Fill_TweenGoal)
	Fill_Tween:Play()
	if result.JustShiny then
		task.delay(after + 0.5, function()
			I.Sound.Play({ Name = "Reveal_Shiny", SoundGroup = "SFX" })
			Effects.Burst("Stars", Module.GetCardPoint(), 40, Color3.fromRGB(255, 224, 102))
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Name Card

--[[
	Names a pack's card: its rarity bar and name under it, NEW when it's the first copy, a little pop and burst, and
	for the best one the BEST ribbon, its rarity's reveal sound and a bigger burst.
]]
--- @param result Crates_Result
function Module.NameCard(card: Frame, result, slot: Vector2, cardSize: Vector2, isBest: boolean, count: number)
	--[[ Data ]]

	local item = I.G_Inventory.Items[result.ItemId] --- @type Inventory_ItemData

	--[[ Cloning ]]

	local info: Frame = prefabs["ResultInfo"]:Clone()
	info.Name = "Info"
	info.Size = UDim2.fromOffset(cardSize.X, cardSize.X * 0.3)
	info.Position = UDim2.fromOffset(slot.X, slot.Y + cardSize.Y / 2 + cardSize.Y * 0.05)
	info.Visible = true

	--[[ Applying ]]

	Module._drawRarityBar(info:FindFirstChild("S_RarityBar"), item.Rarity)
	info:FindFirstChild("S_Name", true).Text = item.Name
	card:FindFirstChild("S_New", true).Visible = result.Copies == 1
	card:FindFirstChild("S_Best", true).Visible = isBest
	info.Parent = elems["Cards"]

	--[[ Popping ]]

	local size: UDim2 = UDim2.fromOffset(cardSize.X, cardSize.Y)
	card.Size = UDim2.fromOffset(cardSize.X * 1.12, cardSize.Y * 1.12)
	local Pop_TweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Pop_TweenGoal = { Size = size }
	local Pop_Tween: Tween = I.S.TweenService:Create(card, Pop_TweenInfo, Pop_TweenGoal)
	Pop_Tween:Play()
	local point: Vector2 = elems["Cards"].AbsolutePosition + slot
	local color: Color3 = Reel.GetRarityColor(item.Rarity)
	local trio: boolean = count <= 3
	if isBest then
		I.Sound.Play({ Name = `Reveal_{item.Rarity}`, SoundGroup = "SFX" })
		Effects.Rarity(item.Rarity, point, color, if trio then 1 else 0.6)
	else
		I.Sound.Play({
			Name = if trio then `Reveal_{item.Rarity}` else "Card_Flip",
			SoundGroup = "SFX",
			Volume = if trio then 0.7 else 0.75,
			PitchMin = if trio then 1 else 0.95,
			PitchMax = if trio then 1 else 1.08,
		})
		Effects.Rarity(item.Rarity, point, color, if trio then 0.55 else 0.32)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Summary

--[[
	The pack's summary under its cards: how many of each rarity (rarest first), and how many are new.
]]
--- @param results { Crates_Result }
function Module.ShowSummary(results)
	--[[ Local Variables ]]

	local counts = {} --- @type { [string]: number }
	local new: number = 0
	--- @param result Crates_Result
	for _index: number, result in ipairs(results) do
		local rarity: string = I.G_Inventory.Items[result.ItemId].Rarity
		counts[rarity] = (counts[rarity] or 0) + 1
		new += if result.Copies == 1 then 1 else 0
	end
	local rarities = {} --- @type { string }
	for rarity: string, _count: number in pairs(counts) do
		table.insert(rarities, rarity)
	end
	table.sort(rarities, function(a: string, b: string): boolean
		return I.Rarity.GetRarityIndex(a) > I.Rarity.GetRarityIndex(b)
	end)

	--[[ Building ]]

	for place: number, rarity: string in ipairs(rarities) do
		local chip: Frame = prefabs["SummaryChip"]:Clone()
		chip.Name = "Chip"
		chip.LayoutOrder = place
		chip.Visible = true
		chip:FindFirstChild("S_Swatch", true).BackgroundColor3 = Reel.GetRarityColor(rarity)
		chip:FindFirstChild("S_Text", true).Text = `{counts[rarity]} {rarity}`
		chip.Parent = elems["Summary"]
	end
	if new > 0 then
		local chip: Frame = prefabs["SummaryChip"]:Clone()
		chip.Name = "Chip"
		chip.LayoutOrder = #rarities + 1
		chip.Visible = true
		chip.BackgroundColor3 = Color3.fromRGB(255, 77, 77)
		chip:FindFirstChild("S_Swatch", true).Visible = false
		chip:FindFirstChild("S_Text", true).Text = `{new} new`
		chip.Parent = elems["Summary"]
	end
	elems["Summary"].Visible = true
end

--%%%%%%%%%%%%%%%%%%%% Clear Big

--[[
	Takes the big card, its light, the black hole's disk and every effect off the screen.
]]
function Module.ClearBig()
	--[[ Clearing ]]

	Effects.Clear()
	elems["Single"].Visible = false
	elems["Glow"].ImageTransparency = 1
	elems["Rays"].ImageTransparency = 1
	elems["Disk"].Visible = false
	elems["Disk"].Size = homeDisk
	elems["Core"].Visible = false
	floating = false
	rainbow = false
	if resultLoop then
		resultLoop:Disconnect()
		resultLoop = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Result Loop

--[[
	Each frame while the result shows: the rays turn (through the rainbow for the party), the black hole's disk turns
	(its flipbook), and a floating card bobs.
]]
function Module._startResultLoop()
	--[[ Checks ]]

	-- Check if it runs already
	if resultLoop then
		return
	end

	--[[ Looping ]]

	local start: number = os.clock()
	resultLoop = I.S.RunService.RenderStepped:Connect(function()
		local now: number = os.clock() - start
		local rays: ImageLabel = elems["Rays"]
		rays.Rotation = (now / 26 * 360) % 360
		if rainbow then
			rays.ImageColor3 = Color3.fromHSV((now * 0.2) % 1, 0.7, 1)
		end
		local disk: ImageLabel = elems["Disk"]
		if disk.Visible then
			local frame: number = math.floor(now * _settings.DISK_FPS) % (_settings.DISK_GRID.X * _settings.DISK_GRID.Y)
			disk.ImageRectOffset = Vector2.new((frame % _settings.DISK_GRID.X) * _settings.DISK_FRAME.X, math.floor(frame / _settings.DISK_GRID.X) * _settings.DISK_FRAME.Y)
		end
		if floating and now > 1.7 then
			elems["CardSlot"].Position = CARD_HOME + UDim2.fromScale(0, math.sin(now * 2) * 0.012)
			elems["CardSlot"].Rotation = math.sin(now * 1.6) * 1.5
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Draw Rarity Bar

--[[
	Draws a rarity bar (the odds list's title look) for a rarity: its outline, mask, and the name in its gradient.
]]
function Module._drawRarityBar(bar: Instance, rarity: string)
	--[[ Local Variables ]]

	local looks: Frame = prefabs["RaritySection"]
	local text: TextLabel = bar:FindFirstChild("S_Rarity", true)

	--[[ Applying ]]

	bar:FindFirstChild("S_BarStroke", true).ImageColor3 = Reel.GetRarityColor(rarity)
	bar:FindFirstChild("S_BarMask", true).Image = looks:GetAttribute(`Look_{rarity}_Mask`) or looks:GetAttribute("Look_Common_Mask")
	text.Text = rarity
	text.UIGradient.Color = looks:GetAttribute(`Look_{rarity}_Gradient`) or looks:GetAttribute("Look_Common_Gradient")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Card Point

--[[
	Returns the big card's middle on the screen (absolute pixels).
]]
--- @return Vector2
function Module.GetCardPoint()
	return elems["Result"].AbsolutePosition + elems["Result"].AbsoluteSize * Vector2.new(0.5, 0.39)
end

return Module
