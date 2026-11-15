--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class MatchBoard_Rotation
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Map

--[[
	Returns the map a public card of a mode plays at a server time (now by default), the same on every server and
	client: worked out from the server's clock, it changes every MAP_SECONDS. Each mode walks through a shuffle of the rotation's maps made for its
	size (MAP_POOL), so a map comes back only after the others, and never twice in a row.
]]
--- @return string
function Module.GetMap(mode: string, size: number, at: number?)
	--[[ Local Variables ]]

	local pool = Module.GetPool(size) --- @type { string }
	local slot: number = math.floor((at or I.S.Workspace:GetServerTimeNow()) / _settings.MAP_SECONDS)
	local round: number = slot // #pool

	--[[ Shuffling ]]

	local order = Module._getShuffle(pool, mode, round) --- @type { string }

	-- A round that would start on the map the last one ended on starts on its second map instead
	if #order > 1 and order[1] == Module._getShuffle(pool, mode, round - 1)[#order] then
		order[1], order[2] = order[2], order[1]
	end

	--[[ Returning ]]

	return order[slot % #pool + 1]
end

--%%%%%%%%%%%%%%%%%%%% Get Seconds Left

--[[
	Returns how many seconds are left before every public card moves on to its next map.
]]
--- @return number
function Module.GetSecondsLeft()
	return _settings.MAP_SECONDS - I.S.Workspace:GetServerTimeNow() % _settings.MAP_SECONDS
end

--%%%%%%%%%%%%%%%%%%%% Get Pool

--[[
	Returns the rotation's maps made for a match size, in MAP_POOL order; every map in it when none is.
]]
--- @return { string }
function Module.GetPool(size: number)
	--[[ Local Variables ]]

	local pool = {} --- @type { string }

	--[[ Collecting ]]

	for _index: number, mapId: string in ipairs(_settings.MAP_POOL) do
		if table.find(_settings.MAPS[mapId].Sizes, size) then
			table.insert(pool, mapId)
		end
	end

	--[[ Returning ]]

	return if #pool > 0 then pool else table.clone(_settings.MAP_POOL)
end

--%%%%%%%%%%%%%%%%%%%% Get Shuffle

--[[
	Returns one round of a mode's rotation: the pool shuffled by a seed made of the mode and the round's number, so
	every server shuffles it the same way.
]]
--- @param pool { string }
--- @return { string }
function Module._getShuffle(pool, mode: string, round: number)
	--[[ Local Variables ]]

	local order = table.clone(pool) --- @type { string }
	local seed: number = round * 1000
	for index: number = 1, #mode do
		seed += string.byte(mode, index) * index
	end
	local random: Random = Random.new(seed)

	--[[ Shuffling ]]

	random:Shuffle(order)

	--[[ Returning ]]

	return order
end

return Module
