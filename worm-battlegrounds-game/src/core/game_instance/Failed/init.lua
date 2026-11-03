--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = game:GetService("Players")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Message shown when the server fails to load.
local SERVER_MESSAGE = "Oops! Ume couldn't load the server instance. Please try again!"

-- Message shown when the client fails to load.
local CLIENT_MESSAGE = "Oops! Ume couldn't load the client instance. Please try again!"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--  ________  ______   ______  __        ________  _______
-- /        |/      \ /      |/  |      /        |/       \
-- $$$$$$$$//$$$$$$  |$$$$$$/ $$ |      $$$$$$$$/ $$$$$$$  |
-- $$ |__   $$ |__$$ |  $$ |  $$ |      $$ |__    $$ |  $$ |
-- $$    |  $$    $$ |  $$ |  $$ |      $$    |   $$ |  $$ |
-- $$$$$/   $$$$$$$$ |  $$ |  $$ |      $$$$$/    $$ |  $$ |
-- $$ |     $$ |  $$ | _$$ |_ $$ |_____ $$ |_____ $$ |__$$ |
-- $$ |     $$ |  $$ |/ $$   |$$       |$$       |$$    $$/
-- $$/      $$/   $$/ $$$$$$/ $$$$$$$$/ $$$$$$$$/ $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--[[
	For more information, please refer to the documentation at https://github.com/ume-roblox.
]]
--- @class Ume_Failed
local Failed = {}

--%%%%%%%%%%%%%%%%%%%% Server

--[[
    **SERVER** |
	Closes server and kicks all active and new players with a default error message.
]]
function Failed.CloseServer(errorMsg: string)
	-- Saving error
	warn(`Ume [Start] - {errorMsg}`)

	--[[ Kicking ]]

	-- Active Players
	for _, player in ipairs(Players:GetPlayers()) do
		player:Kick(SERVER_MESSAGE)
	end

	-- New Players
	Players.PlayerAdded:Connect(function(player)
		player:Kick(SERVER_MESSAGE)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Client

--[[
    **CLIENT** |
	Kicks local player from the game with a default error message.
]]
function Failed.Leave(errorMsg: string)
	-- Saving error
	warn(`Ume [Start] - {errorMsg}`)

	--[[ Kicking ]]

	Players.LocalPlayer:Kick(CLIENT_MESSAGE)
end

return Failed
