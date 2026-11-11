--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

-- The animation a skin shown still is held in (Pose): its first frame puts the shell on the back and the hands in front
local STILL_ANIMATION: string = "Idle"

-- Seconds a track fades in or out, and how close to its end the shell hide stops and holds
local FADE_TIME: number = 0.15
local HIDE_HOLD_MARGIN: number = 0.08

-- The shell hide snaps in: how fast it plays, and the short blend it starts with
local HIDE_PLAY_SPEED: number = 1.8
local HIDE_FADE_TIME: number = 0.05

-- How far a weapon pitches from level, either way
local MAX_PITCH: number = math.rad(90)

--[[ Emotes ]]

-- Seconds an emote's stand-in motion blends in and out
local EMOTE_BLEND_IN: number = 0.18
local EMOTE_BLEND_OUT: number = 0.25

-- How long the backflip's flip takes, and how high it hops (studs)
local FLIP_SECONDS: number = 0.9
local FLIP_HEIGHT: number = 2.2

--[[ Walk ]]

-- The Walk animation plays this much faster than it was made, so its steps read
local WALK_PLAY_SPEED: number = 1.5

--[[
	Walking also moves the snail in code, over its animations and a held weapon's pose (which hides Walk's body): two
	steps per cycle, each lifting and rocking the body, the shell swaying side to side, the tail and eyestalks swinging
	after it. It blends in and out over WALK_BLEND_TIME
]]
local WALK_CYCLES_PER_SECOND: number = 1.4
local WALK_BLEND_TIME: number = 0.15

-- How far each step lifts the body (studs) and rocks it forward and back
local WALK_BOB: number = 0.35
local WALK_LEAN: number = math.rad(6)

-- How far the shell sways side to side, and lifts after the body (studs)
local WALK_SHELL_SWAY: number = math.rad(8)
local WALK_SHELL_BOB: number = 0.2

-- How far each tail bone and eyestalk swings, and how far each lags the one before (radians of the step)
local WALK_TAIL_SWING: number = math.rad(14)
local WALK_EYE_SWING: number = math.rad(14)
local WALK_LAG: number = 0.7

-- The rig's shell, tail and eyestalk bones (the stalks' bases, then their middles)
local SHELL: string = "Bone.013"

--- @type { string }
local TAIL = { "Bone.009", "Bone.010", "Bone.011" }

--- @type { string }
local EYESTALKS = { "Bone.005.L", "Bone.005.R", "Bone.006.L", "Bone.006.R" }

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
	Plays a skin's body motion: "Idle" or "Walk" (looped), or "Hidden", which snaps the snail into its shell (at
	HIDE_PLAY_SPEED) and holds it there; leaving "Hidden" brings it back out.
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
		SnailRig._stop(rig, "Idle", HIDE_FADE_TIME)
		SnailRig._stop(rig, "Walk", HIDE_FADE_TIME)
		local hide: AnimationTrack? = SnailRig._play(rig, "Hide", true, HIDE_FADE_TIME)
		if hide then
			hide:AdjustSpeed(HIDE_PLAY_SPEED)
		end
		return
	end

	--[[ Showing ]]

	if leaving == "Hidden" then
		SnailRig._stop(rig, "Hide", 0)
		SnailRig._play(rig, "Show", false, 0)
	end

	--[[ Moving ]]

	SnailRig._stop(rig, if motion == "Idle" then "Walk" else "Idle")
	local track: AnimationTrack? = SnailRig._play(rig, motion, true)
	if track and motion == "Walk" then
		track:AdjustSpeed(WALK_PLAY_SPEED)
	end
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

--%%%%%%%%%%%%%%%%%%%% Emote

