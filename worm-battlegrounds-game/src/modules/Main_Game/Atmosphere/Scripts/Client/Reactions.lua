--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Liquids = require(script.Parent:FindFirstChild("Liquids")) --- @type Atmosphere_Client_Liquids
local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Atmosphere_Client_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local arenaFolder: Instance
local matchFolder: Instance

-- Combat's effects folder: what plays there freezes with a big hit's stop
local effectsFolder: Instance

--[[ State ]]

-- What's watched for falling into liquid, by its part
local tracked = {} --- @type { [BasePart]: Atmosphere_Track }

-- When a small thing last splashed, the map's terrain last arrived, and obsidian last steamed and hissed
local smallSplashAt: number = -math.huge
local terrainAt: number = -math.huge
local steamedAt: number = -math.huge
local hissedAt: number = -math.huge

local WHITE: Color3 = Color3.new(1, 1, 1)

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

--- @class Atmosphere_Client_Reactions
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(arena: Instance, match: Instance, combat: Instance, snails: Instance)
	--[[ Folders ]]

	arenaFolder = arena
	matchFolder = match
	effectsFolder = combat

	--[[ Connections ]]

	I.Network.Fired("Arena_Carve", Module._onCarve)
	I.Network.Fired("Arena_Fall", Module._onFall)
	arenaFolder.DescendantAdded:Connect(Module._onArenaAdded)
	effectsFolder.ChildAdded:Connect(Module._onEffectAdded)
	snails.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snails:GetChildren()) do
		Module._watchSnail(model)
	end
	I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Splashes each watched thing where it drops through a liquid's surface, and stops watching what's gone. A snail
	going into the sea is left to Snails, which splashes it as it's knocked out.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Watching ]]

	--- @param track Atmosphere_Track
	for part: BasePart, track in pairs(tracked) do
		if not part.Parent then
			tracked[part] = nil
			continue
		end
		local position: Vector3 = part.Position
		if position.Y < track.LastY and now >= track.ReadyAt and (track.Kind ~= "Chip" or now - smallSplashAt >= _settings.SMALL_SPLASH_GAP) then
			local surfaceY: number?
			local rect = nil --- @type Atmosphere_LiquidRect?
			surfaceY, rect = Liquids.GetCrossing(position.X, track.LastY, position.Y)
			if surfaceY and rect and not (track.Kind == "Snail" and Liquids.IsDeep(position.X, surfaceY)) then
				track.ReadyAt = now + _settings.SPLASH_COOLDOWN
				if track.Kind == "Chip" then
					smallSplashAt = now
				end
				Module._splash(Vector3.new(position.X, surfaceY, 0), rect, _settings.SPLASH_SCALES[track.Kind])
			end
		end
		track.LastY = position.Y
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Carve

--[[
	Bursts every prop part a blast reaches: leaves, needles, bushes, cacti and twigs in their own colours, rocks in
	dust. Arena_Carve comes before the server cuts the props, so they're whole here.
]]
function Module._onCarve(_carveId: number, center: Vector3, radius: number)
	--[[ Data ]]

	local decor: Instance? = arenaFolder:FindFirstChild("Decor")
	if not decor then
		return
	end

	--[[ Collecting ]]

	-- The parts reached, by prop, then by the effect they play
	local hits = {} --- @type { [Instance]: { [string]: { BasePart } } }
	for _index: number, part: Instance in ipairs(decor:GetDescendants()) do
		local effect: string? = _settings.PROP_EFFECTS[part.Name]
		if not effect or not part:IsA("BasePart") then
			continue
		end
		local offset: Vector3 = part.Position - center
		local gapX: number = math.max(math.abs(offset.X) - part.Size.X / 2, 0)
		local gapY: number = math.max(math.abs(offset.Y) - part.Size.Y / 2, 0)
		if gapX * gapX + gapY * gapY > radius * radius then
			continue
		end
		local prop: Instance = part:FindFirstAncestorWhichIsA("Model") or part.Parent
		hits[prop] = hits[prop] or {}
		hits[prop][effect] = hits[prop][effect] or {}
		table.insert(hits[prop][effect], part)
	end

	--[[ Bursting ]]

	local pull: Vector3 = Vector3.xAxis * (matchFolder:GetAttribute("Wind") or 0) * _settings.WIND_PUSH * _settings.PROP_WIND_SHARE
	--- @param effects { [string]: { BasePart } }
	for _prop: Instance, effects in pairs(hits) do
		--- @param parts { BasePart }
		for effect: string, parts in pairs(effects) do
			Module._burst(effect, parts, pull)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Burst

