--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Protect
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hide Server Scripts

--[[
	**SERVER** |
	Moves all server-side modules to prevent player access.
]]
function _task.HideServerScripts(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[
		Hides matching children and does not walk a child that was hidden.
	]]
	local function hideIn(parent: Instance)
		--[[ Hiding ]]

		for _: number, elem: Instance in ipairs(parent:GetChildren()) do
			local name: string = elem.Name:lower()

			-- Skip if marked as unprotected
			if elem:GetAttribute("Ume_Unprotected") then
				hideIn(elem)
				continue
			end

			-- Moves the meta folder to the protected folder
			if name == "_meta" then
				elem.Parent = I._dirs.Protected
				continue
			end

			-- Moves server files to the protected folder
			if string.find(name, "server", 1) or string.sub(name, 1, 2) == "s_" then
				elem.Parent = I._dirs.Protected
				continue
			end

			-- Moves Ume component files to the protected folder
			if string.sub(name, -5) == ".comp" then
				elem.Parent = I._dirs.Protected
				continue
			end

			-- Moves type definitions files to the protected folder
			if string.sub(name, -6) == ".d.lua" then
				elem.Parent = I._dirs.Protected
				continue
			end

			hideIn(elem)
		end
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Hiding ]]

	hideIn(I._dirs.Instance)
end

--%%%%%%%%%%%%%%%%%%%% Expose Instance To Client

--[[
	**SERVER** |
	Moves the Ume instance to `ReplicatedStorage` so it can be accessed by the client.
]]
function _task.ExposeInstanceToClient(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	I._dirs.Instance.Parent = I.S.ReplicatedStorage
end

return _task
