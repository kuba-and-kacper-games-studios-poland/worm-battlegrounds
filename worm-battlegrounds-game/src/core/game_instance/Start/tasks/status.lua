--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local LOAD_REMOTE_NAME = "ClientLoaded"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Status
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Listen For Client

--[[
	**SERVER** |
	Creates a RemoteEvent that updates the player's loaded status when fired.
]]
function _task.ListenForClient(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	local clientLoaded: RemoteEvent = Instance.new("RemoteEvent")
	clientLoaded.Name = LOAD_REMOTE_NAME
	clientLoaded.Parent = script

	-- Listen for updates
	clientLoaded.OnServerEvent:Connect(function(player: Player)
		if player:FindFirstChild(I.Config.General._clientStatusBoolName) then
			return -- Return if already created
		end

		local loadedBool: BoolValue = Instance.new("BoolValue")
		loadedBool.Name = `{I.Config.General._clientStatusBoolName}`
		loadedBool.Value = true
		loadedBool.Parent = player
	end)
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	**CLIENT** |
	Notifies the server that the framework has fully loaded on the client.
]]
function _task.Update(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsClient then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	script:FindFirstChild(LOAD_REMOTE_NAME):FireServer()
end

return _task
