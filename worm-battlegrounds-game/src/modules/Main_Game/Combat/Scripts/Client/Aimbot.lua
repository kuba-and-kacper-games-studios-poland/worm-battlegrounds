--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local guideFolder: Folder

-- The guides showing now, for MatchHud's right-click lock-on
local shownGuides = {} --- @type { Combat_AimGuide }

-- The game's font (the GUI kit's Londrina Solid Black)
local LABEL_FONT: Font = Font.new("rbxassetid://113086061264643", Enum.FontWeight.Heavy)

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

--- @class Combat_Client_Aimbot
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Local Variables ]]

	guideFolder = I.Create("Folder")({
		Name = "Aimbot",
		Parent = I.Dirs.UmeWorkspace:WaitForChild(_localName),
	})

	--[[ Connections ]]

	I.Network.Fired("Combat_AimbotGuide", Module._onGuide)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Guide

--[[
	Draws the guides the server solved for the player (only while an admin turned their aimbot on), replacing the last
	ones; an empty list clears them.
]]
--- @param guides { Combat_AimGuide }
function Module._onGuide(guides)
	--[[ Saving ]]

	shownGuides = guides

	--[[ Drawing ]]

	guideFolder:ClearAllChildren()
	--- @param guide Combat_AimGuide
	for _index: number, guide in ipairs(guides) do
		Module._draw(guide)
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws one guide in the guide folder: a dot every stud and a half along its path, and its angle and power over the
	target, in the hit colour when the server found it lands on it.
]]
--- @param guide Combat_AimGuide
function Module._draw(guide)
	--[[ Local Variables ]]

	local color: Color3 = if guide.Hit then _settings.AIMBOT_HIT_COLOR else _settings.AIMBOT_MISS_COLOR
	local last: Vector3? = nil

	--[[ Path ]]

	for _index: number, point: Vector3 in ipairs(guide.Points) do
		if last and (point - last).Magnitude < 1.5 then
			continue
		end
		last = point
		I.Create("Part")({
			Name = "Dot",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 0.4,
			Position = point,
			Color = color,
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
			Parent = guideFolder,
		})
	end

	--[[ Label ]]

	local holder: Part = I.Create("Part")({
		Name = "Label",
		Size = Vector3.one,
		Position = guide.Target + Vector3.yAxis * 4,
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = guideFolder,
	})

	-- Sized in studs, so it keeps to the world at every zoom and screen
	local billboard: BillboardGui = I.Create("BillboardGui")({
		Size = UDim2.fromScale(8, 1.8),
		AlwaysOnTop = true,
		Parent = holder,
	})
	local label: TextLabel = I.Create("TextLabel")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		FontFace = LABEL_FONT,
		TextScaled = true,
		TextColor3 = color,
		Text = Module._getLabel(guide),
		Parent = billboard,
	})
	I.Create("UIStroke")({
		Thickness = 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		Parent = label,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Guides

--[[
	Returns the aim guides showing now: empty unless an admin turned the player's aimbot on and it's their turn.
]]
--- @return { Combat_AimGuide }
function Module.GetGuides()
	return shownGuides
end

--%%%%%%%%%%%%%%%%%%%% Get Label

--[[
	Returns a guide's angle and power as the HUD writes them ("45° 72%"); a gun's angle alone.
]]
--- @param guide Combat_AimGuide
--- @return string
function Module._getLabel(guide)
	--[[ Local Variables ]]

	local angle: number = math.round(math.deg(math.asin(math.sin(guide.Angle))))

	--[[ Returning ]]

	return if guide.Power then `{angle}° {math.round(guide.Power * 100)}%` else `{angle}°`
end

return Module
