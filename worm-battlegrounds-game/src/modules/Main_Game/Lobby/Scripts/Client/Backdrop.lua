--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local cosmeticsRep: Folder?
local random: Random = Random.new()

--[[ Map ]]

local backdrop: Model
local bounds: BasePart
local terrainParams: RaycastParams = RaycastParams.new()

-- The top of the map's highest liquid: a snail below it is knocked out, and no snail starts on ground under it
local liquidTop: number = -math.huge

--[[ Match ]]

local snails = {} --- @type { Lobby_BackdropSnail }
local weaponIds = {} --- @type { string }

-- How many snails a blast threw that haven't landed yet
local flying: number = 0

--[[ View ]]

-- Whether the match plays and the camera watches it (outside matches), what it follows and where it looks
local showing: boolean = false
local followed: PVInstance? = nil
local focus: Vector3? = nil

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

--- @class Lobby_Client_Backdrop
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Weapons ]]

	for weaponId: string, _shotId: string in pairs(_settings.BACKDROP_WEAPONS) do
		table.insert(weaponIds, weaponId)
	end
	table.sort(weaponIds)

	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshShowing)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

	--[[ Starting ]]

	-- The server's copy of the map arrives with the place's streaming, so the match waits for it on its own thread
	task.spawn(Module._run)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Finds the backdrop map, then plays turn after turn while the player is in the lobby: each snail still in play takes
	its turn in order, and a round with one snail left starts again on fresh spots.
]]
function Module._run()
	--[[ Map ]]

	backdrop = I.Dirs.UmeWorkspace:WaitForChild(_localName):WaitForChild(_settings.BACKDROP_NAME)
	bounds = backdrop:WaitForChild("Bounds")
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { backdrop:WaitForChild("Terrain") }
	for _index: number, part: Instance in ipairs(backdrop:GetChildren()) do
		if part:IsA("BasePart") and _settings.BACKDROP_LIQUID_COLORS[part.Name] then
			liquidTop = math.max(liquidTop, part.Position.Y + part.Size.Y / 2)
		end
	end
	Module._refreshShowing()

	--[[ Turns ]]

	local turn: number = 0
	while true do
		if not showing then
			task.wait(0.5)
			continue
		end
		local alive = Module._getAlive() --- @type { Lobby_BackdropSnail }
		if #alive <= 1 then
			task.wait(1.5)
			Module._startRound()
			continue
		end
		turn += 1
		Module._playTurn(alive[(turn - 1) % #alive + 1], alive)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Cosmetics folder, so the first snail wears the equipped skin.
]]
function Module._connectReplicator()
	--[[ Data ]]

	cosmeticsRep = I.Replicator.GetFolder("Cosmetics")

	--[[ Connections ]]

	if cosmeticsRep then
		cosmeticsRep:GetAttributeChangedSignal("EquippedSkin"):Connect(function()
			if snails[1] then
				Module._dress(snails[1], Module._getEquippedSkin())
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Showing

--[[
	Plays and watches the match, blurred, while the player is in the lobby, and hands the camera back during a match
	(the Studio map plays both on one server).
]]
function Module._refreshShowing()
	--[[ Local Variables ]]

	local inLobby: boolean = backdrop ~= nil and not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local weight: number = _settings.BACKDROP_BLUR_WEIGHT

	--[[ Checks ]]

	-- Skip when nothing changes
	if inLobby == showing then
		return
	end

	--[[ Applying ]]

	showing = inLobby
	if showing then
		-- The FOV buff's base, so an open widget's FOV change still adds to it
		I.Buff.Set("FOV", "Standard", _settings.BACKDROP_FOV)
		I.Lighting.SetValueBulk({
			{ "BlurEffect", "Size", { Value = _settings.BACKDROP_BLUR, Weight = weight } },
			{ "BlurEffect", "Enabled", { Value = true, Weight = weight } },
		}, _settings.BACKDROP_BLUR_TWEENINFO)

		-- After Roblox's camera scripts each frame, so nothing moves it off the match
		focus = nil
		I.S.RunService:BindToRenderStep("Lobby_Backdrop", Enum.RenderPriority.Camera.Value + 1, Module._updateCamera)
	else
		I.S.RunService:UnbindFromRenderStep("Lobby_Backdrop")
		I.Lighting.ClearValueBulk({
			{ "BlurEffect", "Size", weight },
			{ "BlurEffect", "Enabled", weight },
		}, _settings.BACKDROP_BLUR_TWEENINFO)
		I.S.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Camera

--[[
	Looks along -Z at what the match follows (the shot in flight, else the snail playing), easing toward it and kept
	inside the map's sides.
]]
function Module._updateCamera(deltaTime: number)
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local target: Vector3 = if followed and followed.Parent then followed:GetPivot().Position else bounds.Position

	-- Half the view's width at the plane, so the camera never looks past the map's sides
	local halfWidth: number = _settings.BACKDROP_DISTANCE * math.tan(math.rad(camera.FieldOfView / 2)) * camera.ViewportSize.X / camera.ViewportSize.Y
	local reach: number = math.max(bounds.Size.X / 2 - halfWidth, 0)
	local goal: Vector3 = Vector3.new(math.clamp(target.X, bounds.Position.X - reach, bounds.Position.X + reach), target.Y, bounds.Position.Z)

	--[[ Applying ]]

	focus = if focus then focus:Lerp(goal, 1 - math.exp(-_settings.BACKDROP_FOLLOW_SPEED * deltaTime)) else goal
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(focus + Vector3.zAxis * _settings.BACKDROP_DISTANCE, focus)
end

--%%%%%%%%%%%%%%%%%%%% Start Round

--[[
	Clears the snails and stands BACKDROP_SNAILS new ones on spread-out spots of land, the first in the player's
	equipped skin.
]]
function Module._startRound()
	--[[ Clearing ]]

	--- @param snail Lobby_BackdropSnail
	for _index: number, snail in ipairs(snails) do
		snail.Model:Destroy()
	end
	snails = {}

	--[[ Spawning ]]

	for index: number, spot: Vector3 in ipairs(Module._getSpots()) do
		--- @type Lobby_BackdropSnail
		local snail = {
			Position = spot,
			Facing = if spot.X > bounds.Position.X then -1 else 1,
			Health = _settings.BACKDROP_HEALTH,
			Alive = true,
		}
		Module._dress(snail, if index == 1 then Module._getEquippedSkin() else I.Settings["Cosmetics"].DEFAULT_SKIN)
		if snail.Model then
			table.insert(snails, snail)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Gives a snail the model of a skin (the default snail's when the skin has none of its own), where it stands.
]]
--- @param snail Lobby_BackdropSnail
function Module._dress(snail, skinId: string)
	--[[ Data ]]

	local skins: Folder = I.Dirs.Assets:FindFirstChild("Skins")
	local skin = I.G_Cosmetics.GetSkin(skinId) --- @type Cosmetics_SkinData?
	local fallback = I.G_Cosmetics.GetSkin(I.Settings["Cosmetics"].DEFAULT_SKIN) --- @type Cosmetics_SkinData

	-- shortcut: a skin without its own model plays as the default snail, as the Skins window shows it
	local source: Instance? = skin and skins:FindFirstChild(skin.Model) or skins:FindFirstChild(fallback.Model)
	if not source or not source:IsA("Model") then
		return
	end

	--[[ Building ]]

	if snail.Model then
		snail.Model:Destroy()
	end
	snail.Model = source:Clone()
	for _index: number, part: Instance in ipairs(snail.Model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end
	end
	Module._place(snail)
	snail.Model.Parent = backdrop
end

--%%%%%%%%%%%%%%%%%%%% Play Turn

--[[
	One bot's turn: it thinks, walks a little toward a rival (or flies there with the jetpack), turns its weapon to the
	shot, fires, and the match waits until the shot and every snail it threw have landed, then rests.
]]
--- @param snail Lobby_BackdropSnail
--- @param alive { Lobby_BackdropSnail }
function Module._playTurn(snail, alive)
	--[[ Local Variables ]]

	local rivals = {} --- @type { Lobby_BackdropSnail }
	--- @param other Lobby_BackdropSnail
	for _index: number, other in ipairs(alive) do
		if other ~= snail then
			table.insert(rivals, other)
		end
	end
	local rival = rivals[random:NextInteger(1, #rivals)] --- @type Lobby_BackdropSnail
	local weaponId: string = weaponIds[random:NextInteger(1, #weaponIds)]

	--[[ Thinking ]]

	followed = snail.Model
	task.wait(random:NextNumber(_settings.BACKDROP_THINK[1], _settings.BACKDROP_THINK[2]))

	--[[ Moving ]]

	snail.Facing = if rival.Position.X < snail.Position.X then -1 else 1
	local jetpack: Model? = nil
	if random:NextNumber() < _settings.BACKDROP_JETPACK_CHANCE then
		jetpack = Module._flyJetpack(snail)
	else
		Module._walk(snail, random:NextNumber(_settings.BACKDROP_WALK[1], _settings.BACKDROP_WALK[2]))
	end

	--[[ Aiming ]]

	local velocity: Vector3
	local start: Vector3
	velocity, start = Module._getShot(snail, rivals)
	local angle: number = math.atan2(velocity.Y, velocity.X)
	snail.Facing = if velocity.X < 0 then -1 else 1
	Module._place(snail)
	if jetpack then
		Module._wearJetpack(snail, jetpack)
	end
	Module._aim(snail, weaponId, angle)

	--[[ Firing ]]

	local impact: Vector3? = Module._fly(snail, _settings.BACKDROP_WEAPONS[weaponId], start, velocity)
	if impact then
		Module._blast(weaponId, impact)
	end

	--[[ Settling ]]

	while flying > 0 do
		task.wait()
	end
	task.wait(_settings.BACKDROP_REST)

	-- The jetpack comes off when the turn ends, as in a match
	if jetpack then
		jetpack:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%% Fly Jetpack

--[[
	Puts the jetpack on a snail and flies it in an arc to land JETPACK_REACH studs toward the way it faces, when there's
	ground there above the liquid. Returns the jetpack, which stays on its back for the rest of the turn, or nil when the
	snail has no room to fly or the jetpack has no model.
]]
--- @param snail Lobby_BackdropSnail
--- @return Model?
function Module._flyJetpack(snail)
	--[[ Checks ]]

	-- Check if the jetpack has a model to wear
	if not I.G_Arsenal.HasModel("Jetpack") then
		return nil
	end

	-- Check if there's ground to land on, about as high as the snail, out of the liquid and inside the map
	local reach: number = random:NextNumber(_settings.BACKDROP_JETPACK_REACH[1], _settings.BACKDROP_JETPACK_REACH[2])
	local landX: number = snail.Position.X + reach * snail.Facing
	local ground: Vector3? = Module._getGround(landX, snail.Position.Y + _settings.BACKDROP_JETPACK_HEIGHT)
	if
		not ground
		or math.abs(ground.Y + _settings.BACKDROP_SNAIL_RADIUS - snail.Position.Y) > _settings.BACKDROP_JETPACK_HEIGHT
		or ground.Y <= liquidTop
		or math.abs(landX - bounds.Position.X) > bounds.Size.X / 2 - _settings.BACKDROP_SPACING / 2
	then
		return nil
	end

	--[[ Building ]]

	local jetpack: Model = Module._getPropCopy(I.G_Arsenal.GetModel("Jetpack"))
	jetpack.Parent = backdrop
	Module._wearJetpack(snail, jetpack)

	--[[ Flying ]]

	-- Up and over in an arc, eased in and out, the jetpack on the snail's back all the way
	local start: Vector3 = snail.Position
	local landing: Vector3 = ground + Vector3.yAxis * _settings.BACKDROP_SNAIL_RADIUS
	local elapsed: number = 0
	while elapsed < _settings.BACKDROP_JETPACK_TIME do
		elapsed += task.wait()
		local along: number = math.min(elapsed / _settings.BACKDROP_JETPACK_TIME, 1)
		local eased: number = (1 - math.cos(along * math.pi)) / 2
		local base: Vector3 = start:Lerp(landing, eased)
		snail.Position = base + Vector3.yAxis * _settings.BACKDROP_JETPACK_HEIGHT * math.sin(along * math.pi)
		Module._place(snail)
		Module._wearJetpack(snail, jetpack)
	end

	--[[ Landing ]]

	snail.Position = landing
	Module._place(snail)
	Module._wearJetpack(snail, jetpack)

	--[[ Returning ]]

	return jetpack
end

--%%%%%%%%%%%%%%%%%%%% Wear Jetpack

--[[
	Puts the jetpack on the back of the snail's shell, its straps toward the way the snail faces.
]]
--- @param snail Lobby_BackdropSnail
function Module._wearJetpack(snail, jetpack: Model)
	--[[ Local Variables ]]

	local forward: Vector3 = Vector3.xAxis * snail.Facing
	local position: Vector3 = snail.Position + Vector3.yAxis * _settings.BACKDROP_JETPACK_UP - forward * _settings.BACKDROP_JETPACK_BEHIND

	--[[ Applying ]]

	jetpack:PivotTo(CFrame.lookAlong(position, forward))
end

--%%%%%%%%%%%%%%%%%%%% Walk

--[[
	Walks a snail along the ground the way it faces, up to a distance, stopping at a wall, a drop or liquid.
]]
--- @param snail Lobby_BackdropSnail
function Module._walk(snail, distance: number)
	--[[ Walking ]]

	local walked: number = 0
	while walked < distance do
		local step: number = math.min(_settings.BACKDROP_WALK_SPEED * task.wait(), distance - walked)
		local ground: Vector3? = Module._getGround(snail.Position.X + step * snail.Facing, snail.Position.Y)
		local height: number = if ground then ground.Y + _settings.BACKDROP_SNAIL_RADIUS - snail.Position.Y else 0

		-- A wall or a drop of a few studs, or the liquid, ends the walk
		if not ground or height > 2 or height < -3 or ground.Y <= liquidTop then
			break
		end
		snail.Position = ground + Vector3.yAxis * _settings.BACKDROP_SNAIL_RADIUS
		walked += step
		Module._place(snail)
	end
end

--%%%%%%%%%%%%%%%%%%%% Aim

--[[
	Holds a weapon on the snail's camera side and turns it from level to the shot's angle over BACKDROP_AIM seconds,
	then puts it away.
]]
--- @param snail Lobby_BackdropSnail
function Module._aim(snail, weaponId: string, angle: number)
	--[[ Checks ]]

	-- Check if the weapon has a model to hold
	if not I.G_Arsenal.HasModel(weaponId) then
		task.wait(_settings.BACKDROP_AIM)
		return
	end

	--[[ Building ]]

	local held: Model = Module._getPropCopy(I.G_Arsenal.GetModel(weaponId))
	held.Parent = backdrop

	--[[ Turning ]]

	local level: number = if snail.Facing < 0 then math.pi else 0
	local turn: number = ((angle - level + math.pi) % (2 * math.pi)) - math.pi
	local elapsed: number = 0
	while elapsed < _settings.BACKDROP_AIM do
		elapsed += task.wait()
		local eased: number = math.sin(math.min(elapsed / _settings.BACKDROP_AIM, 1) * math.pi / 2)
		local current: number = level + turn * eased
		local direction: Vector3 = Vector3.new(math.cos(current), math.sin(current), 0)
		local up: Vector3 = if direction.X >= 0 then Vector3.new(-direction.Y, direction.X, 0) else Vector3.new(direction.Y, -direction.X, 0)
		local position: Vector3 = snail.Position + direction * _settings.BACKDROP_HELD_FORWARD + Vector3.new(0, _settings.BACKDROP_HELD_HEIGHT, _settings.BACKDROP_HELD_DEPTH)
		held:PivotTo(CFrame.lookAlong(position, direction, up))
	end

	--[[ Clearing ]]

	held:Destroy()
end

--%%%%%%%%%%%%%%%%%%%% Fly

--[[
	Flies a shot from a start under gravity (no wind), pointing along its flight, until it hits the ground or a snail
	(not the shooter's own, as it leaves), or leaves the map. Returns where it hit, or nil when it left the map.
]]
--- @param shooter Lobby_BackdropSnail
--- @return Vector3?
function Module._fly(shooter, shotId: string, start: Vector3, velocity: Vector3)
	--[[ Building ]]

	local model: Model? = if I.G_Arsenal.HasProjectileModel(shotId) or I.G_Arsenal.HasModel(shotId) then Module._getPropCopy(I.G_Arsenal.GetProjectileModel(shotId)) else nil
	if model then
		model.Parent = backdrop
		followed = model
	end

	--[[ Flying ]]

	local position: Vector3 = start
	local elapsed: number = 0
	local impact: Vector3? = nil
	local bottom: number = bounds.Position.Y - bounds.Size.Y / 2
	while elapsed < 8 and position.Y > bottom and math.abs(position.X - bounds.Position.X) < bounds.Size.X / 2 do
		local deltaTime: number = task.wait()
		elapsed += deltaTime
		velocity -= Vector3.yAxis * _settings.BACKDROP_GRAVITY * deltaTime
		local nextPosition: Vector3 = position + velocity * deltaTime

		-- The ground, the liquid, or a snail in the way stops it
		local hit: RaycastResult? = I.S.Workspace:Raycast(position, nextPosition - position, terrainParams)
		impact = if hit then hit.Position elseif nextPosition.Y <= liquidTop then nextPosition else Module._getSnailHit(shooter, nextPosition, elapsed)
		position = impact or nextPosition

		if model then
			local direction: Vector3 = velocity.Unit
			local up: Vector3 = if direction.X >= 0 then Vector3.new(-direction.Y, direction.X, 0) else Vector3.new(direction.Y, -direction.X, 0)
			model:PivotTo(CFrame.lookAlong(position, direction, up))
		end
		if impact then
			break
		end
	end

	--[[ Clearing ]]

	if model then
		model:Destroy()
	end

	--[[ Returning ]]

	return impact
end

--%%%%%%%%%%%%%%%%%%%% Blast

--[[
	Bursts a weapon's blast at a point: a fireball and smoke, its Arsenal damage to every snail it reaches, and its
	knockback (times BACKDROP_KNOCKBACK_SCALE) throwing them away from it and up.
]]
function Module._blast(weaponId: string, point: Vector3)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(weaponId) --- @type Arsenal_WeaponData

	--[[ Effect ]]

	Module._showBlast(point, row.BlastRadius)

	--[[ Hitting ]]

	--- @param snail Lobby_BackdropSnail
	for _index: number, snail in ipairs(Module._getAlive()) do
		local away: Vector3 = snail.Position - point
		if away.Magnitude > row.BlastRadius + _settings.BACKDROP_SNAIL_RADIUS then
			continue
		end
		snail.Health -= I.G_Arsenal.GetDamage(weaponId, away.Magnitude)

		-- Away from the blast and up, harder near its middle; a snail right on it goes up and to its side
		local share: number = 1 - math.clamp(away.Magnitude / (row.BlastRadius + _settings.BACKDROP_SNAIL_RADIUS), 0, 1) / 2
		local flat: Vector3 = Vector3.new(away.X, math.max(away.Y, 0), 0)
		local direction: Vector3 = (Vector3.new(if away.X >= 0 then 1 else -1, 1, 0) + (if flat.Magnitude > 0.01 then flat.Unit else Vector3.zero)).Unit
		local speed: number = I.G_Arsenal.GetKnockback(row.Knockback) * _settings.BACKDROP_KNOCKBACK_SCALE * share
		task.spawn(Module._throw, snail, direction * speed)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Blast

--[[
	Draws a blast: a fireball that grows to its radius and fades, and a puff of smoke.
]]
function Module._showBlast(point: Vector3, radius: number)
	--[[ Building ]]

	local fireball: Part = I.Create("Part")({
		Name = "Blast",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one,
		Position = point,
		Color = Color3.fromRGB(255, 150, 40),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Parent = backdrop,
	})
	local smoke: ParticleEmitter = I.Create("ParticleEmitter")({
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(90, 90, 90)),
		Size = NumberSequence.new(radius * 0.6, radius * 1.2),
		Transparency = NumberSequence.new(0.2, 1),
		Lifetime = NumberRange.new(0.8, 1.4),
		Speed = NumberRange.new(radius, radius * 2),
		SpreadAngle = Vector2.new(180, 180),
		Rate = 0,
		Parent = fireball,
	})
	smoke:Emit(12)

	--[[ Tweening ]]

	local Burst_TweenInfo: TweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Burst_TweenGoal = { Size = Vector3.one * radius * 2, Transparency = 1 }
	local Burst_Tween: Tween = I.S.TweenService:Create(fireball, Burst_TweenInfo, Burst_TweenGoal)
	Burst_Tween:Play()

	--[[ Cleaning ]]

	I.S.Debris:AddItem(fireball, 2)
end

--%%%%%%%%%%%%%%%%%%%% Throw

--[[
	Throws a snail with a velocity under gravity until it lands on the ground, then knocks it out when its health is
	gone; one that falls into the liquid or off the map is knocked out at once.
]]
--- @param snail Lobby_BackdropSnail
function Module._throw(snail, velocity: Vector3)
	--[[ Throwing ]]

	flying += 1
	local radius: number = _settings.BACKDROP_SNAIL_RADIUS
	local elapsed: number = 0
	while elapsed < 6 do
		local deltaTime: number = task.wait()
		elapsed += deltaTime
		velocity -= Vector3.yAxis * _settings.BACKDROP_GRAVITY * deltaTime
		local move: Vector3 = velocity * deltaTime
		if move.Magnitude < 1e-4 then
			continue
		end
		local hit: RaycastResult? = I.S.Workspace:Raycast(snail.Position, move + move.Unit * radius, terrainParams)

		-- Standing ground ends the throw; a wall or a ceiling only stops the snail's move across it
		if hit then
			snail.Position = hit.Position + hit.Normal * radius
			if hit.Normal.Y > 0.5 then
				break
			end
			velocity = Vector3.new(0, math.min(velocity.Y, 0), 0)
		else
			snail.Position += move
		end
		Module._place(snail)
		if snail.Position.Y <= liquidTop or math.abs(snail.Position.X - bounds.Position.X) > bounds.Size.X / 2 then
			snail.Health = 0
			break
		end
	end
	Module._place(snail)

	--[[ Knocking Out ]]

	if snail.Health <= 0 and snail.Alive then
		snail.Alive = false
		task.spawn(Module._fadeOut, snail)
	end
	flying -= 1
end

--%%%%%%%%%%%%%%%%%%%% Fade Out

--[[
	Turns a knocked-out snail into a ghost that floats up and fades away.
]]
--- @param snail Lobby_BackdropSnail
function Module._fadeOut(snail)
	--[[ Fading ]]

	local elapsed: number = 0
	while elapsed < 1.5 and snail.Model.Parent do
		local deltaTime: number = task.wait()
		elapsed += deltaTime
		snail.Position += Vector3.yAxis * 4 * deltaTime
		Module._place(snail)
		for _index: number, part: Instance in ipairs(snail.Model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = math.min(elapsed / 1.5, 1)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Stands a snail's model where it is, side-on and facing its way.
]]
--- @param snail Lobby_BackdropSnail
function Module._place(snail)
	--[[ Applying ]]

	snail.Model:PivotTo(CFrame.lookAlong(snail.Position, Vector3.xAxis * snail.Facing))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Alive

--[[
	Returns the snails still in play, in their order.
]]
--- @return { Lobby_BackdropSnail }
function Module._getAlive()
	--[[ Collecting ]]

	local alive = {} --- @type { Lobby_BackdropSnail }
	--- @param snail Lobby_BackdropSnail
	for _index: number, snail in ipairs(snails) do
		if snail.Alive then
			table.insert(alive, snail)
		end
	end

	--[[ Returning ]]

	return alive
end

--%%%%%%%%%%%%%%%%%%%% Get Spots

--[[
	Returns up to BACKDROP_SNAILS random spots where a snail stands on land above the liquid, BACKDROP_SPACING apart.
]]
--- @return { Vector3 }
function Module._getSpots()
	--[[ Local Variables ]]

	local spots = {} --- @type { Vector3 }
	local halfWidth: number = bounds.Size.X / 2 - _settings.BACKDROP_SPACING / 2

	--[[ Searching ]]

	for _try: number = 1, 80 do
		local ground: Vector3? = Module._getGround(bounds.Position.X + random:NextNumber(-halfWidth, halfWidth), bounds.Position.Y + bounds.Size.Y / 2)
		if not ground or ground.Y <= liquidTop then
			continue
		end
		local spot: Vector3 = ground + Vector3.yAxis * _settings.BACKDROP_SNAIL_RADIUS
		local roomy: boolean = true
		for _index: number, other: Vector3 in ipairs(spots) do
			roomy = roomy and (other - spot).Magnitude >= _settings.BACKDROP_SPACING
		end
		if roomy then
			table.insert(spots, spot)
		end
		if #spots >= _settings.BACKDROP_SNAILS then
			break
		end
	end

	--[[ Returning ]]

	return spots
end

--%%%%%%%%%%%%%%%%%%%% Get Ground

--[[
	Returns the top of the ground under a point of the map's plane, looking down from a little above a height, or nil
	over a gap.
]]
--- @return Vector3?
function Module._getGround(x: number, fromY: number)
	--[[ Local Variables ]]

	local origin: Vector3 = Vector3.new(x, fromY + 3, bounds.Position.Z)
	local hit: RaycastResult? = I.S.Workspace:Raycast(origin, Vector3.yAxis * -bounds.Size.Y, terrainParams)

	--[[ Returning ]]

	return if hit then hit.Position else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Shot

--[[
	Returns a shot's velocity and where it leaves the weapon: one that lands near a rival after a flight time from
	BACKDROP_FLIGHT, off by up to BACKDROP_MISS, through clear sky. A ledge overhead or a hill in the way would stop
	it short, so the bot tries other rivals and flight times, and fires its last try when none is clear.
]]
--- @param snail Lobby_BackdropSnail
--- @param rivals { Lobby_BackdropSnail }
--- @return Vector3
--- @return Vector3
function Module._getShot(snail, rivals)
	--[[ Local Variables ]]

	local gravity: number = _settings.BACKDROP_GRAVITY
	local velocity: Vector3 = Vector3.zero
	local start: Vector3 = snail.Position

	--[[ Trying ]]

	for _try: number = 1, _settings.BACKDROP_AIM_TRIES do
		--[[ Aiming ]]

		local rival = rivals[random:NextInteger(1, #rivals)] --- @type Lobby_BackdropSnail
		local flightTime: number = random:NextNumber(_settings.BACKDROP_FLIGHT[1], _settings.BACKDROP_FLIGHT[2])
		local aimPoint: Vector3 = rival.Position + Vector3.xAxis * random:NextNumber(-_settings.BACKDROP_MISS, _settings.BACKDROP_MISS)
		local offset: Vector3 = aimPoint - snail.Position
		velocity = Vector3.new(offset.X / flightTime, offset.Y / flightTime + gravity * flightTime / 2, 0)
		start = snail.Position + velocity.Unit * (_settings.BACKDROP_SNAIL_RADIUS + _settings.BACKDROP_HELD_FORWARD)

		--[[ Following ]]

		-- The arc in steps of a 30th of a second, until the ground catches it or its flight time is up
		local position: Vector3 = start
		local stepVelocity: Vector3 = velocity
		local elapsed: number = 0
		while elapsed < flightTime do
			local nextPosition: Vector3 = position + stepVelocity / 30
			local hit: RaycastResult? = I.S.Workspace:Raycast(position, nextPosition - position, terrainParams)
			if hit then
				position = hit.Position
				break
			end
			position = nextPosition
			stepVelocity -= Vector3.yAxis * gravity / 30
			elapsed += 1 / 30
		end

		--[[ Checking ]]

		-- Take the first arc that ends near where it was aimed
		if (position - aimPoint).Magnitude <= _settings.BACKDROP_MISS then
			break
		end
	end

	--[[ Returning ]]

	return velocity, start
end

--%%%%%%%%%%%%%%%%%%%% Get Snail Hit

--[[
	Returns a shot's position when it touches a snail in play (the shooter's own only once the shot has left it), else
	nil.
]]
--- @param shooter Lobby_BackdropSnail
--- @return Vector3?
function Module._getSnailHit(shooter, position: Vector3, elapsed: number)
	--[[ Checking ]]

	--- @param snail Lobby_BackdropSnail
	for _index: number, snail in ipairs(Module._getAlive()) do
		if (snail ~= shooter or elapsed > 0.3) and (snail.Position - position).Magnitude <= _settings.BACKDROP_SNAIL_RADIUS + 0.5 then
			return position
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Equipped Skin

--[[
	Returns the player's equipped skin, or the default one before their data arrives.
]]
--- @return string
function Module._getEquippedSkin()
	return cosmeticsRep and cosmeticsRep:GetAttribute("EquippedSkin") or I.Settings["Cosmetics"].DEFAULT_SKIN
end

--%%%%%%%%%%%%%%%%%%%% Get Prop Copy

--[[
	Returns an anchored copy of a weapon or shot model that nothing touches, for the backdrop to move.
]]
--- @return Model
function Module._getPropCopy(source: Model)
	--[[ Building ]]

	local copy: Model = source:Clone()
	for _index: number, part: Instance in ipairs(copy:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end
	end

	--[[ Returning ]]

	return copy
end

return Module
