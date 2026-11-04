--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Where client-made effects go
local effectsFolder: Folder

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	I.Network.Fired("Combat_Explosion", Module._onExplosion)
	I.Network.Fired("Combat_Tracer", Module._onTracer)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Explosion

--[[
	Draws a blast: a placeholder neon ball that swells to the blast's size and fades, with Roblox's explosion puff
	(which pushes and breaks nothing).
]]
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, shiny: boolean)
	--[[ Building ]]

	local ball: Part = I.Create("Part")({
		Name = "Blast",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one,
		Position = position,
		Color = if shiny then Color3.fromRGB(255, 230, 90) else Color3.fromRGB(255, 140, 40),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = effectsFolder,
	})
	I.Create("Explosion")({
		Position = position,
		BlastRadius = 0,
		BlastPressure = 0,
		DestroyJointRadiusPercent = 0,
		ExplosionType = Enum.ExplosionType.NoCraters,
		Parent = effectsFolder,
	})

	--[[ Animating ]]

	local Blast_TweenInfo: TweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Blast_TweenGoal = { Size = Vector3.one * math.max(radius, 1) * 2, Transparency = 1 }
	local Blast_Tween: Tween = I.S.TweenService:Create(ball, Blast_TweenInfo, Blast_TweenGoal)
	Blast_Tween:Play()
	Blast_Tween.Completed:Once(function()
		ball:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Tracer

--[[
	Draws a shot's lines from the muzzle to where each bullet (or swing) landed, as placeholder neon beams that fade.
]]
--- @param hits { Vector3 }
function Module._onTracer(_itemId: string, from: Vector3, hits)
	--[[ Drawing ]]

	for _index: number, to: Vector3 in ipairs(hits) do
		local length: number = (to - from).Magnitude
		if length < 0.05 then
			continue
		end
		local line: Part = I.Create("Part")({
			Name = "Tracer",
			Size = Vector3.new(0.15, 0.15, length),
			CFrame = CFrame.lookAt((from + to) / 2, to),
			Color = Color3.fromRGB(255, 240, 160),
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Parent = effectsFolder,
		})

		local Tracer_TweenInfo: TweenInfo = TweenInfo.new(0.25)
		local Tracer_TweenGoal = { Transparency = 1 }
		local Tracer_Tween: Tween = I.S.TweenService:Create(line, Tracer_TweenInfo, Tracer_TweenGoal)
		Tracer_Tween:Play()
		Tracer_Tween.Completed:Once(function()
			line:Destroy()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
