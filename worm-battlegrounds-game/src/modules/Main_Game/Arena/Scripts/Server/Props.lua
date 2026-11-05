--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Loader = require(script.Parent:FindFirstChild("Loader")) --- @type Arena_Server_Loader

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The loaded map's props still standing (Decor items with `Arena_Prop`)
local standing = {} --- @type { PVInstance }

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

--- @class Arena_Server_Props
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Collect

--[[
	Takes the loaded map's props: every Model or part under its Decor with the `Arena_Prop` attribute.
]]
function Module.Collect()
	--[[ Data ]]

	local decor: Instance? = Loader.GetArenaFolder():FindFirstChild("Decor")

	--[[ Collecting ]]

	standing = {}
	for _index: number, item: Instance in ipairs(if decor then decor:GetDescendants() else {}) do
		if item:GetAttribute("Arena_Prop") and (item:IsA("Model") or item:IsA("BasePart")) then
			table.insert(standing, item)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	After a blast: knocks away every standing prop the blast reaches, and drops every one whose ground is gone.
]]
function Module.Update(center: Vector3, radius: number)
	--[[ Checking ]]

	for index: number = #standing, 1, -1 do
		local prop: PVInstance = standing[index]
		local boxCFrame: CFrame
		local boxSize: Vector3
		boxCFrame, boxSize = Module._getBox(prop)

		-- The blast's reach to the prop's box, on the plane
		local offset: Vector3 = boxCFrame.Position - center
		local gap: Vector2 = Vector2.new(math.max(math.abs(offset.X) - boxSize.X / 2, 0), math.max(math.abs(offset.Y) - boxSize.Y / 2, 0))
		local hit: boolean = gap.Magnitude <= radius

		if hit or not Module._isSupported(boxCFrame, boxSize) then
			-- A hit prop flies away from the blast and up
			local away: Vector3 = Vector3.new(offset.X, offset.Y, 0)
			local direction: Vector3 = if away.Magnitude > 0.01 then away.Unit else Vector3.yAxis
			table.remove(standing, index)
			Module._release(prop, if hit then (direction + Vector3.yAxis * 0.5) * _settings.PROP_KNOCK_SPEED else nil)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Welds a prop together and lets it fall with the server's physics (thrown at `push` when a blast hit it), then fades
	it out and removes it.
]]
function Module._release(prop: PVInstance, push: Vector3?)
	--[[ Local Variables ]]

	local parts = {} --- @type { BasePart }
	for _index: number, item: Instance in ipairs(if prop:IsA("BasePart") then { prop } else prop:GetDescendants()) do
		if item:IsA("BasePart") then
			table.insert(parts, item)
		end
	end
	local root: BasePart? = parts[1]
	if not root then
		return
	end

	--[[ Welding ]]

	for index: number, part: BasePart in ipairs(parts) do
		if index > 1 then
			I.Create("WeldConstraint")({
				Name = "PropWeld",
				Part0 = root,
				Part1 = part,
				Parent = part,
			})
		end
	end

	--[[ Releasing ]]

	for _index: number, part: BasePart in ipairs(parts) do
		part.Anchored = false
		part.CanCollide = true
	end
	root:SetNetworkOwner(nil)
	if push then
		root.AssemblyLinearVelocity = push
		root.AssemblyAngularVelocity = Vector3.new(0, 0, (math.random() - 0.5) * 2 * _settings.PROP_KNOCK_SPIN)
	end

	--[[ Fading ]]

	task.delay(_settings.PROP_FADE_DELAY, function()
		for _index: number, part: BasePart in ipairs(parts) do
			local Fade_TweenGoal = { Transparency = 1 }
			local Fade_Tween: Tween = I.S.TweenService:Create(part, _settings.PROP_FADE_TWEENINFO, Fade_TweenGoal)
			Fade_Tween:Play()
		end
		task.wait(_settings.PROP_FADE_TWEENINFO.Time)
		prop:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Box

--[[
	Returns a prop's bounding box.
]]
--- @return CFrame
--- @return Vector3
function Module._getBox(prop: PVInstance)
	--[[ Returning ]]

	if prop:IsA("Model") then
		return prop:GetBoundingBox()
	end
	return prop.CFrame, prop.Size
end

--%%%%%%%%%%%%%%%%%%%% Is Supported

--[[
	Returns whether anchored terrain is right under the middle of a prop's base, within PROP_SUPPORT_DEPTH.
]]
--- @return boolean
function Module._isSupported(boxCFrame: CFrame, boxSize: Vector3)
	--[[ Local Variables ]]

	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Loader.GetTerrain() }
	local base: Vector3 = boxCFrame.Position - Vector3.new(0, boxSize.Y / 2 - 0.5, 0)

	--[[ Returning ]]

	local hit: RaycastResult? = I.S.Workspace:Raycast(base, Vector3.new(0, -(_settings.PROP_SUPPORT_DEPTH + 0.5), 0), params)
	return hit ~= nil and hit.Instance.Anchored
end

return Module
