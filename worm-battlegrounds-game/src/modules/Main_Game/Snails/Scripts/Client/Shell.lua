--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

-- Whether each snail's shell is broken on this screen, by snail
local broken = {} --- @type { [Model]: boolean }

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

--- @class Snails_Client_Shell
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Looks again at a snail's shell whenever its health changes, and forgets the snail once it's gone.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Connections ]]

	model:GetAttributeChangedSignal("Health"):Connect(function()
		Module._refresh(model)
	end)
	model.Destroying:Connect(function()
		broken[model] = nil
	end)

	--[[ Refreshing ]]

	-- A snail already hurt when it reaches this screen shows its shell broken, without the chips
	broken[model] = Module._isBelowShellHealth(model)
	Module._showShell(model, not broken[model])
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Breaks a snail's shell when its health drops below SHELL_BREAK_HEALTH, and shows it again once healing brings the
	health back up to it.
]]
--- @param model Model
function Module._refresh(model)
	--[[ Data ]]

	local nowBroken: boolean = Module._isBelowShellHealth(model)

	--[[ Checks ]]

	-- Check if the shell changed
	if nowBroken == broken[model] then
		return
	end

	--[[ Applying ]]

	broken[model] = nowBroken
	Module._showShell(model, not nowBroken)
	if nowBroken then
		Module._throwChips(model)
		I.Sound.Play({
			Name = "Snail_ShellBreak",
			Location = model.PrimaryPart,
			SoundGroup = "SFX",
			RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
			RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Shell

--[[
	Shows or hides a snail's shell on this screen only, over whatever see-through the server gives the skin (a ghost).
]]
--- @param model Model
function Module._showShell(model, show: boolean)
	--[[ Data ]]

	local shell: BasePart? = Module._getShell(model)

	--[[ Checks ]]

	-- Check if the skin has a shell
	if not shell then
		return
	end

	--[[ Applying ]]

	shell.LocalTransparencyModifier = if show then 0 else 1
end

--%%%%%%%%%%%%%%%%%%%% Throw Chips

--[[
	Bursts a broken shell into chips in its colours that fly off, bounce on the terrain (never on snails or shots), then
	fade. They sit in the snail's model, like its gear, and go with it.
]]
--- @param model Model
function Module._throwChips(model)
	--[[ Data ]]

	local shell: BasePart? = Module._getShell(model)

	--- @type { number }
	local sizes = _settings.SHELL_CHIP_SIZE

	--- @type { number }
	local speeds = _settings.SHELL_CHIP_SPEED

	--- @type { Color3 }
	local colors = _settings.SHELL_CHIP_COLORS

	--[[ Checks ]]

	-- Check if the skin has a shell
	if not shell then
		return
	end

	--[[ Throwing ]]

	-- shortcut: chips made in code stand in for a shell-break effect, until the owner provides one
	for _index: number = 1, _settings.SHELL_CHIPS do
		--[[ Local Variables ]]

		local angle: number = random:NextNumber(0.15, math.pi - 0.15)
		local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), random:NextNumber(-0.3, 0.3))
		local offset: Vector3 = shell.Size * Vector3.new(random:NextNumber(-0.4, 0.4), random:NextNumber(-0.4, 0.4), random:NextNumber(-0.4, 0.4))
		local size: number = random:NextNumber(sizes[1], sizes[2])

		--[[ Building ]]

		local chip: Part = I.Create("Part")({
			Name = "ShellChip",
			Size = Vector3.one * size,
			CFrame = shell.CFrame * CFrame.new(offset) * CFrame.Angles(random:NextNumber(0, math.pi), random:NextNumber(0, math.pi), 0),
			Color = colors[random:NextInteger(1, #colors)],
			Material = Enum.Material.SmoothPlastic,
			CollisionGroup = "Chip",
			CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.6, 0.35),
			CanQuery = false,
			CanTouch = false,
			Parent = model,
		})
		chip.AssemblyLinearVelocity = direction * random:NextNumber(speeds[1], speeds[2])
		chip.AssemblyAngularVelocity = random:NextUnitVector() * 12

		--[[ Fading ]]

		local Chip_TweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, _settings.SHELL_CHIP_LIFETIME)
		local Chip_TweenGoal = { Transparency = 1 }
		local Chip_Tween: Tween = I.S.TweenService:Create(chip, Chip_TweenInfo, Chip_TweenGoal)
		Chip_Tween:Play()
		Chip_Tween.Completed:Once(function()
			chip:Destroy()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Shell

--[[
	Returns the part of a snail's skin that breaks (SHELL_PART), or nil when its skin has none.
]]
--- @param model Model
--- @return BasePart?
function Module._getShell(model)
	--[[ Data ]]

	local skin: Instance? = model:FindFirstChild("Skin")
	local shell: Instance? = skin and skin:FindFirstChild(_settings.SHELL_PART, true)

	--[[ Returning ]]

	return if shell and shell:IsA("BasePart") then shell else nil
end

--%%%%%%%%%%%%%%%%%%%% Is Below Shell Health

--[[
	Returns whether a snail's health is below SHELL_BREAK_HEALTH. A snail with no health yet (the lobby's) is whole.
]]
--- @param model Model
--- @return boolean
function Module._isBelowShellHealth(model)
	--[[ Data ]]

	local health: number? = model:GetAttribute("Health")

	--[[ Returning ]]

	return health ~= nil and health < _settings.SHELL_BREAK_HEALTH
end

return Module
