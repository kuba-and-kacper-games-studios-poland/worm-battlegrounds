--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local SkinModels = require(script.Parent:FindFirstChild("SkinModels")) --- @type Crates_Client_SkinModels

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ State ]]

-- The reels on the screen now, whether a skip was asked for, and when the last tick played
local reels = {} --- @type { Crates_Reel }
local skipping: boolean = false
local lastTick: number = 0

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

--- @class Crates_Client_Reel
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Reels"] = moduleGui:FindFirstChild("U_Reels", true) --- @type Frame
	elems["MarkerV"] = moduleGui:FindFirstChild("S_MarkerV", true) --- @type Frame
	elems["MarkerH"] = moduleGui:FindFirstChild("S_MarkerH", true) --- @type Frame
	prefabs["Card"] = elems["Reels"]:FindFirstChild("PREFAB | Card") --- @type Frame
	prefabs["Band"] = elems["Reels"]:FindFirstChild("PREFAB | Band") --- @type Frame
	prefabs["Column"] = elems["Reels"]:FindFirstChild("PREFAB | Column") --- @type Frame
	prefabs["RaritySection"] = moduleGui:FindFirstChild("PREFAB | RaritySection", true) --- @type Frame

	--[[ Pictures ]]

	-- The snails' pictures load now, so the first reel shows them as it rolls
	local pictures = {} --- @type { string }
	for _model: string, picture: string in pairs(_settings.SKIN_PICTURES) do
		table.insert(pictures, picture)
	end
	task.spawn(function()
		I.S.ContentProvider:PreloadAsync(pictures)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Lays out a pack's reels, one per result (a band for one crate, stacked bands for two or three, ten columns for ten),
	each a strip of cards drawn from the crate's odds with the result in the winner's place, and the line across them.
	The reels don't move until Run; the rarest result's reel stops last.
]]
--- @param results { Crates_Result }
--- @param row Crates_CrateData
--- @return { Crates_Reel }
function Module.Build(results, row, payWith: string, quick: boolean)
	--[[ Local Variables ]]

	local count: number = #results
	local timing: number = if count > 3 then 10 else count
	local odds = row.OddsByCurrency[payWith] or row.OddsByCurrency[_settings.VIP_ODDS] or {} --- @type { [string]: number }
	local seconds: number = (if quick then _settings.QUICK_ROLL_SECONDS else _settings.ROLL_SECONDS)[timing]
	local stagger: number = (if quick then _settings.QUICK_ROLL_STAGGER else _settings.ROLL_STAGGER)[timing]
	local order = Module._getStopOrder(results) --- @type { [number]: number }

	-- A fixed crate has no odds: its strips show its own items
	if next(odds) == nil then
		odds = {}
		--- @param result Crates_Result
		for _index: number, result in ipairs(results) do
			odds[result.ItemId] = 1
		end
	end

	--[[ Building ]]

	Module.Clear()
	--- @param result Crates_Result
	for index: number, result in ipairs(results) do
		local item = I.G_Inventory.Items[result.ItemId] --- @type Inventory_ItemData
		local reel = Module._buildReel(count, index, result.ItemId, item.Rarity == "Legendary", odds, row) --- @type Crates_Reel
		reel.Duration = seconds + order[index] * stagger
		reel.Delay = (index - 1) * (if count > 3 then 0.045 else 0.09)
		table.insert(reels, reel)
	end

	--[[ Marker ]]

	Module._placeMarker(count > 3, if row.Premium then _settings.PREMIUM_MARKER_COLOR else _settings.MARKER_COLOR)

	--[[ Returning ]]

	return reels
end

--%%%%%%%%%%%%%%%%%%%% Build Golden

