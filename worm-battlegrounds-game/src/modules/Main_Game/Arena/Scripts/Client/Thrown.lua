--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local PropCut = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("PropCut")) --- @type Arena_PropCut

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local arenaFolder: Instance

-- This screen's own pieces of props while they fly, lie and fade
local thrownFolder: Folder

local landParams: RaycastParams = RaycastParams.new()

--[[ Groups ]]

-- Every group of prop parts flying, falling or lying on this screen
local groups = {} --- @type { Arena_ThrownGroup }

-- The server's parts this screen moves now, which this screen's cuts leave alone
local flying = {} --- @type { [BasePart]: boolean }

local stepConnection: RBXScriptConnection? = nil

-- How far inside its box a group's landing is swept, so one lying a little in the ground isn't stuck there
local LAND_INSET: number = 0.25

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

--- @class Arena_Client_Thrown
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Instance)
	--[[ Local Variables ]]

	arenaFolder = folder
	thrownFolder = I.Create("Folder")({
		Name = "Thrown",
		Parent = arenaFolder,
	})
	landParams.FilterType = Enum.RaycastFilterType.Include
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Each frame while something flies: moves every group on the game's own motion (one move for all their parts) and
	fades each one PROP_FADE_DELAY after it set off, then takes it away. Stops once no group is left.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = I.Match.GetDrawTime()
	local terrain: Instance? = arenaFolder:FindFirstChild("Terrain")
	local markers: Instance? = arenaFolder:FindFirstChild("Markers")
	local bounds: BasePart? = if markers then markers:FindFirstChild("Bounds") else nil
	local floor: number = if bounds then bounds.Position.Y - bounds.Size.Y / 2 - _settings.DEBRIS_KILL_DEPTH else -math.huge
	local moved = {} --- @type { BasePart }
	local cframes = {} --- @type { CFrame }
	landParams.FilterDescendantsInstances = if terrain then { terrain } else {}

	--[[ Moving ]]

	--- @param group Arena_ThrownGroup
	for _index: number, group in ipairs(groups) do
		if group.Still or now <= group.Started then
			continue
		end
		if group.Drop then
			local elapsed: number = now - group.Started
			local fallen: number = math.min(0.5 * I.S.Workspace.Gravity * elapsed * elapsed, group.Drop)
			group.Frame = group.Start - Vector3.yAxis * fallen
			group.Still = fallen >= group.Drop
		else
			Module._fly(group, now - group.Last, floor)
		end
		group.Last = now
		for partIndex: number, part: BasePart in ipairs(group.Parts) do
			if part.Parent then
				table.insert(moved, part)
				table.insert(cframes, group.Frame * group.Offsets[partIndex])
			end
		end
	end
	if #moved > 0 then
		I.S.Workspace:BulkMoveTo(moved, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end

	--[[ Fading ]]

	local fadeInfo: TweenInfo = _settings.PROP_FADE_TWEENINFO
	for index: number = #groups, 1, -1 do
		local group = groups[index] --- @type Arena_ThrownGroup
		local fade: number = (now - group.Started - _settings.PROP_FADE_DELAY) / fadeInfo.Time
		if fade <= 0 then
			continue
		end
		local alpha: number = I.S.TweenService:GetValue(math.min(fade, 1), fadeInfo.EasingStyle, fadeInfo.EasingDirection)
		for partIndex: number, part: BasePart in ipairs(group.Parts) do
			local from: number = group.Transparencies[partIndex]
			part.Transparency = from + (1 - from) * alpha
		end
		if fade >= 1 then
			Module._finish(group)
			table.remove(groups, index)
		end
	end

	--[[ Stopping ]]

	if #groups == 0 and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Throw

--[[
	Throws a group of a prop's parts off it on this screen, from now, at a velocity and spinning in the plane (up to
	PROP_KNOCK_SPIN): it flies by the game's gravity until it lands on the terrain, lies there, then fades. `owned`
	marks this screen's own pieces, which go after; the server's parts are put back where they stood if the server
	kept them after all, else left see-through for it to remove.
]]
--- @param parts { BasePart }
--- @param owned { [BasePart]: boolean }
function Module.Throw(parts, owned, push: Vector3)
	Module._add(parts, owned, push, (math.random() - 0.5) * 2 * _settings.PROP_KNOCK_SPIN, nil, I.Match.GetDrawTime())
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	Drops a prop's parts on this screen straight down by the game's gravity, `drop` studs from server time `started`
	(Arena_PropFall), so it falls with the ground under it; it lies there, then fades. `owned` marks this screen's own
	pieces, which go after; the server's parts are left see-through for it to remove.
]]
--- @param parts { BasePart }
--- @param owned { [BasePart]: boolean }
function Module.Drop(parts, owned, drop: number, started: number)
	Module._add(parts, owned, Vector3.zero, 0, drop, started)
