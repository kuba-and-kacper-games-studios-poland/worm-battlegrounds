--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lighting"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Tweens ]]

local playingTweens = {} --- @type { [string]: { [string]: Lighting_PlayingTween } }

--[[ ClockTime ]]

local CLOCK_TIME_TOLERANCE: number = 0.001

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

--- @class Lighting_Client_Tweening
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Moves one lighting property to its goal: tweened when a TweenInfo is given, set at once otherwise.
	A tween already heading to that goal keeps playing; any other tween on the property is cancelled first.
]]
--- @param clockTimeDirection Lighting_ClockTimeDirection?
function Module.Apply(instance: Instance, effectName: string, propertyName: string, goalValue: any, tweenInfo: TweenInfo?, clockTimeDirection)
	--[[ Data ]]

	--- @type Lighting_PlayingTween?
	local playing = playingTweens[effectName] and playingTweens[effectName][propertyName]

	--[[ Checks ]]

	-- Skip when the playing tween already heads to this goal
	if playing and playing.Goal == goalValue then
		return
	end

	--[[ Cancelling ]]

	Module._cancel(effectName, propertyName)

	--[[ Checks ]]

	-- Skip when the property already has the goal
	if instance[propertyName] == goalValue then
		return
	end

	-- Set at once when there's no tween or the type can't be tweened
	if not tweenInfo or typeof(goalValue) == "string" then
		instance[propertyName] = goalValue
		return
	end

	--[[ Local Variables ]]

	local isClockTime: boolean = effectName == "Lighting" and propertyName == "ClockTime"
	local clockTimeDelta: number = if isClockTime then Module._getClockTimeDelta(instance[propertyName], goalValue, clockTimeDirection) else 0

	-- Skip when ClockTime is already at the goal
	if isClockTime and clockTimeDelta == 0 then
		return
	end

	--[[ Tweening ]]

	local proxy: NumberValue? = nil
	local Property_TweenGoal = { [propertyName] = goalValue } --- @type { [string]: any }

	-- ClockTime wraps at 24: tween a proxy past the wrap and write it back modulo 24
	if isClockTime then
		proxy = Instance.new("NumberValue")
		proxy.Value = instance[propertyName]
		Property_TweenGoal = { Value = proxy.Value + clockTimeDelta }
	end

	local Property_Tween: Tween = TweenService:Create(proxy or instance, tweenInfo, Property_TweenGoal)

	--[[ Saving ]]

	--- @type Lighting_PlayingTween
	local entry = { Tween = Property_Tween, Goal = goalValue, Proxy = proxy }

	playingTweens[effectName] = playingTweens[effectName] or {}
	playingTweens[effectName][propertyName] = entry

	--[[ Connections ]]

	-- Write the proxy back to ClockTime while this tween is the current one
	if proxy then
		proxy.Changed:Connect(function(value: number)
			if playingTweens[effectName][propertyName] == entry then
				instance[propertyName] = value % 24
			end
		end)
	end

	-- Clear the entry once the tween ends on its own
	Property_Tween.Completed:Connect(function()
		--[[ Checks ]]

		-- Skip a tween another update replaced
		if playingTweens[effectName][propertyName] ~= entry then
			return
		end

		--[[ Clearing ]]

		playingTweens[effectName][propertyName] = nil

		-- Write the final ClockTime and remove the proxy
		if proxy then
			instance[propertyName] = proxy.Value % 24
			proxy:Destroy()
		end
	end)

	--[[ Playing ]]

	Property_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Cancel

--[[
	Cancels the property's playing tween, leaving the property where the tween got to.
]]
function Module._cancel(effectName: string, propertyName: string)
	--[[ Data ]]

	--- @type Lighting_PlayingTween?
	local playing = playingTweens[effectName] and playingTweens[effectName][propertyName]

	--[[ Checks ]]

	-- Check if a tween is playing
	if not playing then
		return
	end

	--[[ Cancelling ]]

	playingTweens[effectName][propertyName] = nil
	playing.Tween:Cancel()

	-- Remove the ClockTime proxy
	if playing.Proxy then
		playing.Proxy:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Property Tween Info

--[[
	Returns the TweenInfo one property tweens with, or nil when it's set at once.
	A table is read as `{ [effectName]: TweenInfo | { [propertyName]: TweenInfo } }`, then as `{ [propertyName]: TweenInfo }`.
]]
--- @param tweenInfo TweenInfo | { [string]: any } | nil
--- @return TweenInfo?
function Module.GetPropertyTweenInfo(tweenInfo, effectName: string, propertyName: string)
	--[[ Checks ]]

	-- One TweenInfo covers every property
	if typeof(tweenInfo) == "TweenInfo" then
		return tweenInfo
	end

	-- No tween at all
	if typeof(tweenInfo) ~= "table" then
		return nil
	end

	--[[ Finding ]]

	local effectTweenInfo: any = tweenInfo[effectName]
	local foundTweenInfo: any = tweenInfo[propertyName]

	-- An effect entry comes before a property entry
	if typeof(effectTweenInfo) == "TweenInfo" then
		foundTweenInfo = effectTweenInfo
	elseif typeof(effectTweenInfo) == "table" then
		foundTweenInfo = effectTweenInfo[propertyName]
	end

	--[[ Returning ]]

	return if typeof(foundTweenInfo) == "TweenInfo" then foundTweenInfo else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Clock Time Delta

--[[
	Returns how many hours ClockTime moves to reach the goal in the direction, forward positive (Shortest when nil).
	A goal within CLOCK_TIME_TOLERANCE hours of the current time returns 0.
]]
--- @param direction Lighting_ClockTimeDirection?
--- @return number
function Module._getClockTimeDelta(current: number, goal: number, direction)
	--[[ Calculating ]]

	local forward: number = (goal - current) % 24

	--[[ Checks ]]

	-- Check if ClockTime is already at the goal
	if forward < CLOCK_TIME_TOLERANCE or forward > 24 - CLOCK_TIME_TOLERANCE then
		return 0
	end

	-- Always run forward, through midnight when needed
	if direction == "Forward" then
		return forward
	end

	-- Always run backward, through midnight when needed
	if direction == "Backward" then
		return forward - 24
	end

	--[[ Returning ]]

	return if forward > 12 then forward - 24 else forward
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
