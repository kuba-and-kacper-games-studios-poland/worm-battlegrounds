--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Flight = require(script.Parent:FindFirstChild("Flight")) --- @type Combat_Client_Flight
local Shots = require(script.Parent:FindFirstChild("Shots")) --- @type Combat_Client_Shots

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local effectsFolder: Instance

--[[ Drawn ]]

-- The Shiny and Golden shots this screen draws accents on, by shot id, the held weapons it dressed, and whether the step runs
local shots = {} --- @type { [number]: Combat_VariantShot }
local dressed = {} --- @type { [Model]: Combat_VariantDress }
local stepping: boolean = false

-- Effects whose prefab is missing, warned about once (I.Vfx.Get) and skipped after
local missing = {} --- @type { [string]: boolean }

--[[ Timing ]]

-- Kept past an effect's last particle before its copy goes
local CLEANUP_MARGIN: number = 0.25

-- Spreads the twinkles, dust and glints out, so they never tick in step
local random: Random = Random.new()

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

--- @class Combat_Client_Variants
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Folders ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Connections ]]

	I.Network.Fired("Combat_Shot", Module._onShot)
	I.Network.Fired("Combat_Explosion", Module._onExplosion)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Dresses a held weapon's model in its variant's look (VARIANT_LOOKS): a Golden one turns gold, then it wears the
	sheen and the outline, and twinkles (and Golden's dust) play on it until the model is gone. A plain copy stays as it is.
]]
function Module.Dress(model: Model, variant: string?)
	--[[ Local Variables ]]

	--- @type Combat_VariantLook?
	local look = if variant then _settings.VARIANT_LOOKS[variant] else nil

	--[[ Checks ]]

	-- Check if the copy is a Shiny or Golden one
	if not look then
		return
	end

	--[[ Parts ]]

	-- The parts it shows (its hidden RootPart aside), taken before the looks add their own
	local parts = {} --- @type { BasePart }
	for _index: number, part: Instance in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(parts, part)
		end
	end

	--[[ Gilding ]]

	if look.Gild then
		Module._gild(parts, look)
	end

	--[[ Sheen ]]

	local sheens = {} --- @type { BasePart }
	for _index: number, part: BasePart in ipairs(parts) do
		table.insert(sheens, Module._makeCopy(part, look.Sheen[1], Enum.Material.ForceField, 0, _settings.VARIANT_SHEEN_GROW))
	end

	--[[ Outline ]]

	local outline: Highlight = I.Create("Highlight")({
		Adornee = model,
		DepthMode = Enum.HighlightDepthMode.Occluded,
		FillTransparency = 1,
		OutlineColor = look.Outline,
		OutlineTransparency = look.OutlineTransparency,
		Parent = model,
	})

	--[[ Saving ]]

	dressed[model] = {
		Look = look,
		Probe = parts[1],
		Sheens = sheens,
		Outline = outline,
		NextTwinkle = os.clock(),
		NextDust = os.clock(),
	}
	Module._startStepping()
end

--%%%%%%%%%%%%%%%%%%%% On Shot

--[[
	The server launched a shot: a Shiny or Golden one gets its accents (a painted trail beside its own and glints along
	its way), which ride on the part Shots draws it on from the next frame.
]]
--- @param options Combat_ShotOptions
function Module._onShot(id: number, _kind: string, name: string, _start: number, _position: Vector3, _velocity: Vector3, options)
	--[[ Local Variables ]]

	--- @type Combat_VariantLook?
	local look = if options.Variant then _settings.VARIANT_LOOKS[options.Variant] else nil

	--[[ Checks ]]

	-- Check if it's a Shiny or Golden shot
	if not look then
		return
	end

	--[[ Saving ]]

	shots[id] = {
		Look = look,
		Name = name,
		Carrier = nil,
		NextGlint = os.clock(),
	}
	Module._startStepping()
end

--%%%%%%%%%%%%%%%%%%%% On Explosion

