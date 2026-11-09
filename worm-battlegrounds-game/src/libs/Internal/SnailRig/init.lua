--[[
	Created By: 	Nari
]]

local _localName = "SnailRig"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

--- @type Ume
local I

-- The animations' folder, `Assets/Snails/Animations`, found on first use
local animationsFolder: Instance?

-- Every skin animated on this side, and the frame step that aims their hands
local rigs = {} --- @type { [Model]: SnailRig_Rig }
local stepConnection: RBXScriptConnection?

-- Animations loaded for Studio from their keyframes, by name, and names already warned about
local studioAnimations = {} --- @type { [string]: Animation }
local warned = {} --- @type { [string]: boolean }

--[[ Rig ]]

-- The hand bones of the studio's snail rig (`.L` is the hand on the snail's right, which holds the weapon)
local HANDS = { "Bone.014.L", "Bone.014.R" } --- @type { string }

-- The pose an item without its own `HoldPose` is held in, and the hands that follow the aim in each pose
local DEFAULT_POSE: string = "Gun"

--- @type { [string]: { string } }
local AIM_HANDS = {
	Gun = { "Bone.014.L" },
	MiniGun = HANDS,
	Bazooka = HANDS,
	ShotGun = HANDS,
}

--[[ Motion ]]

-- Each motion's track priority: holding a weapon plays over walking, hiding over both
--- @type { [string]: Enum.AnimationPriority }
local PRIORITIES = {
	Idle = Enum.AnimationPriority.Idle,
	Walk = Enum.AnimationPriority.Movement,
	Hide = Enum.AnimationPriority.Action2,
	Show = Enum.AnimationPriority.Action2,
}

-- Seconds a track fades in or out, and how close to its end the shell hide stops and holds
local FADE_TIME: number = 0.15
local HIDE_HOLD_MARGIN: number = 0.08

-- How far a weapon pitches from level, either way
local MAX_PITCH: number = math.rad(90)

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

--- @class Ume_Library_SnailRig : Ume_Library
local SnailRig = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function SnailRig._injectUme(umeInstance)
	--[[ Saving ]]

	I = umeInstance

	--[[ Assigning ]]

	I.SnailRig = SnailRig --- @type Ume_Library_SnailRig
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Motion

--[[
	Plays a skin's body motion: "Idle" or "Walk" (looped), or "Hidden", which pulls the snail into its shell and holds it
	there; leaving "Hidden" brings it back out.
]]
function SnailRig.SetMotion(skin: Model, motion: "Idle" | "Walk" | "Hidden")
	--[[ Data ]]

	--- @type SnailRig_Rig?
	local rig = SnailRig._getRig(skin)

	--[[ Checks ]]

	-- Check if the skin is rigged and the motion changes
	if not rig or rig.Motion == motion then
		return
	end

	--[[ Local Variables ]]

	local leaving: string = rig.Motion
	rig.Motion = motion

	--[[ Hiding ]]

	if motion == "Hidden" then
		SnailRig._stop(rig, "Idle")
		SnailRig._stop(rig, "Walk")
		SnailRig._play(rig, "Hide", true)
		return
	end

	--[[ Showing ]]

	if leaving == "Hidden" then
		SnailRig._stop(rig, "Hide", 0)
		SnailRig._play(rig, "Show", false, 0)
	end

	--[[ Moving ]]

	SnailRig._stop(rig, if motion == "Idle" then "Walk" else "Idle")
	SnailRig._play(rig, motion, true)
