--[[
	Created By: 	HungryN00B
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Camera ]]

-- The match camera's own numbers (MatchCamera): a 30° field of view, 110 studs from the play plane
local TAN_HALF_FOV: number = math.tan(math.rad(15))
local CAMERA_DISTANCE: number = 110

-- Where the camera starts, farther back, and how fast it settles in
local CAMERA_START: number = 150
local CAMERA_SETTLE: number = 1.4

-- The camera's height over the map's bottom, which puts the far range's foot at 60% of the screen
local CAMERA_HEIGHT: number = 64.8

-- The camera's slow sway across the map: how far either way (studs), how fast (radians a second) and where it starts
local SWAY_DISTANCE: number = 110
local SWAY_RATE: number = 0.127
local SWAY_PHASE: number = -0.9

-- How fast clouds drift on their own, studs a second
local CLOUD_DRIFT: number = 4

-- Nothing comes nearer the camera than this, in studs
local MIN_DISTANCE: number = 8

--[[ Moves ]]

-- A whip between scenes: how far the camera swings (studs), how long it takes, and how far the sky slides with it
local WHIP_DISTANCE: number = 650
local WHIP_SECONDS: number = 0.42
local WHIP_SKY_SHARE: number = 0.15

-- The intro's whip in, and the reveal's flight through the layers to this camera distance
local INTRO_SECONDS: number = 0.46
local REVEAL_SECONDS: number = 0.8
local REVEAL_DISTANCE: number = -270

-- The plate rises in and drops away; hidden, it sits this much of the screen lower
local PLATE_IN_TWEENINFO: TweenInfo = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local PLATE_OUT_TWEENINFO: TweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local PLATE_DROP: number = 0.36

--[[ Progress ]]

-- The bar creeps toward PROGRESS_HOLD while loading, then fills once the player is ready
local PROGRESS_HOLD: number = 0.9
local PROGRESS_RATE: number = 0.28
local PROGRESS_READY_RATE: number = 5

--[[ Dots ]]

-- The searching dots' pulse, and the gap after the title they sit in (a share of the screen's width)
local DOTS_RATE: number = 6
local DOTS_LAG: number = 0.7
local DOTS_GAP: number = 0.012

--[[ State ]]

local states = {} --- @type { [ScreenGui]: TransitionMotion_State }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Clamp

--[[
	Keeps a share between 0 and 1.
]]
--- @return number
local function clamp(value: number)
	return math.clamp(value, 0, 1)
end

--%%%%%%%%%%%%%%%%%%%% Out Cubic

--[[
	Eases out: fast first, settling at the end.
]]
--- @return number
local function outCubic(value: number)
	return 1 - (1 - value) ^ 3
end

--%%%%%%%%%%%%%%%%%%%% Project

--[[
	Where a point of the map at a depth behind the play plane lands on the screen, in pixels, and how many pixels a stud
	there takes across and up.
]]
--- @return number
--- @return number
--- @return number
--- @return number
local function project(x: number, y: number, depth: number, cameraX: number, distance: number, width: number, height: number)
	--[[ Local Variables ]]

	local reach: number = math.max(distance + depth, MIN_DISTANCE)
	local halfHeight: number = reach * TAN_HALF_FOV
	local halfWidth: number = halfHeight * width / height

	--[[ Returning ]]

	return width * (0.5 + (x - cameraX) / (2 * halfWidth)), height * (0.5 - (y - CAMERA_HEIGHT) / (2 * halfHeight)), width / (2 * halfWidth), height / (2 * halfHeight)
end

--%%%%%%%%%%%%%%%%%%%% Set Alpha

--[[
	Shows a layer at its own transparency times how much its scene shows.
]]
local function setAlpha(element: GuiObject, alpha: number)
	--[[ Local Variables ]]

	local base: number = element:GetAttribute("L_Alpha") or 0
	local transparency: number = 1 - (1 - base) * alpha

	--[[ Applying ]]

	if element:IsA("ImageLabel") then
		element.ImageTransparency = transparency
	else
		element.BackgroundTransparency = transparency
	end
end

--%%%%%%%%%%%%%%%%%%%% Pose Scene

