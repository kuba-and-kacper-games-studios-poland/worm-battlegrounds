--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Kinds ]]

--[[
	Motes: shapes round the letters (a pixel speck, a comet, a round ring opening out, a turned gem with a white heart),
	per kind its shape, how many, where on a letter one is born (a share of its height from the top), how far it travels
	down and across (design px, up and left negative), how its travel eases (1 steady, 2 falling), how far it sways, how
	long it lives (seconds) and its size (design px; a ring's when fully open)
]]
--- @type { [string]: { [string]: any } }
local MOTES = {
	Embers = { Shape = "Speck", Count = 6, From = 0.7, Travel = -22, Drift = 0, Ease = 1, Sway = 2, Life = 1.2, Size = 6 },
	Drops = { Shape = "Speck", Count = 6, From = 0.85, Travel = 18, Drift = 0, Ease = 2, Sway = 0, Life = 0.9, Size = 6 },
	Flakes = { Shape = "Speck", Count = 6, From = 0.1, Travel = 16, Drift = 0, Ease = 1, Sway = 4, Life = 1.8, Size = 5 },
	Comets = { Shape = "Comet", Count = 3, From = 0, Travel = 16, Drift = 48, Ease = 1, Sway = 0, Life = 0.75, Size = 5 },
	Rings = { Shape = "Ring", Count = 3, From = 0.5, Travel = 0, Drift = 0, Ease = 1, Sway = 0, Life = 0.9, Size = 44 },
	Gems = { Shape = "Gem", Count = 5, From = 0.3, Travel = -12, Drift = 0, Ease = 1, Sway = 1.5, Life = 1.1, Size = 9 },
}

--[[ Comet ]]

--[[
	A comet: a white head trailing a tail in its colour that fades out behind it, with a fainter glow round the tail (its
	length and widths, design px), turned along its path
]]
local COMET_TAIL_LENGTH: number = 30
local COMET_TAIL_WIDTH: number = 3
local COMET_GLOW_WIDTH: number = 8

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

--- @class Utils_LetterText_Motes
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Makes the shapes for each kind of mote a LetterText's effects name, in its letters' frame, each waiting a moment
	before it's first born (rings and gems behind the letters, so they never hide one; the rest pass in front).
]]
--- @param component Utils_LetterText
function Module.Build(component)
	--- @param mote { [string]: any }
	for kind: string, mote in pairs(MOTES) do
		--[[ Checks ]]

		-- Skip kinds the effects don't name
		if not component.Effects[kind] then
			continue
		end

		--[[ Building ]]

		for moteIndex: number = 1, mote.Count do
			local speck: Frame = Instance.new("Frame")
			speck.Name = `{kind}{moteIndex}`
			speck.AnchorPoint = Vector2.new(0.5, 0.5)
			speck.BorderSizePixel = 0
			speck.Rotation = if mote.Shape == "Gem" then 45 elseif mote.Shape == "Comet" then math.deg(math.atan2(mote.Travel, mote.Drift)) else 0
			speck.Size = UDim2.fromOffset(mote.Size, mote.Size)
			speck.Visible = false
			speck.ZIndex = if mote.Shape == "Ring" or mote.Shape == "Gem" then 1 else 4
			speck.Parent = component._letterFrame
			local scale: UIScale = Instance.new("UIScale")
			scale.Parent = speck
			local ring: UIStroke? = nil
			local parts = {} --- @type { Frame }

			if mote.Shape == "Ring" then
				speck.BackgroundTransparency = 1
				ring = Instance.new("UIStroke")
				ring.Thickness = 2
				ring.Parent = speck
				local round: UICorner = Instance.new("UICorner")
				round.CornerRadius = UDim.new(1, 0)
				round.Parent = speck
			elseif mote.Shape == "Gem" then
				local heart: Frame = Instance.new("Frame")
				heart.Name = "Heart"
				heart.AnchorPoint = Vector2.new(0.5, 0.5)
				heart.BackgroundColor3 = Color3.new(1, 1, 1)
				heart.BorderSizePixel = 0
				heart.Position = UDim2.fromScale(0.5, 0.5)
				heart.Size = UDim2.fromScale(0.4, 0.4)
				heart.ZIndex = 5
				heart.Parent = speck
			elseif mote.Shape == "Comet" then
				-- The frame only carries the parts: a glow and a tail stretching back from the head, then the head on top
				speck.BackgroundTransparency = 1
				--- @param part { [string]: any }
				for partIndex: number, part in ipairs({
					{ Name = "Glow", Width = COMET_GLOW_WIDTH, Length = COMET_TAIL_LENGTH * 0.8, From = 0.75 },
					{ Name = "Tail", Width = COMET_TAIL_WIDTH, Length = COMET_TAIL_LENGTH, From = 0 },
					{ Name = "Head", Width = mote.Size, Length = mote.Size, From = nil },
				}) do
					local piece: Frame = Instance.new("Frame")
					piece.Name = part.Name
					piece.AnchorPoint = if part.From then Vector2.new(1, 0.5) else Vector2.new(0.5, 0.5)
					piece.BorderSizePixel = 0
					piece.Position = if part.From then UDim2.new(0.5, mote.Size / 2, 0.5, 0) else UDim2.fromScale(0.5, 0.5)
					piece.Size = UDim2.fromOffset(part.Length, part.Width)
					piece.ZIndex = partIndex
					piece.Parent = speck
					if part.From then
						local fading: UIGradient = Instance.new("UIGradient")
						fading.Transparency = NumberSequence.new(1, part.From)
						fading.Parent = piece
					end
					table.insert(parts, piece)
				end
			end

			table.insert(component._motes, {
				Kind = kind,
				Frame = speck,
				Scale = scale,
				Stroke = ring,
				Parts = parts,
				Life = 0,
				Duration = 0,
				Delay = math.random() * mote.Life,
				X = 0,
				Y = 0,
				Sway = 0,
			})
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves a LetterText's motes one step: each waits out its pause, travels and fades over its life, then is born again
	on a random letter (where it was last placed) in one of the colours (`sample` reads a colour off the keypoints).
]]
--- @param component Utils_LetterText
--- @param sample (keypoints: { ColorSequenceKeypoint }, alpha: number) -> Color3
function Module.Step(component, deltaTime: number, sample)
	--[[ Local Variables ]]

	local count: number = #component._letters
	local keypoints = component.Keypoints --- @type { ColorSequenceKeypoint }?

	--[[ Moving ]]

	--- @param mote Utils_LetterTextMote
	for _index: number, mote in ipairs(component._motes) do
		local kind = MOTES[mote.Kind] --- @type { [string]: any }

		-- Wait out the pause before the first one, and skip a word with no letters
		if mote.Delay > 0 or count == 0 then
			mote.Delay -= deltaTime
			continue
		end

		mote.Life += deltaTime

		-- One that lived its life is born again on a random letter, in one of the colours (flakes paler, comet heads white)
		if mote.Life >= mote.Duration then
			local letter = component._letters[math.random(count)] --- @type Utils_LetterTextLetter
			local tint: Color3 = if keypoints then sample(keypoints, math.random()) else Color3.new(1, 1, 1)
			mote.X = letter.X + (math.random() - 0.5) * letter.Width
			mote.Y = letter.Y + (kind.From - 0.5) * letter.Height
			mote.Life = 0
			mote.Duration = kind.Life * (0.7 + math.random() * 0.6)
			mote.Sway = math.random() * math.pi * 2
			mote.Frame.BackgroundColor3 = if mote.Kind == "Flakes" then tint:Lerp(Color3.new(1, 1, 1), 0.5) else tint
			if mote.Stroke then
				mote.Stroke.Color = tint
			end
			for _partIndex: number, part: Frame in ipairs(mote.Parts) do
				part.BackgroundColor3 = if part.Name == "Head" then Color3.new(1, 1, 1) else tint
			end
			continue
		end

		local alpha: number = mote.Life / mote.Duration
		local fade: number = alpha ^ 2
		mote.Frame.Visible = true
		mote.Frame.Position = UDim2.new(mote.X, kind.Drift * alpha + math.sin(alpha * 6 + mote.Sway) * kind.Sway, mote.Y, kind.Travel * alpha ^ kind.Ease)

		-- A ring opens out as it fades, a gem twinkles in and out, a comet's parts and a speck fade
		if kind.Shape == "Ring" then
			mote.Scale.Scale = 0.15 + 0.85 * alpha
			mote.Stroke.Transparency = fade
		elseif kind.Shape == "Gem" then
			mote.Scale.Scale = math.sin(alpha * math.pi) * component.Intensity
		elseif kind.Shape == "Comet" then
			for _partIndex: number, part: Frame in ipairs(mote.Parts) do
				part.BackgroundTransparency = fade
			end
		else
			mote.Frame.BackgroundTransparency = fade
		end
	end
end

return Module