end

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	Starts drawing a group of a prop's parts as one rigid piece about the middle of its box: this screen's own pieces
	move to the Thrown folder, the server's stay where they are and are only moved here. Tells others it set off
	(Arena_PropThrown).
]]
--- @param parts { BasePart }
--- @param owned { [BasePart]: boolean }
function Module._add(parts, owned, velocity: Vector3, spin: number, drop: number?, started: number)
	--[[ Checks ]]

	-- Check if there's anything to draw
	if #parts == 0 then
		return
	end

	--[[ Local Variables ]]

	local low: Vector3 = Vector3.one * math.huge
	local high: Vector3 = -Vector3.one * math.huge
	for _index: number, part: BasePart in ipairs(parts) do
		local half: Vector3 = PropCut.GetExtents(part)
		low = low:Min(part.Position - half)
		high = high:Max(part.Position + half)
	end
	local frame: CFrame = CFrame.new((low + high) / 2)

	--- @type Arena_ThrownGroup
	local group = {
		Parts = parts,
		Owned = owned,
		Offsets = {},
		Transparencies = {},
		Homes = {},
		Origins = {},
		Frame = frame,
		Start = frame,
		Size = high - low,
		Velocity = velocity,
		Spin = spin,
		Drop = drop,
		Started = started,
		Last = started,
		Still = false,
	}

	--[[ Taking ]]

	for index: number, part: BasePart in ipairs(parts) do
		group.Offsets[index] = frame:ToObjectSpace(part.CFrame)
		group.Transparencies[index] = part.Transparency
		if owned[part] then
			part.Parent = thrownFolder
		else
			flying[part] = true
			group.Homes[part] = part.Parent
			group.Origins[part] = part.CFrame
		end
	end
	table.insert(groups, group)

	--[[ Publishing ]]

	I.Topic.Publish("Arena_PropThrown", parts[1])

	--[[ Connections ]]

	if not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fly

--[[
	Moves a thrown group on by `deltaTime` seconds of the game's gravity, spinning, and sweeps its box (LAND_INSET in
	from its sides) along the move: where it meets the terrain it stops and lies, and it falls on again if the ground
	under it goes. Once below the arena (DEBRIS_KILL_DEPTH under the bounds) it stops for good.
]]
--- @param group Arena_ThrownGroup
function Module._fly(group, deltaTime: number, floor: number)
	--[[ Local Variables ]]

	local gravity: Vector3 = Vector3.new(0, -I.S.Workspace.Gravity, 0)
	local move: Vector3 = group.Velocity * deltaTime + gravity * (0.5 * deltaTime * deltaTime)

	--[[ Checks ]]

	-- Check if it moves at all this frame
	if deltaTime <= 0 or move.Magnitude < 1e-6 then
		return
	end

	--[[ Casting ]]

	group.Velocity += gravity * deltaTime
	local size: Vector3 = (group.Size - Vector3.one * LAND_INSET * 2):Max(Vector3.one * 0.1)
	local hit: RaycastResult? = I.S.Workspace:Blockcast(group.Frame, size, move + move.Unit * LAND_INSET, landParams)

	--[[ Moving ]]

	if hit then
		group.Frame += move.Unit * math.max(hit.Distance - LAND_INSET, 0)
		group.Velocity = Vector3.zero
		group.Spin = 0
	else
		group.Frame = (group.Frame + move) * CFrame.Angles(0, 0, group.Spin * deltaTime)
	end
	group.Still = group.Frame.Position.Y < floor
end

--%%%%%%%%%%%%%%%%%%%% Finish

--[[
	Ends a faded group: this screen's own pieces go; a server part the server never threw (still where it stood) goes
	back there as it was, the rest stay see-through until the server removes them.
]]
--- @param group Arena_ThrownGroup
function Module._finish(group)
	--[[ Clearing ]]

	for index: number, part: BasePart in ipairs(group.Parts) do
		if group.Owned[part] then
			part:Destroy()
			continue
		end
		flying[part] = nil

		-- The server kept it standing after all: back where it stood
		if not group.Drop and part.Parent and part.Parent == group.Homes[part] then
			part.CFrame = group.Origins[part]
			part.Transparency = group.Transparencies[index]
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Flying

--[[
	Returns whether this screen moves a server part now (thrown off a prop, or falling with it).
]]
--- @return boolean
function Module.IsFlying(part: BasePart)
	return flying[part] == true
end

return Module
