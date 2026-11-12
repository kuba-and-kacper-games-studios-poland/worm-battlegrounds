--[[
	Created By: 	HungryN00B
	Edited By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local effectsFolder: Instance

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

--- @class Snails_Client_Ghost
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Folders ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild("Combat")

	--[[ Connections ]]

	folder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(folder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Turns a snail into its ghost when it's knocked out; one already out when it reaches this screen is gone from sight
	at once.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail with its skin
	if not model:IsA("Model") or not model.PrimaryPart or not model:FindFirstChild("Skin") then
		return
	end

	-- Check if it's already out
	if model:GetAttribute("Alive") == false then
		Module._setFade(Module._getParts(model), 1)
		return
	end

	--[[ Connections ]]

	model:GetAttributeChangedSignal("Alive"):Connect(function()
		if model:GetAttribute("Alive") == false then
			Module._play(model)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a snail's ghost on this screen: a flash of ghost light and a puff with a rush of air, then it floats up,
	bobbing and swaying, fades away, and vanishes in a last small puff. The server anchored its ball and never moves it
	again, so this screen moves it.
]]
--- @param model Model
function Module._play(model)
	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local start: CFrame = root.CFrame
	local started: number = os.clock()
	local parts = Module._getParts(model) --- @type { [BasePart]: number }
	local glow: Highlight = I.Create("Highlight")({
		Name = "Ghost",
		Adornee = model:FindFirstChild("Skin"),
		FillColor = _settings.GHOST_COLOR,
		OutlineColor = Color3.new(1, 1, 1),
		FillTransparency = 0,
		OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Parent = model,
	})
	local connection: RBXScriptConnection

	--[[ Effects ]]

	I.Vfx.Play("Spawn", CFrame.new(root.Position), effectsFolder)
	I.Sound.Play({
		Name = "Snail_Ghost",
		Location = root.Position,
		SoundGroup = "SFX",
		RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
		RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
		PitchMin = 0.95,
		PitchMax = 1.1,
	})

	--[[ Floating ]]

	connection = I.S.RunService.RenderStepped:Connect(function()
		-- Its model went with the match
		if not root.Parent then
			connection:Disconnect()
			return
		end

		local alpha: number = math.clamp((os.clock() - started) / _settings.GHOST_TIME, 0, 1)
		local fade: number = math.clamp((alpha - _settings.GHOST_FADE_FROM) / (1 - _settings.GHOST_FADE_FROM), 0, 1)
		local bob: number = math.sin((os.clock() - started) * _settings.GHOST_BOB_RATE * 2 * math.pi) * math.min(alpha * 4, 1)
		local rise: number = 1 - (1 - alpha) ^ 3

		-- Up from where it went out, side to side, swaying with the bob
		local position: Vector3 = start.Position + Vector3.new(bob * _settings.GHOST_BOB, rise * _settings.GHOST_RISE, 0)
		root.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(bob * _settings.GHOST_SWAY)) * start.Rotation

		-- A bright flash as it turns, then see-through light that fades with it
		glow.FillTransparency = if alpha < 0.1 then alpha / 0.1 * 0.45 else 0.45 + 0.55 * fade
		glow.OutlineTransparency = fade
		Module._setFade(parts, 0.25 + 0.75 * fade)

		if alpha >= 1 then
			connection:Disconnect()
			glow:Destroy()
			Module._setFade(parts, 1)
			I.Vfx.Play("Spawn", CFrame.new(root.Position), effectsFolder, 0.6)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Set Fade

--[[
	Fades a snail's skin parts on this screen, never showing a part more than it already was.
]]
--- @param parts { [BasePart]: number }
function Module._setFade(parts, amount: number)
	--[[ Applying ]]

	for part: BasePart, base: number in pairs(parts) do
		part.LocalTransparencyModifier = math.max(base, amount)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Parts

--[[
	Returns a snail's skin parts, each with how see-through this screen draws it now.
]]
--- @param model Model
--- @return { [BasePart]: number }
function Module._getParts(model)
	--[[ Local Variables ]]

	local parts = {} --- @type { [BasePart]: number }

	--[[ Collecting ]]

	for _index: number, part: Instance in ipairs(model:FindFirstChild("Skin"):GetDescendants()) do
		if part:IsA("BasePart") then
			parts[part] = part.LocalTransparencyModifier
		end
	end

	--[[ Returning ]]

	return parts
end

return Module
