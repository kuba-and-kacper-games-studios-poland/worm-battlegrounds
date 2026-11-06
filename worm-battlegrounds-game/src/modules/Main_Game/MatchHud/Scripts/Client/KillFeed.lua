--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ Lines ]]

-- The lines shown, oldest first
local lines = {} --- @type { TextLabel }
local count: number = 0

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

--- @class MatchHud_Client_KillFeed
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Feed"] = gui:FindFirstChild("U_KillFeed") --- @type Frame
	prefabs["FeedLine"] = elems["Feed"]:FindFirstChild("PREFAB | FeedLine") --- @type TextLabel

	--[[ Connections ]]

	I.Network.Fired("Match_KnockedOut", Module._onKnockedOut)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Knocked Out

--[[
	Adds a line for a knockout, names in team colours: "Bax knocked out Ninja with the Grenade", or "Ninja fell into
	the water". The oldest line goes when there are too many, and each one goes after FEED_SECONDS.
]]
function Module._onKnockedOut(participantId: string, cause: string, killerId: string?, itemId: string?)
	--[[ Local Variables ]]

	local victim: string = Module._getName(participantId)
	local text: string

	if killerId and killerId ~= participantId then
		local row = if itemId then I.G_Arsenal.Get(itemId) else nil --- @type Arsenal_WeaponData?
		text = `{Module._getName(killerId)} knocked out {victim}` .. (if row then ` with the {row.Name}` else "")
	elseif cause == "Water" or cause == "Lava" then
		text = `{victim} fell into the {string.lower(cause)}`
	elseif cause == "Bounds" then
		text = `{victim} fell out of the arena`
	elseif cause == "Left" then
		text = `{victim} left the match`
	else
		text = `{victim} was knocked out`
	end

	--[[ Cloning ]]

	local line: TextLabel = prefabs["FeedLine"]:Clone()
	count += 1
	line.Name = "FeedLine"
	line.RichText = true
	line.Text = text
	line.LayoutOrder = count
	line.Visible = true
	line.Parent = elems["Feed"]
	table.insert(lines, line)

	--[[ Trimming ]]

	if #lines > _settings.FEED_LINES then
		table.remove(lines, 1):Destroy()
	end
	task.delay(_settings.FEED_SECONDS, function()
		local index: number? = table.find(lines, line)
		if index then
			table.remove(lines, index)
		end
		line:Destroy()
	end)

	--[[ Height ]]

	-- A line too long for the feed wraps onto a second line instead of shrinking
	line.Size = UDim2.new(1, 0, 0, line.Size.Y.Offset * Module._getLineCount(line))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Name

--[[
	Returns a participant's name in their team colour, as rich text.
]]
--- @return string
function Module._getName(participantId: string)
	--[[ Data ]]

	local entry: Configuration? = I.Match.GetParticipantInfo(participantId)
	if not entry then
		return "Someone"
	end

	--[[ Returning ]]

	local color: Color3 = entry:GetAttribute("Color") or Color3.new(1, 1, 1)
	return `<font color="#{color:ToHex()}">{entry:GetAttribute("DisplayName")}</font>`
end

--%%%%%%%%%%%%%%%%%%%% Get Line Count

--[[
	Returns how many lines a feed line's text takes at its design size in the feed's width: 2 when it doesn't fit on
	one. One line when the font can't be measured.
]]
--- @return number
function Module._getLineCount(line: TextLabel)
	--[[ Local Variables ]]

	local padding: UIPadding = elems["Feed"]:FindFirstChildOfClass("UIPadding")
	local width: number = elems["Feed"].Size.X.Offset - padding.PaddingLeft.Offset - padding.PaddingRight.Offset
	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = line.ContentText
	params.Font = line.FontFace
	params.Size = line:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize

	--[[ Measuring ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.TextService.GetTextBoundsAsync, I.S.TextService, params)

	--[[ Returning ]]

	return if success and result.X > width then 2 else 1
end

return Module
