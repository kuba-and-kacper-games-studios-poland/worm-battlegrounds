--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Tree ]]

local ATTRIBUTE_NAME = "Ume_DescendantManifest"
local MAX_DEPTH = 2

--[[ Diagnostics ]]

local MAX_REPLICATION_ISSUES = 100
local REPLICATION_DIAGNOSTIC_INTERVAL = 1
local WARN_MANIFEST_MISSING = false

--[[ Client Wait ]]

local CLIENT_WAIT_SECONDS = 10
local REPLICATION_TIMEOUT_MESSAGE = "Ume Instance replication incomplete or manifest mismatch (timed out)."

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Build Name Tree

--[[
	Builds a nested table of instance names mirroring the hierarchy under `root`, truncating branches at `MAX_DEPTH` to a `descendantCount` leaf.
]]
--- @return ReplicationGate_NameTreeNode
local function buildNameTree(root: Instance, depth: number)
	--[[ Depth Cutoff ]]

	-- Save the descendant count when the branch is truncated
	if depth >= MAX_DEPTH then
		return {
			name = root.Name,
			descendantCount = #root:GetDescendants(),
		}
	end

	--[[ Local Variables ]]

	--- @type { ReplicationGate_NameTreeNode }
	local children = {}

	--[[ Building Children ]]

	for _: number, child: Instance in ipairs(root:GetChildren()) do
		table.insert(children, buildNameTree(child, depth + 1))
	end

	--[[ Returning ]]

	return {
		name = root.Name,
		children = children,
	}
end

--%%%%%%%%%%%%%%%%%%%% Index Children By Name

--[[
	Groups live children by name so sibling order can be ignored.
]]
--- @return { [string]: { Instance } }
local function indexChildrenByName(parent: Instance)
	--[[ Local Variables ]]

	--- @type { [string]: { Instance } }
	local actualByName = {}

	--[[ Indexing ]]

	for _: number, child: Instance in ipairs(parent:GetChildren()) do
		--[[ Queue ]]

		--- @type { Instance }?
		local unmatchedQueue = actualByName[child.Name]

		-- Create the queue when this name is new
		if not unmatchedQueue then
			unmatchedQueue = {}
			actualByName[child.Name] = unmatchedQueue
		end

		--[[ Inserting ]]

		table.insert(unmatchedQueue, child)
	end

	--[[ Returning ]]

	return actualByName
end

--%%%%%%%%%%%%%%%%%%%% Hierarchy Matches

--[[
	Returns whether the live instance hierarchy matches the encoded tree (same names, sibling order ignored); truncated leaves compare descendant counts instead.
]]
--- @param node ReplicationGate_NameTreeNode
--- @return boolean
local function hierarchyMatches(parent: Instance, node)
	--[[ Checks ]]

	-- Check if the manifest node matches this instance name
	if type(node) ~= "table" or parent.Name ~= node.name then
		return false
	end

	--[[ Truncated Leaf ]]

	-- Compare descendant counts when the branch was truncated
	if type(node.descendantCount) == "number" then
		return #parent:GetDescendants() == node.descendantCount
	end

	--[[ Local Variables ]]

	--- @type { ReplicationGate_NameTreeNode }
	local expectedChildren = node.children

	--[[ Checks ]]

	-- Check if the manifest children are a table
	if type(expectedChildren) ~= "table" then
		return false
	end

	--[[ Indexing ]]

	--- @type { [string]: { Instance } }
	local actualByName = indexChildrenByName(parent)

	--[[ Matching Children ]]

	--- @param childNode ReplicationGate_NameTreeNode
	for _: number, childNode in ipairs(expectedChildren) do
		--[[ Checks ]]

		--- @type { Instance }?
		local unmatchedQueue = actualByName[childNode.name]

		-- Check if a live sibling shares this name
		if not unmatchedQueue or #unmatchedQueue == 0 then
			return false
		end

		--[[ Matching ]]

		local childInst: Instance = table.remove(unmatchedQueue, 1)

		-- Check if this child matches the manifest
		if not hierarchyMatches(childInst, childNode) then
			return false
		end
	end

	--[[ Leftover Check ]]

	--- @param unmatchedQueue { Instance }
	for _: string, unmatchedQueue in pairs(actualByName) do
		--[[ Checks ]]

		-- Check if this name still has unmatched children
		if #unmatchedQueue > 0 then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Collect Replication Mismatches

