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

local Aim = require(script.Parent:FindFirstChild("Aim")) --- @type Bots_Server_Aim
local Brain = require(script.Parent:FindFirstChild("Brain")) --- @type Bots_Server_Brain
local Parity = require(script.Parent:FindFirstChild("Parity")) --- @type Bots_Server_Parity
local Sim = require(script.Parent:FindFirstChild("Sim")) --- @type Bots_Server_Sim

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The gym's world folder (Studio only), and the stand-in snails in it
local gymFolder: Folder? = nil
local snailsFolder: Folder? = nil

-- Whether a run is going, and whether it was asked to stop after its current match
local running: boolean = false
local stopping: boolean = false

-- A genome's keys in the order they're written (ServerData/Brains)
--- @type { string }
local GENOME_KEYS = {
	"EnemyDamage",
	"Knockout",
	"Focus",
	"Grudge",
	"Pressure",
	"AllyDamage",
	"AllyKnockout",
	"SelfDamage",
	"SelfKnockout",
	"Ammo",
	"Walk",
	"Jetpack",
	"Edge",
	"Footing",
	"Low",
	"Height",
	"Cover",
	"Exposure",
	"Crowd",
	"Threat",
	"HealBelow",
}

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

--- @class Bots_Server_Gym
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Checks ]]

	-- The gym only runs in Studio
	if not I.S.RunService:IsStudio() then
		return
	end

	--[[ Building ]]

	Sim.Init()
	gymFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
	snailsFolder = I.Create("Folder")({
		Name = "Snails",
		Parent = gymFolder,
	})
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Checks ]]

	-- The gym only runs in Studio
	if not I.S.RunService:IsStudio() then
		return
	end

	--[[ Connections ]]

	I.S.Workspace:GetAttributeChangedSignal(_settings.TRAIN_ATTRIBUTE):Connect(Module._onTrainChanged)
	I.S.Workspace:GetAttributeChangedSignal(_settings.PARITY_ATTRIBUTE):Connect(Module._onParityChanged)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Train Changed

