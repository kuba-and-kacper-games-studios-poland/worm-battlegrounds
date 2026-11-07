--[[
	Created By: 	Nari
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
	Puts a SnailTag over a snail and an outline around it, both in its team's colour and kept in step with its
	attributes, and pops a damage number whenever its health drops.
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
	Shows a snail's health on its tag, number and bar in its team's colour, the turn marker and timer while it's the
	active snail (the timer for everyone but its own player, who reads it on the turn panel), and hides the tag and
	outline once it's a ghost.
]]
function Module._refreshTag(model: Instance, tag: BillboardGui)
	--[[ Elements ]]

	local active: Frame = tag:FindFirstChild("S_Active", true)
	local timer: TextLabel = active:FindFirstChild("S_Timer")
	local healthBar: Frame = tag:FindFirstChild("S_Health", true)
	local status: TextLabel = healthBar:FindFirstChild("Status")
	local fill: Frame = healthBar:FindFirstChild("Track"):FindFirstChild("Fill")

	--[[ Local Variables ]]

	local share: number = math.clamp(model:GetAttribute("Health") / model:GetAttribute("MaxHealth"), 0, 1)
	local isActive: boolean = model:GetAttribute("Active") == true

	--[[ Applying ]]

	tag.Enabled = not model:GetAttribute("Ghost")
	model:FindFirstChild("TeamOutline").Enabled = not model:GetAttribute("Ghost")
	active.Visible = isActive
	timer.Visible = isActive and model ~= I.Snails.GetMine()
	status.Text = tostring(model:GetAttribute("Health"))
	status.TextColor3 = model:GetAttribute("Color")
	fill.Size = UDim2.fromScale(share, 1)
	fill.BackgroundColor3 = model:GetAttribute("Color")

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
	local seconds: number = math.max(math.ceil(endsAt - I.S.Workspace:GetServerTimeNow()), 0)

	--[[ Applying ]]

	timer.Text = if I.Match.GetPhase() == "Turn" then tostring(seconds) else ""
end

--%%%%%%%%%%%%%%%%%%%% Pop Damage

--[[
	Shows a damage number over a snail that rises and fades, then goes away.
]]
function Module._popDamage(root: BasePart, amount: number)
	--[[ Local Variables ]]

	local pop: BillboardGui = templates:FindFirstChild("U_DamagePop", true):Clone()

	--[[ Elements ]]

	local amountLabel: TextLabel = pop:FindFirstChild("S_Amount", true)

	--[[ Building ]]

	pop.Enabled = true
	pop.Name = "DamagePop"
	pop.Adornee = root
	pop.AlwaysOnTop = true
	pop.StudsOffset = Vector3.yAxis * _settings.TAG_OFFSET
	amountLabel.Text = `-{amount}`
	I.ScreenScale.AddBillboard(pop)
	pop.Parent = root

	--[[ Tweening ]]

	local Rise_TweenGoal = { StudsOffset = pop.StudsOffset + Vector3.yAxis * _settings.POP_RISE }
	local Rise_Tween: Tween = I.S.TweenService:Create(pop, _settings.POP_TWEENINFO, Rise_TweenGoal)
	Rise_Tween:Play()

	local Fade_TweenGoal = { TextTransparency = 1 }
	local Fade_Tween: Tween = I.S.TweenService:Create(amountLabel, _settings.POP_TWEENINFO, Fade_TweenGoal)
	Fade_Tween:Play()

	local FadeStroke_TweenGoal = { Transparency = 1 }
	local FadeStroke_Tween: Tween = I.S.TweenService:Create(amountLabel.UIStroke, _settings.POP_TWEENINFO, FadeStroke_TweenGoal)
	FadeStroke_Tween:Play()

	--[[ Cleaning ]]

	Rise_Tween.Completed:Once(function()
		pop:Destroy()
	end)
end

return Module
