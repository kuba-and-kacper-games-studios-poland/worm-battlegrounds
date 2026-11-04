--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Worms"

--- @type Worms_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The WormTag and DamagePop billboards, which the server keeps in ReplicatedStorage.Ume.Worms
local templates: Instance

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

--- @class Worms_Client_Tags
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(wormsFolder: Folder)
	--[[ Templates ]]

	templates = I.Dirs.UmeReplicated:WaitForChild(_localName)

	--[[ Connections ]]

	wormsFolder.ChildAdded:Connect(Module._addTag)
	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		task.spawn(Module._addTag, model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Tag

--[[
	Puts a WormTag over a worm, kept in step with its attributes, and pops a damage number whenever its health drops.
]]
function Module._addTag(model: Instance)
	--[[ Local Variables ]]

	local root: BasePart = model:WaitForChild("Root")
	local tag: BillboardGui = templates:FindFirstChild("WormTag"):Clone()
	local health: number = model:GetAttribute("Health")

	--[[ Elements ]]

	local nameLabel: TextLabel = tag:FindFirstChild("S_Name", true)
	local levelLabel: TextLabel = tag:FindFirstChild("S_Level", true)
	local healthBar: Frame = tag:FindFirstChild("S_Health", true)

	--[[ Layout ]]

	--[[
		shortcut: the exported tag stacks down from its top, and ume-gui's Progress status label (TextScaled with
		automatic height) grows tall in a live billboard; this pins the stack to the bottom and fixes the label's
		height until the WormTag gui and the Progress control are fixed
	]]
	local stack: Frame = tag:FindFirstChild("U_Tag"):FindFirstChild("Stack")
	local status: TextLabel = healthBar:FindFirstChild("Status")
	stack.AnchorPoint = Vector2.new(0, 1)
	stack.Position = UDim2.fromScale(0, 1)
	status.AutomaticSize = Enum.AutomaticSize.None
	status.Size = UDim2.new(1, 0, 0, healthBar:FindFirstChild("Track").Size.Y.Offset)

	--[[ Building ]]

	tag.Adornee = root
	tag.AlwaysOnTop = true
	tag.SizeOffset = Vector2.new(0, 0.5)
	tag.StudsOffset = Vector3.yAxis * _settings.TAG_OFFSET
	nameLabel.Text = model:GetAttribute("DisplayName")
	nameLabel.TextColor3 = if model:GetAttribute("Vip") then _settings.VIP_NAME_COLOR else model:GetAttribute("Color")
	levelLabel.Text = `Lv {model:GetAttribute("Level")}`
	levelLabel.Visible = model:GetAttribute("Level") > 0

	tag.Parent = root
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
	Shows a worm's health and team colour on its tag, the turn marker while it's the active worm, and hides the tag
	once it's a ghost.
]]
function Module._refreshTag(model: Instance, tag: BillboardGui)
	--[[ Elements ]]

	local active: Frame = tag:FindFirstChild("S_Active", true)
	local healthBar: Frame = tag:FindFirstChild("S_Health", true)
	local status: TextLabel = healthBar:FindFirstChild("Status")
	local fill: Frame = healthBar:FindFirstChild("Track"):FindFirstChild("Fill")

	--[[ Applying ]]

	tag.Enabled = not model:GetAttribute("Ghost")
	active.Visible = model:GetAttribute("Active") == true
	status.Text = tostring(model:GetAttribute("Health"))
	fill.Size = UDim2.fromScale(model:GetAttribute("Health") / model:GetAttribute("MaxHealth"), 1)
	fill.BackgroundColor3 = model:GetAttribute("Color")
end

--%%%%%%%%%%%%%%%%%%%% Pop Damage

--[[
	Shows a damage number over a worm that rises and fades, then goes away.
]]
function Module._popDamage(root: BasePart, amount: number)
	--[[ Local Variables ]]

	local pop: BillboardGui = templates:FindFirstChild("DamagePop"):Clone()

	--[[ Elements ]]

	local amountLabel: TextLabel = pop:FindFirstChild("S_Amount", true)

	--[[ Building ]]

	pop.Enabled = true
	pop.Adornee = root
	pop.AlwaysOnTop = true
	pop.StudsOffset = Vector3.yAxis * _settings.TAG_OFFSET
	amountLabel.Text = `-{amount}`
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