--[[
	Replaces the reels with the golden reel: one band of the crate's legendaries in gold, which stops on the one won.
]]
--- @param pool { string }
--- @return Crates_Reel
function Module.BuildGolden(pool, itemId: string, quick: boolean)
	--[[ Building ]]

	Module.Clear()
	local odds = {} --- @type { [string]: number }
	for _index: number, poolId: string in ipairs(pool) do
		odds[poolId] = 1
	end
	local reel = Module._buildReel(1, 1, itemId, false, odds, nil) --- @type Crates_Reel
	reel.Duration = if quick then _settings.QUICK_GOLDEN_SECONDS else _settings.GOLDEN_SECONDS
	reel.Delay = 0
	reel.TickPitch = 1.12
	reel.Frame.BackgroundColor3 = _settings.GOLDEN_BAND_COLOR
	reel.Frame:FindFirstChild("S_LineTop", true).BackgroundColor3 = _settings.GOLDEN_LINE_COLOR
	reel.Frame:FindFirstChild("S_LineBottom", true).BackgroundColor3 = _settings.GOLDEN_LINE_COLOR
	table.insert(reels, reel)

	--[[ Marker ]]

	Module._placeMarker(false, _settings.MARKER_COLOR)

	--[[ Returning ]]

	return reel
end

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Rolls the reels on CS2's curve until every one has landed, ticking as cards cross the line, and calls onLand for
	each as it stops. A skip brings every reel still moving in at once.
]]
--- @param list { Crates_Reel }
--- @param onLand (reel: Crates_Reel) -> ()
function Module.Run(list, onLand)
	--[[ Local Variables ]]

	local start: number = os.clock()
	local finished: boolean = false
	skipping = false
	--- @param reel Crates_Reel
	for _index: number, reel in ipairs(list) do
		reel.Start = start + reel.Delay
		reel.From = reel.Position
		reel.Ease = Module._ease
	end

	--[[ Rolling ]]

	local connection: RBXScriptConnection = I.S.RunService.RenderStepped:Connect(function()
		local now: number = os.clock()
		local moving: boolean = false

		-- A skip: every reel still moving runs out its last stretch quickly
		if skipping then
			skipping = false
			--- @param reel Crates_Reel
			for _index: number, reel in ipairs(list) do
				if not reel.Done then
					reel.From = reel.Position
					reel.Start = now
					reel.Delay = 0
					reel.Duration = _settings.SKIP_SECONDS
					reel.Ease = function(t: number): number
						return 1 - (1 - t) ^ 3
					end
				end
			end
		end

		--- @param reel Crates_Reel
		for _index: number, reel in ipairs(list) do
			if reel.Done then
				continue
			end
			if now < reel.Start then
				moving = true
				continue
			end
			local progress: number = math.min(1, (now - reel.Start) / reel.Duration)
			Module._setPosition(reel, reel.From + (reel.To - reel.From) * reel.Ease(progress))

			-- A tick each time a card crosses the line
			local cardIndex: number = math.floor((reel.Position + reel.Gap / 2) / reel.Pitch)
			if reel.LastIndex and cardIndex ~= reel.LastIndex then
				Module._tick(reel.TickPitch, #list)
			end
			reel.LastIndex = cardIndex

			if progress >= 1 then
				reel.Done = true
				onLand(reel)
			else
				moving = true
			end
		end
		finished = not moving
	end)

	--[[ Waiting ]]

	while not finished do
		task.wait()
	end
	connection:Disconnect()
end

--%%%%%%%%%%%%%%%%%%%% Skip

--[[
	Brings every moving reel in at once.
]]
function Module.Skip()
	skipping = true
end

--%%%%%%%%%%%%%%%%%%%% Settle

--[[
	After a short pause, glides a landed reel so the line sits on its card's centre, with the soft settle click.
]]
--- @param reel Crates_Reel
function Module.Settle(reel, sound: boolean)
	--[[ Waiting ]]

	task.wait(_settings.SETTLE_DELAY)
	if not reel.Frame.Parent then
		return
	end

	--[[ Gliding ]]

	if sound then
		I.Sound.Play({ Name = "Crate_Settle", SoundGroup = "SFX", Volume = 0.8 })
	end
	local from: number = reel.Position
	local start: number = os.clock()
	while reel.Frame.Parent do
		local progress: number = math.min(1, (os.clock() - start) / _settings.SETTLE_SECONDS)
		local eased: number = if progress < 0.5 then 4 * progress ^ 3 else 1 - (-2 * progress + 2) ^ 3 / 2
		Module._setPosition(reel, from + (reel.Centre - from) * eased)
		if progress >= 1 then
			break
		end
		I.S.RunService.RenderStepped:Wait()
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Takes every reel and the line off the screen, and stops any that still move.
]]
function Module.Clear()
	--[[ Clearing ]]

	--- @param reel Crates_Reel
	for _index: number, reel in ipairs(reels) do
		reel.Done = true
		reel.Frame:Destroy()
	end
	table.clear(reels)

	--[[ Visibility ]]

	elems["MarkerV"].Visible = false
	elems["MarkerH"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Set Hot

--[[
	Makes the line glow harder while a rare drop slows in, or back to normal.
]]
function Module.SetHot(hot: boolean)
	--[[ Applying ]]

	for _index: number, marker: Frame in ipairs({ elems["MarkerV"], elems["MarkerH"] }) do
		marker:FindFirstChild("Glow").ImageTransparency = if hot then 0.15 else 0.55
	end
end

--%%%%%%%%%%%%%%%%%%%% Fill Card

--[[
	Writes an item on a card: its picture and name, the outline and glow in its rarity's colour; a gold card instead
	shows the star, "???" and gold. A skin with a snail shows the snail, posed, in place of its picture, in the card's
	S_Model viewport; a reel card (inReel) shows the snail's picture instead (SKIN_PICTURES), as a rolling reel can't
	draw that many snails. A card with no name centres its picture (the card's Look_NoName* attributes).
]]
function Module.FillCard(card: Frame, itemId: string, gold: boolean, showName: boolean, inReel: boolean?)
	--[[ Data ]]

	local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData
	local snail: string? = if gold then nil else SkinModels.GetModelName(itemId)
	local picture: string? = if snail and inReel then _settings.SKIN_PICTURES[snail] else nil
	local live: boolean = snail ~= nil and not inReel

	--[[ Elements ]]

	local icon: ImageLabel = card:FindFirstChild("S_Icon", true)
	local model: ViewportFrame = card:FindFirstChild("S_Model", true)
	local star: ImageLabel = card:FindFirstChild("S_Star", true)
	local name: TextLabel = card:FindFirstChild("S_Name", true)
	local homeIcon: ImageLabel = prefabs["Card"]:FindFirstChild("S_Icon", true)
	local homeStar: ImageLabel = prefabs["Card"]:FindFirstChild("S_Star", true)

	--[[ Applying ]]

	local color: Color3 = Module.GetRarityColor(if gold then "Legendary" else item.Rarity)
	card:FindFirstChild("S_Stroke", true).ImageColor3 = color
	card:FindFirstChild("S_Glow", true).ImageColor3 = color
	icon.Image = picture or item.IconId
	icon.Visible = not gold and not live
	model.Visible = live
	star.Visible = gold
	name.Text = if gold then "???" else item.Name
	name.Visible = showName

	--[[ Layout ]]

	icon.Position = if showName then homeIcon.Position else prefabs["Card"]:GetAttribute("Look_NoNameIconPosition")
	icon.Size = if showName then homeIcon.Size else prefabs["Card"]:GetAttribute("Look_NoNameIconSize")
	model.Position = icon.Position
	model.Size = icon.Size
	star.Position = if showName then homeStar.Position else prefabs["Card"]:GetAttribute("Look_NoNameStarPosition")

	--[[ Snail ]]

	SkinModels.Release(card)
	if live then
		SkinModels.Put(card, itemId)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Make Card

--[[
	Returns a new card for an item, in a parent, at a size. A card sized in pixels caps its name's text at a share of
	its height, so short names don't outgrow long ones. A reel card (inReel) shows a skin's snail as a picture.
]]
--- @return Frame
function Module.MakeCard(parent: Instance, itemId: string, gold: boolean, showName: boolean, size: UDim2, inReel: boolean?)
	--[[ Cloning ]]

	local card: Frame = prefabs["Card"]:Clone()
	card.Name = "Card"
	card.Size = size
	card.Visible = true

	--[[ Elements ]]

	local nameSize: UITextSizeConstraint = card:FindFirstChild("S_Name", true):FindFirstChildOfClass("UITextSizeConstraint")

	--[[ Applying ]]

	Module.FillCard(card, itemId, gold, showName, inReel)
	if size.Y.Offset > 0 then
		nameSize.MaxTextSize = math.max(1, math.floor(size.Y.Offset * _settings.CARD_NAME_TEXT))
	end
	card.Parent = parent

	--[[ Returning ]]

	return card
end

--%%%%%%%%%%%%%%%%%%%% Get Rarity Color

--[[
	Returns a rarity's colour as the odds list draws it (the RaritySection prefab's Look_<Rarity>_Color).
]]
--- @return Color3
function Module.GetRarityColor(rarity: string)
	return prefabs["RaritySection"]:GetAttribute(`Look_{rarity}_Color`) or prefabs["RaritySection"]:GetAttribute("Look_Common_Color")
end

--%%%%%%%%%%%%%%%%%%%% Build Reel

--[[
	Makes one reel of a pack: its band or column placed for the pack's size, its strip(s) of cards (the one-crate
	reel also fills its lens), and where it starts and stops.
]]
--- @param odds { [string]: number }
--- @param row Crates_CrateData?
--- @return Crates_Reel
function Module._buildReel(count: number, index: number, itemId: string, gold: boolean, odds, row)
	--[[ Local Variables ]]

	local area: Vector2 = elems["Reels"].AbsoluteSize
	local unit: number = math.min(area.X / 1920, area.Y / 1080)
	local offset: Vector2 = (area - Vector2.new(1920, 1080) * unit) / 2
	local vertical: boolean = count > 3
	local frame: Frame = (if vertical then prefabs["Column"] else prefabs["Band"]):Clone()
	local cards: number = if vertical then _settings.COLUMN_CARDS else _settings.STRIP_CARDS
	local win: number = if vertical then _settings.COLUMN_WIN_CARD else _settings.WIN_CARD
	local size: Vector2
	local cardSize: Vector2

	--[[ Placing ]]

	if vertical then
		local columnSize: Vector2 = _settings.COLUMN_SIZE * unit
		local pitch: number = columnSize.X + _settings.COLUMN_GAP * unit
		local first: number = area.X / 2 - pitch * 4.5
		size = columnSize
		frame.Position = UDim2.fromOffset(first + pitch * (index - 1), offset.Y + _settings.COLUMN_Y * unit)
		local width: number = columnSize.X * _settings.COLUMN_CARD_FILL
		cardSize = Vector2.new(width, width / _settings.CARD_ASPECT)
	else
		local height: number = _settings.BAND_HEIGHT[math.min(count, 3)] * unit
		size = Vector2.new(area.X, height)
		frame.Position = UDim2.fromOffset(area.X / 2, offset.Y + _settings.BAND_Y[math.min(count, 3)][index] * unit)
		local cardHeight: number = height * _settings.CARD_FILL
		cardSize = Vector2.new(cardHeight * _settings.CARD_ASPECT, cardHeight)
	end
	frame.Size = UDim2.fromOffset(size.X, size.Y)
	local centre: Vector2 = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
	frame.Name = `Reel{index}`
	frame.Visible = true

	--[[ Look ]]

	if row and not vertical then
		frame:FindFirstChild("S_LineTop", true).BackgroundColor3 = row.Glow
		frame:FindFirstChild("S_LineBottom", true).BackgroundColor3 = row.Glow
	end

	--[[ Cards ]]

	local span: number = if vertical then cardSize.Y else cardSize.X
	local gap: number = span * _settings.CARD_GAP
	local pitch: number = span + gap
	local strips = { frame:FindFirstChild("S_Strip", true) } --- @type { Frame }
	local lens: Frame? = frame:FindFirstChild("S_Lens", true)
	if lens and count == 1 then
		local zoom: Frame = lens:FindFirstChild("S_Zoom", true)
		lens.Visible = true
		lens.Size = UDim2.new(0, span * _settings.LENS_WIDTH, 0.94, 0)
		zoom.Size = UDim2.fromOffset(size.X, size.Y)
		zoom:FindFirstChild("S_ZoomScale").Scale = _settings.LENS_ZOOM
		frame:FindFirstChild("S_Dim", true).BackgroundTransparency = 1 - _settings.LENS_DIM
		table.insert(strips, lens:FindFirstChild("S_LensStrip", true))
	end

	--[[ Filling ]]

	local winCard: Frame
	for cardIndex: number = 0, cards - 1 do
		local cardId: string = if cardIndex == win then itemId else Module._getFiller(odds)
		local position: UDim2 = if vertical then UDim2.fromOffset((size.X - cardSize.X) / 2, cardIndex * pitch) else UDim2.fromOffset(cardIndex * pitch, (size.Y - cardSize.Y) / 2)
		for _stripIndex: number, strip: Frame in ipairs(strips) do
			local card: Frame = Module.MakeCard(strip, cardId, cardIndex == win and gold, not vertical, UDim2.fromOffset(cardSize.X, cardSize.Y), true)
			card.Position = position
			if cardIndex == win then
				winCard = card
			end
		end
	end
	frame.Parent = elems["Reels"]

	--[[ Returning ]]

	local start: number = if vertical then (cards - 3) * pitch + span / 2 else 2 * pitch + span / 2
	local reel = {
		Frame = frame,
		Strips = strips,
		Min = centre - size / 2,
		Max = centre + size / 2,
		WinCard = winCard,
		Vertical = vertical,
		Pitch = pitch,
		Span = span,
		Gap = gap,
		Middle = (if vertical then size.Y else size.X) / 2,
		From = start,
		To = win * pitch + span * (_settings.LAND_SPREAD.Min + math.random() * (_settings.LAND_SPREAD.Max - _settings.LAND_SPREAD.Min)),
		Centre = win * pitch + span / 2,
		Position = start,
		Start = 0,
		Delay = 0,
		Duration = 1,
		Ease = Module._ease,
		LastIndex = nil,
		Done = false,
		TickPitch = 1,
	} --- @type Crates_Reel
	Module._setPosition(reel, start)
	return reel
