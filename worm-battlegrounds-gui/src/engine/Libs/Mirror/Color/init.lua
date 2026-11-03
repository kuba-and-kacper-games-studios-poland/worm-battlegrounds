--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local LUMINANCE_WEIGHTS: Vector3 = Vector3.new(0.299, 0.587, 0.114)

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

--- @class UmeGui_Ume_Library_Color : Ume_Library
local Color = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Color._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Color = Color --- @type UmeGui_Ume_Library_Color
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Color At Time

--[[
	Returns the interpolated color of a ColorSequence at `goalTime` (clamped to the sequence).
]]
--- @return Color3
function Color.GetColorAtTime(sequence: ColorSequence, goalTime: number)
	--[[ Local Variables ]]

	local keypoints = sequence.Keypoints --- @type { ColorSequenceKeypoint }
	local firstKeypoint: ColorSequenceKeypoint = keypoints[1]
	local lastKeypoint: ColorSequenceKeypoint = keypoints[#keypoints]

	--[[ Checks ]]

	-- Clamp times outside the sequence to its ends
	if goalTime <= firstKeypoint.Time then
		return firstKeypoint.Value
	end
	if goalTime >= lastKeypoint.Time then
		return lastKeypoint.Value
	end

	--[[ Finding ]]

	for index: number = 1, #keypoints - 1 do
		local currentKeypoint: ColorSequenceKeypoint = keypoints[index]
		local nextKeypoint: ColorSequenceKeypoint = keypoints[index + 1]

		-- Skip segments that end before the goal time
		if goalTime > nextKeypoint.Time then
			continue
		end

		--[[ Interpolating ]]

		local span: number = nextKeypoint.Time - currentKeypoint.Time

		-- Use the next value for zero-length segments
		if span <= 0 then
			return nextKeypoint.Value
		end

		return currentKeypoint.Value:Lerp(nextKeypoint.Value, (goalTime - currentKeypoint.Time) / span)
	end

	--[[ Returning ]]

	return lastKeypoint.Value
end

--%%%%%%%%%%%%%%%%%%%% Get Color Luminance

--[[
	Returns the perceptual grayscale luminance of a color (0–1).
]]
--- @return number
function Color.GetColorLuminance(color: Color3)
	return color.R * LUMINANCE_WEIGHTS.X + color.G * LUMINANCE_WEIGHTS.Y + color.B * LUMINANCE_WEIGHTS.Z
end

--%%%%%%%%%%%%%%%%%%%% To Grayscale Tint

--[[
	Converts a color to grayscale, then scales `tintColor` by that luminance.
]]
--- @return Color3
function Color.ToGrayscaleTint(color: Color3, tintColor: Color3)
	--[[ Calculating ]]

	local luminance: number = Color.GetColorLuminance(color)

	--[[ Returning ]]

	return Color3.new(tintColor.R * luminance, tintColor.G * luminance, tintColor.B * luminance)
end

--%%%%%%%%%%%%%%%%%%%% Map Color Sequence

--[[
	Returns a ColorSequence with every keypoint color passed through `mapper`.
]]
--- @return ColorSequence
function Color.MapColorSequence(sequence: ColorSequence, mapper: (color: Color3) -> Color3)
	--[[ Mapping ]]

	local keypoints = {} --- @type { ColorSequenceKeypoint }

	for _index: number, keypoint: ColorSequenceKeypoint in ipairs(sequence.Keypoints) do
		table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.Time, mapper(keypoint.Value)))
	end

	--[[ Returning ]]

	return ColorSequence.new(keypoints)
end

--%%%%%%%%%%%%%%%%%%%% Lerp Color Sequence

--[[
	Interpolates between two ColorSequences at the keypoint times of `fromSequence`.
	`toSequence` is sampled at those times, so the keypoint counts do not have to match.
]]
--- @return ColorSequence
function Color.LerpColorSequence(fromSequence: ColorSequence, toSequence: ColorSequence, alpha: number)
	--[[ Interpolating ]]

	local keypoints = {} --- @type { ColorSequenceKeypoint }

	for _index: number, fromKeypoint: ColorSequenceKeypoint in ipairs(fromSequence.Keypoints) do
		local toColor: Color3 = Color.GetColorAtTime(toSequence, fromKeypoint.Time)
		table.insert(keypoints, ColorSequenceKeypoint.new(fromKeypoint.Time, fromKeypoint.Value:Lerp(toColor, alpha)))
	end

	--[[ Returning ]]

	return ColorSequence.new(keypoints)
end

return Color
