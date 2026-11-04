--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local _data: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local skins = {} --- @type { [string]: Cosmetics_SkinData }
local emotes = {} --- @type { [string]: Cosmetics_EmoteData }

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
	----------- DATA -----------
	----------------------------

	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Skins"):GetChildren()) do
		skins[row.Name] = require(row)
	end
	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Emotes"):GetChildren()) do
		emotes[row.Name] = require(row)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Cosmetics = {

		--[[ Methods ]]

		GetSkin = Module.GetSkin,
		GetSkins = Module.GetSkins,
		GetEmote = Module.GetEmote,
		GetEmotes = Module.GetEmotes,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Skin

--[[
	Returns a skin's row by its item id.
]]
--- @return Cosmetics_SkinData?
function Module.GetSkin(skinId: string)
	--[[ Checks ]]

	-- Check if the skin has a row
	if not skins[skinId] then
		warn(`[{_localName}::{script.Name}]: Skin ({skinId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return skins[skinId]
end

--%%%%%%%%%%%%%%%%%%%% Get Skins

--[[
	Returns every skin row, by item id.
]]
--- @return { [string]: Cosmetics_SkinData }
function Module.GetSkins()
	return skins
end

--%%%%%%%%%%%%%%%%%%%% Get Emote

--[[
	Returns an emote's row by its item id.
]]
--- @return Cosmetics_EmoteData?
function Module.GetEmote(emoteId: string)
	--[[ Checks ]]

	-- Check if the emote has a row
	if not emotes[emoteId] then
		warn(`[{_localName}::{script.Name}]: Emote ({emoteId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return emotes[emoteId]
end

--%%%%%%%%%%%%%%%%%%%% Get Emotes

--[[
	Returns every emote row, by item id.
]]
--- @return { [string]: Cosmetics_EmoteData }
function Module.GetEmotes()
	return emotes
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