--[[
	Places every layer of one scene for the camera at this moment: the sky, the tiled ranges (repeating end to end), the
	drifting clouds, the ground fills and the weather.
]]
--- @param elements { GuiObject }
local function poseScene(elements, cameraX: number, distance: number, clock: number, width: number, height: number, whip: number, alpha: number)
	--[[ Local Variables ]]

	local x: number = cameraX + whip

	--[[ Layers ]]

	for _index: number, element: GuiObject in ipairs(elements) do
		local kind: string = element:GetAttribute("L_Kind")

		-- The sky stands infinitely far: only the whip slides it, its horizon on the far range's foot
		if kind == "Sky" then
			local _skyX: number, horizon: number = project(0, 0, 1100, x, distance, width, height)
			local size: number = width * 1.02
			element.Size = UDim2.fromOffset(size, size)
			element.Position = UDim2.fromOffset((width - size) / 2 - whip / WHIP_DISTANCE * WHIP_SKY_SHARE * width, horizon - element:GetAttribute("L_Horizon") * size)
		elseif kind == "Mote" then
			local depth: number = element:GetAttribute("M_Depth")
			local _baseX: number, _baseY: number, baseScaleX: number, baseScaleY: number = project(x, 0, depth, x, distance, width, height)
			local spanX: number = width / baseScaleX * 1.1
			local low: boolean = element:GetAttribute("M_Low")
			local spanY: number = if low then 70 else height / baseScaleY * 1.1
			local wobble: number = math.sin(clock * 1.3 + element:GetAttribute("M_Phase")) * element:GetAttribute("M_Wobble")
			local bob: number = math.sin(clock * 0.9 + element:GetAttribute("M_Phase")) * element:GetAttribute("M_Bob")
			local worldX: number = (element:GetAttribute("M_U") * spanX + element:GetAttribute("M_VX") * clock + wobble) % spanX - spanX / 2 + x
			local worldY: number = (element:GetAttribute("M_V") * spanY + element:GetAttribute("M_VY") * clock + bob) % spanY
			worldY += if low then -8 else CAMERA_HEIGHT - spanY / 2
			local screenX: number, screenY: number, scaleX: number, scaleY: number = project(worldX, worldY, depth, x, distance, width, height)
			local thick: number = element:GetAttribute("M_Thick")
			local size: number = element:GetAttribute("M_Size")
			element.Size = UDim2.fromOffset(math.max(size * scaleX, 1.2), math.max((if thick > 0 then thick else size) * scaleY, 1.2))
			element.Position = UDim2.fromOffset(screenX, screenY)
			element.Rotation = clock * element:GetAttribute("M_Spin") + element:GetAttribute("M_Phase") * 50
		else
			local depth: number = element:GetAttribute("L_Depth")
			local rowHeight: number = element:GetAttribute("L_Height")
			local drift: number = if kind == "Cloud" then clock * CLOUD_DRIFT else 0
			local screenX: number, top: number, scaleX: number, scaleY: number = project(element:GetAttribute("L_X") + drift, element:GetAttribute("L_Bottom") + rowHeight, depth, x, distance, width, height)
			local w: number = element:GetAttribute("L_Width") * scaleX
			local h: number = rowHeight * scaleY
			local left: number = screenX - w / 2

			-- A ground fill spans the screen and stops at its bottom edge; tiles repeat over their range's span; clouds wrap round the screen
			if kind == "Fill" then
				left, w, h = -2, width + 4, math.max(0, math.min(h, height * 1.02 - top))
			elseif kind == "Tile" then
				local span: number = element:GetAttribute("L_Span") * scaleX
				left = (left + w) % span - w

				-- One pixel wider, so neighbouring tiles never show a seam between them
				w += 1
			else
				local span: number = width + w
				left = (left + w) % span - w
			end
			element.Size = UDim2.fromOffset(w, h)
			element.Position = UDim2.fromOffset(left, top)
		end
		setAlpha(element, alpha)
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Returns a scene's layers, kept until the scene changes.
]]
--- @return { GuiObject }
local function getElements(state: TransitionMotion_State, scene: Frame)
	--[[ Checks ]]

	-- Check if the scene's layers are already listed
	local cached = state.Elements[scene] --- @type { GuiObject }?
	if cached then
		return cached
	end

	--[[ Collecting ]]

	local elements = {} --- @type { GuiObject }
	for _index: number, child: Instance in ipairs(scene:GetChildren()) do
		if child:IsA("GuiObject") and child:GetAttribute("L_Kind") then
			table.insert(elements, child)
		end
	end

	--[[ Returning ]]

	state.Elements[scene] = elements
	return elements
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class TransitionMotion
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Moves a teleport card every frame until it's gone: the camera's sway over its scene, whips when its scene changes,
	the progress bar and the searching dots. Its clock and progress live in its attributes, so a copy handed through a
	teleport carries on where this one was.
]]
function Module.Play(card: ScreenGui)
	--[[ Checks ]]

	-- Check if the card already moves
	if states[card] then
		return
	end

	--[[ Local Variables ]]

	local state = {
		Clock = card:GetAttribute("Transition_Clock") or 0,
		Progress = card:GetAttribute("Transition_Progress") or 0,
		Shown = card:GetAttribute("Transition_Scene"),
		WhipFrom = nil,
		WhipAt = 0,
		IntroAt = nil,
		RevealAt = nil,
		Elements = {},
		Connection = nil,
	} --- @type TransitionMotion_State

	--[[ Saving ]]

	states[card] = state

	--[[ Connections ]]

	state.Connection = RunService.RenderStepped:Connect(function(deltaTime: number)
		Module._step(card, state, math.min(deltaTime, 0.1))
	end)
	card.Destroying:Once(function()
		state.Connection:Disconnect()
		states[card] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%% Intro

--[[
	Whips the scene in from the side over the game while the plate rises, in under half a second.
]]
function Module.Intro(card: ScreenGui)
	--[[ Elements ]]

	local plate: Frame = card:FindFirstChild("U_Plate", true)

	--[[ Applying ]]

	states[card].IntroAt = os.clock()
	plate.Position = UDim2.fromScale(0.5, 0.5 + PLATE_DROP)

	--[[ Tweening ]]

	local Rise_TweenGoal = { Position = UDim2.fromScale(0.5, 0.5) }
	local Rise_Tween: Tween = TweenService:Create(plate, PLATE_IN_TWEENINFO, Rise_TweenGoal)
	Rise_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Reveal

--[[
	Drops the plate and flies the camera through the layers into the real map behind them, then returns.
]]
function Module.Reveal(card: ScreenGui)
	--[[ Elements ]]

	local plate: Frame = card:FindFirstChild("U_Plate", true)

	--[[ Applying ]]

	states[card].RevealAt = os.clock()

	--[[ Tweening ]]

	local Drop_TweenGoal = { Position = UDim2.fromScale(0.5, 0.5 + PLATE_DROP) }
	local Drop_Tween: Tween = TweenService:Create(plate, PLATE_OUT_TWEENINFO, Drop_TweenGoal)
	Drop_Tween:Play()

	--[[ Waiting ]]

	task.wait(REVEAL_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Settle

--[[
	Poses a copy of a card as it shows now, settled (no whip, the plate in place) and with only its current scene, for
	Roblox to hold through a teleport: a copy is never on the screen, so it's posed at the original's size.
]]
function Module.Settle(copy: ScreenGui, size: Vector2)
	--[[ Elements ]]

	local backdrop: Frame = copy:FindFirstChild("U_Backdrop")
	local scenes: Frame = backdrop:FindFirstChild("U_Scene")
	local plate: Frame = backdrop:FindFirstChild("U_Plate")
	local shade: CanvasGroup = backdrop:FindFirstChild("U_Shade")

	--[[ Local Variables ]]

	local clock: number = copy:GetAttribute("Transition_Clock") or 0
	local shown: string? = copy:GetAttribute("Transition_Scene")
	local cameraX: number = SWAY_DISTANCE * math.sin(clock * SWAY_RATE + SWAY_PHASE)
	local distance: number = CAMERA_DISTANCE + (CAMERA_START - CAMERA_DISTANCE) * math.exp(-clock * CAMERA_SETTLE)
	local state = { Elements = {} } --- @type TransitionMotion_State

	--[[ Posing ]]

	for _index: number, scene: Instance in ipairs(scenes:GetChildren()) do
		if scene.Name ~= shown then
			scene:Destroy()
		elseif scene:IsA("Frame") then
			scene.Visible = true
			poseScene(getElements(state, scene), cameraX, distance, clock, size.X, size.Y, 0, 1)
		end
	end

	--[[ Applying ]]

	plate.Position = UDim2.fromScale(0.5, 0.5)
	backdrop.BackgroundTransparency = 0
	shade.GroupTransparency = 0
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	One frame of a card: its clock, camera, scenes, progress and dots.
]]
function Module._step(card: ScreenGui, state: TransitionMotion_State, deltaTime: number)
	--[[ Elements ]]

	local backdrop: Frame = card:FindFirstChild("U_Backdrop")
	local scenes: Frame = backdrop:FindFirstChild("U_Scene")
	local shade: CanvasGroup = backdrop:FindFirstChild("U_Shade")
	local plate: Frame = backdrop:FindFirstChild("U_Plate")
	local track: Frame = plate:FindFirstChild("S_Track")
	local dots: Frame = plate:FindFirstChild("S_Dots")
	local title: TextLabel = plate:FindFirstChild("S_Title")

	--[[ Checks ]]

	-- Skip frames before the card has a size
	local width: number = backdrop.AbsoluteSize.X
	local height: number = backdrop.AbsoluteSize.Y
	if width < 1 or height < 1 then
		return
	end

	--[[ Clock ]]

	local now: number = os.clock()
	state.Clock += deltaTime
	card:SetAttribute("Transition_Clock", state.Clock)

	--[[ Camera ]]

	local cameraX: number = SWAY_DISTANCE * math.sin(state.Clock * SWAY_RATE + SWAY_PHASE)
	local distance: number = CAMERA_DISTANCE + (CAMERA_START - CAMERA_DISTANCE) * math.exp(-state.Clock * CAMERA_SETTLE)
	local fade: number = 1
	if state.RevealAt then
		local reveal: number = clamp((now - state.RevealAt) / REVEAL_SECONDS)
		distance -= (distance - REVEAL_DISTANCE) * reveal ^ 3
		fade = 1 - clamp((reveal - 0.45) / 0.4)
	end

	--[[ Whips ]]

	-- A new scene whips in over the last one
	local shown: string? = card:GetAttribute("Transition_Scene")
	if shown ~= state.Shown then
		state.WhipFrom = state.Shown
		state.WhipAt = now
		state.Shown = shown
	end
	local whip: number = clamp((now - state.WhipAt) / WHIP_SECONDS)
	if whip >= 1 then
		state.WhipFrom = nil
	end
	local intro: number = if state.IntroAt then clamp((now - state.IntroAt) / INTRO_SECONDS) else 1

	--[[ Scenes ]]

	for _index: number, scene: Instance in ipairs(scenes:GetChildren()) do
		if not scene:IsA("Frame") then
			continue
		end

		local offset: number = 0
		local alpha: number = 0
		if scene.Name == state.Shown then
			offset = -WHIP_DISTANCE * (1 - outCubic(intro))
			alpha = clamp(intro / 0.3)
			if state.WhipFrom then
				offset -= WHIP_DISTANCE * (1 - outCubic(clamp((whip - 0.3) / 0.7)))
				alpha *= clamp((whip - 0.3) / 0.2)
			end
		elseif scene.Name == state.WhipFrom then
			offset = WHIP_DISTANCE * clamp(whip / 0.7) ^ 3
			alpha = 1 - clamp((whip - 0.35) / 0.25)
		end
		scene.Visible = alpha > 0
		if scene.Visible then
			poseScene(getElements(state, scene), cameraX, distance, state.Clock, width, height, offset, alpha * fade)
		end
	end

	--[[ Backdrop ]]

	-- The intro opens on the game and the reveal ends on it, so the backdrop and shade fade with the scene
	local cover: number = clamp(intro / 0.3) * fade
	backdrop.BackgroundTransparency = 1 - cover
	shade.GroupTransparency = 1 - cover

	--[[ Progress ]]

	local ready: boolean = card:GetAttribute("Transition_Ready") == true
	if ready then
		state.Progress += (1 - state.Progress) * math.min(1, deltaTime * PROGRESS_READY_RATE)
	else
		state.Progress += (PROGRESS_HOLD - state.Progress) * deltaTime * PROGRESS_RATE
	end
	card:SetAttribute("Transition_Progress", state.Progress)
	local fill: Frame = track:FindFirstChild("Fill")
	local shell: ImageLabel = track:FindFirstChild("Shell")
	fill.Size = UDim2.fromScale(state.Progress, 1)
	shell.Position = UDim2.fromScale(state.Progress, 0.5)
	shell.Rotation = state.Progress * track.AbsoluteSize.X / (math.pi * math.max(shell.AbsoluteSize.Y, 1)) * 360

	--[[ Dots ]]

	dots.Visible = card:GetAttribute("Transition_Searching") == true
	if dots.Visible then
		local titleScale: number = title.Position.X.Scale + (title.TextBounds.X / width) + DOTS_GAP
		dots.Position = UDim2.fromScale(titleScale, dots.Position.Y.Scale)
		for _dotIndex: number, dot: Instance in ipairs(dots:GetChildren()) do
			if dot:IsA("Frame") then
				local pulse: number = math.max(0, math.sin(state.Clock * DOTS_RATE - dot.LayoutOrder * DOTS_LAG))
				dot.BackgroundTransparency = 0.65 * (1 - pulse)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
