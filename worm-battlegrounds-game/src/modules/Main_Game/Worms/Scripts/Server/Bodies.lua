--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Worms"

--- @type Worms_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local wormsFolder: Folder

-- Every worm, by its participant id
local worms = {} --- @type { [string]: Model }

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

--- @class Worms_Server_Bodies
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Building ]]

	wormsFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})

	--[[ Templates ]]

	-- The tag and damage number billboards wait here for clients to clone, where the gui loader leaves them alone
	local templates: Folder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeReplicated,
	})
	for _index: number, name: string in ipairs({ "WormTag", "DamagePop" }) do
		I.Dirs.UmeReplicated.UserInterface:FindFirstChild(name).Parent = templates
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Spawn

--[[
	Builds a participant's worm at a position on the loaded arena's plane: an invisible ball held upright and on the
	plane, wearing the default skin, with the participant's attributes. Returns the worm, or nil when no arena is
	loaded or the skin is missing.
]]
--- @param participant Worms_Participant
--- @return Model?
function Module.Spawn(participant, position: Vector3)
	--[[ Checks ]]

	-- Check if the participant already has a worm
	if worms[participant.Id] then
		warn(`[{_localName}::{script.Name}]: Participant ({participant.Id}) already has a worm!`)
		return worms[participant.Id]
	end

	--[[ Data ]]

	local plane: Attachment? = I.Arena.GetPlane()
	local skins: Instance? = I.Dirs.Assets:FindFirstChild("Skins")
	local skinName: string = participant.Skin or _settings.DEFAULT_SKIN
	local skin: Instance? = skins and (skins:FindFirstChild(skinName) or skins:FindFirstChild(_settings.DEFAULT_SKIN))

	--[[ Checks ]]

	-- Check if an arena is loaded
	if not plane then
		warn(`[{_localName}::{script.Name}]: No arena is loaded to spawn ({participant.Id}) on!`)
		return nil
	end

	-- Check if the skin exists
	if not skin or not skin:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: Skin ({skinName}) and the default skin are missing from Assets.Skins!`)
		return nil
	end

	--[[ Body ]]

	local facing: CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis)
	local model: Model = I.Create("Model")({
		Name = participant.Id,
		ModelStreamingMode = Enum.ModelStreamingMode.Persistent,
	})
	local root: Part = I.Create("Part")({
		Name = "Root",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * _settings.ROOT_SIZE,
		CFrame = CFrame.new(position.X, position.Y, plane.WorldPosition.Z) * facing,
		Transparency = 1,
		CollisionGroup = "Worm",
		CustomPhysicalProperties = PhysicalProperties.new(1, _settings.ROOT_FRICTION, 0, 100, 100),
		Parent = model,
	})
	model.PrimaryPart = root

	--[[ Constraints ]]

	local center: Attachment = I.Create("Attachment")({
		Name = "Center",
		Parent = root,
	})
	I.Create("PlaneConstraint")({
		Name = "Plane",
		Attachment0 = plane,
		Attachment1 = center,
		Parent = root,
	})
	I.Create("AlignOrientation")({
		Name = "Upright",
		Mode = Enum.OrientationAlignmentMode.OneAttachment,
		Attachment0 = center,
		RigidityEnabled = true,
		CFrame = facing,
		Parent = root,
	})

	-- WormControl's owner client turns this on to walk; three times the worm's weight carries it up steep slopes
	I.Create("LinearVelocity")({
		Name = "Walk",
		Attachment0 = center,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		VelocityConstraintMode = Enum.VelocityConstraintMode.Line,
		LineDirection = Vector3.xAxis,
		MaxForce = root:GetMass() * I.S.Workspace.Gravity * 3,
		Enabled = false,
		Parent = root,
	})

	-- WormControl's effects: a parachute caps the fall speed, and Lift holds up part of the weight (low gravity)
	I.Create("LinearVelocity")({
		Name = "Chute",
		Attachment0 = center,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		VelocityConstraintMode = Enum.VelocityConstraintMode.Line,
		LineDirection = Vector3.yAxis,
		MaxForce = root:GetMass() * I.S.Workspace.Gravity * 2,
		Enabled = false,
		Parent = root,
	})
	I.Create("VectorForce")({
		Name = "Lift",
		Attachment0 = center,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		ApplyAtCenterOfMass = true,
		Force = Vector3.zero,
		Enabled = false,
		Parent = root,
	})

	--[[ Skin ]]

	local skinModel: Model = skin:Clone()
	skinModel.Name = "Skin"
	skinModel:PivotTo(root.CFrame)
	for _index: number, part: Instance in ipairs(skinModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.Massless = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			I.Create("WeldConstraint")({
				Part0 = root,
				Part1 = part,
				Parent = part,
			})
		end
	end
	skinModel.Parent = model

	--[[ Attributes ]]

	model:SetAttribute("ParticipantId", participant.Id)
	model:SetAttribute("UserId", participant.UserId)
	model:SetAttribute("DisplayName", participant.DisplayName)
	model:SetAttribute("Team", participant.Team)
	model:SetAttribute("Color", participant.Color)
	model:SetAttribute("IsBot", participant.IsBot)
	model:SetAttribute("Health", _settings.MAX_HEALTH)
	model:SetAttribute("MaxHealth", _settings.MAX_HEALTH)
	model:SetAttribute("Alive", true)
	model:SetAttribute("Ghost", false)
	model:SetAttribute("Facing", 1)
	model:SetAttribute("Shiny", participant.Shiny == true)
	model:SetAttribute("Vip", participant.Vip == true)
	model:SetAttribute("Level", participant.Level or 0)
	model:SetAttribute("DamageTaken", participant.DamageTaken or 1)

	--[[ Saving ]]

	model.Parent = wormsFolder
	root:SetNetworkOwner(nil)
	worms[participant.Id] = model

	-- Stream the arena around the player's worm, not around their parked avatar
	local player: Player? = I.S.Players:GetPlayerByUserId(participant.UserId)
	if player then
		player.ReplicationFocus = root
	end

	--[[ Returning ]]

	return model
end

--%%%%%%%%%%%%%%%%%%%% Set Owner

--[[
	**SERVER** |
	Gives a worm's physics to a player's client (so its movement feels instant), or back to the server with nil.
]]
function Module.SetOwner(participantId: string, player: Player?)
	--[[ Data ]]

	local model: Model? = worms[participantId]

	--[[ Checks ]]

	-- Check if the worm is alive
	if not model or not model:GetAttribute("Alive") then
		return
	end

	--[[ Applying ]]

	model.PrimaryPart:SetNetworkOwner(player)
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	**SERVER** |
	Removes every worm, before a new map or match.
]]
function Module.Clear()
	--[[ Clearing ]]

	for _id: string, model: Model in pairs(worms) do
		model:Destroy()
	end
	worms = {}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns a participant's worm, or nil when it has none.
]]
--- @return Model?
function Module.Get(participantId: string)
	return worms[participantId]
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	**SERVER** |
	Returns every worm, ghosts included.
]]
--- @return { Model }
function Module.GetAll()
	--[[ Local Variables ]]

	local all = {} --- @type { Model }

	--[[ Collecting ]]

	for _id: string, model: Model in pairs(worms) do
		table.insert(all, model)
	end

	--[[ Returning ]]

	return all
end

--%%%%%%%%%%%%%%%%%%%% Get Alive

--[[
	**SERVER** |
	Returns every worm that hasn't been knocked out.
]]
--- @return { Model }
function Module.GetAlive()
	--[[ Local Variables ]]

	local alive = {} --- @type { Model }

	--[[ Collecting ]]

	for _id: string, model: Model in pairs(worms) do
		if model:GetAttribute("Alive") then
			table.insert(alive, model)
		end
	end

	--[[ Returning ]]

	return alive
end

--%%%%%%%%%%%%%%%%%%%% Is Settled

--[[
	Returns whether every worm still in play is at rest (slower than SETTLE_SPEED).
]]
--- @return boolean
function Module.IsSettled()
	--[[ Checking ]]

	for _index: number, model: Model in ipairs(Module.GetAlive()) do
		if model.PrimaryPart.AssemblyLinearVelocity.Magnitude > _settings.SETTLE_SPEED then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

return Module
