--[[
	Created By: 	Nari
]]

local _localName: string = "CurrencyPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local UmeGui: Instance = script:FindFirstAncestor("Guis").Parent
local LibsDir: Instance = UmeGui:FindFirstChild("Libs")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Runtime = require(LibsDir:FindFirstChild("Runtime")) --- @type UmeGui_Runtime
local UIEmitter = require(LibsDir:FindFirstChild("Mirror"):FindFirstChild("UIEmitter")) --- @type UmeGui_Ume_Library_UIEmitter

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Orbs ]]

-- The orb image: ume's example currency (Coins) icon, as I.G_Currency.GetCurrencyIcon gives it
local ORB_TEXTURE: string = "rbxassetid://92339054232049"
-- Seconds an emitter lives after its burst, longer than an orb's flight
local EMITTER_LIFETIME: number = 5

-- The values ume's Currency slot (Components/Slot.lua) emits its orbs with, except where they fly: here to the mouse
local ORB_SIZE_SCALE: NumberRange = NumberRange.new(0.075, 0.125)
local ORB_VELOCITY_MIN: number = 420
local ORB_VELOCITY_MAX: number = 620
local ORB_LAUNCH_ANGLE: number = 35
local ORB_LIFETIME: NumberRange = NumberRange.new(1.35, 1.75)
local ORB_ATTRACT_AFTER: NumberRange = NumberRange.new(0.12, 0.2)
local ORB_ATTRACT_ARRIVE_RADIUS: number = 48
-- An orb's lifetime holds here until it comes within the arrive radius, so none fades out on the way; then it
-- shrinks out over the release duration
local ORB_ATTRACT_PAUSE_PROGRESS: number = 0.7
local ORB_ATTRACT_RELEASE_DURATION: number = 0.12
local ORB_Z_INDEX: number = 10

--[[ Mouse ]]

-- The mouse is followed through a transparent frame over the whole preview: its MouseMoved gives the position in
-- the space the orbs fly in, while UserInputService only follows the mouse while the 3D view has focus
local TRACKER_NAME: string = "__MouseTracker"

--[[ State ]]

local random: Random = Random.new()
-- The mouse's last position over each previewed orb area. Weak by area, so it goes with the preview
local mousePositions = setmetatable({}, { __mode = "k" }) --- @type { [GuiObject]: Vector2 }

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