--[[
	A blast went off: a Shiny or Golden copy's blast plays its look's effects over the normal explosion (scaled by its
	radius, a ring of them round it for one with Ring) and its sound.
]]
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, variant: string?)
	--[[ Local Variables ]]

	--- @type Combat_VariantLook?
	local look = if variant then _settings.VARIANT_LOOKS[variant] else nil

	--[[ Checks ]]

	-- Check if it's a Shiny or Golden blast
	if not look then
		return
	end

	--[[ Playing ]]

	local scale: number = radius / _settings.BLAST_VFX_RADIUS
	--- @param effect Combat_VariantEffect
	for _index: number, effect in ipairs(look.Blast) do
		local count: number = effect.Ring or 1
		for spot: number = 1, count do
			local angle: number = (spot - 1) / count * 2 * math.pi
			local offset: Vector3 = if effect.Ring then Vector3.new(math.cos(angle), math.sin(angle), 0) * radius * (effect.RingRadius or 1) else Vector3.zero
			Module._play(effect, position + offset, effect.Scale * scale)
		end
	end

	--[[ Sound ]]

	I.Sound.Play({
		Name = look.Sound,
		Location = position,
		SoundGroup = "SFX",
		RollOffMin = _settings.SOUND_ROLLOFF_MIN,
		RollOffMax = _settings.SOUND_ROLLOFF_MAX,
	})
end

--%%%%%%%%%%%%%%%%%%%% Start Stepping

--[[
	Binds the step that draws the accents, when it isn't running yet.
]]
function Module._startStepping()
	--[[ Checks ]]

	-- Skip when the step already runs
	if stepping then
		return
	end

	--[[ Connections ]]

	-- After Shots moved the shots' parts, with Flight, before the camera
	stepping = true
	I.S.RunService:BindToRenderStep("Combat_Variants", Enum.RenderPriority.Camera.Value - 1, Module._step)
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame while a shot or a held weapon has a look: each shot's accent trail rides on its part and its glints play
	along the way, the trail left to fade where the shot ended; each held weapon's sheen sways between its colours, its
	outline shows only while the weapon does, and its twinkles and dust play. Unbinds once nothing is left.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Drawing ]]

	--- @param shot Combat_VariantShot
	for id: number, shot in pairs(shots) do
		Module._stepShot(id, shot, now)
	end
	--- @param dress Combat_VariantDress
	for model: Model, dress in pairs(dressed) do
		Module._stepDress(model, dress, now)
	end

	--[[ Stopping ]]

	if not next(shots) and not next(dressed) then
		stepping = false
		I.S.RunService:UnbindFromRenderStep("Combat_Variants")
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Shot

--[[
	Moves a shot's accent trail onto its part (made the first time) and plays its glints along the way; once the shot
	is over, leaves the trail to fade where it ended.
]]
--- @param shot Combat_VariantShot
function Module._stepShot(id: number, shot, now: number)
	--[[ Data ]]

	local part: Part? = Shots.GetPart(id)

	--[[ Ending ]]

	if not part then
		if shot.Carrier then
			Flight.FadeTrailCarrier(shot.Carrier)
		end
		shots[id] = nil
		return
	end

	--[[ Trail ]]

	shot.Carrier = shot.Carrier or Module._makeTrail(shot.Look, part.Position, shot.Name)
	if shot.Carrier then
		shot.Carrier.CFrame = CFrame.new(part.Position)
	end

	--[[ Glints ]]

	if now >= shot.NextGlint then
		shot.NextGlint = now + (shot.Look.Glint.Every or 0) * random:NextNumber(0.6, 1.4)
		Module._play(shot.Look.Glint, part.Position, shot.Look.Glint.Scale)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Dress

