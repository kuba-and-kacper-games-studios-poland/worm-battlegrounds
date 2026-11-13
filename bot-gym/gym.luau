--[[
	The PC bot gym: the game's own bot, combat and arena code run outside Roblox (engine/), as fast as the PC thinks and
	on every core at once. Run from this folder:

		lune run gym train --difficulty Hard [--generations 8] [--population 16] [--matches 48] [--exam 24] [--seed 11]
		lune run gym match --map PicnicPlains [--difficulty Hard] [--seed 5] [--log]
		lune run gym parity [--maps PicnicPlains,Desert] [--out runs/parity-pc.txt]
		lune run gym hashes runs/parity-pc.txt          (the block hashes parity.luau's Studio snippet prints too)
		lune run gym block runs/parity-pc.txt <map|kind> <n>

	Every command takes --place <saved place .rbxl> (or `Place` in gym.local.json) for the maps, and --workers <n>
	(train: how many matches play at once, default the cores less two). README.md says how it's used.
]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local boot = require("./engine/boot")
local datatypes = require("./engine/datatypes")
local scheduler = require("./engine/scheduler")

local SOURCE: string = "../worm-battlegrounds-game/src"
local WORK: string = "runs/.work"

--%%%%%%%%%%%%%%%%%%%% Options

local function parseArgs(args)
	local options = { _ = {} }
	local index = 1
	while index <= #args do
		local arg = args[index]
		local key = arg:match("^%-%-(.+)$")
		if key then
			local value = args[index + 1]
			if value == nil or value:match("^%-%-") then
				options[key] = true
				index += 1
			else
				options[key] = value
				index += 2
			end
		else
			table.insert(options._, arg)
			index += 1
		end
	end
	return options
end

local args = parseArgs(process.args)
local command = args._[1]

local function getPlace(): string
	if args.place then
		return args.place
	end
	if fs.isFile("gym.local.json") then
		local config = serde.decode("json", fs.readFile("gym.local.json"))
		if config.Place then
			return config.Place
		end
	end
	error("No place: pass --place <saved place .rbxl> or set Place in gym.local.json (README.md)")
end

local function list(value: any): { string }?
	if type(value) ~= "string" then
		return nil
	end
	local items = {}
	for item in value:gmatch("[^,]+") do
		table.insert(items, item)
	end
	return items
end

local function startGame(quiet: boolean)
	return boot.Boot({ Place = getPlace(), Source = SOURCE, Quiet = quiet })
end

--[[
	Seconds of game time each gym turn takes beyond its own waits, so the liquid flows about as far between turns as
	in a Studio run, where the brain's thinking takes real time. Measured with `compare` (README).
]]
local function padTurns(gym, seconds: number)
	if seconds <= 0 then
		return
	end
	local Sim = gym.Require("Bots/Scripts/Server/Sim")
	local playTurn = Sim._playTurn
	Sim._playTurn = function(...)
		playTurn(...)
		scheduler.task.wait(seconds)
	end
end

local TURN_SECONDS: number = tonumber(args["turn-seconds"]) or 0

--%%%%%%%%%%%%%%%%%%%% Match jobs (worker side)

--[[
	Plays a list of matches, as Gym._playMatch does in Studio: each job is { Genomes, Duo, Map, Seed, Difficulty,
	MaxRounds, Log }. Returns each job's seat points and the play stats of all of them.
]]
local function playJobs(gym, jobs)
	local Gym = gym.Require("Bots/Scripts/Server/Gym")
	local Brain = gym.Require("Bots/Scripts/Server/Brain")
	local settings = gym.Require("Bots/ServerSettings")
	padTurns(gym, TURN_SECONDS)
	return scheduler.Run(function()
		Brain.SetThinkSlice(settings.GYM_THINK_SLICE)
		local stats = Gym._getNewStats()
		local points = {}
		for index, job in jobs do
			local options = table.clone(settings.TRAIN_DEFAULTS)
			options.Difficulty = job.Difficulty
			options.MaxRounds = job.MaxRounds or options.MaxRounds
			options.Log = job.Log == true
			points[index] = Gym._playMatch(job.Genomes, job.Duo, options, { job.Map }, datatypes.Random.new(job.Seed), stats)
			scheduler.Reset()
		end
		return { Points = points, Stats = stats }
	end)
end

--%%%%%%%%%%%%%%%%%%%% Workers (master side)

local function addStats(into, from)
	for key, value in from do
		if key == "Weapons" then
			for itemId, count in value do
				into.Weapons[itemId] = (into.Weapons[itemId] or 0) + count
			end
		else
			into[key] += value
		end
	end
end

--[[
	Plays jobs on `workers` processes at once (each `lune run gym worker` with a batch), and returns each job's seat
	points and their summed stats.
]]
local function runJobs(Gym, jobs, workers: number)
	if not fs.isDir(WORK) then
		fs.writeDir(WORK)
	end
	local batches = {}
	for index, job in jobs do
		local slot = (index - 1) % workers + 1
		batches[slot] = batches[slot] or { Indexes = {}, Jobs = {} }
		table.insert(batches[slot].Indexes, index)
		table.insert(batches[slot].Jobs, job)
	end
	local points = {}
	local stats = Gym._getNewStats()
	local running = 0
	local failures = {}
	local stamp = `{os.time()}_{math.random(1, 1e6)}`
	for slot, batch in batches do
		running += 1
		task.spawn(function()
			local input = `{WORK}/{stamp}_{slot}_in.json`
			local output = `{WORK}/{stamp}_{slot}_out.json`
			fs.writeFile(input, serde.encode("json", batch.Jobs))
			local extra = { "run", "gym", "worker", input, output, "--turn-seconds", tostring(TURN_SECONDS) }
			if args.place then
				table.insert(extra, "--place")
				table.insert(extra, args.place)
			end
			local result = process.exec("lune", extra, { cwd = process.cwd })
			if result.ok and fs.isFile(output) then
				local done = serde.decode("json", fs.readFile(output))
				for i, index in batch.Indexes do
					points[index] = done.Points[i]
				end
				addStats(stats, done.Stats)
				fs.removeFile(output)
			else
				table.insert(failures, result.stderr .. result.stdout)
				for _, index in batch.Indexes do
					points[index] = { 0, 0, 0, 0 }
				end
			end
			fs.removeFile(input)
			running -= 1
		end)
	end
	while running > 0 do
		task.wait(0.05)
	end
	if #failures > 0 then
		print(`[gym] {#failures} worker(s) failed:\n{failures[1]}`)
	end
	return points, stats
end

local function workerCount(): number
	if args.workers then
		return tonumber(args.workers)
	end
	local cores = tonumber(process.env.NUMBER_OF_PROCESSORS or "") or 8
	return math.max(cores - 2, 1)
end

--%%%%%%%%%%%%%%%%%%%% Train

--[[
	A training run as Gym.Train does in Studio (same population, breeding, mutation, scoring and exam, the game's own
	functions), with each generation's matches planned up front and played on every worker at once.
]]
local function train()
	local gym = startGame(true)
	local Gym = gym.Require("Bots/Scripts/Server/Gym")
	local Brains = gym.Require("Bots/ServerData/Brains")
	local settings = gym.Require("Bots/ServerSettings")

	local options = table.clone(settings.TRAIN_DEFAULTS)
	options.Difficulty = args.difficulty or options.Difficulty
	options.Generations = tonumber(args.generations) or 8
	options.Population = tonumber(args.population) or 16
	options.MatchesPerGeneration = tonumber(args.matches) or options.Population * 3
	options.ExamMatches = tonumber(args.exam) or 24
	options.Seed = tonumber(args.seed) or os.time()
	options.MaxRounds = tonumber(args["max-rounds"]) or options.MaxRounds
	if args.start then
		options.Start = serde.decode("json", fs.readFile(args.start))
	end
	if args.baseline then
		options.Baseline = serde.decode("json", fs.readFile(args.baseline))
	end
	local workers = workerCount()
	local maps = list(args.maps) or Gym._getMaps()
	local random = datatypes.Random.new(options.Seed)
	local started = os.clock()

	local baseline = options.Baseline or Brains[options.Difficulty] or Brains.Hard
	local start = options.Start or baseline
	local population = { table.clone(start) }
	while #population < options.Population do
		table.insert(population, Gym._mutate(table.clone(start), options.MutationRate * 2, options.MutationSize, random))
	end

	local function job(genomes, duo: boolean)
		return {
			Genomes = genomes,
			Duo = duo,
			Map = maps[random:NextInteger(1, #maps)],
			Seed = random:NextInteger(1, 2 ^ 30),
			Difficulty = options.Difficulty,
			MaxRounds = options.MaxRounds,
		}
	end

	print(`[gym] Training {options.Difficulty}: {options.Generations} generations of {options.Population}, {options.MatchesPerGeneration} matches each, {options.ExamMatches} exam matches, seed {options.Seed}, {workers} workers, maps {table.concat(maps, ", ")}`)
	local history = {}
	local champion = start
	for generation = 1, options.Generations do
		-- The generation's seating, as Gym._playGeneration picks it: those who played least, ties at random
		local games = {}
		for index = 1, #population do
			games[index] = 0
		end
		local jobs = {}
		local seating = {}
		for match = 1, options.MatchesPerGeneration do
			local picks = {}
			for index = 1, #population do
				table.insert(picks, index)
			end
			random:Shuffle(picks)
			table.sort(picks, function(a, b)
				return games[a] < games[b]
			end)
			local genomes = {}
			for seat = 1, 4 do
				genomes[seat] = population[picks[seat]]
				games[picks[seat]] += 1
			end
			table.insert(seating, { picks[1], picks[2], picks[3], picks[4] })
			table.insert(jobs, job(genomes, match % 2 == 0))
		end
		local points, stats = runJobs(Gym, jobs, workers)
		local totals, counts = {}, {}
		for index = 1, #population do
			totals[index], counts[index] = 0, 0
		end
		for match, seats in seating do
			for seat = 1, 4 do
				totals[seats[seat]] += points[match][seat]
				counts[seats[seat]] += 1
			end
		end
		local fitness, order, mean = {}, {}, 0
		for index = 1, #population do
			fitness[index] = if counts[index] > 0 then totals[index] / counts[index] else -math.huge
			mean += fitness[index] / #population
			table.insert(order, index)
		end
		table.sort(order, function(a, b)
			return fitness[a] > fitness[b]
		end)
		champion = population[order[1]]
		table.insert(history, { Generation = generation, Best = fitness[order[1]], Mean = mean, Play = Gym._getSummary(stats) })
		print(string.format("[gym] Generation %d/%d (%.0fs): best %.3f, mean %.3f; %s", generation, options.Generations, os.clock() - started, fitness[order[1]], mean, Gym._getSummary(stats)))
		if generation < options.Generations then
			population = Gym._breed(population, order, options, random)
		end
	end

	-- The exam: champion against the baseline, two seats each, team and free-for-all in turn, who sits first
	-- swapping every two matches (Gym._examine)
	local jobs = {}
	local championFirst = {}
	for match = 1, options.ExamMatches do
		championFirst[match] = math.ceil(match / 2) % 2 == 1
		local genomes = if championFirst[match] then { champion, baseline, champion, baseline } else { baseline, champion, baseline, champion }
		table.insert(jobs, job(genomes, match % 2 == 1))
	end
	local points, examStats = runJobs(Gym, jobs, workers)
	local exam = { Champion = 0, Baseline = 0, Matches = #jobs }
	for match, seatPoints in points do
		local first = (seatPoints[1] + seatPoints[3]) / 2 / #jobs
		local second = (seatPoints[2] + seatPoints[4]) / 2 / #jobs
		exam.Champion += if championFirst[match] then first else second
		exam.Baseline += if championFirst[match] then second else first
	end

	local report = {
		Difficulty = options.Difficulty,
		Seed = options.Seed,
		Minutes = (os.clock() - started) / 60,
		History = history,
		Exam = exam,
		ExamPlay = Gym._getSummary(examStats),
		Champion = champion,
		Lua = Gym._getLua(options.Difficulty, champion),
	}
	if not fs.isDir("runs") then
		fs.writeDir("runs")
	end
	local path = `runs/{options.Difficulty}-{options.Seed}.json`
	fs.writeFile(path, serde.encode("json", report, true))
	fs.writeFile(`runs/{options.Difficulty}-{options.Seed}-champion.json`, serde.encode("json", champion, true))
	print(string.format("[gym] Done in %.1f min. Exam over %d matches: champion %.3f vs baseline %.3f per seat; %s", report.Minutes, #jobs, exam.Champion, exam.Baseline, report.ExamPlay))
	print(report.Lua)
	print(`[gym] Report: {path}`)
end

--%%%%%%%%%%%%%%%%%%%% Commands

if command == "worker" then
	local gym = startGame(true)
	local jobs = serde.decode("json", fs.readFile(args._[2]))
	local done = playJobs(gym, jobs)
	fs.writeFile(args._[3], serde.encode("json", done))
elseif command == "match" then
	local gym = startGame(false)
	local Brains = gym.Require("Bots/ServerData/Brains")
	local Gym = gym.Require("Bots/Scripts/Server/Gym")
	local difficulty = args.difficulty or "Hard"
	local genome = Brains[difficulty]
	local started = os.clock()
	local done = playJobs(gym, {
		{
			Genomes = { genome, genome, genome, genome },
			Duo = args.duo == true,
			Map = args.map or "PicnicPlains",
			Seed = tonumber(args.seed) or os.time(),
			Difficulty = difficulty,
			Log = args.log == true,
		},
	})
	print(`[gym] points {table.concat(done.Points[1], ", ")} in {string.format("%.2f", os.clock() - started)} s; {Gym._getSummary(done.Stats)}`)
elseif command == "parity" then
	local gym = startGame(true)
	local Parity = gym.Require("Bots/Scripts/Server/Parity")
	local Gym = gym.Require("Bots/Scripts/Server/Gym")
	padTurns(gym, 0)
	local lines = scheduler.Run(function()
		return Parity.Run(list(args.maps) or Gym._getMaps(), gym.I.Dirs.UmeWorkspace.Bots.Snails)
	end)
	local out = args.out or "runs/parity-pc.txt"
	if not fs.isDir("runs") then
		fs.writeDir("runs")
	end
	fs.writeFile(out, table.concat(lines, "\n"))
	print(`[gym] Parity report: {out} ({#lines} lines)`)
elseif command == "hashes" then
	local parity = require("./parity")
	print(parity.GetBlockHashes(fs.readFile(args._[2]), tonumber(args.block) or 25))
elseif command == "block" then
	local parity = require("./parity")
	print(parity.GetBlock(fs.readFile(args._[2]), args._[3], tonumber(args._[4]), tonumber(args.block) or 25))
elseif command == "train" then
	train()
else
	print("Commands: train, match, parity, hashes, block (see the top of gym.luau and README.md)")
end
