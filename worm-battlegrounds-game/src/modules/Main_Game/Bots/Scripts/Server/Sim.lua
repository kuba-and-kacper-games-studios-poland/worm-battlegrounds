--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Aim = require(script.Parent:FindFirstChild("Aim")) --- @type Bots_Server_Aim
local Brain = require(script.Parent:FindFirstChild("Brain")) --- @type Bots_Server_Brain
local Move = require(script.Parent:FindFirstChild("Move")) --- @type Bots_Server_Move
local Predict = require(script.Parent:FindFirstChild("Predict")) --- @type Bots_Server_Predict

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Casts that see what snails stand on (the terrain)
local groundParams: RaycastParams = RaycastParams.new()

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

--- @class Bots_Server_Sim
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Setup ]]

	groundParams.CollisionGroup = "Snail"
	groundParams.RespectCanCollide = true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays one headless match on a map between seats, as fast as the server thinks: the real arena (Arena.Load, its
	craters and sea), each seat a stand-in ball the brain and shots see as a snail, turns in the match's team order
	with a random wind, sudden death from Match's SUDDEN_DEATH_ROUND, until one team is left or `maxRounds` pass. A
	shortcut of a real match: snails teleport to their spot instead of walking, and thrown ones land where Predict's
	throw says. Fills each seat's result fields and adds the match to `stats`; with `log`, prints each turn to the
	Output. Returns whether the map could be played.
]]
--- @param seats { Bots_Seat }
--- @param stats Bots_Stats
--- @return boolean
function Module.Play(mapId: string, seats, maxRounds: number, folder: Folder, random: Random, stats, log: boolean)
	--[[ Loading ]]

	if not I.Arena.Load(mapId) then
		return false
	end
	local spots = I.Arena.GetLandSpots(#seats, I.Settings["Snails"].ROOT_SIZE / 2) --- @type { Vector3 }
	if #spots == 0 then
		return false
	end

	--[[ Seating ]]

	local taken = {} --- @type { Vector3 }
	local teams = {} --- @type { { Bots_Seat } }
	local teamOf = {} --- @type { [number]: { Bots_Seat } }
	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		local spot: Vector3 = Brain.GetStart(spots, taken, seat.Genome)
		table.insert(taken, spot)
		Module._seat(seat, spot, folder)
		if not teamOf[seat.Team] then
			teamOf[seat.Team] = {}
			table.insert(teams, teamOf[seat.Team])
		end
		table.insert(teamOf[seat.Team], seat)
	end

	--[[ Playing ]]

	local match = I.Settings["Match"] --- @type Match_Settings
	local teamIndex: number = 0
	local memberIndex = {} --- @type { [number]: number }
	local round: number = 1
	local turn: number = 0
	while Module._getTeamsLeft(teams) > 1 and round <= maxRounds do
		-- The next team with a snail in play, and its next snail
		local seat = nil --- @type Bots_Seat?
		for _try: number = 1, #teams do
			teamIndex = teamIndex % #teams + 1
			if teamIndex == 1 and turn > 0 then
				round += 1
			end
			local members = teams[teamIndex] --- @type { Bots_Seat }
			for _member: number = 1, #members do
				memberIndex[teamIndex] = (memberIndex[teamIndex] or 0) % #members + 1
				if not members[memberIndex[teamIndex]].Out then
					seat = members[memberIndex[teamIndex]]
					break
				end
			end
			if seat then
				break
			end
		end
		if not seat then
			break
		end

		turn += 1
		if round >= match.SUDDEN_DEATH_ROUND then
			I.Arena.RaiseLiquid(match.SUDDEN_DEATH_RISE)
		end
		Module._playTurn(seat, seats, turn, round, random, stats, log)
	end
	stats.Matches += 1
	stats.Turns += turn

	--[[ Cleaning ]]

	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		seat.Model:Destroy()
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Seat

--[[
	Readies a seat for a match: full health, its Loadout's uses (and the Bazooka's endless ones), no cooldowns, and a
	stand-in snail on its spot: an anchored ball of a snail's size in its team's colour, in the gym's Snails folder,
	which shots hit and the ground under snails ignores.
]]
--- @param seat Bots_Seat
function Module._seat(seat, spot: Vector3, folder: Folder)
	--[[ Saving ]]

	seat.Health = I.Settings["Snails"].MAX_HEALTH
	seat.Uses = { Bazooka = -1 }
	seat.Cooldowns = { Bazooka = 0 }
	seat.Out = false
	seat.OutTurn = math.huge
	seat.Dealt = 0
	seat.Friendly = 0
	seat.LastAttacker = nil
	seat.Ranging = nil
	for _index: number, itemId: string in ipairs(seat.Loadout) do
		local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
		seat.Uses[itemId] = row.Uses

		-- As in a match (Combat's Uses.Reset), strong weapons start on their cooldown
		local starts: boolean = I.G_Arsenal.IsWeapon(itemId) and row.Cooldown ~= nil and row.Cooldown > 0
		seat.Cooldowns[itemId] = if starts then row.Cooldown + 1 else 0
	end

	--[[ Building ]]

	local model: Model = I.Create("Model")({
		Name = seat.Id,
	})
	local root: Part = I.Create("Part")({
		Name = "Root",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * I.Settings["Snails"].ROOT_SIZE,
		CFrame = CFrame.new(spot),
		Color = I.Settings["Match"].TEAMS[(seat.Team - 1) % #I.Settings["Match"].TEAMS + 1].Color,
		Material = Enum.Material.SmoothPlastic,
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CollisionGroup = "Snail",
		Parent = model,
	})
	model.PrimaryPart = root
	model.Parent = folder
	seat.Model = model
end

--%%%%%%%%%%%%%%%%%%%% Play Turn

--[[
	Plays one seat's turn: its cooldowns count down, it heals and plans with its brain, goes to its spot (a jetpack use
	when it flies), fires with its hand's error into the real wind, runs from placed Dynamite, and the shot's effects
	land: damage with credit, knockouts and throws, craters. Then everyone settles on what ground is left. Counts what
	it did in `stats`, and prints it with `log`.
]]
--- @param seat Bots_Seat
--- @param seats { Bots_Seat }
--- @param stats Bots_Stats
function Module._playTurn(seat, seats, turn: number, round: number, random: Random, stats, log: boolean)
	--[[ Local Variables ]]

	local wind: number = random:NextInteger(-I.Settings["Match"].WIND_MAX, I.Settings["Match"].WIND_MAX)
	for itemId: string, turns: number in pairs(seat.Cooldowns) do
		seat.Cooldowns[itemId] = math.max(turns - 1, 0)
	end

	--[[ Healing ]]

	local heal: string? = Brain.GetHeal(Module._getView(seat, seats, wind, round), seat.Genome)
	if heal then
		seat.Health = math.min(seat.Health + (I.G_Arsenal.Get(heal).Amount or 0), I.Settings["Snails"].MAX_HEALTH)
		Module._take(seat, heal)
		stats.Heals += 1
	end

	--[[ Planning ]]

	local plan = Brain.GetPlan(Module._getView(seat, seats, wind, round), seat.Genome, seat.Skill) --- @type Bots_Plan?
	if not plan then
		return
	end
	local row = I.G_Arsenal.Get(plan.ItemId) --- @type Arsenal_WeaponData

	--[[ Moving ]]

	if plan.Spot.Fly and seat.Uses["Jetpack"] and seat.Uses["Jetpack"] ~= 0 then
		Module._take(seat, "Jetpack")
		stats.Jetpacks += 1
	end
	stats.Moves += if plan.Spot.Walk > 0 then 1 else 0
	stats.Air += if plan.Spot.Air then 1 else 0
	stats.Weapons[plan.ItemId] = (stats.Weapons[plan.ItemId] or 0) + 1
	seat.Model:PivotTo(CFrame.new(plan.Spot.Position))

	--[[ Firing ]]

	local angle: number = plan.Angle
	local power: number = plan.Power
	if row.Aim ~= "Melee" and row.Aim ~= "Feet" then
		local ranging = seat.Ranging --- @type Bots_Ranging?
		local same: boolean = ranging ~= nil and ranging.TargetId == plan.TargetId and (ranging.From - plan.Spot.Position).Magnitude <= _settings.MOVE_STEP
		local shots: number = if same and ranging then ranging.Shots else 0
		seat.Ranging = { TargetId = plan.TargetId, From = plan.Spot.Position, Shots = shots + 1 }
		angle, power = Aim.GetShaken(angle, power, seat.Skill, shots)
	end
	Module._take(seat, plan.ItemId)
	local shot = Predict.GetShot(plan.Spot.Position, plan.ItemId, angle, power, plan.Target, wind, seat.Model, Module._getSnails(seats), random) --- @type Bots_Shot?
	if not shot then
		return
	end

	-- From placed Dynamite it runs toward the side with more ground before it goes off
	if row.Retreat then
		local origin: Vector3 = plan.Spot.Position
		local run: number = I.Settings["SnailControl"].WALK_SPEED * row.Retreat
		local left: number = Move.GetRunway(origin, -1, run)
		local right: number = Move.GetRunway(origin, 1, run)
		local x: number = origin.X + (if left > right then -left else right)
		seat.Model:PivotTo(CFrame.new(Move.GetGround(x, origin.Y, 5) or origin))
	end

	--[[ Applying ]]

	local snails = Module._getSnails(seats) --- @type { Bots_Snail }
	local effects = Predict.GetEffects(shot, snails) --- @type { [string]: Bots_Effect }
	local dealt: number = seat.Dealt
	local friendly: number = seat.Friendly
	stats.Shots += 1
	--- @param other Bots_Seat
	for _index: number, other in ipairs(seats) do
		local effect = effects[other.Id] --- @type Bots_Effect?
		if effect and not other.Out then
			local damage: number = math.min(effect.Damage, other.Health)
			if other.Team ~= seat.Team then
				seat.Dealt += damage
			else
				seat.Friendly += damage
			end
			if other ~= seat then
				other.LastAttacker = seat.Id
			end
			other.Health -= damage
			if effect.Out then
				Module._knockOut(other, turn)
				stats.Knockouts += 1
				stats.Thrown += if other.Health > 0 then 1 else 0
			else
				other.Model:PivotTo(CFrame.new(effect.Position))
			end
		end
	end

	stats.Hits += if seat.Dealt > dealt then 1 else 0
	stats.Friendly += if seat.Friendly > friendly then 1 else 0
	stats.Damage += seat.Dealt - dealt
	--- @param blast Bots_Blast
	for _index: number, blast in ipairs(shot.Blasts) do
		I.Arena.Carve(blast.Center, blast.Radius)
	end
	if log then
		print(
			`[{_localName}::{script.Name}]: Turn {turn} {seat.Id}: {plan.ItemId} at {plan.TargetId} from {plan.Spot.Walk} studs{if plan.Spot.Air then " (in the air)" elseif plan.Spot.Fly then " (jetpack)" else ""}, wind {wind}, planned {string.format(
				"%.2f",
				plan.Score
			)}; dealt {seat.Dealt - dealt}, own side {seat.Friendly - friendly}`
		)
	end

	--[[ Settling ]]

	local deadline: number = os.clock() + _settings.SETTLE_LIMIT
	while not I.Arena.IsSettled() and os.clock() < deadline do
		task.wait(0.1)
	end
	Module._settle(seats, turn, stats)
end

--%%%%%%%%%%%%%%%%%%%% Settle

--[[
	Drops every snail in play onto the ground under it, which a crater may have taken: a fall into the sea or out of
	the arena knocks it out, a long one costs fall damage, a head in a pond costs Match's UNDERWATER_DAMAGE, and 0
	health knocks it out. Counts its knockouts in `stats`.
]]
--- @param seats { Bots_Seat }
--- @param stats Bots_Stats
function Module._settle(seats, turn: number, stats)
	--[[ Local Variables ]]

	local snails = I.Settings["Snails"] --- @type Snails_Settings
	local match = I.Settings["Match"] --- @type Match_Settings

	--[[ Dropping ]]

	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		if not seat.Out then
			-- From a stud up: a cast misses the ground the ball already touches
			local position: Vector3 = seat.Model.PrimaryPart.Position
			local from: Vector3 = position + Vector3.yAxis
			local hit: RaycastResult? = I.S.Workspace:Spherecast(from, snails.ROOT_SIZE / 2, Vector3.yAxis * -_settings.FALL_LOOK * 4, groundParams)
			local landed: Vector3 = if hit then from - Vector3.yAxis * hit.Distance else position
			if not hit or I.Arena.GetHazard(landed) then
				Module._knockOut(seat, turn)
				stats.Knockouts += 1
				stats.Thrown += 1
			else
				seat.Health -= math.clamp(math.floor(position.Y - landed.Y - snails.SAFE_FALL_HEIGHT), 0, snails.MAX_FALL_DAMAGE)
				seat.Model:PivotTo(CFrame.new(landed))

				-- A head in a pond: Match's poison at the end of the turn, never below 1
				if seat.Health > 1 and I.Arena.GetLiquid(landed + Vector3.yAxis * match.UNDERWATER_HEAD_HEIGHT) then
					seat.Health -= math.min(match.UNDERWATER_DAMAGE, seat.Health - 1)
				end
				if seat.Health <= 0 then
					Module._knockOut(seat, turn)
					stats.Knockouts += 1
				end
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Knock Out

--[[
	Takes a seat's snail out of the match on a turn.
]]
--- @param seat Bots_Seat
function Module._knockOut(seat, turn: number)
	--[[ Saving ]]

	seat.Out = true
	seat.OutTurn = turn
	seat.Health = 0
	seat.Model.Parent = nil
end

--%%%%%%%%%%%%%%%%%%%% Take

--[[
	Takes one use of an item from a seat and starts its cooldown, as Combat's Uses does.
]]
--- @param seat Bots_Seat
function Module._take(seat, itemId: string)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Saving ]]

	if seat.Uses[itemId] > 0 then
		seat.Uses[itemId] -= 1
	end
	if row.Cooldown and row.Cooldown > 0 then
		seat.Cooldowns[itemId] = row.Cooldown + 1
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get View

