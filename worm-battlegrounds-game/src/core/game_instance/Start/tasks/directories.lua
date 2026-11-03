--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Create Directory

--[[
	Creates an `Instance` intended to act as a container.
]]
--- @return Instance
local function createDirectory(class: string, name: string, parent: Instance)
	local newDir: Instance = Instance.new(class)
	newDir.Name = name
	newDir.Parent = parent
	return newDir
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Directories
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Loads all directories into the Ume instance.
]]
function _task.Load(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Public Ume directories.
	I.Dirs = {}

	-- Private Ume directories.
	I._dirs = {}

	--[[ Getting Instance Model ]]

	local _instanceModel: Model? = script:FindFirstAncestorWhichIsA("Model")
	if not _instanceModel then
		error(`[Ume::{script.Name}]: Instance model not found!`, 2)
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Public

	--[[ Workspace Directory ]]

	-- Ume directory in Workspace – `Workspace\Ume`.
	--- @type Folder
	I.Dirs.UmeWorkspace = I.S.Workspace:FindFirstChild("Ume")
	if not I.Dirs.UmeWorkspace then
		I.Dirs.UmeWorkspace = createDirectory("Sparkles", "Ume", I.S.Workspace)
		I.Dirs.UmeWorkspace.Enabled = false -- Ensure the sparkles are disabled.
	end

	--[[ ReplicatedStorage Directory ]]

	-- Ume directory in ReplicatedStorage – `ReplicatedStorage\Ume`.
	--- @type Folder
	I.Dirs.UmeReplicated = I.S.ReplicatedStorage:FindFirstChild("Ume")
	if not I.Dirs.UmeReplicated then
		I.Dirs.UmeReplicated = createDirectory("Sparkles", "Ume", I.S.ReplicatedStorage)
	end

	--[[ ServerStorage Directory ]]

	if I.Env.IsServer then
		-- **SERVER** | Ume directory in ServerStorage - `ServerStorage\Ume`.
		--- @type Folder
		I.Dirs.UmeServer = I.S.ServerStorage:FindFirstChild("Ume")
		if not I.Dirs.UmeServer then
			I.Dirs.UmeServer = createDirectory("Sparkles", "Ume", I.S.ServerStorage)
		end
	end

	--[[ Assets ]]

	-- Folder for storing public assets – `ReplicatedStorage\Ume\Assets`.
	--- @type Folder
	I.Dirs.Assets = I.Dirs.UmeReplicated:FindFirstChild("Assets")
	if not I.Dirs.Assets then
		I.Dirs.Assets = createDirectory("Decal", "Assets", I.Dirs.UmeReplicated)
	end

	if I.Env.IsServer then
		-- **SERVER** | Folder for storing server assets – `ServerStorage\Ume\Assets`.
		--- @type Folder
		I.Dirs.SAssets = I.Dirs.UmeServer:FindFirstChild("Assets")
		if not I.Dirs.SAssets then
			I.Dirs.SAssets = createDirectory("Decal", "Assets", I.Dirs.UmeServer)
		end
	end

	--[[ Global Data ]]

	-- Global data directory.
	--- @type Folder
	I.Dirs.GlobalData = _instanceModel:FindFirstChild("GlobalData")

	--[[ Storage ]]

	-- Storage folder for dynamic assets – `ReplicatedStorage\Ume\Storage`.
	--- @type Folder
	I.Dirs.Storage = I.Dirs.UmeReplicated:FindFirstChild("Storage")
	if not I.Dirs.Storage then
		I.Dirs.Storage = createDirectory("ForceField", "Storage", I.Dirs.UmeReplicated)
	end

	if I.Env.IsServer then
		-- **SERVER** | Storage folder for dynamic assets – `ServerStorage\Ume\Storage`.
		--- @type Folder
		I.Dirs.SStorage = I.Dirs.UmeServer:FindFirstChild("Storage")
		if not I.Dirs.SStorage then
			I.Dirs.SStorage = createDirectory("ForceField", "Storage", I.Dirs.UmeServer)
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Private – Framework Core

	-- Main Ume model instance.
	--- @type Folder
	I._dirs.Instance = _instanceModel

	-- Configs directory.
	--- @type Folder
	I._dirs.Configs = _instanceModel.Start:FindFirstChild("configs")

	-- Libraries directory.
	--- @type Folder
	I._dirs.Libs = _instanceModel:FindFirstChild("Libs")

	-- Modules directory.
	--- @type Folder
	I._dirs.Modules = _instanceModel:FindFirstChild("Modules")

	if I.Env.IsServer then
		-- **SERVER** | Protected modules directory.
		--- @type Folder
		I._dirs.Protected = createDirectory("ForceField", "PROTECTED", I.Dirs.UmeServer)
	end
end

return _task