end

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Holds an item in a skin's hands: plays its row's `HoldPose` (the Gun pose for an item without one), paused on its
	first frame, and joins the weapon model to the skin's `Handle` at the model's `Grip` attachment. nil lets go of what
	it held (the caller destroys the old model).
]]
function SnailRig.Hold(skin: Model, itemId: string?, weapon: Model?)
	--[[ Data ]]

	--- @type SnailRig_Rig?
	local rig = SnailRig._getRig(skin)

	--[[ Checks ]]

	-- Check if the skin is rigged
	if not rig then
		return
	end

	--[[ Releasing ]]

	if rig.Pose then
		SnailRig._stop(rig, rig.Pose)
	end
	if rig.Joint then
		rig.Joint:Destroy()
	end
	rig.Pose = nil
	rig.Joint = nil
	rig.ShootUntil = nil

	--[[ Checks ]]

	-- Check if there's something new to hold
	if not itemId then
		return
	end

	--[[ Posing ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData?
	local pose: string = row and row.HoldPose or DEFAULT_POSE
	local track: AnimationTrack? = SnailRig._play(rig, pose, true)
	if track then
		track:AdjustSpeed(0)
		track.TimePosition = 0
	end
	rig.Pose = pose

	--[[ Joining ]]

	if weapon and weapon.PrimaryPart then
		for _index: number, part: Instance in ipairs(weapon:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.Massless = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
			end
		end
		local grip: Attachment? = weapon.PrimaryPart:FindFirstChild("Grip")
		rig.Joint = I.Create("Weld")({
			Name = "Grip",
			Part0 = rig.Handle,
			Part1 = weapon.PrimaryPart,
			C1 = if grip then grip.CFrame else CFrame.identity,
			Parent = weapon.PrimaryPart,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Aim

--[[
	Points a skin's held weapon along an angle (radians, 0 is +X, counterclockwise on the arena's plane), pitching the
	hands that hold it with it; nil holds it level.
]]
function SnailRig.SetAim(skin: Model, angle: number?)
	--[[ Data ]]

	--- @type SnailRig_Rig?
	local rig = rigs[skin]

	--[[ Saving ]]

	if rig then
		rig.Aim = angle
	end
end

--%%%%%%%%%%%%%%%%%%%% Shoot

--[[
	Plays the held pose's shot (its recoil) from the start, for at least a number of seconds (a burst), then pauses on
	its first frame again. Returns how many seconds it plays, 0 when nothing is held.
]]
--- @return number
function SnailRig.Shoot(skin: Model, seconds: number?)
	--[[ Data ]]

	local rig = rigs[skin] --- @type SnailRig_Rig?
	local track: AnimationTrack? = rig and rig.Pose and rig.Tracks[rig.Pose]

	--[[ Checks ]]

	-- Check if a pose is held
	if not rig or not track then
		return 0
	end

	--[[ Playing ]]

	local length: number = math.max(seconds or 0, track.Length)
	track.TimePosition = 0
	track:AdjustSpeed(1)
	rig.ShootUntil = os.clock() + length

	--[[ Returning ]]

	return length
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Runs after the animations each frame, before physics: holds the shell hide on its last frame, ends shots, and moves
	each held weapon and its hands to the camera's side of the snail and along its aim.
]]
function SnailRig._step()
	--[[ Local Variables ]]

	local now: number = os.clock()
	local camera: Vector3 = I.S.Workspace.CurrentCamera.CFrame.Position

	--[[ Stepping ]]

	--- @param rig SnailRig_Rig
	for _skin: Model, rig in pairs(rigs) do
		local hide: AnimationTrack? = rig.Tracks["Hide"]
		if rig.Motion == "Hidden" and hide and hide.Length > 0 and hide.TimePosition >= hide.Length - HIDE_HOLD_MARGIN then
			hide:AdjustSpeed(0)
		end
		if rig.ShootUntil and now >= rig.ShootUntil then
			rig.ShootUntil = nil
			local track: AnimationTrack? = rig.Pose and rig.Tracks[rig.Pose]
			if track then
				track.TimePosition = 0
				track:AdjustSpeed(0)
			end
		end
		if rig.Pose then
			SnailRig._aimHands(rig, camera)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Aim Hands

--[[
	Moves a held weapon (its Handle) and the hands to the camera's side of the snail, mirrored across its middle, then
	pitches the weapon and the pose's aiming hands about the Handle toward the aim.
]]
--- @param rig SnailRig_Rig
function SnailRig._aimHands(rig, camera: Vector3)
	--[[ Local Variables ]]

	local frame: CFrame = rig.Root.CFrame
	local motor: Motor6D = rig.Motor
	local base: CFrame = motor.Part0.CFrame * motor.C0
	local handle: CFrame = base * motor.Transform

	-- The studio holds weapons in the snail's right hand; a snail facing the other way swaps its hands over
	local mirror: boolean = frame.RightVector:Dot(camera - frame.Position) < 0
	local shift: Vector3 = if mirror then frame.RightVector * (-2 * frame:PointToObjectSpace(handle.Position).X) else Vector3.zero

	-- The weapon's pitch from level toward the aim, in the snail's own up and forward
	local pitch: number = 0
	if rig.Aim then
		local direction: Vector3 = Vector3.new(math.cos(rig.Aim), math.sin(rig.Aim), 0)
		pitch = math.clamp(math.atan2(direction:Dot(frame.UpVector), direction:Dot(frame.LookVector)), -MAX_PITCH, MAX_PITCH)
	end
	local pivot: Vector3 = handle.Position + shift
	local turn: CFrame = CFrame.new(pivot) * CFrame.fromAxisAngle(frame.RightVector, pitch) * CFrame.new(-pivot)

	--[[ Applying ]]

	motor.Transform = base:Inverse() * turn * CFrame.new(shift) * handle
	for _index: number, name: string in ipairs(HANDS) do
		local bone: Bone = rig.Hands[name]
		local parent: Bone = bone.Parent
		local rest: CFrame = parent.TransformedWorldCFrame * bone.CFrame
		local current: CFrame = rest * bone.Transform
		local handShift: Vector3 = if mirror then frame.RightVector * (-2 * frame:PointToObjectSpace(current.Position).X) else Vector3.zero
		local move: CFrame = if table.find(AIM_HANDS[rig.Pose] or AIM_HANDS[DEFAULT_POSE], name) then turn * CFrame.new(handShift) else CFrame.new(handShift)
		bone.Transform = rest:Inverse() * move * current
	end
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays one of a rig's animations, loading it on first use. Returns its track, nil when the animation can't load.
]]
--- @param rig SnailRig_Rig
--- @return AnimationTrack?
function SnailRig._play(rig, name: string, looped: boolean, fadeTime: number?)
	--[[ Data ]]

	local track: AnimationTrack? = rig.Tracks[name]

	--[[ Loading ]]

	if not track then
		local animation: Animation? = SnailRig._getAnimation(name)
		if not animation then
			return nil
		end
		track = rig.Animator:LoadAnimation(animation)
		track.Priority = PRIORITIES[name] or Enum.AnimationPriority.Action
		rig.Tracks[name] = track
	end

	--[[ Playing ]]

	track.Looped = looped
	track:Play(fadeTime or FADE_TIME)
	track:AdjustSpeed(1)

	--[[ Returning ]]

	return track
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	Stops one of a rig's animations when it plays.
]]
--- @param rig SnailRig_Rig
function SnailRig._stop(rig, name: string, fadeTime: number?)
	--[[ Data ]]

	local track: AnimationTrack? = rig.Tracks[name]

	--[[ Stopping ]]

	if track and track.IsPlaying then
		track:Stop(fadeTime or FADE_TIME)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Rig