--[[
	Returns what a seat's brain knows on its turn, as a live bot's view: every snail in play, the wind, the round, full
	stamina,
	the items it may use now and who hurt it last.
]]
--- @param seat Bots_Seat
--- @param seats { Bots_Seat }
--- @return Bots_View
function Module._getView(seat, seats, wind: number, round: number)
	--[[ Local Variables ]]

	local others = {} --- @type { Bots_Snail }
	local uses = {} --- @type { [string]: number }
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(Module._getSnails(seats)) do
		if snail.Id ~= seat.Id then
			table.insert(others, snail)
		end
	end
	for itemId: string, left: number in pairs(seat.Uses) do
		if left ~= 0 and seat.Cooldowns[itemId] == 0 then
			uses[itemId] = left
		end
	end

	--[[ Returning ]]

	--- @type Bots_View
	local view = {
		Self = {
			Id = seat.Id,
			Model = seat.Model,
			Team = seat.Team,
			IsBot = true,
			Position = seat.Model.PrimaryPart.Position,
			Health = seat.Health,
		},
		Snails = others,
		Wind = wind,
		Round = round,
		Stamina = I.Settings["SnailControl"].STAMINA_STUDS,
		Uses = uses,
		LastAttacker = seat.LastAttacker,
	}
	return view
