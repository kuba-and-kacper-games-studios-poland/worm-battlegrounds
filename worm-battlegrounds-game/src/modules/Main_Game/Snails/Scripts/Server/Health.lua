--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Snails_Server_Bodies

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Who last hurt or pushed each snail, and with what, for kill credit
local lastAttackers = {} --- @type { [string]: string }
local lastItems = {} --- @type { [string]: string }

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

--- @class Snails_Server_Health
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Registry ]]

	I.Topic.Register("Snails_Died", {
		"string",
		"string",
		{ Type = "string", Optional = true },
		{ Type = "string", Optional = true },
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Damage

--[[
	**SERVER** |
	Takes health from a snail, rounded to a whole number and never below 0, and remembers who did it for kill credit.
	A snail at 0 stays in play until the match knocks it out once the shot settles.
]]
function Module.Damage(participantId: string, amount: number, sourceId: string?, itemId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)
	local damage: number = math.round(amount)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	-- Check if the damage hurts
	if damage <= 0 then
		return
	end

	--[[ Saving ]]

	Module._setAttacker(participantId, sourceId, itemId)
	model:SetAttribute("Health", math.max(model:GetAttribute("Health") - damage, 0))
end

--%%%%%%%%%%%%%%%%%%%% Heal

--[[
	**SERVER** |
	Gives a snail health, rounded to a whole number and never above its MaxHealth.
]]
function Module.Heal(participantId: string, amount: number)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)
	local heal: number = math.round(amount)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	-- Check if the heal adds health
	if heal <= 0 then
		return
	end

	--[[ Saving ]]

	model:SetAttribute("Health", math.min(model:GetAttribute("Health") + heal, model:GetAttribute("MaxHealth")))
end

--%%%%%%%%%%%%%%%%%%%% Knockback

--[[
	**SERVER** |
	Throws a snail with an impulse, and remembers who did it for kill credit. The server must own the snail then:
	SnailControl takes it back from its player before anything hits.
]]
function Module.Knockback(participantId: string, impulse: Vector3, sourceId: string?, itemId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	--[[ Applying ]]

	Module._setAttacker(participantId, sourceId, itemId)
	model.PrimaryPart:ApplyImpulse(impulse)
end

--%%%%%%%%%%%%%%%%%%%% Kill

--[[
	**SERVER** |
	Knocks a snail out: it becomes a see-through ghost that touches nothing and floats up, and Snails_Died is published
	with the cause ("Water", "Lava", "Bounds", a weapon's cause), the killer and the item, falling back on whoever last
	hurt or pushed it.
]]
function Module.Kill(participantId: string, cause: string, sourceId: string?)
	--[[ Data ]]

	local model: Model? = Bodies.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local killerId: string? = sourceId or lastAttackers[participantId]
	local itemId: string? = if sourceId then nil else lastItems[participantId]

	--[[ Saving ]]

	model:SetAttribute("Health", 0)
	model:SetAttribute("Alive", false)
	model:SetAttribute("Ghost", true)

	--[[ Ghost ]]

	root:SetNetworkOwner(nil)
	root.Anchored = true
	root.CollisionGroup = "Ghost"
	root:FindFirstChild("Walk").Enabled = false
	for _index: number, part: Instance in ipairs(model:FindFirstChild("Skin"):GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = math.max(part.Transparency, _settings.GHOST_TRANSPARENCY)
		end
	end

	local Rise_TweenInfo: TweenInfo = TweenInfo.new(_settings.GHOST_RISE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Rise_TweenGoal = { CFrame = root.CFrame + Vector3.yAxis * _settings.GHOST_RISE }
	local Rise_Tween: Tween = I.S.TweenService:Create(root, Rise_TweenInfo, Rise_TweenGoal)
	Rise_Tween:Play()

	--[[ Publishing ]]

	I.Topic.Publish("Snails_Died", participantId, cause, killerId, itemId)
end

--%%%%%%%%%%%%%%%%%%%% Set Attacker

--[[
	Remembers who last hurt or pushed a snail, and with what, unless it did so itself; bots read who in its LastAttacker
	attribute.
]]
function Module._setAttacker(participantId: string, sourceId: string?, itemId: string?)
	--[[ Checks ]]

	-- Skip hits with no source, and snails hurting themselves
	if not sourceId or sourceId == participantId then
		return
	end

	--[[ Saving ]]

	lastAttackers[participantId] = sourceId
	lastItems[participantId] = itemId
	Bodies.Get(participantId):SetAttribute("LastAttacker", sourceId)
end

return Module
