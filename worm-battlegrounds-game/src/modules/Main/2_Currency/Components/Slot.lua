--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--- @type Currency_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = I.S.RunService
local TweenService: TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ BigNum ]]

local zeroBN = I.BN.new("0")
local abbreviateThresholdBN = I.BN.new("1000000000000000")

local DISPLAY_ABBREVIATE_LENGTH: number = 16
local FRACTION_SCALE: number = 100000
local fractionScaleBN = I.BN.new(`{FRACTION_SCALE}`)

--[[ Orbs - Count ]]

local ORB_COUNT_MIN: number = 3
local ORB_COUNT_MAX: number = 5
local ORB_FRACTION_THRESHOLD = I.BN.new("1000")
local ORB_FRACTION_STEP: number = 0.05
local ORB_FRACTION_BONUS_MIN: number = 1
local ORB_FRACTION_BONUS_MAX: number = 2

--[[ Orbs - Scale ]]

local ORB_UI_SCALE_STEP: number = 0.05
local ORB_UI_SCALE_MAX: number = 0.5
local ORB_UI_SCALE_DECAY: number = 0.55
local ORB_UI_SCALE_UP_RATE: number = 14

--[[ Orbs - Sound ]]

local ORB_COLLECT_SOUND_NAME: string = "Currency_OrbCollect"
local ORB_COLLECT_SOUND_VOLUME: number = 0.5

--[[ Orbs - Outbound ]]

local ORB_VELOCITY_MIN: number = 420
local ORB_VELOCITY_MAX: number = 620
local ORB_LAUNCH_ANGLE_MIN: number = -35
local ORB_LAUNCH_ANGLE_MAX: number = 35
local ORB_ATTRACT_AFTER_MIN: number = 0.12
local ORB_ATTRACT_AFTER_MAX: number = 0.2

--[[ Orbs - Return ]]

local ORB_ATTRACT_ARRIVE_RADIUS: number = 48
local ORB_ATTRACT_RELEASE_DURATION: number = 0.12
local ORB_ATTRACT_PAUSE_PROGRESS: number = 0.7
local ORB_FLUSH_DELAY: number = 4

--[[ Orbs - Visual ]]

local ORB_SIZE_SCALE_MIN: number = 0.075
local ORB_SIZE_SCALE_MAX: number = 0.125
local ORB_LIFETIME_MIN: number = 1.35
local ORB_LIFETIME_MAX: number = 1.75
local ORB_ROTATION_MIN: number = -15
local ORB_ROTATION_MAX: number = 15
local ORB_ROTATION_SPEED_MIN: number = -1
local ORB_ROTATION_SPEED_MAX: number = 1
local ORB_Z_INDEX: number = 10

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