--[[
	Plays an emote on a skin for a number of seconds: its animation from `Assets/Snails/Animations` (named after the
	emote) once it exists, until then a stand-in motion of the body and hands made here, toward the camera.
]]
function SnailRig.Emote(skin: Model, emoteId: string, seconds: number)
	--[[ Data ]]

	local rig = SnailRig._getRig(skin) --- @type SnailRig_Rig?
	if not rig then
		return
	end

	--[[ Animation ]]

	animationsFolder = animationsFolder or I.Dirs.Assets:FindFirstChild("Snails"):FindFirstChild("Animations")
	if animationsFolder:FindFirstChild(emoteId) then
		local track: AnimationTrack? = SnailRig._play(rig, emoteId, false)
		if track then
			return
		end
	end

	--[[ Stand-in ]]

	-- shortcut: a motion made in code stands in for each emote until its animation exists (named after the emote)
	rig.Emote = (string.gsub(emoteId, "^Emote_", ""))
	rig.EmoteStart = os.clock()
	rig.EmoteUntil = rig.EmoteStart + seconds
end

--%%%%%%%%%%%%%%%%%%%% Pose

--[[
	Holds a skin still in the first frame of one of its animations (STILL_ANIMATION unless named) by setting its bones'
	Transforms, with no Animator: for a skin shown without being animated, as in a ViewportFrame, whose rest pose has
	its shell above its back and its hands held out.
]]
function SnailRig.Pose(skin: Model, name: string?)
	--[[ Data ]]

	animationsFolder = animationsFolder or I.Dirs.Assets:FindFirstChild("Snails"):FindFirstChild("Animations")
	local animation: Instance? = animationsFolder:FindFirstChild(name or STILL_ANIMATION)
	local keyframes: KeyframeSequence? = animation and animation:FindFirstChildOfClass("KeyframeSequence")
	local root: BasePart? = skin.PrimaryPart

	-- The first frame (GetKeyframes isn't in time order)
	local first: Keyframe? = nil
	for _index: number, keyframe: Keyframe in ipairs(if keyframes then keyframes:GetKeyframes() else {}) do
		if not first or keyframe.Time < first.Time then
			first = keyframe
		end
	end

	--[[ Checks ]]

	-- Check if the animation has a frame and the skin its bones
	if not first or not root then
		warn(`[{_localName}]: Can't pose ({skin.Name}) in ({name or STILL_ANIMATION}): no keyframes or no PrimaryPart!`)
		return
	end

	--[[ Local Variables ]]

	-- Each bone's pose in the first frame
	local poses = {} --- @type { [string]: CFrame }
	for _index: number, pose: Instance in ipairs(first:GetDescendants()) do
		if pose:IsA("Pose") then
			poses[pose.Name] = pose.CFrame
		end
	end

	-- An Animator scales the poses' moves with the model; a Transform set here isn't, so it's scaled the same
	local scale: number = skin:GetScale()

	--[[ Applying ]]

	for _index: number, bone: Instance in ipairs(root:GetDescendants()) do
		local pose: CFrame? = poses[bone.Name]
		if bone:IsA("Bone") and pose then
			bone.Transform = pose.Rotation + pose.Position * scale
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Runs after the animations each frame, before physics: holds the shell hide on its last frame, ends shots, moves a
	walking snail's body, shell, tail and eyestalks, and moves each held weapon and its hands to the camera's side of
	the snail and along its aim.
]]
function SnailRig._step(deltaTime: number)
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

		-- Before the aim, which builds on where the walk put the hands and the weapon
		SnailRig._walk(rig, now, deltaTime)
		if rig.Pose then
			SnailRig._aimHands(rig, camera)
		end
		if rig.Emote then
			SnailRig._emote(rig, now, camera)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Emote Step

