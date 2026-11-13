--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("ServerData")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local Brains = require(_data:FindFirstChild("Brains")) --- @type { [string]: Bots_Genome }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Brain = require(script.Parent:FindFirstChild("Brain")) --- @type Bots_Server_Brain
local Predict = require(script.Parent:FindFirstChild("Predict")) --- @type Bots_Server_Predict
local Sim = require(script.Parent:FindFirstChild("Sim")) --- @type Bots_Server_Sim

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The probe's shots: every angle (degrees) at every power, with and without wind
--- @type { number }
local ANGLES = { 20, 45, 70, 110, 135, 160 }

--- @type { number }
local POWERS = { 0.5, 0.8, 1 }

--- @type { number }
local WINDS = { 0, 7 }

-- How far apart the probe's stand spots are, and how far in from the bounds' sides they start, in studs
local SPOT_STEP: number = 37
local SPOT_MARGIN: number = 10

--[[
	Where the probe reads a column, off the 1-stud grid the parts meet on: a cast down a seam between two parts of
	the same height hits both at once, and which one Roblox reports is its own pick
]]
local SEAM_OFFSET: number = 0.25

-- How many of its Bazooka blasts it carves, and how long it then lets the ground and liquid settle, in seconds
local CARVES: number = 6
local SETTLE_SECONDS: number = 5

-- How far apart the probe reads the ground and the liquid across the map, in studs
local PROFILE_STEP: number = 2

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

--- @class Bots_Server_Parity
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Probes the game's simulation the same way wherever it runs (Studio, or the PC gym that runs this code outside
	Roblox), so the two reports can be compared line by line: on each map, fresh, where four stand-in snails stand,
	what a fixed set of shots does (blasts, strikes, damage, throws), what the Hard brain plans for each snail, then the
	ground and liquid after carving some of the blasts. Each line starts with its map and its kind.
]]
--- @param maps { string }
--- @return { string }
function Module.Run(maps, folder: Folder)
	--[[ Local Variables ]]

	local lines = {} --- @type { string }

	--[[ Probing ]]

	for _index: number, mapId: string in ipairs(maps) do
		Module._probeMap(mapId, folder, lines)
	end

	--[[ Returning ]]

	return lines
end

--%%%%%%%%%%%%%%%%%%%% Probe Map