end

--%%%%%%%%%%%%%%%%%%%% Place Marker

--[[
	Shows the line across the reels: upright through the bands' middle, or level across the ten columns.
]]
function Module._placeMarker(level: boolean, color: Color3)
	--[[ Local Variables ]]

	local area: Vector2 = elems["Reels"].AbsoluteSize
	local unit: number = math.min(area.X / 1920, area.Y / 1080)
	local top: number = math.huge
	local bottom: number = -math.huge
	local left: number = math.huge
	local right: number = -math.huge
	--- @param reel Crates_Reel
	for _index: number, reel in ipairs(reels) do
		top = math.min(top, reel.Min.Y)
		bottom = math.max(bottom, reel.Max.Y)
		left = math.min(left, reel.Min.X)
		right = math.max(right, reel.Max.X)
	end
	local marker: Frame = if level then elems["MarkerH"] else elems["MarkerV"]

	--[[ Applying ]]

	if level then
		marker.Position = UDim2.fromOffset((left + right) / 2, (top + bottom) / 2)
		marker.Size = UDim2.fromOffset(right - left + 24 * unit, 6 * unit)
	else
		marker.Position = UDim2.fromOffset(area.X / 2, (top + bottom) / 2)
		marker.Size = UDim2.fromOffset(6 * unit, bottom - top + 12 * unit)
	end
	marker.BackgroundColor3 = color
	for _index: number, child: Instance in ipairs(marker:GetChildren()) do
		if child:IsA("Frame") then
			child.BackgroundColor3 = color
		elseif child:IsA("ImageLabel") then
			child.ImageColor3 = color
		end
	end
	marker.Visible = true
	Module.SetHot(false)