--[[
	Appends human-readable mismatch lines (missing names, unexpected extras, descendant count drift) up to `MAX_REPLICATION_ISSUES`; sibling order is ignored.
]]
--- @param node ReplicationGate_NameTreeNode
--- @param issues { string }
local function collectReplicationMismatches(parent: Instance, node, path: string, issues)
	--[[ Checks ]]

	-- Stop once the issue list is full
	if #issues >= MAX_REPLICATION_ISSUES then
		return
	end

	-- Check if the manifest node is a table
	if type(node) ~= "table" then
		table.insert(issues, `{path}: manifest node is not a table`)
		return
	end

	-- Check if the instance name matches the manifest
	if parent.Name ~= node.name then
		table.insert(issues, `{path}: name mismatch (manifest ({node.name}), instance ({parent.Name}))`)
		return
	end

	--[[ Truncated Leaf ]]

	-- Compare descendant counts when the branch was truncated
	if type(node.descendantCount) == "number" then
		--[[ Local Variables ]]

		local actualCount: number = #parent:GetDescendants()

		--[[ Reporting ]]

		-- Record a count mismatch
		if actualCount ~= node.descendantCount then
			table.insert(issues, `{path}: descendant count mismatch (manifest ({node.descendantCount}), instance ({actualCount}))`)
		end

		-- Stop at a truncated leaf
		return
	end

	--[[ Local Variables ]]

	--- @type { ReplicationGate_NameTreeNode }
	local expectedChildren = node.children

	--[[ Checks ]]

	-- Check if the manifest children are a table
	if type(expectedChildren) ~= "table" then
		table.insert(issues, `{path}: manifest children missing or not a table`)
		return
	end

	--[[ Indexing ]]

	--- @type { [string]: { Instance } }
	local actualByName = indexChildrenByName(parent)

	--[[ Matching Expected Children ]]

	--- @param childNode ReplicationGate_NameTreeNode
	for _: number, childNode in ipairs(expectedChildren) do
		--[[ Checks ]]

		-- Stop once the issue list is full
		if #issues >= MAX_REPLICATION_ISSUES then
			return
		end

		--[[ Local Variables ]]

		local childName: string = childNode.name
		local unmatchedQueue = actualByName[childName] --- @type { Instance }?

		--[[ Reporting ]]

		-- Record a missing sibling
		if not unmatchedQueue or #unmatchedQueue == 0 then
			table.insert(issues, `{path}/{childName}: missing (no sibling with this name on client)`)
			continue
		end

		--[[ Matching ]]

		local childInst: Instance = table.remove(unmatchedQueue, 1)
		collectReplicationMismatches(childInst, childNode, `{path}/{childName}`, issues)
	end

	--[[ Reporting Extra Children ]]

	--- @param unmatchedQueue { Instance }
	for extraName: string, unmatchedQueue in pairs(actualByName) do
		for _: number = 1, #unmatchedQueue do
			--[[ Checks ]]

			-- Stop once the issue list is full
			if #issues >= MAX_REPLICATION_ISSUES then
				return
			end

			--[[ Reporting ]]

			table.insert(issues, `{path}/{extraName}: unexpected extra sibling on client (not in manifest)`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Decode Name Tree

--[[
	Decodes a manifest JSON string into a name tree.
]]
--- @return ReplicationGate_NameTreeNode?
local function decodeNameTree(raw: string, httpService: HttpService)
	--[[ Decoding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return httpService:JSONDecode(raw)
	end)

	--[[ Checks ]]

	-- Check if the manifest decoded
	if not success or type(result) ~= "table" then
		return nil
	end

	--[[ Returning ]]

	--- @type ReplicationGate_NameTreeNode
	local tree = result
	return tree
end

--%%%%%%%%%%%%%%%%%%%% Gather Replication Issues

--[[
	Builds the current manifest vs instance mismatch list (attribute missing, decode failure, or `collectReplicationMismatches`).
]]
--- @return { string }
local function gatherReplicationIssues(rootInstance: Instance, httpService: HttpService)
	--[[ Local Variables ]]

	local issues = {} --- @type { string }
	local raw: string? = rootInstance:GetAttribute(ATTRIBUTE_NAME)

	--[[ Attribute Check ]]

	-- Check if the manifest attribute is present
	if type(raw) ~= "string" or raw == "" then
		table.insert(issues, `Attribute ({ATTRIBUTE_NAME}) missing or empty (not replicated yet?)`)
		return issues
	end

	--[[ Decoding ]]

	--- @type ReplicationGate_NameTreeNode?
	local tree = decodeNameTree(raw, httpService)

	--[[ Checks ]]

	-- Check if the manifest decoded
	if not tree then
		table.insert(issues, `Failed to JSONDecode manifest attribute ({ATTRIBUTE_NAME})`)
		return issues
	end

	--[[ Collecting Mismatches ]]

	collectReplicationMismatches(rootInstance, tree, rootInstance.Name, issues)

	--[[ Empty Diff Fallback ]]

	-- Record a mismatch when the trees differ but no line was produced
	if #issues == 0 and not hierarchyMatches(rootInstance, tree) then
		table.insert(issues, "Hierarchy mismatch with empty diff (unexpected manifest shape)")
	end

	--[[ Returning ]]

	return issues
end

--%%%%%%%%%%%%%%%%%%%% Warn Replication Issues

--[[
	Emits mismatch lines with `warn`, truncating when `MAX_REPLICATION_ISSUES` is reached.
]]
--- @param issues { string }
local function warnReplicationIssues(issues)
	--[[ Truncation ]]

	-- Append a cap notice when the issue list is full
	if #issues >= MAX_REPLICATION_ISSUES then
		table.insert(issues, "Further mismatches omitted; raise (MAX_REPLICATION_ISSUES) if needed.")
	end

	--[[ Emitting Warnings ]]

	for _: number, line: string in ipairs(issues) do
		warn(`[Ume::{script.Name}]: Replication mismatch - {line}`)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_ReplicationGate
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Write Server Manifest

--[[
	**SERVER** |
	Serializes the descendant name tree of the Ume instance and stores it as an attribute.
]]
function _task.WriteServerManifest(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer or not I.Env.IsStudio then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Building Name Tree ]]

	--- @type ReplicationGate_NameTreeNode
	local tree = buildNameTree(I._dirs.Instance, 0)

	--[[ Encoding JSON ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return I.S.HttpService:JSONEncode(tree)
	end)

	--[[ Checks ]]

	-- Check if the manifest encoded
	if not success or not result then
		warn(`[Ume::{script.Name}]: Failed to JSONEncode descendant manifest (tree may be too large).`)
		return
	end

	--[[ Writing Instance Attribute ]]

	I._dirs.Instance:SetAttribute(ATTRIBUTE_NAME, result)
end

--%%%%%%%%%%%%%%%%%%%% Wait Before Framework Load

--[[
	**CLIENT** |
	Waits until the manifest attribute is present and the instance hierarchy matches it.
]]
function _task.WaitBeforeFrameworkLoad(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Client Check ]]

	local RunService: RunService = game:GetService("RunService")

	-- Skip when this is not a Studio client
	if not RunService:IsClient() or not RunService:IsStudio() then
		return
	end

	--[[ Services ]]

	local HttpService: HttpService = game:GetService("HttpService")
	local Players: Players = game:GetService("Players")

	--[[ Getting Ume Instance Model ]]

	local rootInstance: Instance? = script:FindFirstAncestorWhichIsA("Model")

	--[[ Checks ]]

	-- Check if the Ume instance model exists
	if not rootInstance then
		error(`[Ume::{script.Name}]: Ume Instance model not found (ancestor of Start tasks).`, 0)
	end

	-- Skip when the manifest attribute is absent
	if not rootInstance:GetAttribute(ATTRIBUTE_NAME) then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Local Variables ]]

	local deadline: number = os.clock() + CLIENT_WAIT_SECONDS
	local nextDiagnosticAt: number = 0

	--[[ Replication Check ]]

	repeat
		--[[ Diagnostic Tick ]]

		local now: number = os.clock()

		-- Emit diagnostics on the interval
		if now >= nextDiagnosticAt then
			nextDiagnosticAt = now + REPLICATION_DIAGNOSTIC_INTERVAL

			-- Warn when manifest diagnostics are enabled
			if RunService:IsStudio() and WARN_MANIFEST_MISSING then
				warnReplicationIssues(gatherReplicationIssues(rootInstance, HttpService))
			end
		end

		--[[ Attribute And Hierarchy Check ]]

		local raw: any = rootInstance:GetAttribute(ATTRIBUTE_NAME)

		-- Check if the manifest attribute is a string
		if type(raw) == "string" and raw ~= "" then
			--[[ Decoding ]]

			--- @type ReplicationGate_NameTreeNode?
			local tree = decodeNameTree(raw, HttpService)

			--[[ Structural Check ]]

			-- Return once the live hierarchy matches
			if tree and hierarchyMatches(rootInstance, tree) then
				return
			end
		end

		-- Wait for the next heartbeat
		RunService.Heartbeat:Wait()
	until os.clock() >= deadline

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Timeout ]]

	-- Emit diagnostics when warnings are enabled
	if RunService:IsStudio() and WARN_MANIFEST_MISSING then
		warnReplicationIssues(gatherReplicationIssues(rootInstance, HttpService))
	end

	--[[ Kicking ]]

	Players.LocalPlayer:Kick(REPLICATION_TIMEOUT_MESSAGE)
	error(`[Ume::{script.Name}]: {REPLICATION_TIMEOUT_MESSAGE}`, 0)
end

return _task
