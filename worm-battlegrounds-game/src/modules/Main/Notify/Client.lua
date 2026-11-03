--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Notify"

--- @type Notify_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ Caching ]]

local thumbnailCache = {} --- @type { [number]: string }
local thumbnailRequests = {} --- @type { [number]: { ImageLabel } }

--[[ Active ]]

local activeNotifications = {} --- @type { GuiObject }
local activeMessages = {} --- @type { GuiObject }
local messageTypewriters = {} --- @type { [GuiObject]: RBXScriptConnection }
local removingEntries = {} --- @type { [GuiObject]: boolean }

--[[ Stacking ]]

--- @type { [string]: Notify_StackedNotification }
local stackedNotifications = {}

--[[ Rich Text ]]

--- @type { [string]: string }
local richTextEscapes = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&apos;" }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Escape Rich Text

--[[
	Returns the text with the characters rich text reads as markup turned into their entities.
]]
--- @return string
local function escapeRichText(text: string)
	return (string.gsub(text, "[&<>\"']", richTextEscapes))
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
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Notify_ShowNotification", { "string", { Type = "string", Optional = true }, { Type = "number", Optional = true }, { Type = "string", Optional = true } })
	I.Network.Fired("Notify_ShowNotification", Module.ShowNotification)

	I.Network.GetEvent("Notify_ShowMessage", { "number", "string", "string", { Type = "number", Optional = true }, { Type = "string", Optional = true } })
	I.Network.Fired("Notify_ShowMessage", Module.ShowMessage)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Notify = {

		--[[ Control ]]

		ShowNotification = Module.ShowNotification,
		ShowMessage = Module.ShowMessage,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	local notifyGui: ScreenGui = I.UserInterface.UI["Notify"]

	--[[ General ]]

	elems["Container-Notification"] = notifyGui:FindFirstChild("U_Container-Notification", true) --- @type Frame
	elems["Container-Message"] = notifyGui:FindFirstChild("U_Container-Message", true) --- @type Frame

	--[[ Prefabs ]]

	prefabs["Notification"] = elems["Container-Notification"]:FindFirstChild("PREFAB | Notification", true) --- @type GuiObject
	prefabs["Message"] = elems["Container-Message"]:FindFirstChild("PREFAB | Message", true) --- @type GuiObject

	-- Hiding Prefabs
	prefabs["Notification"].Visible = false
	prefabs["Message"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Notification

--[[
	Shows notification toast.
	A repeat of a notification still on screen adds to its counter instead of showing another toast.
]]
function Module.ShowNotification(message: string, gradientId: string?, duration: number?, soundId: string?)
	--%%%%%%%%%%%%%%%%%%%% Stacking

	--- @type Notify_StackedNotification?
	local stacked = stackedNotifications[message]

	-- Count a repeat of a notification still on screen
	if stacked then
		Module._stackNotification(stacked, message, duration)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Display

	-- Clone and show
	local newNotification: GuiObject = prefabs["Notification"]:Clone()
	newNotification.Visible = true
	newNotification.Parent = elems["Container-Notification"]

	--[[ Active ]]

	table.insert(activeNotifications, newNotification)
	while #activeNotifications > _settings.NOTIFICATION_DISPLAY_LIMIT do
		Module._removeEntry(activeNotifications[1], activeNotifications)
	end

	--[[ Elements ]]

	-- Find text
	local messageText: TextLabel = newNotification:FindFirstChild("S_MessageText", true) --- @type TextLabel

	--[[ Updating Properties ]]

	-- Update text
	messageText.Text = `{message}`
	messageText.UIGradient.Color = I.Gradient.GetColor(gradientId)

	--[[ Playing Sound ]]

	-- Play sound
	I.Sound.Play({
		Name = soundId or _settings.DEFAULT_NOTIFICATION_SOUND,
		Volume = 1,
		Location = nil,
		SoundGroup = "SFX",

		PitchMin = 0.95,
		PitchMax = 1,
	})

	--%%%%%%%%%%%%%%%%%%%% Animation

	-- Reset scale
	newNotification.UIScale.Scale = 0

	--[[ Showing ]]

	-- Show tween
	local Show_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local Show_Tween: Tween = I.S.TweenService:Create(newNotification.UIScale, Show_TweenInfo, { Scale = 1 })
	Show_Tween:Play()

	--[[ Removing ]]

	-- Delay removal
	local removeThread: thread = task.delay(tonumber(duration) or _settings.DEFAULT_NOTIFICATION_DURATION, function()
		Module._removeEntry(newNotification, activeNotifications)
	end)

	--[[ Stacking ]]

	stackedNotifications[message] = {
		Toast = newNotification,
		MessageText = messageText,
		Count = 1,
		RemoveThread = removeThread,
	}
end

--%%%%%%%%%%%%%%%%%%%% Show Message

--[[
	Shows user message toast
]]
function Module.ShowMessage(userId: number, username: string, message: string, duration: number?, soundId: string?)
	--%%%%%%%%%%%%%%%%%%%% Display

	-- Clone and show
	local newMessage: GuiObject = prefabs["Message"]:Clone()
	newMessage.Visible = true
	newMessage.Parent = elems["Container-Message"]

	--[[ Active ]]

	table.insert(activeMessages, newMessage)
	while #activeMessages > _settings.MESSAGE_DISPLAY_LIMIT do
		Module._removeEntry(activeMessages[1], activeMessages)
	end

	--[[ Elements ]]

	-- Find elements
	local background: GuiObject = newMessage:FindFirstChild("S_Background", true) --- @type GuiObject
	local userIcon: ImageLabel = newMessage:FindFirstChild("S_UserIcon", true) --- @type ImageLabel
	local messageText: TextLabel = newMessage:FindFirstChild("S_MessageText", true) --- @type TextLabel
	local iconScale: UIScale = userIcon:FindFirstChild("UIScale") --- @type UIScale

	--[[ Updating Properties ]]

	-- Reset elements
	newMessage.UIScale.Scale = 1
	background.BackgroundTransparency = 1
	iconScale.Scale = 0

	-- Reset text
	messageText.RichText = true
	messageText.Text = ""

	--[[ User Icon ]]

	-- Check cache
	local cachedThumbnail: string? = thumbnailCache[userId]
	if cachedThumbnail then
		-- Apply cached thumbnail
		userIcon.Image = cachedThumbnail
	else
		local pendingIcons = thumbnailRequests[userId] --- @type { ImageLabel }?
		if pendingIcons then
			-- Queue icon
			table.insert(pendingIcons, userIcon)
		else
			-- Create request
			thumbnailRequests[userId] = { userIcon }

			task.spawn(function()
				--[[ Fetching ]]

				-- Fetch thumbnail
				local success: boolean, thumbnail: string? = pcall(function()
					return I.S.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)

				--[[ Resolving ]]

				-- Resolve icons
				local requestedIcons = thumbnailRequests[userId] --- @type { ImageLabel }

				-- Clear request
				thumbnailRequests[userId] = nil

				-- Check result
				if not success or not thumbnail then
					return
				end

				--[[ Caching ]]

				-- Cache thumbnail
				thumbnailCache[userId] = thumbnail

				--[[ Updating ]]

				for _, requestedIcon: ImageLabel in ipairs(requestedIcons) do
					-- Update active icons
					if requestedIcon.Parent then
						requestedIcon.Image = thumbnail
					end
				end
			end)
		end
	end

	--[[ Playing Sound ]]

	-- Play sound
	I.Sound.Play({
		Name = soundId or _settings.DEFAULT_MESSAGE_SOUND,
		Volume = 1,
		Location = nil,
		SoundGroup = "SFX",

		PitchMin = 0.95,
		PitchMax = 1,
	})

	--%%%%%%%%%%%%%%%%%%%% Animation

	--[[ Background ]]

	-- Background tween
	local Background_TweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local Background_Tween: Tween = I.S.TweenService:Create(background, Background_TweenInfo, { BackgroundTransparency = 0 })
	Background_Tween:Play()

	--[[ User Icon ]]

	-- Icon tween
	local Icon_TweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local Icon_Tween: Tween = I.S.TweenService:Create(iconScale, Icon_TweenInfo, { Scale = 1 })
	Icon_Tween:Play()

	--[[ Typewriter ]]

	-- Build graphemes
	local usernameText: string = `@{username}:`
	local graphemes = {} --- @type { string }
	local usernameLength: number = 0
	for first: number, last: number in utf8.graphemes(usernameText) do
		table.insert(graphemes, escapeRichText(string.sub(usernameText, first, last)))
		usernameLength += 1
	end
	table.insert(graphemes, " ")
	for first: number, last: number in utf8.graphemes(message) do
		table.insert(graphemes, escapeRichText(string.sub(message, first, last)))
	end

	local revealedUsername: string = ""
	local revealedMessage: string = ""
	local graphemeIndex: number = 0
	local typewriterElapsed: number = 0
	local typewriterConnection: RBXScriptConnection
	local usernameColorValue: Color3 = _settings.USERNAME_COLORS[userId] or _settings.DEFAULT_USERNAME_COLOR
	local usernameColor: string = `rgb({math.round(usernameColorValue.R * 255)}, {math.round(usernameColorValue.G * 255)}, {math.round(usernameColorValue.B * 255)})`

	-- Connect typewriter
	typewriterConnection = I.S.RunService.Heartbeat:Connect(function(deltaTime: number)
		-- Check parent
		if not newMessage.Parent then
			typewriterConnection:Disconnect()
			return
		end

		-- Accumulate time
		typewriterElapsed += deltaTime

		-- Advance graphemes
		while typewriterElapsed >= 0.0075 and graphemeIndex < #graphemes do
			typewriterElapsed -= 0.0075
			graphemeIndex += 1

			local nextGrapheme: string = graphemes[graphemeIndex]
			if graphemeIndex <= usernameLength then
				revealedUsername ..= nextGrapheme
			elseif graphemeIndex > usernameLength + 1 then
				revealedMessage ..= nextGrapheme
			end
		end

		--[[ Updating ]]

		-- Format text
		local finalText: string = ""
		if revealedUsername ~= "" then
			finalText ..= I.RichText.Format(revealedUsername, {
				Color = usernameColor,
				Font_Weight = "Heavy",
			})
		end
		if graphemeIndex > usernameLength then
			finalText ..= " "
		end
		if revealedMessage ~= "" then
			finalText ..= I.RichText.Format(revealedMessage, {
				Color = "rgb(255, 255, 255)",
				Font_Weight = "ExtraBold",
			})
		end
		messageText.Text = finalText

		-- Finish typewriter
		if graphemeIndex >= #graphemes then
			typewriterConnection:Disconnect()
		end
	end)
	messageTypewriters[newMessage] = typewriterConnection

	--[[ Removing ]]

	-- Delay removal
	task.delay(tonumber(duration) or _settings.DEFAULT_MESSAGE_DURATION, function()
		Module._removeEntry(newMessage, activeMessages)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Stack Notification

--[[
	Counts a repeat of a notification on screen and restarts its removal timer.
]]
--- @param stacked Notify_StackedNotification
function Module._stackNotification(stacked, message: string, duration: number?)
	--[[ Counting ]]

	stacked.Count += 1
	stacked.MessageText.Text = `{message} x{stacked.Count}`

	--[[ Active ]]

	-- Move it to the newest slot so the display limit removes older toasts first
	table.remove(activeNotifications, table.find(activeNotifications, stacked.Toast))
	table.insert(activeNotifications, stacked.Toast)

	--[[ Removing ]]

	-- Restart the removal timer
	task.cancel(stacked.RemoveThread)
	stacked.RemoveThread = task.delay(tonumber(duration) or _settings.DEFAULT_NOTIFICATION_DURATION, function()
		Module._removeEntry(stacked.Toast, activeNotifications)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Remove Entry

--[[
	Tweens out and destroys an active notification or message entry.
]]
--- @param activeList { GuiObject }
function Module._removeEntry(entry: GuiObject, activeList)
	--[[ Checks ]]

	-- Already removing
	if removingEntries[entry] then
		return
	end

	--[[ Stacking ]]

	--- @param stacked Notify_StackedNotification
	for stackedMessage: string, stacked in pairs(stackedNotifications) do
		-- Forget the stacked notification this toast shows
		if stacked.Toast == entry then
			stackedNotifications[stackedMessage] = nil
			break
		end
	end

	--[[ Checks ]]

	-- Missing parent
	if not entry.Parent then
		local index: number? = table.find(activeList, entry)
		if index then
			table.remove(activeList, index)
		end
		messageTypewriters[entry] = nil
		return
	end

	--[[ Preparing ]]

	removingEntries[entry] = true

	local index: number? = table.find(activeList, entry)
	if index then
		table.remove(activeList, index)
	end

	local typewriterConnection = messageTypewriters[entry] --- @type RBXScriptConnection?
	if typewriterConnection then
		if typewriterConnection.Connected then
			typewriterConnection:Disconnect()
		end
		messageTypewriters[entry] = nil
	end

	--[[ Removing ]]

	task.spawn(function()
		-- Missing parent
		if not entry.Parent then
			removingEntries[entry] = nil
			return
		end

		local Hide_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local Hide_Tween: Tween = I.S.TweenService:Create(entry.UIScale, Hide_TweenInfo, { Scale = 0 })
		Hide_Tween:Play()

		Hide_Tween.Completed:Wait()
		entry:Destroy()
		removingEntries[entry] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
