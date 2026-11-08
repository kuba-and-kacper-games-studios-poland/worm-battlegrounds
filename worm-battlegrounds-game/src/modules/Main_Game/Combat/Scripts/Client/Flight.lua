--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local effectsFolder: Instance

-- Each shot in flight drawn as a model: the server's projectile part, its model, how it turns, and where it was
local flying = {} --- @type { [BasePart]: Combat_FlyingShot }
local drawing: boolean = false

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

--- @class Combat_Client_Flight
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Folders ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Connections ]]

	effectsFolder.ChildAdded:Connect(Module._addShot)
	for _index: number, child: Instance in ipairs(effectsFolder:GetChildren()) do
		Module._addShot(child)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Shot

--[[
	A projectile part arrived (named after its weapon, or a burst's shot like Snail): when it has a model, hides the
	placeholder ball and draws the model in its place until the part is gone. Bomblets keep their placeholders.
]]
function Module._addShot(child: Instance)
	--[[ Checks ]]

	-- Check if it's a projectile with a model
	if not child:IsA("BasePart") or not child:GetAttribute("Projectile") then
		return
	end
	local modelId: string = _settings.PROJECTILE_STAND_INS[child.Name] or child.Name
	local isWeapon: boolean = I.G_Arsenal.IsWeapon(child.Name)
	if not (isWeapon and I.G_Arsenal.HasModel(modelId)) and not I.G_Arsenal.HasProjectileModel(modelId) then
		return
	end

	--[[ Building ]]

	local model: Model = I.G_Arsenal.GetProjectileModel(modelId):Clone()
	local row = if isWeapon then I.G_Arsenal.Get(child.Name) else nil --- @type Arsenal_WeaponData?
	child.LocalTransparencyModifier = 1

	-- Drawn bigger so shots read from the match camera; a placed one keeps its own size
	if not row or row.Aim ~= "Feet" then
		model:ScaleTo(model:GetScale() * _settings.PROJECTILE_DRAW_SCALE)
	end
	flying[child] = {
		Model = model,
		Kind = if row then row.Kind else "Shot",
		Last = child.Position,
		Facing = if child.AssemblyLinearVelocity.X < 0 then -1 else 1,
		Heading = -Vector3.yAxis,
		Drawn = child.Position,
	}
	Module._place(child, 0)
	model.Parent = effectsFolder

	--[[ Connections ]]

	child.Destroying:Connect(function()
		Module._removeShot(child)
	end)
	child.AncestryChanged:Connect(function()
		if not child:IsDescendantOf(effectsFolder) then
			Module._removeShot(child)
		end
	end)
	-- After Shots moved the simulated shots' parts, before the camera follows them
	if not drawing then
		drawing = true
		I.S.RunService:BindToRenderStep("Combat_Flight", Enum.RenderPriority.Camera.Value - 1, Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove Shot

--[[
	Takes a shot's model away once its part is gone, and stops the loop when nothing flies.
]]
function Module._removeShot(part: BasePart)
	--[[ Checks ]]

	-- Check if the shot is still drawn
	local shot = flying[part] --- @type Combat_FlyingShot?
	if not shot then
		return
	end

	--[[ Clearing ]]

	shot.Model:Destroy()
	flying[part] = nil
	if not next(flying) and drawing then
		drawing = false
		I.S.RunService:UnbindFromRenderStep("Combat_Flight")
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves every drawn shot onto its part each frame.
]]
function Module._step(deltaTime: number)
	--[[ Placing ]]

	for part: BasePart in pairs(flying) do
		Module._place(part, deltaTime)
	end
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Puts a shot's model on its part: rockets and missiles point along their flight, thrown and rolled weapons tumble
	with the part, a crawling spider bomb stands upright facing the way it crawls, and a variety grenade's worm points
	the way it digs, swaying. The server moves the spider bomb and the worms, so their models glide after their parts
	instead of jumping with each update.
]]
function Module._place(part: BasePart, deltaTime: number)
	--[[ Local Variables ]]

	local shot = flying[part] --- @type Combat_FlyingShot
	local position: Vector3 = part.Position
	local moved: Vector3 = if deltaTime > 0 then (position - shot.Last) / deltaTime else part.AssemblyLinearVelocity
	shot.Last = position

	--[[ Gliding ]]

	if part.Anchored and not part:GetAttribute("Simulated") and deltaTime > 0 then
		shot.Drawn = shot.Drawn:Lerp(position, 1 - math.exp(-_settings.CRAWL_GLIDE * deltaTime))
		position = shot.Drawn
	end

	--[[ Applying ]]

	if shot.Kind == "Rocket" or shot.Kind == "Homing" then
		-- Along its flight, the side square to it that faces up on top, so it's never upside down
		local velocity: Vector3 = if moved.Magnitude > 0.1 then moved else part.AssemblyLinearVelocity
		if velocity.Magnitude < 0.1 then
			return
		end
		local direction: Vector3 = Vector3.new(velocity.X, velocity.Y, 0).Unit
		local up: Vector3 = if direction.X >= 0 then Vector3.new(-direction.Y, direction.X, 0) else Vector3.new(direction.Y, -direction.X, 0)
		shot.Model:PivotTo(CFrame.lookAlong(position, direction, up))
	elseif shot.Kind == "Crawler" then
		if math.abs(moved.X) > 0.1 then
			shot.Facing = if moved.X < 0 then -1 else 1
		end
		shot.Model:PivotTo(CFrame.lookAlong(position, Vector3.xAxis * shot.Facing, Vector3.yAxis))
	elseif shot.Kind == "Shot" then
		-- Head first along its tunnel (the last way it moved), swaying in the arena's plane
		if moved.Magnitude > 0.1 then
			shot.Heading = Vector3.new(moved.X, moved.Y, 0).Unit
		end
		local sway: number = math.sin(os.clock() * _settings.WORM_SWAY_SPEED * 2 * math.pi) * _settings.WORM_SWAY
		shot.Model:PivotTo(CFrame.lookAlong(position, shot.Heading, Vector3.zAxis) * CFrame.Angles(0, sway, 0))
	else
		-- The part's own turning, from the model's front along +X and its side to the camera, as a snail holds it
		shot.Model:PivotTo(part.CFrame * CFrame.lookAlong(Vector3.zero, Vector3.xAxis))
	end
end

return Module