--- @class UmeGui_Guis_System_Currency_Preview
local Module = {

	--[[ Settings ]]

	-- How many orbs one simulation bursts, and the button that bursts them
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Orbs", Label = "Orbs", Value = 5, Min = 1, Max = 30, Step = 1 },
		{ Control = "Button", Id = "S_Simulate", Text = "Simulate orbs" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Starts following the mouse over the preview, so the orbs know where it is when Simulate orbs is clicked.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Checks ]]

	local container: GuiObject = preview.View:Get("U_OrbsContainer").Instance

	-- Skip an orb area that already follows the mouse
	if container:FindFirstChild(TRACKER_NAME) then
		return
	end

	--[[ Tracker ]]

	-- The orb area is 80% of the screen, centred: 125% of it, moved out by 12.5%, covers the whole preview
	local tracker: Frame = Instance.new("Frame")
	tracker.Name = TRACKER_NAME
	tracker.Archivable = false
	tracker.BackgroundTransparency = 1
	tracker.Position = UDim2.fromScale(-0.125, -0.125)
	tracker.Size = UDim2.fromScale(1.25, 1.25)
	tracker.ZIndex = 0
	tracker.Parent = container

	--[[ Connections ]]

	tracker.MouseMoved:Connect(function(x: number, y: number)
		mousePositions[container] = Vector2.new(x, y)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Action

--[[
	Simulate orbs: bursts the orbs over the orb area as a Currency slot does when the currency grows, and flies them
	into the mouse's position, following it while they fly.
]]
--- @param preview UmeGui_Preview
function Module.Action(preview, id: string)
	--[[ Checks ]]

	-- Skip buttons other than Simulate orbs
	if id ~= "S_Simulate" then
		return
	end

	--[[ Emitting ]]

	local emitter = Module._createEmitter(preview.View:Get("U_OrbsContainer").Instance) --- @type UmeGui_UIEmitter_Instance
	emitter:Emit(preview.Values.S_Orbs)

	--[[ Cleanup ]]

	task.delay(EMITTER_LIFETIME, function()
		emitter:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Create Emitter

--[[
	Creates an emitter in the orb area with the Currency slot's orb look and flight, attracted to the mouse.
]]
--- @return UmeGui_UIEmitter_Instance
function Module._createEmitter(container: GuiObject)
	--[[ Library ]]

	-- The mirrored libraries run on UmeGui's I shim; this copy of UmeGui may not have started them
	UIEmitter._injectUme(Runtime)

	--[[ Returning ]]

	return UIEmitter.new({
		Parent = container,
		Container = container,
		Texture = ORB_TEXTURE,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 1.15),
			NumberSequenceKeypoint.new(0.25, 1),
			NumberSequenceKeypoint.new(0.85, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		SizeSpace = "Scale",
		SizeScale = ORB_SIZE_SCALE,
		AspectRatio = 1,
		Velocity = NumberRange.new(ORB_VELOCITY_MIN, ORB_VELOCITY_MAX),
		InitialVelocity = function(spawnAbsolutePoint: Vector2)
			-- Launch away from the mouse, turned by a random angle, as the slot launches away from itself
			local away: Vector2 = spawnAbsolutePoint - Module._getMousePosition(container)

			-- Launch straight down an orb that spawns on the mouse
			if away.Magnitude <= 0.001 then
				away = Vector2.new(0, 1)
			end

			local angle: number = math.rad(random:NextNumber(-ORB_LAUNCH_ANGLE, ORB_LAUNCH_ANGLE))
			local launchDirection: Vector2 = Vector2.new(away.X * math.cos(angle) - away.Y * math.sin(angle), away.X * math.sin(angle) + away.Y * math.cos(angle)).Unit

			return launchDirection * random:NextNumber(ORB_VELOCITY_MIN, ORB_VELOCITY_MAX)
		end,
		Lifetime = ORB_LIFETIME,
		Drag = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.2, 0.5),
			NumberSequenceKeypoint.new(0.4, 0.12),
			NumberSequenceKeypoint.new(1, 0.04),
		}),
		Rotation = NumberRange.new(-15, 15),
		RotationSpeed = NumberRange.new(-1, 1),
		FaceMovementDirection = false,
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(1, 1),
		-- The mouse's screen position: "absolute", as a Vector2 is otherwise read from the orb area's corner
		AttractTo = function(_container: GuiObject)
			return Module._getMousePosition(container)
		end,
		AttractToSpace = "absolute",
		AttractAfter = ORB_ATTRACT_AFTER,
		AttractStrength = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 0),
			NumberSequenceKeypoint.new(0.28, 2800),
			NumberSequenceKeypoint.new(0.5, 7000),
			NumberSequenceKeypoint.new(1, 12000),
		}),
		AttractMaxSpeed = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 700),
			NumberSequenceKeypoint.new(0.2, 1400),
			NumberSequenceKeypoint.new(0.45, 2400),
			NumberSequenceKeypoint.new(0.75, 3600),
			NumberSequenceKeypoint.new(1, 4800),
		}),
		AttractArriveRadius = ORB_ATTRACT_ARRIVE_RADIUS,
		AttractStopOnArrive = true,
		AttractDestroyOnArrive = false,
		AttractReleaseDuration = ORB_ATTRACT_RELEASE_DURATION,
		AttractPauseAtProgress = ORB_ATTRACT_PAUSE_PROGRESS,
		AttractArriveOnlyWhenPaused = false,
		CullOffscreen = false,
		Rate = 0,
		ZIndex = ORB_Z_INDEX,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Mouse Position

--[[
	Returns the mouse's last position over the preview, on screen; the orb area's centre until the mouse has moved
	over it.
]]
--- @return Vector2
function Module._getMousePosition(container: GuiObject)
	return mousePositions[container] or container.AbsolutePosition + container.AbsoluteSize / 2
end

return Module
