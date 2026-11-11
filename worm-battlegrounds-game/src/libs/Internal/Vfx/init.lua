--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName = "Vfx"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

--- @type Ume
local I

-- The prefabs' folder, `Assets/Vfx`, found on first use
local prefabsFolder: Instance?

--[[ Timing ]]

-- How long an emitter without an EmitCount (a stream, like the healing crosses) runs when played
local STREAM_SECONDS: number = 1

-- Kept past the last particle's life before the copy goes
local CLEANUP_MARGIN: number = 0.25

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

--- @class Ume_Library_Vfx : Ume_Library
local Vfx = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Vfx._injectUme(umeInstance)
	--[[ Saving ]]

	I = umeInstance

	--[[ Assigning ]]

	I.Vfx = Vfx --- @type Ume_Library_Vfx
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays an effect once: a copy of its prefab, scaled, at a CFrame in a folder, which fires every emitter and goes once
	its last particle is gone. Returns the copy, nil when the prefab is missing.
]]
--- @return BasePart?
function Vfx.Play(name: string, cframe: CFrame, parent: Instance, scale: number?)
	--[[ Data ]]

	local prefab: BasePart? = Vfx.Get(name)
	if not prefab then
		return nil
	end

	--[[ Building ]]

	local copy: BasePart = prefab:Clone()
	copy.Name = name
	copy.Anchored = true
	copy.CFrame = cframe * prefab.CFrame.Rotation
	copy.Parent = parent

	--[[ Emitting ]]

	local seconds: number = Vfx.Emit(copy, scale)

	--[[ Cleaning ]]

	task.delay(seconds + CLEANUP_MARGIN, function()
		copy:Destroy()
	end)

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%% Emit

--[[
	Fires every ParticleEmitter under an instance by its attributes: after `EmitDelay` seconds, `EmitCount` particles,
	or a stream for `EmitDuration` seconds; one without an `EmitCount` streams for STREAM_SECONDS. A scale other than 1
	resizes the particles, their speeds and the attachments' offsets first. Returns how long until the last particle
	is gone.
]]
--- @return number
function Vfx.Emit(root: Instance, scale: number?)
	--[[ Local Variables ]]

	local factor: number = scale or 1
	local longest: number = 0

	--[[ Scaling ]]

	if factor ~= 1 then
		Vfx._scale(root, factor)
	end

	--[[ Emitting ]]

	for _index: number, emitter: Instance in ipairs(root:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end
		local delay: number = emitter:GetAttribute("EmitDelay") or 0
		local count: number? = emitter:GetAttribute("EmitCount")
		local duration: number = emitter:GetAttribute("EmitDuration") or 0
		if not count then
			duration = STREAM_SECONDS
		end
		longest = math.max(longest, delay + duration + emitter.Lifetime.Max)

		task.delay(delay, function()
			if duration > 0 then
				emitter.Enabled = true
				task.wait(duration)
				emitter.Enabled = false
			else
				emitter:Emit(count)
			end
		end)
	end

	--[[ Returning ]]

	return longest
end

--%%%%%%%%%%%%%%%%%%%% Add Trail

--[[
	Puts a trail prefab's Trails on a part (a prefab may layer several): their attachments at the same offsets from the
	part as from the prefab's part, each Trail between its two, and the prefab's other attachments with what they hold
	(an exhaust's emitters, left as the prefab has them). Returns the Trails, none when the prefab is missing.
]]
--- @return { Trail }
function Vfx.AddTrail(name: string, part: BasePart)
	--[[ Data ]]

	local prefab: BasePart? = Vfx.Get(name)
	if not prefab then
		return {}
	end

	--[[ Local Variables ]]

	local trails = {} --- @type { Trail }
	local copies = {} --- @type { [Attachment]: Attachment }

	--[[ Building ]]

	for _index: number, source: Instance in ipairs(prefab:GetDescendants()) do
		if not source:IsA("Trail") or not source.Attachment0 or not source.Attachment1 then
			continue
		end
		local trail: Trail = source:Clone()
		for _index2: number, attachment: Attachment in ipairs({ source.Attachment0, source.Attachment1 }) do
			if not copies[attachment] then
				copies[attachment] = attachment:Clone()
				copies[attachment].Parent = part
			end
		end
		trail.Attachment0 = copies[source.Attachment0]
		trail.Attachment1 = copies[source.Attachment1]
		trail.Parent = part
		table.insert(trails, trail)
	end
	for _index: number, attachment: Instance in ipairs(prefab:GetChildren()) do
		if attachment:IsA("Attachment") and not copies[attachment] then
			attachment:Clone().Parent = part
		end
	end

	--[[ Checks ]]

	-- Check if the prefab had a trail between two attachments
	if #trails == 0 then
		warn(`[{_localName}::{script.Name}]: Prefab ({name}) has no Trail between two attachments!`)
	end

	--[[ Returning ]]

	return trails
end

--%%%%%%%%%%%%%%%%%%%% Scale

--[[
	Resizes an effect copy: its part (emitters on it spread over it), its emitters' particle sizes, speeds and pulls,
	and its attachments' offsets.
]]
function Vfx._scale(root: Instance, factor: number)
	--[[ Scaling ]]

	if root:IsA("BasePart") then
		root.Size *= factor
	end
	for _index: number, descendant: Instance in ipairs(root:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			--- @type { NumberSequenceKeypoint }
			local keypoints = {}
			for _index2: number, keypoint: NumberSequenceKeypoint in ipairs(descendant.Size.Keypoints) do
				table.insert(keypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * factor, keypoint.Envelope * factor))
			end
			descendant.Size = NumberSequence.new(keypoints)
			descendant.Speed = NumberRange.new(descendant.Speed.Min * factor, descendant.Speed.Max * factor)
			descendant.Acceleration *= factor
		elseif descendant:IsA("Attachment") then
			descendant.Position *= factor
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns an effect's prefab, `PREFAB | <name>` in `Assets/Vfx`; warns and returns nil when it's missing.
]]
--- @return BasePart?
function Vfx.Get(name: string)
	--[[ Data ]]

	prefabsFolder = prefabsFolder or I.Dirs.Assets:FindFirstChild("Vfx")
	local prefab: Instance? = prefabsFolder and prefabsFolder:FindFirstChild(`PREFAB | {name}`)

	--[[ Checks ]]

	-- Check if the prefab exists
	if not prefab or not prefab:IsA("BasePart") then
		warn(`[{_localName}::{script.Name}]: Effect ({name}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return prefab
end

return Vfx
