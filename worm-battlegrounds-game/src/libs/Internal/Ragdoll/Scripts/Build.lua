--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ Names ]]

local CONSTRAINTS_FOLDER_NAME: string = "RagdollConstraints"
local ROOT_SOCKET_NAME: string = "RagdollRootSocket"
local ROOT_ALIGN_NAME: string = "RagdollUpright"
local ROOT_ATTACHMENT_NAME: string = "RagdollUprightAttachment"
local TORSO_ATTACHMENT_NAME: string = "RagdollRootAttachment"
local JOINT_ATTRIBUTE: string = "Ragdoll_Joint"

--[[ Limits ]]

local LIMB_UPPER_ANGLE: number = 75
local LIMB_TWIST: number = 40
local ROOT_UPPER_ANGLE: number = 120
local ROOT_TWIST: number = 80
local UPRIGHT_TILT: CFrame = CFrame.Angles(0, 0, math.rad(90))

--[[ Joints ]]

--- @type { [string]: boolean }
local R6_JOINTS = {
	["Neck"] = true,
	["Left Shoulder"] = true,
	["Right Shoulder"] = true,
	["Left Hip"] = true,
	["Right Hip"] = true,
}

--- @type { [string]: boolean }
local R15_JOINTS = {
	["Waist"] = true,
	["Neck"] = true,
	["LeftShoulder"] = true,
	["RightShoulder"] = true,
	["LeftElbow"] = true,
	["RightElbow"] = true,
	["LeftWrist"] = true,
	["RightWrist"] = true,
	["LeftHip"] = true,
	["RightHip"] = true,
	["LeftKnee"] = true,
	["RightKnee"] = true,
	["LeftAnkle"] = true,
	["RightAnkle"] = true,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Root Joint

--[[
	Returns whether a motor name is the root joint, which keeps its own socket.
]]
--- @return boolean
local function isRootJoint(jointName: string)
	return jointName == "Root" or jointName == "RootJoint"
end

--%%%%%%%%%%%%%%%%%%%% Get Rig Type

--[[
	Returns R15 or R6 from the humanoid, then from the torso part names.
]]
--- @return Enum.HumanoidRigType?
local function getRigType(model: Model)
	--[[ Humanoid ]]

	local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")

	-- Use the humanoid's rig type when there is one
	if humanoid then
		return humanoid.RigType
	end

	--[[ Returning ]]

	-- Fall back to the torso part names
	if model:FindFirstChild("UpperTorso") or model:FindFirstChild("LowerTorso") then
		return Enum.HumanoidRigType.R15
	end

	if model:FindFirstChild("Torso") then
		return Enum.HumanoidRigType.R6
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Body Joint

--[[
	Returns whether a motor is a ragdoll body joint for this rig. Unknown rigs use every non-root motor.
]]
--- @return boolean
local function isBodyJoint(model: Model, jointName: string)
	--[[ Checks ]]

	-- Skip the root joint
	if isRootJoint(jointName) then
		return false
	end

	--[[ Local Variables ]]

	local rigType: Enum.HumanoidRigType? = getRigType(model)

	--[[ Returning ]]

	if rigType == Enum.HumanoidRigType.R15 then
		return R15_JOINTS[jointName] == true
	end

	if rigType == Enum.HumanoidRigType.R6 then
		return R6_JOINTS[jointName] == true
	end

	-- Use every non-root motor on unknown rigs
	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Torso

--[[
	Returns the part the root joint drives, falling back to the torso part names.
]]
--- @return BasePart?
local function getTorso(model: Model)
	--[[ Root Joint ]]

	local humanoidRootPart: Instance? = model:FindFirstChild("HumanoidRootPart")

	-- Look up the root joint when the rig has a root part
	if humanoidRootPart then
		local rootJoint: Instance? = humanoidRootPart:FindFirstChild("Root") or humanoidRootPart:FindFirstChild("RootJoint")

		-- Use the part a root motor drives
		if rootJoint and rootJoint:IsA("Motor6D") and rootJoint.Part1 then
			return rootJoint.Part1
		end

		-- Use the part a root animation constraint drives
		if rootJoint and rootJoint:IsA("AnimationConstraint") and rootJoint.Attachment1 and rootJoint.Attachment1.Parent and rootJoint.Attachment1.Parent:IsA("BasePart") then
			return rootJoint.Attachment1.Parent
		end
	end

	--[[ Returning ]]

	local torso: Instance? = model:FindFirstChild("LowerTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")

	-- Fall back to the torso part names
	if torso and torso:IsA("BasePart") then
		return torso
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Find Ball Socket

--[[
	Returns a ball socket that already joins the two parts, searching the parts and the constraints folder.
]]
--- @return BallSocketConstraint?
local function findBallSocket(part0: BasePart, part1: BasePart)
	--[[ Roots ]]

	local roots = { part0, part1 } --- @type { Instance }
	local model: Model? = part0:FindFirstAncestorOfClass("Model")
	local constraintsFolder: Instance? = model and model:FindFirstChild(CONSTRAINTS_FOLDER_NAME)

	-- Search the constraints folder too once the model was rigged
	if constraintsFolder then
		table.insert(roots, constraintsFolder)
	end

	--[[ Finding ]]

	for _index: number, root: Instance in ipairs(roots) do
		for _descendantIndex: number, descendant: Instance in ipairs(root:GetDescendants()) do
			--[[ Checks ]]

			-- Skip anything that is not a wired ball socket
			if not descendant:IsA("BallSocketConstraint") or not descendant.Attachment0 or not descendant.Attachment1 then
				continue
			end

			--[[ Matching ]]

			local parent0: Instance? = descendant.Attachment0.Parent
			local parent1: Instance? = descendant.Attachment1.Parent

			-- Match the two parts in either order
			if (parent0 == part0 and parent1 == part1) or (parent0 == part1 and parent1 == part0) then
				return descendant
			end
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Attachment

--[[
	Returns the named attachment on a part, replacing a non-attachment child with that name.
]]
--- @return Attachment
local function getAttachment(part: BasePart, attachmentName: string)
	--[[ Finding ]]

	local existing: Instance? = part:FindFirstChild(attachmentName)

	-- Reuse an existing attachment
	if existing and existing:IsA("Attachment") then
		return existing
	end

	-- Remove a non-attachment child with that name
	if existing then
		existing:Destroy()
	end

	--[[ Creating ]]

	local attachment: Attachment = Instance.new("Attachment")
	attachment.Name = attachmentName
	attachment.Parent = part

	--[[ Returning ]]

	return attachment
end

--%%%%%%%%%%%%%%%%%%%% Get Rig Attachments

--[[
	Returns the rig attachment pair of a motor, rebuilding it from C0 / C1 when one is missing.
]]
--- @return Attachment?
--- @return Attachment?
local function getRigAttachments(joint: Motor6D)
	--[[ Checks ]]

	local part0: BasePart? = joint.Part0
	local part1: BasePart? = joint.Part1

	-- Check if the motor joins two parts
	if not part0 or not part1 then
		return nil, nil
	end

	--[[ Finding ]]

	local attachmentName: string = `{joint.Name}RigAttachment`
	local attachment0: Instance? = part0:FindFirstChild(attachmentName)
	local attachment1: Instance? = part1:FindFirstChild(attachmentName)

	-- Reuse a complete attachment pair
	if attachment0 and attachment0:IsA("Attachment") and attachment1 and attachment1:IsA("Attachment") then
		return attachment0, attachment1
	end

	--[[ Rebuilding ]]

	-- Remove the incomplete pair before rebuilding it
	if attachment0 then
		attachment0:Destroy()
	end
	if attachment1 then
		attachment1:Destroy()
	end

	local newAttachment0: Attachment = getAttachment(part0, attachmentName)
	local newAttachment1: Attachment = getAttachment(part1, attachmentName)
	newAttachment0.CFrame = joint.C0
	newAttachment1.CFrame = joint.C1

	--[[ Returning ]]

	return newAttachment0, newAttachment1
end

--%%%%%%%%%%%%%%%%%%%% Create Limb Socket

--[[
	Creates a disabled, limited ball socket for a body motor that does not have one yet.
]]
local function createLimbSocket(model: Model, joint: Motor6D, constraintsFolder: Folder)
	--[[ Checks ]]

	-- Skip motors that are not body joints
	if not isBodyJoint(model, joint.Name) or not joint.Part0 or not joint.Part1 then
		return
	end

	-- Skip joints that already have a socket
	if findBallSocket(joint.Part0, joint.Part1) then
		return
	end

	--[[ Attachments ]]

	local attachment0: Attachment?, attachment1: Attachment? = getRigAttachments(joint)

	-- Check if the motor has an attachment pair
	if not attachment0 or not attachment1 then
		return
	end

	--[[ Creating ]]

	local socket: BallSocketConstraint = Instance.new("BallSocketConstraint")
	socket.Name = `{joint.Part1.Name}BallSocketConstraint`
	socket.Attachment0 = attachment0
	socket.Attachment1 = attachment1
	socket.LimitsEnabled = true
	socket.UpperAngle = LIMB_UPPER_ANGLE
	socket.TwistLimitsEnabled = true
	socket.TwistLowerAngle = -LIMB_TWIST
	socket.TwistUpperAngle = LIMB_TWIST
	socket.Enabled = false
	socket:SetAttribute(JOINT_ATTRIBUTE, string.match(joint.Name, "(%u%l*)$") or joint.Name)
	socket.Parent = constraintsFolder
end

--%%%%%%%%%%%%%%%%%%%% Create Root Constraints

--[[
	Builds the upright align on the root part, and a root socket when the rig does not have one.
]]
local function createRootConstraints(model: Model, constraintsFolder: Folder)
	--[[ Checks ]]

	local humanoidRootPart: Instance? = model:FindFirstChild("HumanoidRootPart")
	local torso: BasePart? = getTorso(model)

	-- Check if the rig has a root part and a torso
	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or not torso then
		return
	end

	--[[ Attachment ]]

	local rootMotor: Instance? = humanoidRootPart:FindFirstChild("Root") or humanoidRootPart:FindFirstChild("RootJoint")
	local rootOffset: Vector3 = if rootMotor and rootMotor:IsA("Motor6D") then rootMotor.C0.Position else Vector3.zero

	-- Point the attachment's X axis (the align axis) up so only yaw stays free
	local rootAttachment: Attachment = getAttachment(humanoidRootPart, ROOT_ATTACHMENT_NAME)
	rootAttachment.CFrame = CFrame.new(rootOffset) * UPRIGHT_TILT

	--[[ Align ]]

	local align: AlignOrientation = Instance.new("AlignOrientation")
	align.Name = ROOT_ALIGN_NAME
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.AlignType = Enum.AlignType.PrimaryAxisParallel
	align.PrimaryAxis = Vector3.yAxis
	align.Attachment0 = rootAttachment
	align.RigidityEnabled = true
	align.ReactionTorqueEnabled = false
	align.Enabled = false
	align.Parent = constraintsFolder

	--[[ Checks ]]

	-- Skip the socket when the rig already joins the root part and torso
	if findBallSocket(humanoidRootPart, torso) then
		return
	end

	--[[ Socket ]]

	local torsoAttachment: Attachment = getAttachment(torso, TORSO_ATTACHMENT_NAME)
	torsoAttachment.CFrame = torso.CFrame:ToObjectSpace(rootAttachment.WorldCFrame)

	local socket: BallSocketConstraint = Instance.new("BallSocketConstraint")
	socket.Name = ROOT_SOCKET_NAME
	socket.Attachment0 = rootAttachment
	socket.Attachment1 = torsoAttachment
	socket.LimitsEnabled = true
	socket.UpperAngle = ROOT_UPPER_ANGLE
	socket.TwistLimitsEnabled = true
	socket.TwistLowerAngle = -ROOT_TWIST
	socket.TwistUpperAngle = ROOT_TWIST
	socket.Enabled = false
	socket.Parent = constraintsFolder
end

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

--- @class Ragdoll_Build
local Build = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Rig

--[[
	Builds the missing ragdoll constraints of a model. Calling it again only fills joints that are new.
]]
function Build.Rig(model: Model)
	--[[ Root Weld ]]

	local humanoidRootPart: Instance? = model:FindFirstChild("HumanoidRootPart")
	local legacyRootWeld: Instance? = humanoidRootPart and humanoidRootPart:FindFirstChild("RootWeld")

	-- Remove the legacy root weld that would freeze the body in the air
	if legacyRootWeld then
		legacyRootWeld:Destroy()
	end

	--[[ Folder ]]

	local constraintsFolder: Instance? = model:FindFirstChild(CONSTRAINTS_FOLDER_NAME)

	-- Create the folder when it is missing
	if not constraintsFolder or not constraintsFolder:IsA("Folder") then
		-- Remove a non-folder child with the folder name
		if constraintsFolder then
			constraintsFolder:Destroy()
		end

		constraintsFolder = Instance.new("Folder")
		constraintsFolder.Name = CONSTRAINTS_FOLDER_NAME
		constraintsFolder.Parent = model
	end

	--[[ Sockets ]]

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			createLimbSocket(model, descendant, constraintsFolder)
		end
	end

	--[[ Root ]]

	-- Build the root constraints once
	if not constraintsFolder:FindFirstChild(ROOT_ALIGN_NAME) then
		createRootConstraints(model, constraintsFolder)
	end
end

--%%%%%%%%%%%%%%%%%%%% Scan

--[[
	Fills a rig cache with the model's motors, generated sockets, root constraints, and root welds.
]]
--- @param cache Ragdoll_RigCache
function Build.Scan(model: Model, cache)
	--[[ Resetting ]]

	cache.Motors = {}
	cache.AnimationJoints = {}
	cache.Sockets = {}
	cache.ForeignSockets = {}
	cache.RootWelds = {}
	cache.RootSocket = nil
	cache.RootSocketOwned = false
	cache.RootAlign = nil

	--[[ Joints ]]

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		if descendant:IsA("Motor6D") and (isRootJoint(descendant.Name) or isBodyJoint(model, descendant.Name)) then
			table.insert(cache.Motors, descendant)
		elseif descendant:IsA("AnimationConstraint") then
			table.insert(cache.AnimationJoints, descendant)
		end
	end

	--[[ Foreign Sockets ]]

	local constraintsFolder: Instance? = model:FindFirstChild(CONSTRAINTS_FOLDER_NAME)

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		--[[ Checks ]]

		-- Skip non-sockets and generated sockets
		if not descendant:IsA("BallSocketConstraint") or (constraintsFolder and descendant:IsDescendantOf(constraintsFolder)) then
			continue
		end

		--[[ Saving ]]

		local part0: BasePart? = descendant.Attachment0 and descendant.Attachment0:FindFirstAncestorWhichIsA("BasePart")
		local part1: BasePart? = descendant.Attachment1 and descendant.Attachment1:FindFirstAncestorWhichIsA("BasePart")

		-- Keep sockets that do not touch the root part
		if part0 and part1 and part0.Name ~= "HumanoidRootPart" and part1.Name ~= "HumanoidRootPart" then
			table.insert(cache.ForeignSockets, descendant)
		end
	end

	--[[ Checks ]]

	-- Check if the model was rigged
	if not constraintsFolder then
		return
	end

	--[[ Constraints ]]

	for _index: number, descendant: Instance in ipairs(constraintsFolder:GetDescendants()) do
		if descendant:IsA("BallSocketConstraint") and descendant.Name ~= ROOT_SOCKET_NAME then
			table.insert(cache.Sockets, descendant)
		end
	end

	-- Use the generated root socket when there is one
	local rootSocket: Instance? = constraintsFolder:FindFirstChild(ROOT_SOCKET_NAME)
	if rootSocket and rootSocket:IsA("BallSocketConstraint") then
		cache.RootSocket = rootSocket
		cache.RootSocketOwned = true
	end

	-- Use the generated upright align when there is one
	local rootAlign: Instance? = constraintsFolder:FindFirstChild(ROOT_ALIGN_NAME)
	if rootAlign and rootAlign:IsA("AlignOrientation") then
		cache.RootAlign = rootAlign
	end

	--[[ Foreign Root ]]

	local humanoidRootPart: Instance? = model:FindFirstChild("HumanoidRootPart")
	local torso: BasePart? = getTorso(model)

	-- Check if the rig has a root part and a torso
	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or not torso then
		return
	end

	-- Fall back to a root socket the rig shipped with
	if not cache.RootSocket then
		cache.RootSocket = findBallSocket(humanoidRootPart, torso)
	end

	--[[ Root Welds ]]

	for _index: number, part: BasePart in ipairs({ humanoidRootPart, torso }) do
		for _childIndex: number, child: Instance in ipairs(part:GetChildren()) do
			--[[ Checks ]]

			-- Skip non-welds
			if not child:IsA("WeldConstraint") then
				continue
			end

			--[[ Saving ]]

			-- Keep only welds that join the root part to the torso
			if (child.Part0 == humanoidRootPart and child.Part1 == torso) or (child.Part0 == torso and child.Part1 == humanoidRootPart) then
				table.insert(cache.RootWelds, child)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Joint Group

--[[
	Returns the joint group of a socket (`Shoulder`, `Knee`, …) from its attribute, or from a name like `LeftShoulderBallSocket`.
]]
--- @return string?
function Build.GetJointGroup(socket: BallSocketConstraint)
	--[[ Returning ]]

	local jointGroup: any = socket:GetAttribute(JOINT_ATTRIBUTE)

	-- Use the joint attribute when it is set
	if type(jointGroup) == "string" then
		return jointGroup
	end

	-- Fall back to the socket name
	local jointName: string = string.gsub(socket.Name, "BallSocket.*$", "")

	return string.match(jointName, "(%u%l*)$")
end

--%%%%%%%%%%%%%%%%%%%% Has Constraints

--[[
	Returns whether the model already has the generated ragdoll folder.
]]
--- @return boolean
function Build.HasConstraints(model: Model)
	return model:FindFirstChild(CONSTRAINTS_FOLDER_NAME) ~= nil
end

return Build
