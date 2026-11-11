--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Reel = require(script.Parent:FindFirstChild("Reel")) --- @type Crates_Client_Reel
local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Crates_Client_Effects
local Drops = require(script.Parent:FindFirstChild("Drops")) --- @type Crates_Client_Drops
local Showcase = require(script.Parent:FindFirstChild("Showcase")) --- @type Crates_Client_Showcase
local Result = require(script.Parent:FindFirstChild("Result")) --- @type Crates_Client_Result
local Stage3D = require(script.Parent:FindFirstChild("Stage3D")) --- @type Crates_Client_Stage3D

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui

--[[ State ]]

-- The last crate opened, to open it again, and the opener
local lastCrate: string = ""
local lastCount: number = 1
local lastPayWith: string = "Coins"
local openCrate: (crateId: string, count: number, payWith: string) -> ()

-- Counts openings, so a newer one (or the widget closing) stops an older one
local revealId: number = 0

-- Whether Quick open is on, whether the shop is out of the way, and the regions' places in the shop
local quick: boolean = false
local shopOut: boolean = false
local homes = {} --- @type { [string]: UDim2 }

-- The heartbeat playing, and the card a crate's only legendary rises out of the golden crate on
local tease: Sound? = nil
local riseCard: Frame? = nil

-- The regions that make way for the crate, and where each goes
--- @type { [string]: UDim2 }
local REGIONS_OUT = {
	U_TopLeft = UDim2.fromScale(0, -0.25),
	U_TopRight = UDim2.fromScale(0, -0.25),
	U_Left = UDim2.fromScale(-0.45, 0),
	U_BottomCenter = UDim2.fromScale(0, 0.3),
	U_BottomRight = UDim2.fromScale(0, 0.3),
}

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

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	for name: string, _offset: UDim2 in pairs(REGIONS_OUT) do
		elems[name] = moduleGui:FindFirstChild(name, true)
		homes[name] = elems[name].Position
	end
	elems["Center"] = moduleGui:FindFirstChild("U_Center", true) --- @type Frame
	elems["Backdrop"] = moduleGui:FindFirstChild("U_Backdrop", true) --- @type Frame
	elems["Quick"] = moduleGui:FindFirstChild("U_Quick", true) --- @type ImageButton
	elems["Open"] = moduleGui:FindFirstChild("U_Open", true) --- @type Frame
	elems["Title"] = elems["Open"]:FindFirstChild("S_Title", true) --- @type Frame
	elems["BarTop"] = elems["Open"]:FindFirstChild("S_BarTop", true) --- @type Frame
	elems["BarBottom"] = elems["Open"]:FindFirstChild("S_BarBottom", true) --- @type Frame
	elems["Reels"] = elems["Open"]:FindFirstChild("U_Reels", true) --- @type Frame
	elems["Skip"] = elems["Open"]:FindFirstChild("U_Skip", true) --- @type ImageButton
	elems["Result"] = moduleGui:FindFirstChild("U_Result", true) --- @type Frame
	elems["Cards"] = elems["Result"]:FindFirstChild("U_Cards", true) --- @type Frame
	elems["Summary"] = elems["Result"]:FindFirstChild("U_Summary", true) --- @type Frame
	elems["Buttons"] = elems["Result"]:FindFirstChild("U_Buttons", true) --- @type Frame
	elems["Again"] = elems["Buttons"]:FindFirstChild("U_Again", true) --- @type ImageButton
	elems["Continue"] = elems["Buttons"]:FindFirstChild("U_Continue", true) --- @type ImageButton
	openCrate = opener

	--[[ Connections ]]

	I.Interact.OnPress(elems["Skip"], function()
		Reel.Skip()
		Module._stopTease(true)
		elems["Skip"].Visible = false
	end)
	I.Interact.OnPress(elems["Continue"], function()
		Module._finish(false)
	end)
	I.Interact.OnPress(elems["Again"], function()
		openCrate(lastCrate, lastCount, lastPayWith)
	end)
	I.Interact.OnPress(elems["Quick"], function()
		quick = not quick
		Module._drawQuick()
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		if widgetName == _settings.GUI_NAME then
			Module._finish(true)
		end
	end)

	--[[ Drawing ]]

	Module._drawQuick()
	Module._finish(true)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Plays an opening on the crates screen: the shop makes way and the bought crates drop in as 3D crates, tapped open
	into the reels; the reels roll (the heartbeat under an epic or legendary), then the winners are revealed: one big
	card, or a row or grid of cards; a legendary first lands as the gold card, then gets its own drop. Open again and
	Continue follow.
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

	--[[ Opening ]]

	Module._clearResult()
	Module._intro(row, count)
	if thisReveal ~= revealId then
		return
	end

	--[[ Reels ]]

	local reels = Reel.Build(results, row, payWith, quick) --- @type { Crates_Reel }
	elems["Title"]:FindFirstChild("S_Name", true).Text = row.Name
	elems["Title"]:FindFirstChild("S_CountText", true).Text = `x{count}`
	elems["Title"].Visible = true
	elems["Open"].Visible = true
	elems["Skip"].Visible = true
	Module._unfold(reels)
	if #results > 1 then
		I.Sound.Play({ Name = "Crate_Spin", SoundGroup = "SFX", Volume = 0.8 })
	end

	-- A rare drop slowing in gets the heartbeat
	local slowest = reels[1] --- @type Crates_Reel
	local slowestResult = results[1] --- @type Crates_Result
	--- @param reel Crates_Reel
	for index: number, reel in ipairs(reels) do
		if reel.Delay + reel.Duration > slowest.Delay + slowest.Duration then
			slowest = reel
			slowestResult = results[index]
		end
	end
	local rarity: string = I.G_Inventory.Items[slowestResult.ItemId].Rarity
	if not quick and I.Rarity.GetRarityIndex(rarity) >= I.Rarity.GetRarityIndex(_settings.TEASE_FROM_RARITY) then
		task.delay(slowest.Delay + slowest.Duration - _settings.TEASE_SECONDS, Module._startTease, thisReveal)
	end

	--[[ Rolling ]]

	Reel.Run(reels, function(reel)
		I.Sound.Play({ Name = "Crate_Land", SoundGroup = "SFX", Volume = if #results > 3 then 0.55 else 0.9 })
		Module._flashCard(reel.WinCard)
	end)
	elems["Skip"].Visible = false
	Module._stopTease(true)
	if thisReveal ~= revealId then
		return
	end
	--- @param reel Crates_Reel
	for index: number, reel in ipairs(reels) do
		task.spawn(Reel.Settle, reel, #reels == 1 or index == #reels)
	end
	task.wait(_settings.SETTLE_DELAY + _settings.SETTLE_SECONDS + 0.12)
	Reel.SetHot(false)
	if thisReveal ~= revealId then
		return
	end

	--[[ Revealing ]]

	if #results == 1 then
		Module._revealOne(results[1], reels[1], row, payWith, thisReveal)
	else
		Module._revealMany(results, reels, row, payWith, thisReveal)
	end
	if thisReveal ~= revealId then
		return
	end

	--[[ Buttons ]]

	Module._setBars(false)
	Module._showButtons(row, count, payWith)
end

--%%%%%%%%%%%%%%%%%%%% Intro

--[[
	The shop makes way (tabs and balance up, odds left, buttons down) and the screen dims; the 2D crate gives way to the
	3D crates, which drop in, wait for the tap (unless Quick open is on) and burst open into the reels.
]]
--- @param row Crates_CrateData
function Module._intro(row, count: number)
	--[[ Local Variables ]]

	local tweenInfo: TweenInfo = if quick then _settings.QUICK_INTRO_TWEENINFO else _settings.INTRO_TWEENINFO

	--[[ Shop ]]

	if shopOut then
		Showcase.SetOpening(false)
	end
	Showcase.SetOpening(true)
	if not shopOut then
		shopOut = true
		for name: string, offset: UDim2 in pairs(REGIONS_OUT) do
			local Out_TweenGoal = { Position = homes[name] + offset }
			local Out_Tween: Tween = I.S.TweenService:Create(elems[name], tweenInfo, Out_TweenGoal)
			Out_Tween:Play()
		end
		task.delay(tweenInfo.Time, function()
			if shopOut then
				for name: string, _offset: UDim2 in pairs(REGIONS_OUT) do
					elems[name].Visible = false
				end
			end
		end)
	end
	local Dim_TweenGoal = {
		BackgroundColor3 = if row.Premium then _settings.BACKDROP_PREMIUM_COLOR else _settings.BACKDROP_OPEN_COLOR,
		BackgroundTransparency = _settings.BACKDROP_OPEN_TRANSPARENCY,
	}
	local Dim_Tween: Tween = I.S.TweenService:Create(elems["Backdrop"], _settings.BACKDROP_TWEENINFO, Dim_TweenGoal)
	Dim_Tween:Play()

	--[[ Crates ]]

	-- The showcase's crate leaps off the pedestal as the bought crates drop onto the stage
	Showcase.Lift()
	task.delay(_settings.SHOWCASE_LIFT_TWEENINFO.Time, function()
		if shopOut then
			elems["Center"].Visible = false
		end
	end)
	Stage3D.Play(row, count, false, quick)
end

--%%%%%%%%%%%%%%%%%%%% Unfold

--[[
	Opens the reels: bands grow out of a line, columns rise into place, each after its delay.
]]
--- @param reels { Crates_Reel }
function Module._unfold(reels)
	--[[ Unfolding ]]

	--- @param reel Crates_Reel
	for _index: number, reel in ipairs(reels) do
		local frame: Frame = reel.Frame
		local Unfold_TweenInfo: TweenInfo = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, reel.Delay)
		local Unfold_TweenGoal = { Size = frame.Size, Position = frame.Position }
		if reel.Vertical then
			frame.Position += UDim2.fromOffset(0, 60 * Effects.GetUnit())
		else
			frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0)
		end
		local Unfold_Tween: Tween = I.S.TweenService:Create(frame, Unfold_TweenInfo, Unfold_TweenGoal)
		Unfold_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Reveal One

--[[
	One crate: the winning card lifts out of the reel and becomes the big card, in its rarity's light and burst. A
	legendary is the gold card's moment first.
]]
--- @param result Crates_Result
--- @param reel Crates_Reel
--- @param row Crates_CrateData
function Module._revealOne(result, reel, row, payWith: string, thisReveal: number)
	--[[ Data ]]

	local item = I.G_Inventory.Items[result.ItemId] --- @type Inventory_ItemData

	--[[ Legendary ]]

	if item.Rarity == "Legendary" then
		Module._goldMoment(result, reel.WinCard, row, payWith, thisReveal)
		return
	end

	--[[ Revealing ]]

	I.Sound.Play({ Name = `Reveal_{item.Rarity}`, SoundGroup = "SFX" })
	Result.ShowBig(result, "Fly", reel.WinCard)
	task.delay(0.3, function()
		if thisReveal == revealId then
			elems["Open"].Visible = false
			Reel.Clear()
		end
	end)
	task.delay(0.33, function()
		Effects.Rarity(item.Rarity, Result.GetCardPoint(), Reel.GetRarityColor(item.Rarity), 1)
	end)
	task.wait(0.7)
end

--%%%%%%%%%%%%%%%%%%%% Gold Moment

--[[
	A legendary: the gold card hits (the gold hit, a flash, a dark screen and letterbox bars), a golden crate drops in
	and is tapped open, then a golden reel picks which legendary when the crate holds more than one (else its card
	rises out of the crate), then that legendary's own drop brings in the big card.
]]
--- @param result Crates_Result
--- @param row Crates_CrateData
function Module._goldMoment(result, goldCard: Frame, row, payWith: string, thisReveal: number)
	--[[ Local Variables ]]

	local gold: Color3 = Reel.GetRarityColor("Legendary")
	local point: Vector2 = goldCard.AbsolutePosition + goldCard.AbsoluteSize / 2
	local pool = {} --- @type { string }
	for itemId: string, _chance: number in pairs(row.OddsByCurrency[payWith] or row.OddsByCurrency[_settings.VIP_ODDS] or {}) do
		if I.G_Inventory.Items[itemId].Rarity == "Legendary" then
			table.insert(pool, itemId)
		end
	end

	--[[ Gold Hit ]]

	I.Sound.Play({ Name = "Crate_GoldHit", SoundGroup = "SFX" })
	Effects.Flash(Color3.fromRGB(255, 233, 160), 0.7, 0.5)
	Module._dim(0.06)
	Module._setBars(true)
	Effects.Ring(point, gold, 80, 1040, 0.6)
	Effects.Burst("Sparks", point, 60, gold)
	Effects.Burst("Stars", point, 24, Color3.fromRGB(255, 246, 196))
	local Pulse_TweenInfo: TweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Pulse_TweenGoal = {
		Size = UDim2.fromOffset(goldCard.AbsoluteSize.X * 1.12, goldCard.AbsoluteSize.Y * 1.12),
		Position = goldCard.Position - UDim2.fromOffset(goldCard.AbsoluteSize.X * 0.06, goldCard.AbsoluteSize.Y * 0.06),
	}
	if goldCard.AnchorPoint.X > 0 then
		Pulse_TweenGoal.Position = goldCard.Position
	end
	local Pulse_Tween: Tween = I.S.TweenService:Create(goldCard, Pulse_TweenInfo, Pulse_TweenGoal)
	Pulse_Tween:Play()
	task.wait(if quick then 0.7 else 1.1)
	if thisReveal ~= revealId then
		return
	end

	--[[ Golden Crate ]]

	-- The gold card gives way to a golden crate, tapped open like the first
	elems["Open"].Visible = false
	Stage3D.Play(row, 1, true, quick)
	if thisReveal ~= revealId then
		return
	end
	goldCard.Visible = false
	elems["Title"].Visible = false
	elems["Open"].Visible = true

	--[[ Golden Reel ]]

	if #pool > 1 then
		local golden = Reel.BuildGolden(pool, result.ItemId, quick) --- @type Crates_Reel
		Module._unfold({ golden })
		I.Sound.Play({ Name = "Crate_Spin", SoundGroup = "SFX", Volume = 0.9 })
		elems["Skip"].Visible = true
		Reel.Run({ golden }, function(_reel)
			I.Sound.Play({ Name = "Crate_Land", SoundGroup = "SFX", Volume = 0.9 })
		end)
		elems["Skip"].Visible = false
		if thisReveal ~= revealId then
			return
		end
		Reel.Settle(golden, true)
		goldCard = golden.WinCard
		task.wait(0.15)
	else
		-- The crate's only legendary: its card rises out of the golden crate
		Reel.Clear()
		local size: Vector2 = Vector2.new(236, 211) * Effects.GetUnit()
		local card: Frame = Reel.MakeCard(elems["Reels"], result.ItemId, false, false, UDim2.fromOffset(size.X * 0.4, size.Y * 0.4))
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Position = UDim2.fromScale(0.5, 0.56)
		riseCard = card
		local Rise_TweenInfo: TweenInfo = TweenInfo.new(0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local Rise_TweenGoal = { Position = UDim2.fromScale(0.5, 0.444), Size = UDim2.fromOffset(size.X, size.Y) }
		local Rise_Tween: Tween = I.S.TweenService:Create(card, Rise_TweenInfo, Rise_TweenGoal)
		Rise_Tween:Play()
		I.Sound.Play({ Name = "Crate_Land", SoundGroup = "SFX", Volume = 0.9 })
		task.wait(0.52)
		if thisReveal ~= revealId then
			return
		end
		goldCard = card
	end

	--[[ Drop ]]

	Drops.Play(_settings.LEGENDARY_DROPS[result.ItemId], goldCard, function(entrance: string, mood: string?)
		if thisReveal == revealId then
			if riseCard then
				riseCard:Destroy()
				riseCard = nil
			end
			Result.ShowBig(result, entrance, nil, mood)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Reveal Many

--[[
	Three or ten crates: every winner flies from its reel to its place in a row or a grid, then they're named one by
	one, rarest last, the best with a BEST ribbon; a legendary then takes the middle for the gold card's moment and goes
	back to its place; the pack's summary closes it.
]]
--- @param results { Crates_Result }
--- @param reels { Crates_Reel }
--- @param row Crates_CrateData
function Module._revealMany(results, reels, row, payWith: string, thisReveal: number)
	--[[ Local Variables ]]

	local count: number = #results
	local trio: boolean = count <= 3
	local area: Vector2 = elems["Cards"].AbsoluteSize
	local origin: Vector2 = elems["Cards"].AbsolutePosition
	local unit: number = Effects.GetUnit()
	local offset: Vector2 = (area - Vector2.new(1920, 1080) * unit) / 2
	local width: number = (if trio then _settings.TRIO_CARD_WIDTH else _settings.TEN_CARD_WIDTH) * unit
	local cardSize: Vector2 = Vector2.new(width, width / _settings.CARD_ASPECT)
	local cards = {} --- @type { Frame }
	local slots = {} --- @type { Vector2 }

	--[[ Flying ]]

	I.Sound.Play({ Name = "Results_Open", SoundGroup = "SFX" })
	--- @param result Crates_Result
	for index: number, result in ipairs(results) do
		local slot: Vector2
		if trio then
			slot = Vector2.new(area.X / 2 + (index - (count + 1) / 2) * _settings.TRIO_SPACING * unit, offset.Y + _settings.TRIO_Y * unit)
		else
			local column: number = (index - 1) % 5
			slot = Vector2.new(area.X / 2 + (column - 2) * _settings.TEN_SPACING * unit, offset.Y + _settings.TEN_ROWS_Y[if index <= 5 then 1 else 2] * unit)
		end
		local legendary: boolean = I.G_Inventory.Items[result.ItemId].Rarity == "Legendary"
		local from: Frame = reels[index].WinCard
		local card: Frame = Reel.MakeCard(elems["Cards"], result.ItemId, legendary, false, UDim2.fromOffset(from.AbsoluteSize.X, from.AbsoluteSize.Y))
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Position = UDim2.fromOffset(from.AbsolutePosition.X - origin.X + from.AbsoluteSize.X / 2, from.AbsolutePosition.Y - origin.Y + from.AbsoluteSize.Y / 2)
		local Fly_TweenInfo: TweenInfo = TweenInfo.new(0.52, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, index * 0.03)
		local Fly_TweenGoal = { Position = UDim2.fromOffset(slot.X, slot.Y), Size = UDim2.fromOffset(cardSize.X, cardSize.Y) }
		local Fly_Tween: Tween = I.S.TweenService:Create(card, Fly_TweenInfo, Fly_TweenGoal)
		Fly_Tween:Play()
		cards[index] = card
		slots[index] = slot
	end
	task.wait(0.3)
	elems["Open"].Visible = false
	Reel.Clear()
	task.wait(0.3 + count * 0.03)
	if thisReveal ~= revealId then
		return
	end

	--[[ Naming ]]

	local order = Module._getRevealOrder(results) --- @type { number }
	local best: number = order[#order]
	local step: number = if trio then _settings.TRIO_STEP else _settings.TEN_STEP
	for _place: number, index: number in ipairs(order) do
		local result = results[index] --- @type Crates_Result
		if I.G_Inventory.Items[result.ItemId].Rarity == "Legendary" then
			continue
		end
		Result.NameCard(cards[index], result, slots[index], cardSize, index == best, count)
		task.wait(step)
		if thisReveal ~= revealId then
			return
		end
	end

	--[[ Legendaries ]]

	for _place: number, index: number in ipairs(order) do
		local result = results[index] --- @type Crates_Result
		if I.G_Inventory.Items[result.ItemId].Rarity ~= "Legendary" then
			continue
		end
		task.wait(0.4)

		-- The gold card takes the middle
		local card: Frame = cards[index]
		local solo: Frame = Reel.MakeCard(elems["Reels"], result.ItemId, true, false, UDim2.fromOffset(cardSize.X, cardSize.Y))
		local centreSize: Vector2 = Vector2.new(236, 211) * unit
		solo.AnchorPoint = Vector2.new(0.5, 0.5)
		solo.Position = card.Position
		elems["Cards"].Visible = false
		elems["Summary"].Visible = false
		elems["Title"].Visible = false
		elems["Open"].Visible = true
		local Centre_TweenInfo: TweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local Centre_TweenGoal = { Position = UDim2.fromScale(0.5, 0.444), Size = UDim2.fromOffset(centreSize.X, centreSize.Y) }
		local Centre_Tween: Tween = I.S.TweenService:Create(solo, Centre_TweenInfo, Centre_TweenGoal)
		Centre_Tween:Play()
		task.wait(0.48)
		Module._goldMoment(result, solo, row, payWith, thisReveal)
		task.wait(_settings.PACK_LEGENDARY_HOLD)
		if thisReveal ~= revealId then
			return
		end

		-- Back to its place, revealed
		Result.ClearBig()
		Module._dim(_settings.BACKDROP_OPEN_TRANSPARENCY)
		Reel.Clear()
		solo:Destroy()
		elems["Open"].Visible = false
		Module._setBars(false)
		elems["Cards"].Visible = true
		Reel.FillCard(card, result.ItemId, false, false)
		Result.NameCard(card, result, slots[index], cardSize, index == best, count)
	end

	--[[ Summary ]]

	Result.ShowSummary(results)
end

--%%%%%%%%%%%%%%%%%%%% Show Buttons

--[[
	Shows Open again (the pack's price in the paying currency, in its colours) and Continue. A free daily crate or the
	tutorial's can't be opened again from here.
]]
--- @param row Crates_CrateData
function Module._showButtons(row, count: number, payWith: string)
	--[[ Local Variables ]]

	local again: ImageButton = elems["Again"]
	local price: string? = I.G_Crates.GetPrice(lastCrate, payWith, count)
	local canAgain: boolean = payWith ~= "VipDaily" and not row.Hidden and price ~= nil

	--[[ Applying ]]

	again.Visible = canAgain
	if canAgain then
		again:FindFirstChild("S_Amount", true).Text = if count == 1 then "OPEN AGAIN" else `OPEN x{count} AGAIN`
		again:FindFirstChild("S_Price", true).Text = I.Format.Text(price)
		again:FindFirstChild("S_Icon", true).Image = again:GetAttribute(`Look_{payWith}Icon`)
		again:FindFirstChild("S_Main", true).ImageColor3 = again:GetAttribute(`Look_{payWith}MainColor`)
		again:FindFirstChild("S_Stroke", true).ImageColor3 = again:GetAttribute(`Look_{payWith}StrokeColor`)
	end
	elems["Buttons"].Visible = true

	--[[ Tweening ]]

	elems["Buttons"].Position = UDim2.fromScale(0.5, 0.925)
	local Buttons_TweenInfo: TweenInfo = TweenInfo.new(0.36, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local Buttons_TweenGoal = { Position = UDim2.fromScale(0.5, 0.875) }
	local Buttons_Tween: Tween = I.S.TweenService:Create(elems["Buttons"], Buttons_TweenInfo, Buttons_TweenGoal)
	Buttons_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Finish

--[[
	Ends the opening and brings the shop back (at once when the widget closed): the reels, results and effects go,
	the tabs, odds and buttons slide back and the crate pops back onto its pedestal.
]]
function Module._finish(instant: boolean)
	--[[ Clearing ]]

	revealId += 1
	Module._stopTease(false)
	Module._clearResult()
	Stage3D.Clear()
	Reel.Clear()
	if riseCard then
		riseCard:Destroy()
		riseCard = nil
	end
	elems["Open"].Visible = false
	elems["Result"].Visible = false
	elems["Skip"].Visible = false

	--[[ Shop ]]

	shopOut = false
	local tweenInfo: TweenInfo = if instant then TweenInfo.new(0) else _settings.INTRO_TWEENINFO
	for name: string, _offset: UDim2 in pairs(REGIONS_OUT) do
		elems[name].Visible = true
		local Back_TweenGoal = { Position = homes[name] }
		local Back_Tween: Tween = I.S.TweenService:Create(elems[name], tweenInfo, Back_TweenGoal)
		Back_Tween:Play()
	end
	elems["Center"].Visible = true
	Showcase.SetOpening(false)
end

--%%%%%%%%%%%%%%%%%%%% Clear Result

--[[
	Empties the result: the big card and its light, a pack's cards and summary, the buttons and every effect; the result
	layer stays shown for the opening's effects.
]]
function Module._clearResult()
	--[[ Clearing ]]

	Result.ClearBig()
	for _index: number, holder: Frame in ipairs({ elems["Cards"], elems["Summary"] }) do
		for _childIndex: number, child: Instance in ipairs(holder:GetChildren()) do
			if child:IsA("Frame") and not child.Name:find("PREFAB") then
				child:Destroy()
			end
		end
	end

	--[[ Visibility ]]

	elems["Cards"].Visible = true
	elems["Summary"].Visible = false
	elems["Buttons"].Visible = false
	elems["Result"].Visible = true
	Module._setBars(false)
end

--%%%%%%%%%%%%%%%%%%%% Start Tease

--[[
	The heartbeat under a rare drop slowing in: its sound, the letterbox bars, the line burning brighter and the screen
	dimming on each beat.
]]
function Module._startTease(thisReveal: number)
	--[[ Checks ]]

	-- Check if this opening still plays and the reels still roll
	if thisReveal ~= revealId or not elems["Skip"].Visible then
		return
	end

	--[[ Playing ]]

	tease = I.Sound.Play({ Name = "Crate_Tease", SoundGroup = "SFX" })
	Module._setBars(true)
	Reel.SetHot(true)
	for _index: number, beat: number in ipairs(_settings.TEASE_BEATS) do
		task.delay(beat, function()
			if tease and thisReveal == revealId then
				Effects.Flash(Color3.new(0, 0, 0), 0.28, 0.3)
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop Tease

--[[
	Stops the heartbeat; the bars stay when keepBars (a reveal follows), else they go too.
]]
function Module._stopTease(keepBars: boolean)
	--[[ Stopping ]]

	if tease then
		tease:Stop()
		tease = nil
	end
	if not keepBars then
		Module._setBars(false)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Bars

--[[
	Slides the letterbox bars in or out.
]]
function Module._setBars(shown: boolean)
	--[[ Tweening ]]

	local Bars_TweenInfo: TweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local Top_TweenGoal = { Position = UDim2.fromScale(0, if shown then 0 else -0.07) }
	local Top_Tween: Tween = I.S.TweenService:Create(elems["BarTop"], Bars_TweenInfo, Top_TweenGoal)
	Top_Tween:Play()
	local Bottom_TweenGoal = { Position = UDim2.fromScale(0, if shown then 0.93 else 1) }
	local Bottom_Tween: Tween = I.S.TweenService:Create(elems["BarBottom"], Bars_TweenInfo, Bottom_TweenGoal)
	Bottom_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Dim

--[[
	Fades the dim behind the screen to a transparency (0.06 for the gold card's moment, back to the opening's after).
]]
function Module._dim(transparency: number)
	--[[ Tweening ]]

	local Dim_TweenGoal = { BackgroundTransparency = transparency }
	local Dim_Tween: Tween = I.S.TweenService:Create(elems["Backdrop"], _settings.BACKDROP_TWEENINFO, Dim_TweenGoal)
	Dim_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Flash Card

--[[
	Lights a card up for a moment as its reel lands.
]]
function Module._flashCard(card: Frame)
	--[[ Applying ]]

	local glow: ImageLabel = card:FindFirstChild("S_Glow", true)
	glow.ImageTransparency = -0.4

	--[[ Tweening ]]

	local Land_TweenInfo: TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Land_TweenGoal = { ImageTransparency = 0.2 }
	local Land_Tween: Tween = I.S.TweenService:Create(glow, Land_TweenInfo, Land_TweenGoal)
	Land_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Draw Quick

--[[
	Draws Quick open's toggle in its on or off look.
]]
function Module._drawQuick()
	--[[ Applying ]]

	local button: ImageButton = elems["Quick"]
	local look: string = if quick then "On" else "Off"
	button:FindFirstChild("S_Stroke", true).ImageColor3 = button:GetAttribute(`Look_{look}StrokeColor`)
	button:FindFirstChild("S_Text", true).TextColor3 = button:GetAttribute(`Look_{look}TextColor`)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Reveal Order

--[[
	Returns a pack's cards in the order they're named: by rarity, the rarest (the best) last.
]]
--- @param results { Crates_Result }
--- @return { number }
function Module._getRevealOrder(results)
	--[[ Local Variables ]]

	local order = {} --- @type { number }
	for index: number = 1, #results do
		table.insert(order, index)
	end

	--[[ Sorting ]]

	table.sort(order, function(a: number, b: number): boolean
		local rankA: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[results[a].ItemId].Rarity)
		local rankB: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[results[b].ItemId].Rarity)
		return if rankA == rankB then a < b else rankA < rankB
	end)

	--[[ Returning ]]

	return order
end

return Module
