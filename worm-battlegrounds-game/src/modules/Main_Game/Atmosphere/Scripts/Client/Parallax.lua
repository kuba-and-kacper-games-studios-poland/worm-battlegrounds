--[[
	Created By: 	HungryN00B
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local worldFolder: Instance

--[[ State ]]

-- The layers showing, and the mood and map bounds they stand behind
local layersFolder: Folder? = nil
local shownProfile = nil --- @type Atmosphere_Profile?
local shownBounds: BasePart? = nil

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

--- @class Atmosphere_Client_Parallax
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(world: Instance)
	--[[ Folders ]]

	worldFolder = world
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Stands the mood's parallax layers far behind the map, each at its depth, so the camera's own perspective moves them
	as it pans and zooms; takes the last map's away. None show in the lobby, for a mood without layers, or until the
	map's bounds are here.
]]
--- @param profile Atmosphere_Profile?
function Module.Show(profile, bounds: BasePart?)
	--[[ Checks ]]

	-- Skip when these layers already stand behind this map
	if profile == shownProfile and bounds == shownBounds then
		return
	end
	shownProfile = profile
	shownBounds = bounds

	--[[ Clearing ]]

	if layersFolder then
		layersFolder:Destroy()
		layersFolder = nil
	end

	-- Check if the mood has layers and the map is here
	if not profile or not profile.Parallax or not bounds then
		return
	end

	--[[ Local Variables ]]

	local planeZ: number = bounds.Position.Z
	local floorY: number = bounds.Position.Y - bounds.Size.Y / 2

	--[[ Building ]]

	local folder: Folder = Instance.new("Folder")
	folder.Name = "Parallax"

	--- @param row Atmosphere_ParallaxRow
	for _index: number, row in ipairs(profile.Parallax) do
		local part: Part = Instance.new("Part")
		part.Name = "Layer"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(row.Width, row.Height, 0.2)
		part.CFrame = CFrame.new(bounds.Position.X + row.X, floorY + row.Bottom + row.Height / 2, planeZ - row.Depth)

		-- Drawn unlit on the face toward the camera (it looks along -Z), so its colours match the sky's
		local surface: SurfaceGui = Instance.new("SurfaceGui")
		surface.Face = Enum.NormalId.Back
		surface.LightInfluence = 0
		surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surface.CanvasSize = Vector2.new(_settings.PARALLAX_CANVAS, _settings.PARALLAX_CANVAS * row.Height / row.Width)
		surface.Parent = part

		if row.Image then
			local image: ImageLabel = Instance.new("ImageLabel")
			image.Size = UDim2.fromScale(1, 1)
			image.BackgroundTransparency = 1
			image.Image = row.Image
			image.ImageTransparency = row.Transparency or 0
			image.Parent = surface
		else
			local fill: Frame = Instance.new("Frame")
			fill.Size = UDim2.fromScale(1, 1)
			fill.BorderSizePixel = 0
			fill.BackgroundColor3 = row.Color
			fill.Parent = surface
		end
		part.Parent = folder
	end
	folder.Parent = worldFolder
	layersFolder = folder
end

return Module