--- @class Currency_Slot : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field CurrencyName string
--- @field CustomFormat string
--- @field ShortFromBN any?
--- @field SpawnOrbs boolean
---
--- # Elements #
---
--- @field Abbreviation string
--- @field CurrencyDir Folder
--- @field CurrencyValue NumberValue
--- @field CurrencyUIScale UIScale
--- @field OrbsContainer GuiObject?
---
--- # Orbs #
---
--- @field LastSpawnOrbs number?
--- @field PendingSpawnOrbs boolean
--- @field LastRawAmount string?
--- @field DefaultUIScale number
--- @field UIScaleBoost number
--- @field UIScaleConnection RBXScriptConnection?
--- @field ActiveOrbs { [string]: number }
--- @field PendingOrbValues { string }
--- @field OrbsEmitter UIEmitter_Instance?
--- @field OrbFlushThread thread?
local Component = {}
Component.__index = Component
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Attributes ]]

	self:GetAttributes()
	if not self.CurrencyName then
		return
	end

	--[[ Elements ]]

	self:GetElements()
	if not self.CurrencyDir or not self.CurrencyUIScale then
		return
	end
	if self.SpawnOrbs and not self.OrbsContainer then
		return
	end

	--[[ Currency Value ]]

	self.CurrencyValue = Instance.new("NumberValue")
	self.CurrencyValue.Name = self.CurrencyName
	self.CurrencyValue.Parent = self.Instance

	--[[ Display State ]]

	self.DefaultUIScale = self.CurrencyUIScale.Scale
	self.UIScaleBoost = 0

	--[[ Orb State ]]

	self.ActiveOrbs = {}
	self.PendingOrbValues = {}
	self.PendingSpawnOrbs = false

	if self.SpawnOrbs then
		self.LastSpawnOrbs = self.CurrencyDir:GetAttribute(`{self.CurrencyName}-SpawnOrbs`)
	end

	--[[ Connections ]]

	self:CreateConnections()

	--[[ Initial Update ]]

	self:UpdateValue()
	self:UpdateDisplay()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	-- Cancelling Orb Flush
	self:CancelOrbFlush()

	-- Stopping the UI Scale ease
	if self.UIScaleConnection then
		self.UIScaleConnection:Disconnect()
		self.UIScaleConnection = nil
	end

	-- Destroying Orbs Emitter
	if self.OrbsEmitter then
		self.OrbsEmitter:Destroy()
		self.OrbsEmitter = nil
	end

	-- Destroying Currency Value
	if self.CurrencyValue then
		self.CurrencyValue:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Getting and storing key attributes.
]]
function Component:GetAttributes()
	--[[ Checks ]]

	local currencyName = self.Instance:GetAttribute("Currency_Name")
	if typeof(currencyName) ~= "string" or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid CurrencyName! -`, self.Instance)
		return
	end

	--[[ Saving ]]

	self.CurrencyName = currencyName
	self.CustomFormat = self.Instance:GetAttribute("Currency_CustomFormat")
	if self.CustomFormat == "" then
		self.CustomFormat = nil
	end

	self.SpawnOrbs = self.Instance:GetAttribute("Currency_SpawnOrbs") == true
	self.Abbreviation = ""

	-- Abbreviate from a lower amount when the label asks for it
	local shortFrom: number = self.Instance:GetAttribute("Currency_ShortFrom") or 0
	if shortFrom > 0 then
		self.ShortFromBN = I.BN.new(string.format("%d", shortFrom))
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	--[[ Checks ]]

	if not self.Instance:IsA("TextLabel") then
		warn(`[{_localName}::{script.Name}]: ({self.Instance.Name}) is not a TextLabel! -`, self.Instance)
		return
	end

	--[[ Replicator ]]

	self.CurrencyDir = I.Replicator.GetFolder(_localName)

	--[[ Currency UI Scale ]]

	local currencyUIScaleObjectValue: Instance? = self.Instance:FindFirstChild("Currency_UIScale")
	if not currencyUIScaleObjectValue then
		warn(`[{_localName}::{script.Name}]: Currency_UIScale ObjectValue is missing! -`, self.Instance)
		return
	end

	if not currencyUIScaleObjectValue:IsA("ObjectValue") then
		warn(`[{_localName}::{script.Name}]: Currency_UIScale is not an ObjectValue! -`, self.Instance)
		return
	end

	local currencyUIScale: Instance? = currencyUIScaleObjectValue.Value
	if not currencyUIScale or not currencyUIScale:IsA("UIScale") then
		warn(`[{_localName}::{script.Name}]: Currency_UIScale does not reference a UIScale! -`, self.Instance)
		return
	end

	self.CurrencyUIScale = currencyUIScale

	--[[ Orbs Container ]]

	if self.SpawnOrbs then
		local currencyGui: ScreenGui? = I.UserInterface.UI["Currency"]
		if not currencyGui then
			warn(`[{_localName}::{script.Name}]: Currency UserInterface is missing! -`, self.Instance)
			return
		end

		local orbsContainer: Instance? = currencyGui:FindFirstChild("U_OrbsContainer", true)
		if not orbsContainer or not orbsContainer:IsA("GuiObject") then
			warn(`[{_localName}::{script.Name}]: U_OrbsContainer is missing! -`, self.Instance)
			return
		end

		self.OrbsContainer = orbsContainer
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for currency updates.
]]
function Component:CreateConnections()
	--[[ Currency Updated ]]

	table.insert(
		self.Connections,
		self.CurrencyDir:GetAttributeChangedSignal(self.CurrencyName):Connect(function()
			self:UpdateValue()
		end)
	)

	--[[ Spawn Orbs Updated ]]

	if self.SpawnOrbs then
		table.insert(
			self.Connections,
			self.CurrencyDir:GetAttributeChangedSignal(`{self.CurrencyName}-SpawnOrbs`):Connect(function()
				self.PendingSpawnOrbs = true
			end)
		)
	end

	--[[ Value Updated ]]

	table.insert(
		self.Connections,
		self.CurrencyValue.Changed:Connect(function()
			self:UpdateDisplay()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Value

--[[
	Updates the abbreviation and tweens the currency value.
]]
function Component:UpdateValue()
	--[[ Getting Value ]]

	local amount: string = self.CurrencyDir:GetAttribute(self.CurrencyName) or "0"
	local previousAmount: string = self.LastRawAmount or amount

	--[[ Calculating ]]

	local amountBN = I.BN.new(amount)
	local previousBN = I.BN.new(previousAmount)
	local differenceBN = amountBN - previousBN

	--[[ Checks ]]

	local shouldSpawnOrbs: boolean = false
	if self.SpawnOrbs then
		if self.PendingSpawnOrbs then
			shouldSpawnOrbs = true
			self.PendingSpawnOrbs = false
		end

		local spawnOrbs = self.CurrencyDir:GetAttribute(`{self.CurrencyName}-SpawnOrbs`)
		if spawnOrbs ~= self.LastSpawnOrbs then
			shouldSpawnOrbs = true
			self.LastSpawnOrbs = spawnOrbs
		end
	end

	--[[ Saving ]]

	self.LastRawAmount = amount

	--[[ Spawning ]]

	if shouldSpawnOrbs and differenceBN > zeroBN then
		self:SpawnCurrencyOrbs(differenceBN, previousAmount)
	end

	--[[ Tweening ]]

	self:TweenDisplayAmount(self:GetDisplayAmount(amount))
end

--%%%%%%%%%%%%%%%%%%%% Update Display

--[[
	Updates the currency display on self.Instance.
]]
function Component:UpdateDisplay()
	--[[ Formatting ]]

	local finalValue: string
	if self.Abbreviation == "" then
		finalValue = I.BN.DynamicFormat(`{math.round(self.CurrencyValue.Value)}`, DISPLAY_ABBREVIATE_LENGTH, ",")
	else
		finalValue = `{math.round(self.CurrencyValue.Value * 100) / 100}{self.Abbreviation}`
	end

	--[[ Updating ]]

	if self.CustomFormat then
		local success: boolean, result: string = pcall(string.format, self.CustomFormat, finalValue)
		self.Instance.Text = success and result or finalValue
	else
		self.Instance.Text = finalValue
	end
end

--%%%%%%%%%%%%%%%%%%%% Tween Display Amount

--[[
	Tweens the currency NumberValue toward the given raw amount string.
]]
function Component:TweenDisplayAmount(amount: string)
	--[[ Calculating ]]

	local amountBN = I.BN.new(amount)
	local suffix: string = ""
	local tweenValue: number

	if amountBN >= (self.ShortFromBN or abbreviateThresholdBN) then
		local value: string | number
		value, suffix = I.BN.AbbreviationConvert(`{amountBN}`, 2, true)
		tweenValue = I.Number.ToNumberOr(value, 0)
	else
		tweenValue = I.Number.ToNumberOr(`{amountBN}`, 0)
	end

	--[[ Checks ]]

	if suffix ~= self.Abbreviation then
		self.Abbreviation = suffix
		self.CurrencyValue.Value = tweenValue
		self:UpdateDisplay()
		return
	end

	--[[ Tweening ]]

	local Value_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
	local Value_TweenGoal = { Value = tweenValue }
	local Value_Tween: Tween = TweenService:Create(self.CurrencyValue, Value_TweenInfo, Value_TweenGoal)
	Value_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Orbs Control

--%%%%%%%%%%%%%%%%%%%% Ensure Orbs Emitter

--[[
	Creates the per-slot UIEmitter used for currency orbs.
]]
function Component:EnsureOrbsEmitter()
	--[[ Checks ]]

	if self.OrbsEmitter or not self.OrbsContainer then
		return
	end

	--[[ Creating ]]

	local texture: string = I.G_Currency.GetCurrencyIcon(self.CurrencyName) or ""

	self.OrbsEmitter = I.UIEmitter.new({
		Parent = self.OrbsContainer,
		Container = self.OrbsContainer,
		Texture = texture,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 1.15),
			NumberSequenceKeypoint.new(0.25, 1),
			NumberSequenceKeypoint.new(0.85, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		SizeSpace = "Scale",
		SizeScale = NumberRange.new(ORB_SIZE_SCALE_MIN, ORB_SIZE_SCALE_MAX),
		AspectRatio = 1,
		Velocity = NumberRange.new(ORB_VELOCITY_MIN, ORB_VELOCITY_MAX),
		InitialVelocity = function(spawnAbsolutePoint: Vector2)
			local destination: Vector2 = self.Instance.AbsolutePosition + self.Instance.AbsoluteSize * 0.5
			local away: Vector2 = spawnAbsolutePoint - destination

			if away.Magnitude <= 0.001 then
				away = Vector2.new(0, 1)
			end

			local angle: number = math.rad(I.Random.Float(ORB_LAUNCH_ANGLE_MIN, ORB_LAUNCH_ANGLE_MAX))
			local cosAngle: number = math.cos(angle)
			local sinAngle: number = math.sin(angle)
			local launchDirection: Vector2 = Vector2.new(away.X * cosAngle - away.Y * sinAngle, away.X * sinAngle + away.Y * cosAngle).Unit

			return launchDirection * I.Random.Float(ORB_VELOCITY_MIN, ORB_VELOCITY_MAX)
		end,
		Lifetime = NumberRange.new(ORB_LIFETIME_MIN, ORB_LIFETIME_MAX),
		Drag = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.2, 0.5),
			NumberSequenceKeypoint.new(0.4, 0.12),
			NumberSequenceKeypoint.new(1, 0.04),
		}),
		Rotation = NumberRange.new(ORB_ROTATION_MIN, ORB_ROTATION_MAX),
		RotationSpeed = NumberRange.new(ORB_ROTATION_SPEED_MIN, ORB_ROTATION_SPEED_MAX),
		FaceMovementDirection = false,
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(1, 1),
		AttractTo = self.Instance,
		AttractAfter = NumberRange.new(ORB_ATTRACT_AFTER_MIN, ORB_ATTRACT_AFTER_MAX),
		AttractStrength = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 0),
			NumberSequenceKeypoint.new(0.28, 2800),
			NumberSequenceKeypoint.new(0.5, 7000),
			NumberSequenceKeypoint.new(1, 12000),
		}),
		AttractMaxSpeed = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 700),
			NumberSequenceKeypoint.new(0.2, 1400),
			NumberSequenceKeypoint.new(0.45, 2400),
			NumberSequenceKeypoint.new(0.75, 3600),
			NumberSequenceKeypoint.new(1, 4800),
		}),
		AttractArriveRadius = ORB_ATTRACT_ARRIVE_RADIUS,
		AttractStopOnArrive = true,
		AttractDestroyOnArrive = false,
		AttractReleaseDuration = ORB_ATTRACT_RELEASE_DURATION,
		AttractPauseAtProgress = ORB_ATTRACT_PAUSE_PROGRESS,
		AttractArriveOnlyWhenPaused = false,
		AttractLiveFromEmitter = true,
		AttractOnArrive = function(_particle: GuiObject)
			self:OnOrbArrived()
		end,
		CullOffscreen = false,
		Rate = 0,
		ZIndex = ORB_Z_INDEX,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Orb Value

--[[
	Tracks one orb value in the active ledger and pending arrival queue.
]]
function Component:RegisterOrbValue(orbValue: string)
	--[[ Saving ]]

	self.ActiveOrbs[orbValue] = (self.ActiveOrbs[orbValue] or 0) + 1
	table.insert(self.PendingOrbValues, orbValue)
end

--%%%%%%%%%%%%%%%%%%%% Spawn Currency Orbs

--[[
	Creates and emits currency orbs for a positive currency difference.
]]
--- @param differenceBN BigNum
function Component:SpawnCurrencyOrbs(differenceBN, previousAmount: string)
	--[[ Calculating ]]

	local differenceFraction: number = 0
	if differenceBN >= ORB_FRACTION_THRESHOLD then
		local previousBN = I.BN.new(previousAmount)

		if previousBN <= zeroBN then
			differenceFraction = 1
		else
			local scaledDifferenceBN = differenceBN * fractionScaleBN
			local dividedBN = I.BN.DivideWithPrecision(`{scaledDifferenceBN}`, previousAmount, 0)
			differenceFraction = (tonumber(`{dividedBN}`) or 0) / FRACTION_SCALE
		end
	end

	--[[ Orb Count ]]

	local cappedFraction: number = math.clamp(differenceFraction, 0, 1)
	local orbCount: number = I.Random.Int(ORB_COUNT_MIN, ORB_COUNT_MAX)
	local fractionSteps: number = math.floor(cappedFraction / ORB_FRACTION_STEP)

	for _ = 1, fractionSteps do
		orbCount += I.Random.Int(ORB_FRACTION_BONUS_MIN, ORB_FRACTION_BONUS_MAX)
	end

	--[[ Orb Values ]]

	local quotientBN = I.BN.new()
	local remainderBN = I.BN.new()
	I.BN.Div(differenceBN, I.BN.new(`{orbCount}`), quotientBN, remainderBN)

	local remainderCount: number = I.Number.ToNumberOr(`{remainderBN}`, 0)
	local baseValue: string = `{quotientBN}`
	local bonusValue: string = `{quotientBN + I.BN.new("1")}`

	for _ = 1, remainderCount do
		self:RegisterOrbValue(bonusValue)
	end

	local baseCount: number = orbCount - remainderCount
	for _ = 1, baseCount do
		self:RegisterOrbValue(baseValue)
	end

	--[[ Emitting ]]

	self:EnsureOrbsEmitter()
	if self.OrbsEmitter then
		self.OrbsEmitter:Emit(orbCount)
	end

	--[[ Flush ]]

	self:ScheduleOrbFlush()
end

--%%%%%%%%%%%%%%%%%%%% On Orb Arrived

--[[
	Applies one arrived orb's value to the display, plays collect SFX, and adds scale.
]]
function Component:OnOrbArrived()
	--[[ Checks ]]

	if self._destroyed then
		return
	end

	local orbValue: string? = table.remove(self.PendingOrbValues, 1)
	if not orbValue then
		return
	end

	--[[ Saving ]]

	local remaining: number = (self.ActiveOrbs[orbValue] or 0) - 1
	if remaining <= 0 then
		self.ActiveOrbs[orbValue] = nil
	else
		self.ActiveOrbs[orbValue] = remaining
	end

	--[[ Updating ]]

	local amount: string = self.CurrencyDir:GetAttribute(self.CurrencyName) or "0"
	if self:HasActiveOrbs() then
		self:TweenDisplayAmount(self:GetDisplayAmount(amount))
	else
		self:CancelOrbFlush()
		self:TweenDisplayAmount(amount)
	end

	--[[ Playing ]]

	I.Sound.Play({
		Name = ORB_COLLECT_SOUND_NAME,
		Volume = ORB_COLLECT_SOUND_VOLUME,
		SoundGroup = "SFX",
	})
	self:AddUIScaleBoost()
end

--%%%%%%%%%%%%%%%%%%%% Cancel Orb Flush

--[[
	Cancels the delayed withheld-orb flush if one is pending.
]]
function Component:CancelOrbFlush()
	--[[ Cancelling ]]

	if self.OrbFlushThread then
		task.cancel(self.OrbFlushThread)
		self.OrbFlushThread = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Schedule Orb Flush

--[[
	Replaces the delayed flush so leftover withheld orbs still credit the display.
]]
function Component:ScheduleOrbFlush()
	--[[ Cancelling ]]

	self:CancelOrbFlush()

	--[[ Scheduling ]]

	self.OrbFlushThread = task.delay(ORB_FLUSH_DELAY, function()
		self.OrbFlushThread = nil
		self:FlushHeldOrbs()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Flush Held Orbs

--[[
	Clears leftover in-flight orb values and tweens the display to the replicator amount.
]]
function Component:FlushHeldOrbs()
	--[[ Checks ]]

	if self._destroyed or not next(self.ActiveOrbs) then
		return
	end

	--[[ Clearing ]]

	table.clear(self.ActiveOrbs)
	table.clear(self.PendingOrbValues)

	--[[ Updating ]]

	local amount: string = self.CurrencyDir:GetAttribute(self.CurrencyName) or "0"
	self:TweenDisplayAmount(amount)
end

--%%%%%%%%%%%%%%%%%%%% Add UI Scale Boost

--[[
	Adds slot scale from an arrived orb with diminishing returns toward the cap, and eases it every frame until it
	settles (the ease runs only then, so idle slots cost nothing).
]]
function Component:AddUIScaleBoost()
	--[[ Checks ]]

	if not self.CurrencyUIScale or self._destroyed then
		return
	end

	--[[ Calculating ]]

	local step: number = ORB_UI_SCALE_STEP * (1 - self.UIScaleBoost / ORB_UI_SCALE_MAX)
	self.UIScaleBoost = math.min(ORB_UI_SCALE_MAX, self.UIScaleBoost + step)

	--[[ Connections ]]

	if not self.UIScaleConnection then
		self.UIScaleConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
			self:UpdateUIScale(deltaTime)
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Update UI Scale

--[[
	Decays slot scale toward default and eases up when an orb has just added boost; stops easing once it settles.
]]
function Component:UpdateUIScale(deltaTime: number)
	--[[ Checks ]]

	if not self.CurrencyUIScale or self._destroyed then
		return
	end

	local defaultScale: number = self.DefaultUIScale
	local currentScale: number = self.CurrencyUIScale.Scale

	-- Check if the scale settled: rest it and stop the ease
	if self.UIScaleBoost <= 0 and currentScale <= defaultScale + 0.0001 then
		self.CurrencyUIScale.Scale = defaultScale
		self.UIScaleBoost = 0
		if self.UIScaleConnection then
			self.UIScaleConnection:Disconnect()
			self.UIScaleConnection = nil
		end
		return
	end

	--[[ Decaying ]]

	self.UIScaleBoost = math.max(0, self.UIScaleBoost - ORB_UI_SCALE_DECAY * deltaTime)
	local targetScale: number = defaultScale * (1 + self.UIScaleBoost)

	--[[ Applying ]]

	if targetScale > currentScale then
		local alpha: number = math.min(1, ORB_UI_SCALE_UP_RATE * deltaTime)
		self.CurrencyUIScale.Scale = currentScale + (targetScale - currentScale) * alpha
	else
		self.CurrencyUIScale.Scale = targetScale
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Held Orbs Amount

--[[
	Returns the BigNum sum of currency still stored in active orbs.
]]
--- @return BigNum
function Component:GetHeldOrbsAmount()
	--[[ Calculating ]]

	local heldBN = I.BN.new("0")

	for orbValue: string, orbCount: number in pairs(self.ActiveOrbs) do
		if orbCount > 0 then
			heldBN = heldBN + (I.BN.new(orbValue) * I.BN.new(`{orbCount}`))
		end
	end

	--[[ Returning ]]

	return heldBN
end

--%%%%%%%%%%%%%%%%%%%% Get Display Amount

--[[
	Returns the currency amount that should currently be shown on the slot.
]]
--- @return string
function Component:GetDisplayAmount(amount: string)
	--[[ Checks ]]

	if not next(self.ActiveOrbs) then
		return amount
	end

	--[[ Calculating ]]

	local displayBN = I.BN.new(amount) - self:GetHeldOrbsAmount()
	if displayBN < zeroBN then
		displayBN = I.BN.new("0")
	end

	--[[ Returning ]]

	return `{displayBN}`
end

--%%%%%%%%%%%%%%%%%%%% Has Active Orbs

--[[
	Returns whether this slot still has orbs in flight.
]]
--- @return boolean
function Component:HasActiveOrbs()
	--[[ Returning ]]

	return next(self.ActiveOrbs) ~= nil
end

return Component
