local function createPlaceLoaderDirs()
	--[[ Services ]]

	local Workspace: Workspace = game:GetService("Workspace")
	local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerStorage: ServerStorage = game:GetService("ServerStorage")

	--[[ Creating PlaceLoader Dir ]]

	local placeLoaderStorage: Configuration = Instance.new("Configuration")
	placeLoaderStorage.Name = "PlaceLoader"

	local defaultMapFolder: Folder = Instance.new("Folder")
	defaultMapFolder.Name = "Default"
	defaultMapFolder.Parent = placeLoaderStorage

	--[[ Getting Directories ]]

	-- Ume directories
	local umeWorkspace: Instance = Workspace:FindFirstChild("Ume")
	local umeReplicated: Instance = ReplicatedStorage:FindFirstChild("Ume")
	local umeServer: Instance = ServerStorage:FindFirstChild("Ume")

	local assets: Instance = umeReplicated and umeReplicated:FindFirstChild("Assets")
	local assetsServer: Instance = umeServer and umeServer:FindFirstChild("Assets")

	--[[ Cloning Folders ]]

	for _, goalDir: Instance in
		{
			--[[ General ]]

			game:GetService("StarterGui"),
			game:GetService("StarterPack"),
			game:GetService("StarterPlayer"),

			--[[ Ume Dirs ]]

			umeWorkspace,
			umeReplicated,
			umeServer,

			--[[ Assets ]]

			assets,
			assetsServer,
		}
	do
		-- Skip if directory is missing or storage exists
		if not goalDir or goalDir:FindFirstChild("PlaceLoader") then
			continue
		end

		--[[ Cloning ]]

		local cloned: Configuration = placeLoaderStorage:Clone()
		cloned.Parent = goalDir
	end

	--[[ ServerStorage - Workspace ]]

	if umeServer then
		-- Skip if storage exists
		if umeServer:FindFirstChild("PlaceLoader_Workspace") then
			return
		end

		--[[ Cloning ]]

		local cloned: Configuration = placeLoaderStorage:Clone()
		cloned.Name = "PlaceLoader_Workspace"
		cloned.Parent = umeServer
	end
end
createPlaceLoaderDirs()
