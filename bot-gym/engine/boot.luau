--[[
	Boots the game's own server code outside Roblox: a DataModel with the services it calls, the code folder's modules
	mounted as ModuleScripts from their files (the same source Studio runs), and ume's `I` with the framework pieces
	the arena, combat and bots use. Networking, sounds and effects do nothing; everything else is the game's code.

	Boot(options) loads the map templates from a saved place (`options.Place`, a .rbxl) and starts Arsenal, Combat's
	shot simulation, the Arena and the bots' scripts, in the order the game starts them.
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")

local datatypes = require("./datatypes")
local instance = require("./instance")
local scheduler = require("./scheduler")
local world = require("./world")

local Vector3 = datatypes.Vector3
local new = instance.New

local boot = {}

-- The game's modules the gym runs, from the code folder's src/modules/Main_Game
local MODULES = { "Arena", "Arsenal", "Bots", "Combat", "Match", "SnailControl", "Snails" }

--%%%%%%%%%%%%%%%%%%%% Output

local warnings = {}
local quiet: boolean = false

local function warnOut(...)
	local parts = {}
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if type(value) ~= "table" or not rawget(value, "_isInstance") then
			table.insert(parts, tostring(value))
		end
	end
	local text = table.concat(parts, " ")
	warnings[text] = (warnings[text] or 0) + 1
	if not quiet and warnings[text] == 1 then
		print(`[warn] {text}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Services

local function makeServices(gravity: number)
	local game = instance.NewService("DataModel", {})
	rawset(game, "_isGame", true)
	game._props.Name = "Game"

	local services = {}
	local function add(name: string, service)
		service._props.Name = name
		service._props.Parent = game
		table.insert(game._children, service)
		services[name] = service
		return service
	end

	local workspaceMembers = table.clone(world.Queries)
	workspaceMembers.Gravity = gravity
	workspaceMembers.GetServerTimeNow = function()
		return scheduler.Now()
	end
	workspaceMembers.CurrentCamera = nil
	local workspace = add("Workspace", instance.NewService("Workspace", workspaceMembers))
	rawset(workspace, "_isWorkspace", true)
	world.SetWorkspace(workspace)

	add("ReplicatedStorage", instance.NewService("ReplicatedStorage", {}))
	add("ServerStorage", instance.NewService("ServerStorage", {}))
	add("ServerScriptService", instance.NewService("ServerScriptService", {}))
	add("Lighting", instance.NewService("Lighting", {}))
	add("SoundService", instance.NewService("SoundService", {}))
	add("StarterGui", instance.NewService("StarterGui", {}))
	add("RunService", instance.NewService("RunService", {
		Heartbeat = scheduler.Heartbeat,
		Stepped = scheduler.Stepped,
		RenderStepped = scheduler.RenderStepped,
		PostSimulation = scheduler.Heartbeat,
		IsStudio = function()
			return true
		end,
		IsServer = function()
			return true
		end,
		IsClient = function()
			return false
		end,
		IsRunning = function()
			return true
		end,
		IsEdit = function()
			return false
		end,
	}))
	add("HttpService", instance.NewService("HttpService", {
		JSONEncode = function(_self, value)
			return serde.encode("json", value)
		end,
		JSONDecode = function(_self, text: string)
			return serde.decode("json", text)
		end,
		GenerateGUID = function()
			return tostring(math.random(1, 2 ^ 30))
		end,
	}))
	add("PhysicsService", instance.NewService("PhysicsService", world.PhysicsService))
	add("GeometryService", instance.NewService("GeometryService", world.GeometryService))
	add("Players", instance.NewService("Players", {
		GetPlayers = function()
			return {}
		end,
		GetPlayerByUserId = function()
			return nil
		end,
		PlayerAdded = scheduler.NewSignal(),
		PlayerRemoving = scheduler.NewSignal(),
	}))
	add("TweenService", instance.NewService("TweenService", {
		Create = function()
			return {
				Play = function() end,
				Cancel = function() end,
				Pause = function() end,
				Completed = scheduler.NewSignal(),
			}
		end,
	}))
	add("CollectionService", instance.NewService("CollectionService", {
		GetTagged = function(_self, tag: string)
			local found = {}
			for _, inst in game:GetDescendants() do
				if inst._tags[tag] then
					table.insert(found, inst)
				end
			end
			return found
		end,
		HasTag = function(_self, inst, tag: string)
			return inst._tags[tag] == true
		end,
		AddTag = function(_self, inst, tag: string)
			inst._tags[tag] = true
		end,
		RemoveTag = function(_self, inst, tag: string)
			inst._tags[tag] = nil
		end,
		GetInstanceAddedSignal = function()
			return scheduler.NewSignal()
		end,
		GetInstanceRemovedSignal = function()
			return scheduler.NewSignal()
		end,
	}))
	add("Debris", instance.NewService("Debris", {
		AddItem = function(_self, item, seconds: number?)
			scheduler.task.delay(seconds or 10, function()
				item:Destroy()
			end)
		end,
	}))

	game._class.Methods.GetService = function(_self, name: string)
		local service = services[name]
		if not service then
			service = add(name, instance.NewService(name, {}))
		end
		return service
	end
	game._class.Methods.FindService = function(_self, name: string)
		return services[name]
	end
	return game, services
end

--%%%%%%%%%%%%%%%%%%%% Modules

-- Mounts a folder of the code as Rojo would: folders, ModuleScripts from .lua files, init.lua as its folder's script
local function mount(path: string, name: string, parent)
	local initPath = nil
	for _, candidate in { "init.lua", "init.luau" } do
		if fs.isFile(`{path}/{candidate}`) then
			initPath = `{path}/{candidate}`
		end
	end
	local folder = new(if initPath then "ModuleScript" else "Folder")
	folder._props.Name = name
	if initPath then
		rawset(folder, "_source", initPath)
		rawset(folder, "_text", fs.readFile(initPath))
	end
	folder.Parent = parent
	for _, entry in fs.readDir(path) do
		local full = `{path}/{entry}`
		if entry == "_meta" or entry == "init.lua" or entry == "init.luau" then
			continue
		end
		if fs.isDir(full) then
			mount(full, entry, folder)
		elseif (entry:match("%.lua$") or entry:match("%.luau$")) and not entry:match("%.server%.") and not entry:match("%.client%.") then
			local script = new("ModuleScript")
			script._props.Name = entry:gsub("%.luau?$", "")
			rawset(script, "_source", full)
			rawset(script, "_text", fs.readFile(full))
			script.Parent = folder
		end
	end
	return folder
end

--%%%%%%%%%%%%%%%%%%%% Maps

local function convertValue(value: any)
	-- Lune's Roblox values to the gym's
	local kind = typeof(value)
	if kind == "Vector3" then
		return Vector3.new(value.X, value.Y, value.Z)
	elseif kind == "CFrame" then
		return datatypes.cf(value:GetComponents())
	elseif kind == "Color3" then
		return datatypes.Color3.new(value.R, value.G, value.B)
	elseif kind == "EnumItem" then
		return datatypes.Enum[tostring(value.EnumType)][value.Name]
	end
	return value
end

local function convertInstance(source, parent)
	local className = source.ClassName
	if source:IsA("BasePart") and className ~= "Part" and className ~= "UnionOperation" then
		className = "Part"
	end
	local inst = new(if instance.Classes[className] then className else "Folder")
	inst._props.Name = source.Name
	if source:IsA("BasePart") then
		local props = inst._props
		props.CFrame = convertValue(source.CFrame)
		props.Size = convertValue(source.Size)
		props.Anchored = source.Anchored
		props.CanCollide = source.CanCollide
		props.CanQuery = source.CanQuery
		props.CanTouch = source.CanTouch
		props.CollisionGroup = source.CollisionGroup
		props.Transparency = source.Transparency
		props.Color = convertValue(source.Color)
		if source:IsA("Part") then
			props.Shape = convertValue(source.Shape)
		end
	end
	for key, value in source:GetAttributes() do
		inst._attributes[key] = convertValue(value)
	end
	for _, tag in source:GetTags() do
		inst._tags[tag] = true
	end
	for _, child in source:GetChildren() do
		if child:IsA("BasePart") or child:IsA("Folder") or child:IsA("Model") then
			convertInstance(child, inst)
		end
	end
	if className == "Model" and source.PrimaryPart then
		inst._props.PrimaryPart = inst:FindFirstChild(source.PrimaryPart.Name, true) or instance.NIL
	end
	inst._props.Parent = parent
	table.insert(parent._children, inst)
	return inst
end

--[[
	Reads a saved place: Workspace's gravity, and the map templates in Workspace.Ume.ServerStorage_Assets.Arenas
	(their Terrain and Markers; the Decor is only looks, which no query sees).
]]
local function readPlace(path: string)
	local roblox = require("@lune/roblox")
	local place = roblox.deserializePlace(fs.readFile(path))
	local workspace = place:GetService("Workspace")
	local arenas = workspace:FindFirstChild("Ume") and workspace.Ume:FindFirstChild("ServerStorage_Assets") and workspace.Ume.ServerStorage_Assets:FindFirstChild("Arenas")
	assert(arenas, `{path} has no Workspace.Ume.ServerStorage_Assets.Arenas`)
	local holder = new("Folder")
	holder._props.Name = "Arenas"
	for _, template in arenas:GetChildren() do
		local map = new("Model")
		map._props.Name = template.Name
		for key, value in template:GetAttributes() do
			map._attributes[key] = convertValue(value)
		end
		for _, name in { "Terrain", "Markers" } do
			local folder = template:FindFirstChild(name)
			if folder then
				convertInstance(folder, map)
			end
		end
		map._props.Parent = holder
		table.insert(holder._children, map)
	end
	return workspace.Gravity, holder
end

--%%%%%%%%%%%%%%%%%%%% Boot

--[[
	Boots the game: returns `I`, the DataModel and a `Require` for any of the mounted modules by path
	("Bots/Scripts/Server/Sim").
]]
function boot.Boot(options)
	quiet = options.Quiet == true
	local gravity, arenas = readPlace(options.Place)
	local game, services = makeServices(gravity)

	--[[ Folders ]]

	local function folder(name: string, parent)
		local made = new("Folder")
		made._props.Name = name
		made.Parent = parent
		return made
	end
	local ume = folder("Ume", services.Workspace)
	local sAssets = folder("SAssets", services.ServerStorage)
	arenas.Parent = sAssets
	local assets = folder("Assets", services.ReplicatedStorage)
	local root = folder("Instance", services.ServerScriptService)
	local modulesFolder = folder("Modules", root)
	local mainGame = folder("Main_Game", modulesFolder)
	for _, name in MODULES do
		mount(`{options.Source}/modules/Main_Game/{name}`, name, mainGame)
	end

	--[[ Requiring ]]

	local I = {}
	local cache = {}
	local loading = {}
	local baseEnv = {}
	local function requireModule(target)
		if type(target) ~= "table" or not rawget(target, "_isInstance") then
			error(`require of a non-ModuleScript ({tostring(target)})`, 2)
		end
		if rawget(target, "_value") ~= nil then
			return rawget(target, "_value")
		end
		local cached = cache[target]
		if cached ~= nil then
			return cached
		end
		local path = rawget(target, "_source")
		assert(path, `{target:GetFullName()} has no source`)
		assert(not loading[target], `require cycle at {target:GetFullName()}`)
		loading[target] = true
		local env = setmetatable({ script = target }, { __index = baseEnv })
		local chunk = luau.load(rawget(target, "_text"), {
			debugName = path:match("src/(.*)$") or path,
			environment = env,
			injectGlobals = false,
			codegenEnabled = options.Codegen ~= false,
		})
		local value = chunk()
		loading[target] = nil
		cache[target] = value
		return value
	end

	-- The Ume pointer: ReplicatedStorage.UmePointer.Value is a module that returns I
	local pointerModule = new("ModuleScript")
	rawset(pointerModule, "_value", I)
	local pointer = new("ObjectValue")
	pointer._props.Name = "UmePointer"
	pointer._props.Value = pointerModule
	pointer.Parent = services.ReplicatedStorage

	--[[ Globals ]]

	local fakeOs = table.clone(os)
	fakeOs.clock = scheduler.Now
	for key, value in
		{
			game = game,
			Game = game,
			workspace = services.Workspace,
			Workspace = services.Workspace,
			require = requireModule,
			task = scheduler.task,
			wait = scheduler.task.wait,
			delay = scheduler.task.delay,
			spawn = scheduler.task.spawn,
			tick = scheduler.Now,
			time = scheduler.Now,
			elapsedTime = scheduler.Now,
			os = fakeOs,
			warn = warnOut,
			print = if quiet then function() end else print,
			typeof = datatypes.typeof,
			Instance = {
				new = function(className: string, parent)
					local made = new(className)
					if parent then
						made.Parent = parent
					end
					return made
				end,
			},
			RaycastParams = world.RaycastParams,
			OverlapParams = world.OverlapParams,
			Vector3 = datatypes.Vector3,
			CFrame = datatypes.CFrame,
			Random = datatypes.Random,
			Enum = datatypes.Enum,
			NumberRange = datatypes.NumberRange,
			math = math,
			string = string,
			table = table,
			buffer = buffer,
			bit32 = bit32,
			coroutine = coroutine,
			utf8 = utf8,
			debug = debug,
			vector = vector,
			assert = assert,
			error = error,
			pcall = pcall,
			xpcall = xpcall,
			type = type,
			ipairs = ipairs,
			pairs = pairs,
			next = next,
			select = select,
			tostring = tostring,
			tonumber = tonumber,
			setmetatable = setmetatable,
			getmetatable = getmetatable,
			rawget = rawget,
			rawset = rawset,
			rawequal = rawequal,
			rawlen = rawlen,
			unpack = table.unpack,
			newproxy = newproxy,
			gcinfo = gcinfo,
			_G = {},
			shared = {},
		}
	do
		baseEnv[key] = value
	end
	for name, value in datatypes do
		if type(value) == "table" and rawget(value, "new") and baseEnv[name] == nil then
			baseEnv[name] = value
		end
	end

	--[[ I ]]

	local noop = function() end
	local stub = setmetatable({}, {
		__index = function()
			return noop
		end,
	})
	local settingsCache = {}
	I.S = setmetatable({}, {
		__index = function(_self, name: string)
			return game:GetService(name)
		end,
	})
	I.Dirs = {
		UmeWorkspace = ume,
		SAssets = sAssets,
		Assets = assets,
		UmeReplicated = services.ReplicatedStorage,
	}
	I.Settings = setmetatable({}, {
		__index = function(_self, name: string)
			if settingsCache[name] == nil then
				local module = mainGame:FindFirstChild(name)
				assert(module and module:FindFirstChild("Settings"), `no Settings for {name}`)
				settingsCache[name] = requireModule(module:FindFirstChild("Settings"))
			end
			return settingsCache[name]
		end,
	})
	I.Create = setmetatable({}, {
		__call = function(_self, className: string)
			return function(properties)
				local made = new(className)
				local parent = nil
				for key, value in properties or {} do
					if key == "Parent" then
						parent = value
					else
						made[key] = value
					end
				end
				if parent then
					made.Parent = parent
				end
				return made
			end
		end,
	})
	I.Env = { IsServer = true, IsClient = false, IsStudio = true }
	I.Network = stub
	I.Topic = stub
	I.Vfx = stub
	I.Sound = stub
	I.Replicator = stub
	I.DoEvery = stub
	I.Priority = setmetatable({}, {
		__index = function()
			return 0
		end,
	})
	I.Match = {
		GetPhase = function()
			return "Waiting"
		end,
		GetWind = function()
			return 0
		end,
	}
	I.Snails = {
		IsGrounded = function()
			return true
		end,
	}

	--[[ Starting ]]

	local function req(path: string)
		local current = mainGame
		for name in path:gmatch("[^/]+") do
			current = current:FindFirstChild(name)
			assert(current, `no module at {path}`)
		end
		return requireModule(current)
	end

	-- The game's start order: Arsenal and Combat's Global, then the servers that use them
	req("Arsenal/Global")._init()
	req("Combat/Global")._init()
	req("Arena/Server")._init()
	local projectiles = req("Combat/Scripts/Server/Projectiles")
	projectiles.Init()
	local arcs = req("Combat/Scripts/Server/Arcs")
	I.Combat = {
		GetArcs = arcs.GetArcs,
		PredictArc = arcs.PredictArc,
		GetShotStart = projectiles.GetStart,
		GetCrawlStep = projectiles.GetCrawlStep,
	}
	for _, name in { "Aim", "Brain", "Move", "Predict", "Gym" } do
		local script = req(`Bots/Scripts/Server/{name}`)
		if script.Init then
			script.Init()
		end
	end

	-- Anything else the code asks I for is a gap in the gym: say so loudly
	setmetatable(I, {
		__index = function(_self, key)
			error(`[gym] I.{key} isn't provided by the gym`, 2)
		end,
	})

	return {
		I = I,
		Game = game,
		Require = req,
		Warnings = warnings,
	}
end

return boot
