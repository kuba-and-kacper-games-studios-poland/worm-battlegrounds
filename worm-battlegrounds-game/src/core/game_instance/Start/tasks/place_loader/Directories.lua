--[[
    Created By:     Nari
]]

local _localName = "place_loader"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Returns directory duplicate checks and map folder merging for the shared place loader task.
]]
--- @param _task Ume_Task_Place_Loader
--- @return Ume_Task_Place_Loader_Directories
return function(_task)
	--- @class Ume_Task_Place_Loader_Directories
	local Directories = {}

	--%%%%%%%%%%%%%%%%%%%% Find Duplicates

	--[[
		 **SERVER** |
		 Finds if there are any duplicated directories.
	]]
	function Directories.FindDuplicated(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[
			Finds directory duplicates.
		]]
		local function findDuplicates(dirName: string, dirs: { Folder })
			-- May occur if folders don't exist
			if #dirs == 0 then
				return
			end

			-- List of all found elem names
			local elemTracker: { string } = {}

			for _, dir: Folder in ipairs(dirs) do
				for _, elem: Folder in ipairs(dir:GetChildren()) do
					-- Duplicated
					if table.find(elemTracker, elem.Name) then
						error(`[Ume::{_localName}]: Map folder ({elem.Name}) is duplicated for directory ({dirName})!`)
					end

					-- Saving
					table.insert(elemTracker, elem.Name)
				end
			end
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ General ]]

		findDuplicates("StarterGui", { I.S.StarterGui:FindFirstChild("PlaceLoader") })
		findDuplicates("StarterPack", { I.S.StarterPack:FindFirstChild("PlaceLoader") })
		findDuplicates("StarterPlayer", { I.S.StarterPlayer:FindFirstChild("PlaceLoader") })

		--[[ Ume Dirs ]]

		local workspaceDirs = {}
		table.insert(workspaceDirs, I.Dirs.UmeWorkspace:FindFirstChild("PlaceLoader"))
		table.insert(workspaceDirs, I.Dirs.UmeServer:FindFirstChild("PlaceLoader_Workspace"))
		findDuplicates("Workspace", workspaceDirs)
		findDuplicates("ReplicatedStorage_Ume", { I.Dirs.UmeReplicated:FindFirstChild("PlaceLoader") })
		findDuplicates("ServerStorage_Ume", { I.Dirs.UmeServer:FindFirstChild("PlaceLoader") })

		--[[ Assets ]]

		findDuplicates("Assets", { I.Dirs.Assets:FindFirstChild("PlaceLoader") })
		findDuplicates("SAssets", { I.Dirs.SAssets:FindFirstChild("PlaceLoader") })
	end

	--%%%%%%%%%%%%%%%%%%%% Move Workspace Map

	--[[
		**SERVER** |
		Moves all `Workspace` maps to one directory in the `ServerStorage`.
	]]
	function Directories.MoveWorkspaceMap(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Workspace Folder ]]

		local workspaceFolder: Folder = I.Dirs.UmeWorkspace:FindFirstChild("PlaceLoader")
		if not workspaceFolder then
			return -- Folder is missing -> place loader is disabled
		end

		--[[ ServerStorage Folder ]]

		-- Getting existing or creating new storage folder
		local storageFolder: Folder = I.Dirs.UmeServer:FindFirstChild("PlaceLoader_Workspace")
		if not storageFolder then
			storageFolder = Instance.new("Folder")
			storageFolder.Name = "PlaceLoader_Workspace"
			storageFolder.Parent = I.Dirs.UmeServer
		end

		--[[ Moving to ServerStorage ]]

		-- Moving
		for _, elem in ipairs(workspaceFolder:GetChildren()) do
			elem.Parent = storageFolder
		end

		-- Removing empty folder
		workspaceFolder:Destroy()
	end

	--%%%%%%%%%%%%%%%%%%%% Update Directories

	--[[
		**SERVER** |
		Updates all directories to match the current place/map.
	]]
	function Directories.UpdateDirectories(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[
			Moves elements under folders in a recursive pattern.
		]]
		local function moveFromTo(params: table)
			--[[ Params ]]

			local dirName: string = params.DirName
			local mapName: string = params.MapName

			local newElem: Folder = params.NewElem
			local existingElem: Folder = params.ExistingElem
			local goalLocation: Folder = params.GoalLocation

			local path: string = params.Path

			--[[ Moving Children ]]

			-- Move all children if both elems are folders
			if newElem:IsA("Folder") and existingElem:IsA("Folder") then
				for _, elem: Instance in ipairs(newElem:GetChildren()) do
					local _existingElem: Instance = existingElem:FindFirstChild(elem.Name)

					--[[ Existing -> Moving all children ]]

					if _existingElem then
						moveFromTo({
							DirName = dirName,
							MapName = mapName,

							NewElem = elem,
							ExistingElem = _existingElem,
							GoalLocation = _existingElem,

							Path = `{path}||{elem.Name}`,
						})
					end

					--[[ New -> Moving ]]

					if not _existingElem then
						elem.Parent = goalLocation
					end
				end

				return
			end

			-- Duplicate warning
			warn(`[Ume::{_localName}]: Instance ({path}) is duplicated!`)
		end

		--[[
			Updates given directory to match the current map config.
		]]
		local function matchDir(params: {
			DirName: string,
			Location: Instance,

			ContainerName: string?,
			GoalLocation: Instance?,
		})
			--[[ Params ]]

			local dirName: string = params.DirName
			local location: Folder | Instance = params.Location
			local goalLocation: Folder | Instance = params.GoalLocation or params.Location
			local containerName: string = params.ContainerName or "PlaceLoader"

			--[[ Getting Container ]]

			local container: Folder = location:FindFirstChild(containerName)
			local dirSettings: { string } = _task.MapConfig.GameDirs[dirName]

			-- Return if container or directory is missing for this location
			if not container or not dirSettings then
				return
			end

			--[[ Moving Maps ]]

			for _, mapName: string in ipairs(dirSettings) do
				--[[ Getting Map Folder ]]

				local mapFolder: Folder = container:FindFirstChild(tostring(mapName))
				if not mapFolder then
					continue
				end

				--[[ Moving Map Elems ]]

				for _, elem in ipairs(mapFolder:GetChildren()) do
					local existingElem: Instance = goalLocation:FindFirstChild(elem.Name)

					--[[ Existing -> Moving all children ]]

					if existingElem then
						moveFromTo({
							DirName = dirName,
							MapName = mapName,

							NewElem = elem,
							ExistingElem = existingElem,
							GoalLocation = existingElem,

							Path = `{dirName}||{mapName}||{elem.Name}`,
						})
					end

					--[[ New -> Moving ]]

					if not existingElem then
						elem.Parent = goalLocation
					end
				end
			end

			--[[ Destroying Container ]]

			container:Destroy()
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ General ]]

		matchDir({
			DirName = "StarterGui",
			Location = I.S.StarterGui,
		})
		matchDir({
			DirName = "StarterPack",
			Location = I.S.StarterPack,
		})
		matchDir({
			DirName = "StarterPlayer",
			Location = I.S.StarterPlayer,
		})

		--[[ Ume Dirs ]]

		matchDir({
			DirName = "Workspace_Ume",
			Location = I.Dirs.UmeServer,
			ContainerName = "PlaceLoader_Workspace",

			GoalLocation = I.Dirs.UmeWorkspace,
		})
		matchDir({
			DirName = "ReplicatedStorage_Ume",
			Location = I.Dirs.UmeReplicated,
		})
		matchDir({
			DirName = "ServerStorage_Ume",
			Location = I.Dirs.UmeServer,
		})

		--[[ Assets ]]

		matchDir({
			DirName = "Assets",
			Location = I.Dirs.Assets,
		})
		matchDir({
			DirName = "SAssets",
			Location = I.Dirs.SAssets,
		})
	end

	return Directories
end