--[[
	Sways a held weapon's sheen from its first colour to its second and back every SheenPeriod, shows its outline only
	while the weapon shows (SnailRig hides it while its snail emotes or hides in its shell), and plays its twinkles and
	dust; forgets it once the model is gone.
]]
--- @param dress Combat_VariantDress
function Module._stepDress(model: Model, dress, now: number)
	--[[ Checks ]]

	-- Check if the model is still held
	if not model.Parent then
		dressed[model] = nil
		return
	end

	--[[ Local Variables ]]

	local look = dress.Look --- @type Combat_VariantLook
	local sway: number = (math.sin(now * 2 * math.pi / look.SheenPeriod) + 1) / 2
	local shown: boolean = not dress.Probe or dress.Probe.LocalTransparencyModifier < 1

	--[[ Sheen ]]

	for _index: number, sheen: BasePart in ipairs(dress.Sheens) do
		sheen.Color = look.Sheen[1]:Lerp(look.Sheen[2], sway)
	end
	if dress.Outline.Enabled ~= shown then
		dress.Outline.Enabled = shown
	end

	--[[ Checks ]]

	-- Check if the weapon shows
	if not shown then
		return
	end

	--[[ Twinkles ]]

	if now >= dress.NextTwinkle then
		dress.NextTwinkle = now + (look.Twinkle.Every or 0) * random:NextNumber(0.6, 1.4)
		Module._play(look.Twinkle, Module._getSpot(model), look.Twinkle.Scale)
	end
	if look.Dust and now >= dress.NextDust then
		dress.NextDust = now + (look.Dust.Every or 0) * random:NextNumber(0.6, 1.4)
		Module._play(look.Dust, Module._getSpot(model), look.Dust.Scale)
	end
end

--%%%%%%%%%%%%%%%%%%%% Gild

