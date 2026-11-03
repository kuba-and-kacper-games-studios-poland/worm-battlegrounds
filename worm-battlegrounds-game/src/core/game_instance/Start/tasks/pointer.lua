--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Pointer
local _task = {}

--[[
	**SERVER** |
	Creates a pointer that references the `Start` module.  
	This pointer is used by all modules to access the framework.
]]
function _task.Create(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Start/Ume Pointer ]]

	local umePointer: ObjectValue = Instance.new("ObjectValue")
	umePointer.Name = "UmePointer"
	umePointer.Value = I._dirs.Instance.Start
	umePointer.Parent = I.S.ReplicatedStorage

	--[[ Failed Pointer ]]

	local failedPointer: ObjectValue = Instance.new("ObjectValue")
	failedPointer.Name = "UmeFailedPointer"
	failedPointer.Value = I._dirs.Instance.Failed
	failedPointer.Parent = I.S.ReplicatedStorage
end

return _task