--[[
	Starts a training run when the Workspace's TRAIN_ATTRIBUTE is set to its options as JSON (`{}` for the defaults),
	or asks the running one to stop after its current match when it's set to "stop".
]]
function Module._onTrainChanged()
	--[[ Data ]]

	local value: any = I.S.Workspace:GetAttribute(_settings.TRAIN_ATTRIBUTE)

	--[[ Checks ]]

	-- Check if it's a request
	if typeof(value) ~= "string" or value == "" then
		return
	end

	-- A stop asks the running one to finish its match
	if value == "stop" then
		stopping = running
		return
	end

	-- Check if a run is going already
	if running then
		warn(`[{_localName}::{script.Name}]: A training run is going already - set {_settings.TRAIN_ATTRIBUTE} to "stop" first.`)
		return
	end

	--[[ Parsing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.HttpService.JSONDecode, I.S.HttpService, value)
	if not success or typeof(result) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Training options ({value}) aren't JSON! - ({result})`)
		return
	end
	local options = table.clone(_settings.TRAIN_DEFAULTS) --- @type Bots_TrainOptions
	for key: string, option: any in pairs(result) do
		options[key] = option
	end

	--[[ Running ]]

	task.spawn(Module.Train, options)
end

--%%%%%%%%%%%%%%%%%%%% On Parity Changed

--[[
	Runs the parity probe when the Workspace's PARITY_ATTRIBUTE is set to its maps (JSON, `{}` for every map) and no
	run or match is going, and writes its report (its lines) to ServerStorage's PARITY_RESULT folder: StringValues
	named 1, 2… of whole lines each, under PARITY_CHUNK characters (a StringValue holds fewer than 200,000).
]]
function Module._onParityChanged()
	--[[ Data ]]

	local value: any = I.S.Workspace:GetAttribute(_settings.PARITY_ATTRIBUTE)

	--[[ Checks ]]

	-- Check if it's a request
	if typeof(value) ~= "string" or value == "" then
		return
	end

	-- Check if the arena is free
	if running or (I.Match.GetPhase() ~= "Waiting" and I.Match.GetPhase() ~= "Ended") then
		warn(`[{_localName}::{script.Name}]: The parity probe needs the arena free - no run or match may be going.`)
		return
	end

	--[[ Parsing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.HttpService.JSONDecode, I.S.HttpService, value)
	if not success or typeof(result) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Parity options ({value}) aren't JSON! - ({result})`)
		return
	end

	--[[ Probing ]]

	running = true
	Module._setStatus("Parity probe running")
	local lines = Parity.Run(result.Maps or Module._getMaps(), snailsFolder) --- @type { string }

	--[[ Saving ]]

	local old: Instance? = I.S.ServerStorage:FindFirstChild(_settings.PARITY_RESULT)
	if old then
		old:Destroy()
	end
	local holder: Folder = I.Create("Folder")({
		Name = _settings.PARITY_RESULT,
	})
	local chunk = {} --- @type { string }
	local size: number = 0
	local chunks: number = 0
	for index: number, line: string in ipairs(lines) do
		table.insert(chunk, line)
		size += #line + 1
		if index == #lines or size + #lines[index + 1] >= _settings.PARITY_CHUNK then
			chunks += 1
			I.Create("StringValue")({
				Name = tostring(chunks),
				Value = table.concat(chunk, "\n"),
				Parent = holder,
			})
			chunk = {}
			size = 0
		end
	end
	holder.Parent = I.S.ServerStorage
	Module._setStatus(`Parity probe done: {#lines} lines in {chunks} parts (ServerStorage.{_settings.PARITY_RESULT})`)
	running = false
end

--%%%%%%%%%%%%%%%%%%%% Train

--[[
	A training run, in Studio with no match playing: self-play evolution of a difficulty's genome. A population starts
	from the shipped genome (ServerData/Brains), or the options' Start, and mutants of it; each generation plays headless matches (Sim) between them,
	free-for-alls and 2 v 2s on the maps, scores every seat by its place and the damage it dealt, keeps the best
	(Elites), and breeds the rest from the better ones with crossover and mutation. The champion then sits an exam
	against the shipped genome, or the options' Baseline (with 0 Generations, Start sits it: a head-to-head). The report (JSON, with the champion as Lua to paste into ServerData/Brains) goes to
	ServerStorage's TRAIN_RESULT and the Output; the progress shows in TRAIN_STATUS_ATTRIBUTE.
]]
--- @param options Bots_TrainOptions
function Module.Train(options)
	--[[ Checks ]]

	-- Check if no match is playing on the arena
	if I.Match.GetPhase() ~= "Waiting" and I.Match.GetPhase() ~= "Ended" then
		Module._setStatus("Stopped: a match is playing, so the arena isn't free")
		return
	end

	-- Check if the aim solver is right before trusting it
	if not Aim.IsSolverRight() then
		Module._setStatus("Stopped: the aim solver's self-check failed")
		return
	end

	--[[ Local Variables ]]

	running = true
	Brain.SetThinkSlice(_settings.GYM_THINK_SLICE)
	stopping = false
	local started: number = os.clock()
	local random: Random = Random.new(if options.Seed ~= 0 then options.Seed else os.time())
	local baseline = options.Baseline or Brains[options.Difficulty] or Brains.Hard --- @type Bots_Genome
	local start = options.Start or baseline --- @type Bots_Genome
	local maps = options.Maps or Module._getMaps() --- @type { string }
	local population = { table.clone(start) } --- @type { Bots_Genome }
	while #population < options.Population do
		table.insert(population, Module._mutate(table.clone(start), options.MutationRate * 2, options.MutationSize, random))
	end
	local history = {} --- @type { { [string]: any } }
	local champion = start --- @type Bots_Genome

	--[[ Evolving ]]

	for generation: number = 1, options.Generations do
		local stats = Module._getNewStats() --- @type Bots_Stats
		local fitness = Module._playGeneration(population, options, maps, random, generation, stats) --- @type { number }
		local order = {} --- @type { number }
		local mean: number = 0
		for index: number = 1, #population do
			table.insert(order, index)
			mean += fitness[index] / #population
		end
		table.sort(order, function(a: number, b: number): boolean
			return fitness[a] > fitness[b]
		end)
		champion = population[order[1]]
		table.insert(history, { Generation = generation, Best = fitness[order[1]], Mean = mean, Play = Module._getSummary(stats) })
		print(`[{_localName}::{script.Name}]: Generation {generation}/{options.Generations}: best {string.format("%.3f", fitness[order[1]])}, mean {string.format("%.3f", mean)}; {Module._getSummary(stats)}`)
		if stopping then
			break
		end
		if generation < options.Generations then
			population = Module._breed(population, order, options, random)
		end
	end

	--[[ Examining ]]

	local examStats = Module._getNewStats() --- @type Bots_Stats
	local exam = Module._examine(champion, baseline, options, maps, random, examStats) --- @type { [string]: number }

	--[[ Reporting ]]

	local report = {
		Difficulty = options.Difficulty,
		Minutes = (os.clock() - started) / 60,
		History = history,
		Exam = exam,
		ExamPlay = Module._getSummary(examStats),
		Champion = champion,
		Lua = Module._getLua(options.Difficulty, champion),
	}
	local holder: StringValue = I.S.ServerStorage:FindFirstChild(_settings.TRAIN_RESULT) or I.Create("StringValue")({
		Name = _settings.TRAIN_RESULT,
		Parent = I.S.ServerStorage,
	})
	holder.Value = I.S.HttpService:JSONEncode(report)
	print(
		`[{_localName}::{script.Name}]: Training done in {string.format("%.1f", report.Minutes)} min. Exam: champion {string.format("%.3f", exam.Champion)} vs shipped {string.format("%.3f", exam.Baseline)} per seat.\n{report.Lua}`
	)
	Module._setStatus(`Done: champion {string.format("%.3f", exam.Champion)} vs shipped {string.format("%.3f", exam.Baseline)} (ServerStorage.{_settings.TRAIN_RESULT})`)
	Brain.SetThinkSlice(nil)
	running = false
end

--%%%%%%%%%%%%%%%%%%%% Play Generation

--[[
	Plays a generation's matches, odd ones a free-for-all of four, even ones a 2 v 2, each seating the genomes that
	played least so far (ties at random), and returns each genome's fitness: its mean points per seat. Adds how they
	played to `stats`.
]]
--- @param population { Bots_Genome }
--- @param options Bots_TrainOptions
--- @param maps { string }
--- @param stats Bots_Stats
--- @return { number }
function Module._playGeneration(population, options, maps, random: Random, generation: number, stats)
	--[[ Local Variables ]]

	local games = {} --- @type { number }
	local points = {} --- @type { number }
	for index: number = 1, #population do
		games[index] = 0
		points[index] = 0
	end

	--[[ Playing ]]

	for match: number = 1, options.MatchesPerGeneration do
		Module._setStatus(`Generation {generation}/{options.Generations}, match {match}/{options.MatchesPerGeneration}`)
		local picks = {} --- @type { number }
		for index: number = 1, #population do
			table.insert(picks, index)
		end
		random:Shuffle(picks)
		table.sort(picks, function(a: number, b: number): boolean
			return games[a] < games[b]
		end)
		local duo: boolean = match % 2 == 0
		local genomes = {} --- @type { Bots_Genome }
		for seat: number = 1, 4 do
			genomes[seat] = population[picks[seat]]
		end
		local seatPoints = Module._playMatch(genomes, duo, options, maps, random, stats) --- @type { number }
		for seat: number = 1, 4 do
			games[picks[seat]] += 1
			points[picks[seat]] += seatPoints[seat]
		end
		if stopping then
			break
		end
	end

	--[[ Returning ]]

	local fitness = {} --- @type { number }
	for index: number = 1, #population do
		fitness[index] = if games[index] > 0 then points[index] / games[index] else -math.huge
	end
	return fitness
end

--%%%%%%%%%%%%%%%%%%%% Play Match

--[[
	Plays one headless match of four seats on a random map, a free-for-all or a 2 v 2 (seats 1 and 3 against 2 and 4),
	and returns each seat's points: its place's PLACE_POINTS (a team match's winners 1, losers 0), plus DAMAGE_POINTS
	for each point of damage it dealt enemies, less each it dealt its own side. A map that can't be played gives none.
	Adds how they played to `stats`.
]]
--- @param genomes { Bots_Genome }
--- @param options Bots_TrainOptions
--- @param maps { string }
--- @param stats Bots_Stats
--- @return { number }
function Module._playMatch(genomes, duo: boolean, options, maps, random: Random, stats)
	--[[ Local Variables ]]

	local seats = {} --- @type { Bots_Seat }
	--- @param genome Bots_Genome
	for index: number, genome in ipairs(genomes) do
		-- Each seat rolls its potion, as a live bot does (Server.CreateParticipant)
		local loadout = table.clone(_settings.LOADOUTS[options.Difficulty] or _settings.LOADOUTS.Hard) --- @type { string }
		local potion: string = _settings.POTIONS[random:NextInteger(1, #_settings.POTIONS)]
		if potion ~= "" then
			table.insert(loadout, potion)
		end
		table.insert(seats, {
			Id = `G_{index}`,
			Team = if duo then (index - 1) % 2 + 1 else index,
			Genome = genome,
			Skill = _settings.SKILLS[options.Difficulty] or _settings.SKILLS.Hard,
			Loadout = loadout,
		})
	end
	local points = { 0, 0, 0, 0 } --- @type { number }

	--[[ Playing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(Sim.Play, maps[random:NextInteger(1, #maps)], seats, options.MaxRounds, snailsFolder, random, stats, options.Log)
	if not success or not result then
		warn(`[{_localName}::{script.Name}]: A gym match failed! - ({result})`)
		--- @param seat Bots_Seat
		for _index: number, seat in ipairs(seats) do
			if seat.Model then
				seat.Model:Destroy()
			end
		end
		return points
	end

	--[[ Scoring ]]

	-- Who lasted longest places best, then who has more health left
	local order = { 1, 2, 3, 4 } --- @type { number }
	table.sort(order, function(a: number, b: number): boolean
		if seats[a].OutTurn ~= seats[b].OutTurn then
			return seats[a].OutTurn > seats[b].OutTurn
		end
		return seats[a].Health > seats[b].Health
	end)
	local winningTeam: number = seats[order[1]].Team
	for place: number, index: number in ipairs(order) do
		local seat = seats[index] --- @type Bots_Seat
		local placed: number = if duo then (if seat.Team == winningTeam then 1 else 0) else _settings.PLACE_POINTS[place]
		points[index] = placed + _settings.DAMAGE_POINTS * (seat.Dealt - seat.Friendly)
	end

	--[[ Returning ]]

	return points
end

--%%%%%%%%%%%%%%%%%%%% Examine

--[[
	Plays ExamMatches between a champion and the shipped genome, two seats each (a 2 v 2 or a free-for-all, in turn),
	and returns their mean points per seat (Champion, Baseline) and the matches played. Adds how they played to `stats`.
	Who sits first swaps every two matches: the first seat moves first, which is worth about a quarter of a point.
]]
--- @param champion Bots_Genome
--- @param baseline Bots_Genome
--- @param options Bots_TrainOptions
--- @param maps { string }
--- @param stats Bots_Stats
--- @return { [string]: number }
function Module._examine(champion, baseline, options, maps, random: Random, stats)
	--[[ Local Variables ]]

	local totals = { Champion = 0, Baseline = 0, Matches = 0 } --- @type { [string]: number }

	--[[ Playing ]]

	for match: number = 1, options.ExamMatches do
		Module._setStatus(`Exam match {match}/{options.ExamMatches}`)
		local championFirst: boolean = math.ceil(match / 2) % 2 == 1
		local genomes = if championFirst then { champion, baseline, champion, baseline } else { baseline, champion, baseline, champion } --- @type { Bots_Genome }
		local seatPoints = Module._playMatch(genomes, match % 2 == 1, options, maps, random, stats) --- @type { number }
		local firstPoints: number = (seatPoints[1] + seatPoints[3]) / 2
		local secondPoints: number = (seatPoints[2] + seatPoints[4]) / 2
		totals.Champion += if championFirst then firstPoints else secondPoints
		totals.Baseline += if championFirst then secondPoints else firstPoints
		totals.Matches += 1
	end

	--[[ Returning ]]

	totals.Champion /= math.max(totals.Matches, 1)
	totals.Baseline /= math.max(totals.Matches, 1)
	return totals
end

--%%%%%%%%%%%%%%%%%%%% Set Status

--[[
	Shows a training run's progress in the Workspace's TRAIN_STATUS_ATTRIBUTE.
]]
function Module._setStatus(text: string)
	I.S.Workspace:SetAttribute(_settings.TRAIN_STATUS_ATTRIBUTE, text)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Breed

--[[
	Returns the next generation: the Elites best as they are, then children of two parents each picked as the better of
	two at random (a tournament), every key from either parent, then mutated.
]]
--- @param population { Bots_Genome }
--- @param order { number }
--- @param options Bots_TrainOptions
--- @return { Bots_Genome }
function Module._breed(population, order, options, random: Random)
	--[[ Local Variables ]]

	local rank = {} --- @type { [number]: number }
	for place: number, index: number in ipairs(order) do
		rank[index] = place
	end
	local offspring = {} --- @type { Bots_Genome }

	--[[ Breeding ]]

	for place: number = 1, math.min(options.Elites, #order) do
		table.insert(offspring, population[order[place]])
	end
	while #offspring < #population do
		local mother = Module._pick(population, rank, random) --- @type Bots_Genome
		local father = Module._pick(population, rank, random) --- @type Bots_Genome
		local child = {} --- @type Bots_Genome
		for _index: number, key: string in ipairs(GENOME_KEYS) do
			child[key] = if random:NextNumber() < 0.5 then mother[key] else father[key]
		end
		table.insert(offspring, Module._mutate(child, options.MutationRate, options.MutationSize, random))
	end

	--[[ Returning ]]

	return offspring
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Returns a parent: the better ranked of two genomes picked at random.
]]
--- @param population { Bots_Genome }
--- @param rank { [number]: number }
--- @return Bots_Genome
function Module._pick(population, rank, random: Random)
	--[[ Local Variables ]]

	local a: number = random:NextInteger(1, #population)
	local b: number = random:NextInteger(1, #population)

	--[[ Returning ]]

	return population[if rank[a] < rank[b] then a else b]
end

--%%%%%%%%%%%%%%%%%%%% Mutate

--[[
	Returns a genome with each key, at `rate`, nudged on a bell curve: weights by `size` of their own size (at least
	0.25), HealBelow by `size` times 30 health, kept within 0 and the max health.
]]
--- @param genome Bots_Genome
--- @return Bots_Genome
function Module._mutate(genome, rate: number, size: number, random: Random)
	--[[ Mutating ]]

	for _index: number, key: string in ipairs(GENOME_KEYS) do
		if random:NextNumber() < rate then
			local bell: number = math.sqrt(-2 * math.log(1 - random:NextNumber())) * math.cos(2 * math.pi * random:NextNumber())
			if key == "HealBelow" then
				genome[key] = math.clamp(math.round(genome[key] + bell * size * 30), 0, I.Settings["Snails"].MAX_HEALTH)
			else
				genome[key] += bell * size * math.max(math.abs(genome[key]), 0.25)
			end
		end
	end

	--[[ Returning ]]

	return genome
end

--%%%%%%%%%%%%%%%%%%%% Get New Stats

--[[
	Returns empty play stats, for Sim to count a batch of matches into.
]]
--- @return Bots_Stats
function Module._getNewStats()
	--- @type Bots_Stats
	local stats = {
		Matches = 0,
		Turns = 0,
		Shots = 0,
		Hits = 0,
		Friendly = 0,
		Damage = 0,
		Knockouts = 0,
		Thrown = 0,
		Weapons = {},
		Moves = 0,
		Jetpacks = 0,
		Air = 0,
		Heals = 0,
	}
	return stats
end

--%%%%%%%%%%%%%%%%%%%% Get Summary

--[[
	Returns play stats in a line: turns per match, the share of shots that hurt an enemy and that hurt the shooter's own
	side, damage per shot, knockouts (and how many were throws into the sea or off the arena), how often bots moved
	and flew, how often they shot from the air, heals, and the weapons fired most.
]]
--- @param stats Bots_Stats
--- @return string
function Module._getSummary(stats)
	--[[ Local Variables ]]

	local shots: number = math.max(stats.Shots, 1)
	local weapons = {} --- @type { string }
	for itemId: string, count: number in pairs(stats.Weapons) do
		table.insert(weapons, `{itemId} {math.round(count / shots * 100)}%`)
	end
	table.sort(weapons)

	--[[ Returning ]]

	return string.format(
		"%.1f turns/match, hit %d%%, own side %d%%, %.1f dmg/shot, %d knockouts (%d thrown), moved %d%%, jetpack %d%%, air %d%%, %d heals; %s",
		stats.Turns / math.max(stats.Matches, 1),
		math.round(stats.Hits / shots * 100),
		math.round(stats.Friendly / shots * 100),
		stats.Damage / shots,
		stats.Knockouts,
		stats.Thrown,
		math.round(stats.Moves / shots * 100),
		math.round(stats.Jetpacks / shots * 100),
		math.round(stats.Air / shots * 100),
		stats.Heals,
		table.concat(weapons, ", ")
	)
end

--%%%%%%%%%%%%%%%%%%%% Get Maps

--[[
	Returns every map id the arena has a template for.
]]
--- @return { string }
function Module._getMaps()
	--[[ Local Variables ]]

	local maps = {} --- @type { string }

	--[[ Listing ]]

	for _index: number, template: Instance in ipairs(I.Dirs.SAssets:FindFirstChild("Arenas"):GetChildren()) do
		table.insert(maps, template.Name)
	end

	--[[ Returning ]]

	return maps
end

--%%%%%%%%%%%%%%%%%%%% Get Lua

--[[
	Returns a genome written as its difficulty's row of ServerData/Brains, to paste over it.
]]
--- @param genome Bots_Genome
--- @return string
function Module._getLua(difficulty: string, genome)
	--[[ Local Variables ]]

	local lines = { `\t{difficulty} = \{` } --- @type { string }

	--[[ Writing ]]

	for _index: number, key: string in ipairs(GENOME_KEYS) do
		local value: number = if key == "HealBelow" then math.round(genome[key]) else math.round(genome[key] * 1000) / 1000
		table.insert(lines, `\t\t{key} = {value},`)
	end
	table.insert(lines, "\t},")

	--[[ Returning ]]

	return table.concat(lines, "\n")
end

return Module