--[[
	Moves a skin through its emote's stand-in for this frame, on top of its animations: the body hops, sways, leans or
	flips about its base, and the hands rise and move, all toward the camera so every screen sees it the same way.
]]
--- @param rig SnailRig_Rig
function SnailRig._emote(rig, now: number, camera: Vector3)
	--[[ Restoring ]]

	-- A bone no animation moves still holds last frame's stand-in: take it off first, so it never builds up
	--- @param applied SnailRig_EmoteTransform
	for bone: Bone, applied in pairs(rig.EmoteBones) do
		if bone.Transform == applied.Set then
			bone.Transform = applied.Base
		end
	end
	table.clear(rig.EmoteBones)

	--[[ Checks ]]

	-- Check if the emote is over
	local t: number = now - rig.EmoteStart
	local length: number = rig.EmoteUntil - rig.EmoteStart
	if t >= length then
		rig.Emote = nil
		return
	end

	--[[ Local Variables ]]

	local weight: number = math.clamp(math.min(t / EMOTE_BLEND_IN, (length - t) / EMOTE_BLEND_OUT), 0, 1)
	local frame: CFrame = rig.Root.CFrame
	local up: Vector3 = Vector3.yAxis
	local flat: Vector3 = (camera - frame.Position) * Vector3.new(1, 0, 1)
	local toCamera: Vector3 = if flat.Magnitude > 0.01 then flat.Unit else frame.LookVector
	local side: Vector3 = up:Cross(toCamera).Unit

	-- The hand nearer the camera (and to the screen's right) leads one-handed emotes
	local lead: string = HANDS[1]
	local leadScore: number = -math.huge
	for _index: number, name: string in ipairs(HANDS) do
		local offset: Vector3 = rig.Hands[name].TransformedWorldCFrame.Position - frame.Position
		local score: number = offset:Dot(toCamera) + offset:Dot(side) * 0.5
		if score > leadScore then
			lead, leadScore = name, score
		end
	end
	local other: string = if lead == HANDS[1] then HANDS[2] else HANDS[1]

	--[[ Motion ]]

	local hop: number = 0
	local sway: number = 0
	local lean: number = 0
	local flip: number = 0
	local hands = {} --- @type { [string]: Vector3 }
	local beat: number = math.sin(t * math.pi * 3.2)
	if rig.Emote == "Wave" then
		sway = math.rad(-6)
		hands[lead] = up * 1.3 + side * (0.3 + math.sin(t * 14) * 0.35)
	elseif rig.Emote == "ThumbsUp" then
		hop = if t < 0.35 then math.sin(t / 0.35 * math.pi) * 0.4 else 0
		lean = math.rad(-5)
		hands[lead] = up * 0.9 + toCamera * 0.6
	elseif rig.Emote == "Laugh" then
		sway = math.sin(t * 18) * math.rad(7)
		hop = math.abs(math.sin(t * 9)) * 0.25
		hands[lead] = up * 0.3 + side * math.sin(t * 18) * 0.12
		hands[other] = up * 0.3 - side * math.sin(t * 18) * 0.12
	elseif rig.Emote == "Dance" then
		sway = beat * math.rad(14)
		hop = math.abs(beat) * 0.45
		hands[lead] = up * (if beat > 0 then 1.2 else 0.2)
		hands[other] = up * (if beat > 0 then 0.2 else 1.2)
	elseif rig.Emote == "Flex" then
		lean = math.rad(-8)
		local pump: number = (math.sin(t * math.pi * 4) + 1) * 0.08
		hands[lead] = up * 1.2 + side * (0.4 - pump)
		hands[other] = up * 1.2 - side * (0.4 - pump)
	elseif rig.Emote == "Taunt" then
		lean = math.rad(12)
		local wiggle: number = math.sin(t * 16) * 0.2
		hands[lead] = up * 1.4 - side * 0.6 + toCamera * wiggle
		hands[other] = up * 1.4 + side * 0.6 - toCamera * wiggle
	elseif rig.Emote == "Cry" then
		lean = math.rad(10)
		hop = math.abs(math.sin(t * 10)) * 0.06
		hands[lead] = up * 1.2 - side * 1.0 + toCamera * 0.3
		hands[other] = up * 1.2 + side * 1.0 + toCamera * 0.3
	elseif rig.Emote == "Backflip" then
		local k: number = math.clamp(t / FLIP_SECONDS, 0, 1)
		hop = 4 * k * (1 - k) * FLIP_HEIGHT
		flip = -2 * math.pi * (1 - (1 - k) ^ 2)
	elseif rig.Emote == "VictoryTrumpet" then
		hop = math.abs(math.sin(t * math.pi * 2.4)) * 0.35
		sway = math.sin(t * math.pi * 1.2) * math.rad(5)
		hands[lead] = up * 1.6 + side * 0.2
		hands[other] = up * 1.6 - side * 0.2
	end

	--[[ Body ]]

	local body: Bone = rig.Body
	local rest: CFrame = frame * body.CFrame
	local current: CFrame = rest * body.Transform
	local base: Vector3 = rest.Position
	local middle: Vector3 = base + up * 1.6
	local move: CFrame = CFrame.new(up * hop * weight)
		* CFrame.new(base)
		* CFrame.fromAxisAngle(toCamera, sway * weight)
		* CFrame.fromAxisAngle(side, lean * weight)
		* CFrame.new(-base)
		* CFrame.new(middle)
		* CFrame.fromAxisAngle(toCamera, flip * weight)
		* CFrame.new(-middle)
	local bodyBase: CFrame = body.Transform
	body.Transform = rest:Inverse() * move * current
	rig.EmoteBones[body] = { Base = bodyBase, Set = body.Transform }

	--[[ Hands ]]

	for name: string, offset: Vector3 in pairs(hands) do
		local bone: Bone = rig.Hands[name]
		local parent: Bone = bone.Parent
		local handRest: CFrame = parent.TransformedWorldCFrame * bone.CFrame
		local handBase: CFrame = bone.Transform
		bone.Transform = handRest:Inverse() * CFrame.new(offset * weight) * handRest * handBase
		rig.EmoteBones[bone] = { Base = handBase, Set = bone.Transform }
	end
end

--%%%%%%%%%%%%%%%%%%%% Walk Step

--[[
	Moves a walking skin for this frame, on top of its animations and a held pose: each step lifts the body and rocks it
	about its base (the held weapon's Handle with it), the shell sways side to side and lifts after it, and the tail
	and eyestalks swing, each bone lagging the one before. Blends in and out with the walk.
]]
--- @param rig SnailRig_Rig
function SnailRig._walk(rig, now: number, deltaTime: number)
	--[[ Restoring ]]

	-- A joint no animation moves still holds last frame's walk: take it off first, so it never builds up
	--- @param applied SnailRig_EmoteTransform
	for joint: Bone | Motor6D, applied in pairs(rig.WalkJoints) do
		if joint.Transform == applied.Set then
			joint.Transform = applied.Base
		end
	end
	table.clear(rig.WalkJoints)

	--[[ Blending ]]

	local step: number = deltaTime / WALK_BLEND_TIME
	rig.WalkWeight = math.clamp(rig.WalkWeight + (if rig.Motion == "Walk" then step else -step), 0, 1)

	--[[ Checks ]]

	-- Check if the snail walks, or is still settling from it
	if rig.WalkWeight <= 0 then
		return
	end

	--[[ Local Variables ]]

	local weight: number = rig.WalkWeight
	local cycle: number = now * WALK_CYCLES_PER_SECOND * 2 * math.pi
	local frame: CFrame = rig.Root.CFrame
	local up: Vector3 = Vector3.yAxis
	local forward: Vector3 = frame.LookVector
	local side: Vector3 = frame.RightVector

	--[[ Body ]]

	local base: Vector3 = (frame * rig.Body.CFrame).Position
	local lift: number = (0.5 - 0.5 * math.cos(cycle * 2)) * WALK_BOB * weight
	local lean: number = math.sin(cycle * 2 - 0.6) * WALK_LEAN * weight
	local move: CFrame = CFrame.new(up * lift) * CFrame.new(base) * CFrame.fromAxisAngle(side, lean) * CFrame.new(-base)
	SnailRig._moveJoint(rig, rig.Body, frame * rig.Body.CFrame, move)
	SnailRig._moveJoint(rig, rig.Motor, rig.Motor.Part0.CFrame * rig.Motor.C0, move)

	--[[ Shell ]]

	local shell: Bone? = rig.Bones[SHELL]
	if shell then
		local rest: CFrame = shell.Parent.TransformedWorldCFrame * shell.CFrame
		local pivot: Vector3 = (rest * shell.Transform).Position
		local sway: number = math.sin(cycle) * WALK_SHELL_SWAY * weight
		local shellLift: number = (0.5 - 0.5 * math.cos(cycle * 2 - WALK_LAG)) * WALK_SHELL_BOB * weight
		SnailRig._moveJoint(rig, shell, rest, CFrame.new(up * shellLift + pivot) * CFrame.fromAxisAngle(forward, sway) * CFrame.new(-pivot))
	end

	--[[ Tail And Eyestalks ]]

	-- Each swings about the snail's side, a lag behind the bone before it
	for index: number, name: string in ipairs(TAIL) do
		SnailRig._swingBone(rig, rig.Bones[name], side, math.sin(cycle * 2 - index * WALK_LAG) * WALK_TAIL_SWING * weight)
	end
	for index: number, name: string in ipairs(EYESTALKS) do
		local lag: number = if index > 2 then 2 else 1
		SnailRig._swingBone(rig, rig.Bones[name], side, math.sin(cycle * 2 - (lag + 1) * WALK_LAG) * WALK_EYE_SWING * weight)
	end
end

--%%%%%%%%%%%%%%%%%%%% Swing Bone

--[[
	Turns a bone about an axis through its own joint for this frame's walk, carrying its children; a missing bone (a
	skin without it) is skipped.
]]
--- @param rig SnailRig_Rig
function SnailRig._swingBone(rig, bone: Bone?, axis: Vector3, angle: number)
	--[[ Checks ]]

	-- Check if the skin has the bone
	if not bone then
		return
	end

	--[[ Local Variables ]]

	local rest: CFrame = bone.Parent.TransformedWorldCFrame * bone.CFrame
	local pivot: Vector3 = (rest * bone.Transform).Position

	--[[ Applying ]]

	SnailRig._moveJoint(rig, bone, rest, CFrame.new(pivot) * CFrame.fromAxisAngle(axis, angle) * CFrame.new(-pivot))
end

--%%%%%%%%%%%%%%%%%%%% Move Joint

--[[
	Moves a bone or Motor6D by a world move on top of its animated Transform, from its rest (its parent's frame times its
	own offset), and keeps both Transforms so the next frame can take the move off again.
]]
--- @param rig SnailRig_Rig
function SnailRig._moveJoint(rig, joint: Bone | Motor6D, rest: CFrame, move: CFrame)
	--[[ Local Variables ]]

	local before: CFrame = joint.Transform

	--[[ Applying ]]

	joint.Transform = rest:Inverse() * move * rest * before
	rig.WalkJoints[joint] = { Base = before, Set = joint.Transform }
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
	local body: Bone? = root and root:FindFirstChildOfClass("Bone")
	local hands = {} --- @type { [string]: Bone }
	local bones = {} --- @type { [string]: Bone }
	if root then
		for _index: number, bone: Instance in ipairs(root:GetDescendants()) do
			if bone:IsA("Bone") then
				bones[bone.Name] = bone
			end
			if bone:IsA("Bone") and table.find(HANDS, bone.Name) then
				hands[bone.Name] = bone
			end
		end
	end

	--[[ Checks ]]

	-- Check if the skin is rigged
	if not root or not animator or not motor or not motor:IsA("Motor6D") or not body or not hands[HANDS[1]] or not hands[HANDS[2]] then
		return nil
	end

	--[[ Building ]]

	--- @type SnailRig_Rig
	local rig = {
		Root = root,
		Animator = animator,
		Motor = motor,
		Handle = motor.Part1,
		Body = body,
		Hands = hands,
		Bones = bones,
		Tracks = {},
		EmoteBones = {},
		WalkJoints = {},
		WalkWeight = 0,
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