--[[
	Returns a skin's rig, set up on first use and forgotten when the skin goes. Nil when the skin has no Animator,
	Handle or hand bones (a skin made before the rig).
]]
--- @return SnailRig_Rig?
function SnailRig._getRig(skin: Model)
	--[[ Checks ]]

	-- Check if the skin is set up already
	if rigs[skin] then
		return rigs[skin]
	end

	--[[ Data ]]

	local root: BasePart? = skin.PrimaryPart
	local animator: Animator? = skin:FindFirstChildWhichIsA("Animator", true)
	local motor: Motor6D? = root and root:FindFirstChild("Handle")
	local hands = {} --- @type { [string]: Bone }
	if root then
		for _index: number, bone: Instance in ipairs(root:GetDescendants()) do
			if bone:IsA("Bone") and table.find(HANDS, bone.Name) then
				hands[bone.Name] = bone
			end
		end
	end

	--[[ Checks ]]

	-- Check if the skin is rigged
	if not root or not animator or not motor or not motor:IsA("Motor6D") or not hands[HANDS[1]] or not hands[HANDS[2]] then
		return nil
	end

	--[[ Building ]]

	--- @type SnailRig_Rig
	local rig = {
		Root = root,
		Animator = animator,
		Motor = motor,
		Handle = motor.Part1,
		Hands = hands,
		Tracks = {},
		Motion = "",
	}
	rigs[skin] = rig

	--[[ Connections ]]

	skin.Destroying:Connect(function()
		rigs[skin] = nil
	end)
	if not stepConnection then
		stepConnection = I.S.RunService.PreSimulation:Connect(SnailRig._step)
	end

	--[[ Returning ]]

	return rig
end

--%%%%%%%%%%%%%%%%%%%% Get Animation

--[[
	Returns one of the snail's animations from `Assets/Snails/Animations`: its published `AnimationId`, or in Studio,
	while it has none, its keyframes loaded for this session. Warns once and returns nil otherwise.
]]
--- @return Animation?
function SnailRig._getAnimation(name: string)
	--[[ Data ]]

	animationsFolder = animationsFolder or I.Dirs.Assets:FindFirstChild("Snails"):FindFirstChild("Animations")
	local animation: Animation? = animationsFolder:FindFirstChild(name)

	--[[ Checks ]]

	-- Check if the animation is in the place
	if not animation then
		if not warned[name] then
			warned[name] = true
			warn(`[{_localName}]: Animation ({name}) is missing from Assets/Snails/Animations!`)
		end
		return nil
	end

	-- Check if it's published
	if animation.AnimationId ~= "" then
		return animation
	end

	--[[ Studio ]]

	-- shortcut: unpublished animations play from their keyframes in Studio only; publish each and set its AnimationId for live servers
	local keyframes: KeyframeSequence? = animation:FindFirstChildOfClass("KeyframeSequence")
	if not studioAnimations[name] and keyframes and I.S.RunService:IsStudio() then
		studioAnimations[name] = I.Create("Animation")({
			Name = name,
			AnimationId = I.S.KeyframeSequenceProvider:RegisterKeyframeSequence(keyframes),
		})
	end
	if not studioAnimations[name] and not warned[name] then
		warned[name] = true
		warn(`[{_localName}]: Animation ({name}) has no AnimationId - publish it from its keyframes.`)
	end

	--[[ Returning ]]

	return studioAnimations[name]
end

return SnailRig
