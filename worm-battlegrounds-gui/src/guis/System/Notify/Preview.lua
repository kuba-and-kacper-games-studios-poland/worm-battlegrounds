--[[
	Created By: 	Nari
]]

local _localName: string = "NotifyPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Example notifications and messages the toasts take in turn. A message shows its user's headshot and their name
-- in ume's Notify DEFAULT_USERNAME_COLOR before the message
--- @type { string }
local NOTIFICATIONS = { "Not enough coins!", "Saved!", "You found a rare pet!" }
--- @type { { [string]: any } }
local MESSAGES = {
	{ UserId = 1, Username = "Roblox", Message = "welcome to the game" },
	{ UserId = 156, Username = "builderman", Message = "hello everyone!" },
}
local USERNAME_COLOR: string = "rgb(200, 200, 200)"

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

--- @class UmeGui_Guis_System_Notify_Preview
local Module = {

	--[[ Settings ]]

	-- How many notifications and user messages are on screen
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Notifications", Label = "Notifications", Value = 2, Min = 0, Max = 6, Step = 1 },
		{ Control = "Slider", Id = "S_Messages", Label = "Messages", Value = 1, Min = 0, Max = 4, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills both containers with example toasts as ume's Notify shows them once their show tweens end: notifications
	with their text, and user messages with the headshot, the coloured name and the message over their background.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Notifications ]]

	local notifications = preview.Fill("PREFAB | Notification", preview.Values.S_Notifications) --- @type { UmeGui_Subview }

	--- @param notification UmeGui_Subview
	for index: number, notification in ipairs(notifications) do
		local messageText: TextLabel = notification:Get("S_MessageText").Instance
		messageText.Text = NOTIFICATIONS[(index - 1) % #NOTIFICATIONS + 1]
	end

	--[[ Messages ]]

	local messages = preview.Fill("PREFAB | Message", preview.Values.S_Messages) --- @type { UmeGui_Subview }

	--- @param message UmeGui_Subview
	for index: number, message in ipairs(messages) do
		local example = MESSAGES[(index - 1) % #MESSAGES + 1] --- @type { [string]: any }
		local userIcon: ImageLabel = message:Get("S_UserIcon").Instance
		local messageText: TextLabel = message:Get("S_MessageText").Instance
		local background: Frame = message:Get("S_Background").Instance
		userIcon.Image = `rbxthumb://type=AvatarHeadShot&id={example.UserId}&w=180&h=180`
		messageText.Text = `<font color="{USERNAME_COLOR}">@{example.Username}:</font> {example.Message}`
		background.BackgroundTransparency = 0
	end
end

return Module
