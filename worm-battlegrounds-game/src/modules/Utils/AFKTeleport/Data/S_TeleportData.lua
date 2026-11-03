--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AFKTeleport"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local defaultMapId: string = `{I.Config.PlaceLoader.PlaceId}-{I.Config.PlaceLoader.MapId}`

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @class AFKTeleport_S_TeleportData
local data = {
	[defaultMapId] = {},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Update

data[defaultMapId]["Update"] = function(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AFKTeleport"]

	--[[ Getting Map Entry ]]

	local mapEntry: table = moduleData.PlaceData[defaultMapId]
	if not mapEntry then
		return
	end

	--[[ Saving Location ]]

	if player.Character then
		local pos: CFrame = player.Character:GetPivot()
		mapEntry.Location = { X = pos.Position.X, Y = pos.Position.Y, Z = pos.Position.Z }
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve

data[defaultMapId]["Resolve"] = function(player: Player, character: Model)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AFKTeleport"]

	--[[ Getting Map Entry ]]

	local mapEntry: table = moduleData.PlaceData[defaultMapId]
	if not mapEntry then
		return
	end

	--[[ Moving Character ]]

	if character and mapEntry.Location then
		character:PivotTo(CFrame.new(Vector3.new(mapEntry.Location.X, mapEntry.Location.Y, mapEntry.Location.Z)))
	end
end

return data