--[[
	Plays one prop's burst from the middle of the parts a blast reached, in their two commonest colours, bigger the
	more parts it reached.
]]
--- @param parts { BasePart }
function Module._burst(effect: string, parts, pull: Vector3)
	--[[ Local Variables ]]

	local sum: Vector3 = Vector3.zero
	local counts = {} --- @type { [string]: number }
	local colors = {} --- @type { string }
	for _index: number, part: BasePart in ipairs(parts) do
		local hex: string = part.Color:ToHex()
		sum += part.Position
		if not counts[hex] then
			table.insert(colors, hex)
		end
		counts[hex] = (counts[hex] or 0) + 1
	end
	table.sort(colors, function(a: string, b: string)
		return counts[a] > counts[b]
	end)
	local shown: number = math.min(#colors, 2)
	local share: number = math.clamp(#parts / _settings.PROP_PARTS_FULL, 0.5, 1.5) / shown

	--[[ Playing ]]

	for index: number = 1, shown do
		Effects.Play(effect, sum / #parts, effectsFolder, nil, Color3.fromHex(colors[index]), pull, share)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Fall

--[[
	Follows a chunk of ground cut loose as it falls (by the same gravity Arena draws it with, on the server's clock):
	a splash where it drops through a liquid, and dust in its own colour where it lands on ground.
]]
--- @param group { BasePart }
function Module._onFall(group, drop: number, started: number)
	--[[ Local Variables ]]

	-- Its bottom, and the parts along it (a part this screen hasn't streamed in arrives as nil)
	local bottom: number = math.huge
	for _index: number, part: BasePart in pairs(group) do
		bottom = math.min(bottom, part.Position.Y - part.Size.Y / 2)
	end
	local lowest: BasePart? = nil
	local minX: number = math.huge
	local maxX: number = -math.huge
	for _index: number, part: BasePart in pairs(group) do
		if part.Position.Y - part.Size.Y / 2 <= bottom + 0.5 then
			lowest = lowest or part
			minX = math.min(minX, part.Position.X - part.Size.X / 2)
			maxX = math.max(maxX, part.Position.X + part.Size.X / 2)
		end
	end

	--[[ Checks ]]

	-- Check if any of it is on this screen
	if not lowest then
		return
	end

	--[[ Local Variables ]]

	local x: number = (minX + maxX) / 2
	local landY: number = bottom - drop
	local scale: number = math.clamp((maxX - minX) / _settings.LANDING_WIDTH, _settings.LANDING_SCALES[1], _settings.LANDING_SCALES[2])
	local gravity: number = I.S.Workspace.Gravity
	local bounds: BasePart = arenaFolder:FindFirstChild("Markers"):FindFirstChild("Bounds")

	--[[ Splashing ]]

	local surfaceY: number?
	local rect = nil --- @type Atmosphere_LiquidRect?
	surfaceY, rect = Liquids.GetCrossing(x, bottom, landY)
	if surfaceY and rect then
		local wait: number = started + math.sqrt(2 * (bottom - surfaceY) / gravity) - I.S.Workspace:GetServerTimeNow()
		task.delay(math.max(wait, 0), Module._splash, Vector3.new(x, surfaceY, 0), rect, scale)
	end

	--[[ Checks ]]

	-- Check if it lands on ground: far enough to raise dust, not under liquid, not below the arena
	if drop < _settings.LANDING_MIN_DROP or Liquids.GetKind(Vector3.new(x, landY + 0.25, 0)) or landY < bounds.Position.Y - bounds.Size.Y / 2 then
		return
	end

	--[[ Landing ]]

	local wait: number = started + math.sqrt(2 * drop / gravity) - I.S.Workspace:GetServerTimeNow()
	task.delay(math.max(wait, 0), function()
		if lowest and lowest.Parent then
			Effects.Play(_settings.LANDING_EFFECT, Vector3.new(x, landY, 0), effectsFolder, scale, lowest.Color:Lerp(WHITE, _settings.LANDING_LIGHTEN))
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Arena Added

--[[
	Watches what turns up in the arena: a prop let go to fall (its weld), new obsidian (steam, once the map's own
	terrain has settled in), and when the map's terrain arrives.
]]
function Module._onArenaAdded(item: Instance)
	--[[ Watching ]]

	if item.Name == "Terrain" and item.Parent == arenaFolder then
		terrainAt = os.clock()
	elseif item:IsA("WeldConstraint") and item.Name == "PropWeld" and item.Part0 then
		Module._track(item.Part0, "Prop")
	elseif item:IsA("BasePart") and item.Name == "Obsidian" and not item:GetAttribute("Arena_Carve") then
		Module._steamObsidian(item)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Effect Added

--[[
	Watches the chunks a blast throws and the shots in flight, as Combat adds them.
]]
function Module._onEffectAdded(item: Instance)
	--[[ Watching ]]

	if not item:IsA("BasePart") then
		return
	end
	if item.Name == "Debris" then
		Module._track(item, "Chip")
	elseif item:GetAttribute("Simulated") then
		Module._track(item, "Shot")
	end
end

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Watches a snail's ball, so it splashes falling into a pond.
]]
function Module._watchSnail(model: Instance)
	--[[ Watching ]]

	if model:IsA("Model") and model.PrimaryPart then
		Module._track(model.PrimaryPart, "Snail")
	end
end

--%%%%%%%%%%%%%%%%%%%% Track

--[[
	Starts watching a part for falling into liquid, once.
]]
function Module._track(part: BasePart, kind: string)
	--[[ Checks ]]

	-- Skip what's already watched
	if tracked[part] then
		return
	end

	--[[ Saving ]]

	tracked[part] = { Kind = kind, LastY = part.Position.Y, ReadyAt = 0 }
end

--%%%%%%%%%%%%%%%%%%%% Splash

--[[
	Plays a liquid's splash effects where something went in, the splash in the liquid's own colour when the map gives
	it one.
]]
--- @param rect Atmosphere_LiquidRect
function Module._splash(position: Vector3, rect, scale: number)
	--[[ Local Variables ]]

	local effects = _settings.SPLASH_EFFECTS[rect.Kind] --- @type { string }?
	local ownColor: boolean = rect.Color ~= I.Settings["Arena"].LIQUID_COLORS[rect.Kind]

	--[[ Checks ]]

	-- Check if the liquid splashes
	if not effects then
		return
	end

	--[[ Playing ]]

	for index: number, effect: string in ipairs(effects) do
		local color: Color3? = if index == 1 and ownColor then rect.Color:Lerp(WHITE, _settings.LIQUID_TINT_LIGHTEN) else nil
		Effects.Play(effect, position, effectsFolder, scale, color)
	end
end

--%%%%%%%%%%%%%%%%%%%% Steam Obsidian

--[[
	Lets off a puff of steam from new obsidian, where lava met water, at most every OBSIDIAN_STEAM_GAP seconds, and
	its hiss (Liquid_Obsidian) at most every OBSIDIAN_SOUND_GAP.
]]
function Module._steamObsidian(part: BasePart)
	--[[ Checks ]]

	-- Skip the map's load and steam that just played
	local now: number = os.clock()
	if now - terrainAt < _settings.OBSIDIAN_SETTLE or now - steamedAt < _settings.OBSIDIAN_STEAM_GAP then
		return
	end
	steamedAt = now

	--[[ Playing ]]

	local top: Vector3 = Vector3.new(part.Position.X, part.Position.Y + part.Size.Y / 2, 0)
	Effects.Play(_settings.OBSIDIAN_EFFECT, top, effectsFolder, math.clamp(part.Size.X / 2, 0.6, 1.6))

	--[[ Hissing ]]

	if now - hissedAt >= _settings.OBSIDIAN_SOUND_GAP then
		hissedAt = now
		I.Sound.Play({
			Name = "Liquid_Obsidian",
			Location = top,
			SoundGroup = "SFX",
			RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
			RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
		})
	end
end

return Module