end

--%%%%%%%%%%%%%%%%%%%% Get Snails

--[[
	Returns every seat's snail still in play, as a brain sees snails.
]]
--- @param seats { Bots_Seat }
--- @return { Bots_Snail }
function Module._getSnails(seats)
	--[[ Local Variables ]]

	local snails = {} --- @type { Bots_Snail }

	--[[ Listing ]]

	--- @param seat Bots_Seat
	for _index: number, seat in ipairs(seats) do
		if not seat.Out then
			table.insert(snails, {
				Id = seat.Id,
				Model = seat.Model,
				Team = seat.Team,
				IsBot = true,
				Position = seat.Model.PrimaryPart.Position,
				Health = seat.Health,
			})
		end
	end

	--[[ Returning ]]

	return snails
end

--%%%%%%%%%%%%%%%%%%%% Get Teams Left

--[[
	Returns how many teams still have a snail in play.
]]
--- @param teams { { Bots_Seat } }
--- @return number
function Module._getTeamsLeft(teams)
	--[[ Counting ]]

	local left: number = 0
	--- @param members { Bots_Seat }
	for _index: number, members in ipairs(teams) do
		--- @param seat Bots_Seat
		for _member: number, seat in ipairs(members) do
			if not seat.Out then
				left += 1
				break
			end
		end
	end

	--[[ Returning ]]

	return left
end

return Module
