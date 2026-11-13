--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The SnailTag and DamagePop billboards' holders (PREFAB | SnailTag, PREFAB | DamagePop) in Assets.Snails
local templates: Instance

-- The tag counting the turn's seconds (the active snail's, unless it's this player's own), and its ticker
local timedTag: BillboardGui? = nil
local timerConnection: RBXScriptConnection?

-- The active snail's turn on its tag (its arrow, and whether it acted and hid the tag), and the frame step that runs it
local turn = nil --- @type Snails_TagTurn?
local turnConnection: RBXScriptConnection?

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

--- @class Snails_Client_Tags
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Templates ]]

	templates = I.Dirs.Assets:FindFirstChild(_localName)

	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._addTag)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		task.spawn(Module._addTag, model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Tag

--[[
	Puts a SnailTag over a snail (its player's badges after the name) and an outline around it, both in its team's
	colour and kept in step with its attributes, and pops a damage number whenever its health drops.
]]
function Module._addTag(model: Instance)
	--[[ Local Variables ]]

	local root: BasePart = model:WaitForChild("Root")
	local tag: BillboardGui = templates:FindFirstChild("U_SnailTag", true):Clone()
	local health: number = model:GetAttribute("Health")
	local color: Color3 = model:GetAttribute("Color")

	--[[ Elements ]]

	local nameLabel: TextLabel = tag:FindFirstChild("S_Name", true)
	local levelLabel: TextLabel = tag:FindFirstChild("S_Level", true)

	--[[ Building ]]

	tag.Name = "SnailTag"
	tag.Adornee = root
	tag.AlwaysOnTop = true
	tag.SizeOffset = Vector2.new(0, 0.5)
	tag.StudsOffset = Vector3.yAxis * _settings.TAG_OFFSET
	nameLabel.Text = model:GetAttribute("DisplayName")
	nameLabel.TextColor3 = if model:GetAttribute("Vip") then _settings.VIP_NAME_COLOR else color
	levelLabel.Text = `Lv {model:GetAttribute("Level")}`
	levelLabel.Visible = model:GetAttribute("Level") > 0
	I.PlayerBadges.Show(nameLabel, model:GetAttribute("UserId"))
	I.ScreenScale.AddBillboard(tag)

	tag.Parent = root
	I.Create("Highlight")({
		Name = "TeamOutline",
		FillTransparency = 1,
		OutlineColor = color,
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Parent = model,
	})
	Module._refreshTag(model, tag)

	--[[ Connections ]]

	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Health" and model:GetAttribute("Health") < health and I.PlayerSettings.Get("DamageNumbers") then
			Module._popDamage(root, health - model:GetAttribute("Health"))
		end
		health = model:GetAttribute("Health")
		Module._refreshTag(model, tag)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Tag

--[[
	Shows a snail's health on its tag (the number, and the bar's outline and fill in its team's colour), the turn arrow
	and timer while it's the active snail (the timer for everyone but its own player, who reads it on the turn panel),
	and hides the tag and outline once it's a ghost. The active snail's tag also hides once it acts, until its turn ends.
]]
function Module._refreshTag(model: Instance, tag: BillboardGui)
	--[[ Elements ]]

	local active: Frame = tag:FindFirstChild("S_Active", true)
	local timer: TextLabel = active:FindFirstChild("S_Timer")
	local healthBar: Frame = tag:FindFirstChild("S_Health", true)
	local healthText: TextLabel = healthBar:FindFirstChild("S_HealthText")
	local fill: ImageLabel = healthBar:FindFirstChild("S_Fill")

	--[[ Local Variables ]]

	local share: number = math.clamp(model:GetAttribute("Health") / model:GetAttribute("MaxHealth"), 0, 1)
	local isActive: boolean = model:GetAttribute("Active") == true

	-- The fill's gradient cuts the picture at the health left, so it never squashes
	local edge: number = math.clamp(share, 0.001, 0.998)

	--[[ Turn ]]

	-- A turn starting drops the arrow in; one ending brings the tag back
	if isActive and (not turn or turn.Tag ~= tag) then
		Module._startTurn(model, tag)
	elseif not isActive and turn and turn.Tag == tag then
		Module._endTurn()
	end

	--[[ Applying ]]

	tag.Enabled = not model:GetAttribute("Ghost") and not (turn and turn.Tag == tag and turn.Hidden)
	model:FindFirstChild("TeamOutline").Enabled = not model:GetAttribute("Ghost")
	active.Visible = isActive
	timer.Visible = isActive and model ~= I.Snails.GetMine()
	healthText.Text = tostring(model:GetAttribute("Health"))
	healthBar:FindFirstChild("Background"):FindFirstChild("Stroke").ImageColor3 = model:GetAttribute("Color")
	fill.ImageColor3 = model:GetAttribute("Color")
	fill.UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(edge, 0),
		NumberSequenceKeypoint.new(edge + 0.001, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

	--[[ Timer ]]

	if timer.Visible and timedTag ~= tag then
		timedTag = tag
		timerConnection = timerConnection or I.S.RunService.Heartbeat:Connect(Module._tickTimer)
		Module._tickTimer()
	elseif not timer.Visible and timedTag == tag and timerConnection then
		timedTag = nil
		timerConnection:Disconnect()
		timerConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick Timer

--[[
	Counts the turn's seconds down on the active snail's tag, blank while a shot flies and settles.
]]
function Module._tickTimer()
	--[[ Checks ]]

	-- Check if a tag counts the turn
	if not timedTag or not timedTag.Parent then
		return
	end

	--[[ Local Variables ]]

	local timer: TextLabel = timedTag:FindFirstChild("S_Timer", true)
	local endsAt: number = I.Match.GetFolder():GetAttribute("TurnEndsAt") or 0
	-- Clamped before rounding up: math.ceil of the last fraction of a second is -0
	local seconds: number = math.ceil(math.max(endsAt - I.S.Workspace:GetServerTimeNow(), 0))

	--[[ Applying ]]

	timer.Text = if I.Match.GetPhase() == "Turn" then tostring(seconds) else ""
end

--%%%%%%%%%%%%%%%%%%%% Start Turn

--[[
	Starts the active snail's turn on its tag: notes where the snail stands and when, and steps the arrow's drop and
	bob each frame until the snail acts.
]]
function Module._startTurn(model: Instance, tag: BillboardGui)
	--[[ Clearing ]]

	Module._endTurn()

	--[[ Local Variables ]]

	local root: BasePart = model:FindFirstChild("Root")

	--[[ Saving ]]

	--- @type Snails_TagTurn
	turn = {
		Model = model,
		Tag = tag,
		Root = root,
		Arrow = tag:FindFirstChild("S_Arrow", true),
		Start = root.Position,
		StartedAt = os.clock(),
		ServerStart = I.S.Workspace:GetServerTimeNow(),
		CameraAt = I.S.Workspace.CurrentCamera.CFrame.Position,
		AimBase = nil,
		SawTurn = false,
		Hidden = false,
	}

	--[[ Connections ]]

	turnConnection = I.S.RunService.Heartbeat:Connect(Module._stepTurn)
	Module._stepTurn()
end

--%%%%%%%%%%%%%%%%%%%% Step Turn

--[[
	Drops the turn arrow in from above the screen with a bounce, then bobs it; once the snail acts, hides its tag and
	arrow until the turn ends.
]]
function Module._stepTurn()
	--[[ Checks ]]

	-- Check if a turn shows on a tag
	if not turn then
		return
	end

	--[[ Hiding ]]

	-- Once the snail acts, its tag and arrow hide and the step stops
	if Module._hasActed(turn) then
		turn.Hidden = true
		turn.Tag.Enabled = false
		turnConnection:Disconnect()
		turnConnection = nil
		return
	end

	--[[ Local Variables ]]

	local elapsed: number = os.clock() - turn.StartedAt
	local offset: number

	--[[ Calculating ]]

	if elapsed < _settings.ARROW_DROP_SECONDS then
		local fall: number = I.S.TweenService:GetValue(elapsed / _settings.ARROW_DROP_SECONDS, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		offset = -_settings.ARROW_DROP_FROM * (1 - fall)
	else
		offset = math.sin((elapsed - _settings.ARROW_DROP_SECONDS) * _settings.ARROW_BOB_SPEED) * _settings.ARROW_BOB_HEIGHT
	end

	--[[ Applying ]]

	turn.Arrow.Position = UDim2.new(0.5, 0, 0.5, offset)
end

--%%%%%%%%%%%%%%%%%%%% End Turn

--[[
	Ends the turn shown on a tag: stops its step, puts the arrow back in its slot and shows the tag again (unless its
	snail is a ghost).
]]
function Module._endTurn()
	--[[ Checks ]]

	-- Check if a turn shows on a tag
	if not turn then
		return
	end

	--[[ Clearing ]]

	if turnConnection then
		turnConnection:Disconnect()
		turnConnection = nil
	end
	turn.Arrow.Position = UDim2.fromScale(0.5, 0.5)
	turn.Tag.Enabled = not turn.Model:GetAttribute("Ghost")
	turn = nil
end

--%%%%%%%%%%%%%%%%%%%% Has Acted

--[[
	Returns whether the active snail acted this turn, as Worms Armageddon hides its worm's tag: it moved TAG_HIDE_MOVE
	studs from where the turn started, aimed TAG_HIDE_AIM from its first aim (or charged a shot), or shot.
]]
--- @param current Snails_TagTurn
--- @return boolean
function Module._hasActed(current)
	--[[ Local Variables ]]

	local model: Instance = current.Model
	local aimTime: number = model:GetAttribute("AimTime") or 0

	--[[ Moving ]]

	if not current.Root.Parent or (current.Root.Position - current.Start).Magnitude > _settings.TAG_HIDE_MOVE then
		return true
	end

	--[[ Shooting ]]

	-- The snail turns active just before the Turn phase starts, so only leaving it once seen counts as a shot
	if I.Match.GetPhase() == "Turn" then
		current.SawTurn = true
	elseif current.SawTurn then
		return true
	end

	--[[ Aiming ]]

	--[[
		The aim is sent all through the turn and follows the pointer, so it drifts while the camera moves (flying to the
		snail as the turn starts, or panned): it counts only while the camera is still, from where it was then
	]]
	local cameraAt: Vector3 = I.S.Workspace.CurrentCamera.CFrame.Position
	local cameraMoved: boolean = (cameraAt - current.CameraAt).Magnitude > _settings.TAG_HIDE_CAMERA_STILL
	current.CameraAt = cameraAt
	if aimTime > current.ServerStart then
		local angle: number = model:GetAttribute("AimAngle") or 0
		local turned: number = math.abs(((angle - (current.AimBase or angle) + math.pi) % (2 * math.pi)) - math.pi)
		if cameraMoved or not current.AimBase then
			current.AimBase = angle
		elseif turned > _settings.TAG_HIDE_AIM then
			return true
		end
		if (model:GetAttribute("AimPower") or 0) > 0 then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Pop Damage

--[[
	Shows a damage number over a snail (the number and its shadow) that rises and fades, then goes away; a bigger hit's
	number is bigger and warmer (POP_TIERS), and punches in. It stays where the snail was hit, so a blow that throws the
	snail away never carries its number off the screen (the testers, 2026-11-13: rocket hits showed none).
]]
function Module._popDamage(root: BasePart, amount: number)
	--[[ Local Variables ]]

	local pop: BillboardGui = templates:FindFirstChild("U_DamagePop", true):Clone()
	local tier: { any } = _settings.POP_TIERS[1]
	local pin: Attachment = Instance.new("Attachment")
	pin.Name = "DamagePop"
	pin.WorldPosition = root.Position
	pin.Parent = I.S.Workspace.Terrain

	--[[ Tier ]]

	for _index: number, row: { any } in ipairs(_settings.POP_TIERS) do
		if amount >= row[1] then
			tier = row
		end
	end

	--[[ Elements ]]

	local amountLabel: TextLabel = pop:FindFirstChild("S_Amount", true)
	local shadowLabel: TextLabel = pop:FindFirstChild("S_Shadow", true)

	--[[ Building ]]

	pop.Enabled = true
	pop.Name = "DamagePop"
	pop.Adornee = pin
	pop.AlwaysOnTop = true
	pop.StudsOffset = Vector3.yAxis * _settings.TAG_OFFSET
	amountLabel.Text = `-{amount}`
	amountLabel.TextColor3 = tier[3]
	shadowLabel.Text = amountLabel.Text
	I.ScreenScale.AddBillboard(pop)

	-- Sized for its tier on top of the screen's scale
	local uiScale: UIScale = pop:FindFirstChild("S_ScreenScale", true)
	local size: number = uiScale.Scale * tier[2]
	pop.Size = UDim2.fromOffset(pop.Size.X.Offset * tier[2], pop.Size.Y.Offset * tier[2])
	uiScale.Scale = if tier == _settings.POP_TIERS[1] then size else size * _settings.POP_PUNCH
	pop.Parent = pin

	--[[ Tweening ]]

	local Punch_TweenGoal = { Scale = size }
	local Punch_Tween: Tween = I.S.TweenService:Create(uiScale, _settings.POP_PUNCH_TWEENINFO, Punch_TweenGoal)
	Punch_Tween:Play()

	local Rise_TweenGoal = { StudsOffset = pop.StudsOffset + Vector3.yAxis * _settings.POP_RISE }
	local Rise_Tween: Tween = I.S.TweenService:Create(pop, _settings.POP_TWEENINFO, Rise_TweenGoal)
	Rise_Tween:Play()

	for _index: number, label: TextLabel in ipairs({ amountLabel, shadowLabel }) do
		local Fade_TweenGoal = { TextTransparency = 1 }
		local Fade_Tween: Tween = I.S.TweenService:Create(label, _settings.POP_TWEENINFO, Fade_TweenGoal)
		Fade_Tween:Play()

		local FadeStroke_TweenGoal = { Transparency = 1 }
		local FadeStroke_Tween: Tween = I.S.TweenService:Create(label.UIStroke, _settings.POP_TWEENINFO, FadeStroke_TweenGoal)
		FadeStroke_Tween:Play()
	end

	--[[ Cleaning ]]

	Rise_Tween.Completed:Once(function()
		pin:Destroy()
	end)
end

return Module