--[[
	Turns a held weapon's parts gold, keeping their dark details: a SurfaceAppearance, a SpecialMesh's texture or a
	decal is tinted the bright gold (a tint keeps what's dark dark), a part with a SurfaceAppearance or a textured
	MeshPart also gets a gold copy over it, GildCover see-through (a tint alone leaves a coloured picture its colour),
	and a plain part takes the gold between the dark and the bright by its own brightness, in Metal.
]]
--- @param parts { BasePart }
--- @param look Combat_VariantLook
function Module._gild(parts, look)
	--[[ Local Variables ]]

	local dark: Color3 = look.Gild[1]
	local bright: Color3 = look.Gild[2]

	--[[ Gilding ]]

	for _index: number, part: BasePart in ipairs(parts) do
		local appearance: SurfaceAppearance? = part:FindFirstChildWhichIsA("SurfaceAppearance")
		local mesh: SpecialMesh? = part:FindFirstChildWhichIsA("SpecialMesh")
		if appearance then
			appearance.Color = bright
			Module._makeCopy(part, bright, Enum.Material.Metal, look.GildCover or 0, _settings.VARIANT_COVER_GROW)
		elseif mesh and mesh.TextureId ~= "" then
			mesh.VertexColor = Vector3.new(bright.R, bright.G, bright.B)
		elseif part:IsA("MeshPart") and part.TextureID ~= "" then
			Module._makeCopy(part, bright, Enum.Material.Metal, look.GildCover or 0, _settings.VARIANT_COVER_GROW)
		else
			local brightness: number = part.Color.R * 0.299 + part.Color.G * 0.587 + part.Color.B * 0.114
			part.Color = dark:Lerp(bright, brightness)
			part.Material = Enum.Material.Metal
		end

		-- Decals and textures on it are tinted too
		for _index2: number, decal: Instance in ipairs(part:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Color3 = bright
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Make Copy

--[[
	Makes a copy of a part's shape over it (no texture, no children but its mesh), grown so it sits just outside it, in
	a colour, a material and a see-through, welded to it in its model so it moves and hides with it. Returns the copy.
]]
--- @return BasePart
function Module._makeCopy(part: BasePart, color: Color3, material: Enum.Material, transparency: number, grow: number)
	--[[ Building ]]

	local copy: BasePart = part:Clone()
	for _index: number, child: Instance in ipairs(copy:GetChildren()) do
		if not child:IsA("DataModelMesh") then
			child:Destroy()
		end
	end

	-- A SpecialMesh draws at its own scale, a MeshPart or a plain part at its size
	local mesh: DataModelMesh? = copy:FindFirstChildWhichIsA("DataModelMesh")
	if mesh then
		mesh.Scale *= grow
	else
		copy.Size *= grow
	end
	if mesh and mesh:IsA("SpecialMesh") then
		mesh.TextureId = ""
	end
	if copy:IsA("MeshPart") then
		copy.TextureID = ""
	end

	--[[ Applying ]]

	copy.Name = `{part.Name}_Variant`
	copy.Color = color
	copy.Material = material
	copy.Transparency = transparency
	copy.CastShadow = false
	copy.Anchored = false
	copy.Massless = true
	copy.CanCollide = false
	copy.CanQuery = false
	copy.CanTouch = false
	copy.CFrame = part.CFrame
	I.Create("WeldConstraint")({
		Part0 = part,
		Part1 = copy,
		Parent = copy,
	})
	copy.Parent = part.Parent

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%% Make Trail

--[[
	Makes a shot's accent trail where it is: a carrier of its look's trail effect (Flight's), painted TrailColor and
	drawn TrailWidth of its width. Nil when the effect is missing.
]]
--- @param look Combat_VariantLook
--- @return BasePart?
function Module._makeTrail(look, position: Vector3, name: string)
	--[[ Checks ]]

	-- Check if the trail's effect is in the place
	if not Module._getPrefab(look.Trail) then
		return nil
	end

	--[[ Building ]]

	local carrier: BasePart = Flight.MakeTrailCarrier(look.Trail, position, `{name}_VariantTrail`)

	--[[ Painting ]]

	for _index: number, child: Instance in ipairs(carrier:GetDescendants()) do
		if child:IsA("Trail") or child:IsA("ParticleEmitter") then
			child.Color = look.TrailColor
		elseif child:IsA("Attachment") then
			child.Position *= look.TrailWidth
		end
	end

	--[[ Returning ]]

	return carrier
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays one of a look's effects once at a spot, as I.Vfx.Play does, its particles painted the effect's Color and drawn
	its Front studs toward the camera. Nothing when its prefab is missing.
]]
--- @param effect Combat_VariantEffect
function Module._play(effect, position: Vector3, scale: number)
	--[[ Data ]]

	local prefab: BasePart? = Module._getPrefab(effect.Effect)
	if not prefab then
		return
	end

	--[[ Building ]]

	local copy: BasePart = prefab:Clone()
	copy.Name = effect.Effect
	copy.Anchored = true
	copy.CFrame = CFrame.new(position) * prefab.CFrame.Rotation

	--[[ Painting ]]

	for _index: number, emitter: Instance in ipairs(copy:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = effect.Color
			emitter.ZOffset += effect.Front or 0
		end
	end
	copy.Parent = effectsFolder

	--[[ Emitting ]]

	local seconds: number = I.Vfx.Emit(copy, scale)
	task.delay(seconds + CLEANUP_MARGIN, function()
		copy:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Prefab

--[[
	Returns an effect's prefab (I.Vfx.Get), or nil when it's missing: warned about the first time, skipped after.
]]
--- @return BasePart?
function Module._getPrefab(name: string)
	--[[ Checks ]]

	-- Skip an effect already found missing
	if missing[name] then
		return nil
	end

	--[[ Data ]]

	local prefab: BasePart? = I.Vfx.Get(name)
	if not prefab then
		missing[name] = true
	end

	--[[ Returning ]]

	return prefab
end

--%%%%%%%%%%%%%%%%%%%% Get Spot

--[[
	Returns a random spot on a model, inside its bounding box, for a twinkle or a mote of dust.
]]
--- @return Vector3
function Module._getSpot(model: Model)
	--[[ Local Variables ]]

	local cframe: CFrame
	local size: Vector3
	cframe, size = model:GetBoundingBox()

	--[[ Returning ]]

	return cframe:PointToWorldSpace(Vector3.new(random:NextNumber(-0.5, 0.5) * size.X, random:NextNumber(-0.5, 0.5) * size.Y, random:NextNumber(-0.5, 0.5) * size.Z))
end

return Module