end

--%%%%%%%%%%%%%%%%%%%% Set Position

--[[
	Moves a reel's strips so a point of the strip sits under the line.
]]
--- @param reel Crates_Reel
function Module._setPosition(reel, position: number)
	--[[ Applying ]]

	reel.Position = position
	local shift: number = reel.Middle - position
	for _index: number, strip: Frame in ipairs(reel.Strips) do
		strip.Position = if reel.Vertical then UDim2.fromOffset(0, shift) else UDim2.fromOffset(shift, 0)
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Plays the reel's tick, never closer together than TICK_GAP, softer for the ten-pack.
]]
function Module._tick(pitch: number, reelCount: number)
	--[[ Checks ]]

	-- Skip a tick too soon after the last
	if os.clock() - lastTick < _settings.TICK_GAP then
		return
	end

	--[[ Playing ]]

	lastTick = os.clock()
	I.Sound.Play({
		Name = "Crate_Tick",
		SoundGroup = "SFX",
		Volume = if reelCount >= 10 then 0.62 else 0.85,
		PitchMin = _settings.TICK_PITCH.Min * pitch,
		PitchMax = _settings.TICK_PITCH.Max * pitch,
	})
end

--%%%%%%%%%%%%%%%%%%%% Ease

--[[
	Returns the reel's progress at a share of its time, on ROLL_CURVE (a cubic bezier through 0,0 and 1,1).
]]
--- @return number
function Module._ease(t: number)
	--[[ Local Variables ]]

	local curve = _settings.ROLL_CURVE --- @type { number }
	local x1: number, y1: number, x2: number, y2: number = curve[1], curve[2], curve[3], curve[4]
	local low: number = 0
	local high: number = 1
	local s: number = t

	--[[ Solving ]]

	-- Find the curve's parameter whose x is t, by halving
	for _step: number = 1, 30 do
		local x: number = 3 * (1 - s) ^ 2 * s * x1 + 3 * (1 - s) * s ^ 2 * x2 + s ^ 3
		if x < t then
			low = s
		else
			high = s
		end
		s = (low + high) / 2
	end

	--[[ Returning ]]

	return 3 * (1 - s) ^ 2 * s * y1 + 3 * (1 - s) * s ^ 2 * y2 + s ^ 3