--[[
	Probes one map from a fresh load (Run) into `lines`, and takes its stand-in snails away after.
]]
--- @param lines { string }
function Module._probeMap(mapId: string, folder: Folder, lines)
	--[[ Loading ]]

	if not I.Arena.Load(mapId) then
		table.insert(lines, `{mapId}|error|the map didn't load`)
		return
	end
	Predict.ClearColumns()

	--[[ Seating ]]

	local seats = {} --- @type { Bots_Seat }
	local spots = {} --- @type { string }
	--- @param spot Vector3
	for index: number, spot in ipairs(Module._getSpots()) do
		--- @type Bots_Seat
		local seat = {
			Id = `G_{index}`,
			Team = (index - 1) % 2 + 1,
			Genome = Brains.Hard,
			Skill = _settings.SKILLS.Hard,
			Loadout = _settings.LOADOUTS.Nightmare,
		}
		Sim._seat(seat, spot, folder)
		table.insert(seats, seat)
		table.insert(spots, Module._getText(spot))
	end
	table.insert(lines, `{mapId}|spots|{table.concat(spots, " ")}`)

	--[[ Shots ]]

	local snails = Sim._getSnails(seats) --- @type { Bots_Snail }
	local items = { "Bazooka" } --- @type { string }
	for _index: number, itemId: string in ipairs(_settings.LOADOUTS.Nightmare) do
		if I.G_Arsenal.IsWeapon(itemId) then
			table.insert(items, itemId)
		end
	end
	local carves = {} --- @type { Bots_Blast }
	for shooter: number = 1, math.min(#seats, 2) do
		local seat = seats[shooter] --- @type Bots_Seat
		local target: Vector3 = seats[if shooter == 1 then 2 else 1].Model.PrimaryPart.Position
		for _itemIndex: number, itemId: string in ipairs(items) do
			for _angleIndex: number, angle: number in ipairs(ANGLES) do
				for _powerIndex: number, power: number in ipairs(POWERS) do
					for _windIndex: number, wind: number in ipairs(WINDS) do
						local shot = Predict.GetShot(seat.Model.PrimaryPart.Position, itemId, math.rad(angle), power, target, wind, seat.Model, snails, nil) --- @type Bots_Shot?
						table.insert(lines, `{mapId}|shot|{seat.Id} {itemId} {angle} {power} {wind}|{Module._getShotText(shot, snails)}`)
						if shot and itemId == "Bazooka" and #carves < CARVES and shot.Blasts[1] and Module._isNewHole(shot.Blasts[1], carves) then
							table.insert(carves, shot.Blasts[1])
						end
					end
				end
			end
		end
	end

	--[[ Plans ]]

	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		local plan = Brain.GetPlan(Sim._getView(seat, seats, 3, 1), Brains.Hard, _settings.SKILLS.Hard) --- @type Bots_Plan?
		local text: string = if plan
			then `{plan.ItemId} at {plan.TargetId} from {Module._getText(plan.Spot.Position)} angle {Module._getNumber(math.deg(plan.Angle))} power {Module._getNumber(plan.Power)} score {Module._getNumber(plan.Score)}`
			else "none"
		table.insert(lines, `{mapId}|plan|{seat.Id}|{text}`)
	end

	--[[ Carving ]]

	--- @param blast Bots_Blast
	for _index: number, blast in ipairs(carves) do
		I.Arena.Carve(blast.Center, blast.Radius)
	end
	local settled: number = 0
	while settled < SETTLE_SECONDS do
		settled += task.wait(0.1)
	end
	Predict.ClearColumns()
	Module._addProfile(mapId, lines)
	table.insert(lines, `{mapId}|sea|{Module._getNumber(I.Arena.GetSeaLevel())}`)

	--[[ Cleaning ]]

	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		seat.Model:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Profile

--[[
	Adds the ground and the liquid across the loaded map every PROFILE_STEP studs to `lines`: each column's solid
	stretches (Predict's, off the seams), and each row of liquid as W (water), L (lava) and . from the bottom up.
]]
--- @param lines { string }
function Module._addProfile(mapId: string, lines)
	--[[ Data ]]

	local bounds: BasePart = I.Arena.GetBounds()

	--[[ Local Variables ]]

	local left: number = bounds.Position.X - bounds.Size.X / 2
	local right: number = bounds.Position.X + bounds.Size.X / 2
	local bottom: number = bounds.Position.Y - bounds.Size.Y / 2
	local top: number = bounds.Position.Y + bounds.Size.Y / 2

	--[[ Ground ]]

	for x: number = left + PROFILE_STEP / 2 + SEAM_OFFSET, right, PROFILE_STEP do
		local stretches = {} --- @type { string }
		--- @param solid Vector2
		for _index: number, solid in ipairs(Predict.GetColumn(x)) do
			table.insert(stretches, `{Module._getNumber(solid.X)}:{Module._getNumber(solid.Y)}`)
		end
		table.insert(lines, `{mapId}|ground|{Module._getNumber(x)}|{table.concat(stretches, " ")}`)
	end

	--[[ Liquid ]]

	for y: number = bottom + PROFILE_STEP / 2, top, PROFILE_STEP do
		local row = {} --- @type { string }
		for x: number = left + PROFILE_STEP / 2, right, PROFILE_STEP do
			local kind: string? = I.Arena.GetLiquid(Vector3.new(x, y, 0))
			table.insert(row, if kind == "Water" then "W" elseif kind == "Lava" then "L" else ".")
		end
		table.insert(lines, `{mapId}|liquid|{Module._getNumber(y)}|{table.concat(row)}`)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Spots

--[[
	Returns up to four spots to stand the probe's snails on, found the same way every time: the highest ground under
	every SPOT_STEP studs across the bounds (off the seams), skipping the sea.
]]
--- @return { Vector3 }
function Module._getSpots()
	--[[ Data ]]

	local bounds: BasePart = I.Arena.GetBounds()

	--[[ Local Variables ]]

	local spots = {} --- @type { Vector3 }
	local top: number = bounds.Position.Y + bounds.Size.Y / 2
	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local params: RaycastParams = RaycastParams.new()
	params.CollisionGroup = "Snail"
	params.RespectCanCollide = true

	--[[ Finding ]]

	for x: number = bounds.Position.X - bounds.Size.X / 2 + SPOT_MARGIN + SEAM_OFFSET, bounds.Position.X + bounds.Size.X / 2 - SPOT_MARGIN, SPOT_STEP do
		local hit: RaycastResult? = I.S.Workspace:Raycast(Vector3.new(x, top, 0), Vector3.new(0, -bounds.Size.Y, 0), params)
		local ground: Vector3? = if hit then hit.Position + Vector3.yAxis * radius else nil
		if ground and not I.Arena.GetHazard(ground) then
			table.insert(spots, ground)
		end
		if #spots == 4 then
			break
		end
	end

	--[[ Returning ]]

	return spots
end

--%%%%%%%%%%%%%%%%%%%% Is New Hole

--[[
	Returns whether a blast is clear of the ones picked to carve already (more than its radius from each), so the
	carves cut different ground.
]]
--- @param blast Bots_Blast
--- @param carves { Bots_Blast }
--- @return boolean
function Module._isNewHole(blast, carves)
	--[[ Checking ]]

	--- @param other Bots_Blast
	for _index: number, other in ipairs(carves) do
		if (other.Center - blast.Center).Magnitude <= blast.Radius then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Shot Text

--[[
	Returns a shot's outcome as text: where it landed, its blasts and strikes, and what its effects do to each snail
	(damage, knocked out, where it ends up), snails in id order.
]]
--- @param shot Bots_Shot?
--- @param snails { Bots_Snail }
--- @return string
function Module._getShotText(shot, snails)
	--[[ Checks ]]

	-- Check if the brain can foresee the shot
	if not shot then
		return "unforeseen"
	end

	--[[ Describing ]]

	local blasts = {} --- @type { string }
	--- @param blast Bots_Blast
	for _index: number, blast in ipairs(shot.Blasts) do
		table.insert(blasts, `{Module._getText(blast.Center)} r{Module._getNumber(blast.Radius)}`)
	end
	local strikes = {} --- @type { string }
	--- @param strike Bots_Strike
	for _index: number, strike in ipairs(shot.Strikes) do
		table.insert(strikes, `{strike.Id} {Module._getNumber(strike.Damage)}`)
	end
	local effects = Predict.GetEffects(shot, snails) --- @type { [string]: Bots_Effect }
	local hurt = {} --- @type { string }
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(snails) do
		local effect = effects[snail.Id] --- @type Bots_Effect?
		if effect then
			table.insert(hurt, `{snail.Id} {Module._getNumber(effect.Damage)}{if effect.Out then " out" else ""} to {Module._getText(effect.Position)}`)
		end
	end

	--[[ Returning ]]

	return `landed {Module._getText(shot.Landed)}|blasts {table.concat(blasts, "; ")}|strikes {table.concat(strikes, "; ")}|effects {table.concat(hurt, "; ")}`
end

--%%%%%%%%%%%%%%%%%%%% Get Text

--[[
	Returns a position's X and Y as text, to a hundredth of a stud.
]]
--- @return string
function Module._getText(position: Vector3)
	return `{Module._getNumber(position.X)},{Module._getNumber(position.Y)}`
end

--%%%%%%%%%%%%%%%%%%%% Get Number

--[[
	Returns a number as text to two decimals, with no minus sign on a zero.
]]
--- @return string
function Module._getNumber(value: number)
	local text: string = string.format("%.2f", value)
	return if text == "-0.00" then "0.00" else text
end

return Module