end

--%%%%%%%%%%%%%%%%%%%% Get Filler

--[[
	Returns a card for the strip, weighted by the crate's odds; legendaries never fill a strip (CS's rule).
]]
--- @param odds { [string]: number }
--- @return string
function Module._getFiller(odds)
	--[[ Local Variables ]]

	local total: number = 0
	local rows = {} --- @type { { any } }
	local allLegendary: boolean = Module._isAllLegendary(odds)
	for itemId: string, chance: number in pairs(odds) do
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		if item and (item.Rarity ~= "Legendary" or allLegendary) then
			total += chance
			table.insert(rows, { itemId, chance })
		end
	end

	--[[ Picking ]]

	local roll: number = math.random() * total
	for _index: number, rowEntry: { any } in ipairs(rows) do
		roll -= rowEntry[2]
		if roll <= 0 then
			return rowEntry[1]
		end
	end

	--[[ Returning ]]

	return rows[#rows][1]
end

--%%%%%%%%%%%%%%%%%%%% Get Stop Order

--[[
	Returns each result's place in the stopping order (0 first): by rarity, the rarest last, ties at random.
]]
--- @param results { Crates_Result }
--- @return { [number]: number }
function Module._getStopOrder(results)
	--[[ Local Variables ]]

	local ranked = {} --- @type { { number } }
	--- @param result Crates_Result
	for index: number, result in ipairs(results) do
		local rarity: string = I.G_Inventory.Items[result.ItemId].Rarity
		table.insert(ranked, { I.Rarity.GetRarityIndex(rarity) + math.random() * 0.5, index })
	end
	table.sort(ranked, function(a: { number }, b: { number }): boolean
		return a[1] < b[1]
	end)

	--[[ Returning ]]

	local order = {} --- @type { [number]: number }
	for place: number, entry: { number } in ipairs(ranked) do
		order[entry[2]] = place - 1
	end
	return order
end

--%%%%%%%%%%%%%%%%%%%% Is All Legendary

--[[
	Returns whether every item in the odds is a legendary (the golden reel's pool).
]]
--- @param odds { [string]: number }
--- @return boolean
function Module._isAllLegendary(odds)
	--[[ Checking ]]

	for itemId: string, _chance: number in pairs(odds) do
		if I.G_Inventory.Items[itemId].Rarity ~= "Legendary" then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

return Module
