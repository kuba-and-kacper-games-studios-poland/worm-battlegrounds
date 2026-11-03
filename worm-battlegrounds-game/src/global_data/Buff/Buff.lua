--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Buff_Buffs
--- @type { [string]: { Buff_BuffData } }
local data = {
	--[[
		["Example"] = {
			DefaultValue = 0,
			ServerUpdate = true,
			ServerUpdateIndividual = true,
			ClientUpdate = false,
		},

		["Example"] = {
			DefaultValue = 0,
			ClientUpdate = false,
			ClientUpdateIndividual = false,
		},
	]]

	["Server"] = {

		["Example"] = {
			DefaultValue = "100",
			ServerUpdate = false,
			ServerUpdateIndividual = true,
			ClientUpdate = true,
		},

		--%%%%%%%%%%%%%%%%%%%% Character

		--[[ Movement ]]

		["WalkSpeed"] = {
			DefaultValue = I.S.StarterPlayer.CharacterWalkSpeed,
			ServerUpdate = false,
			ServerUpdateIndividual = true,
			ClientUpdate = true,
		},
		["JumpHeight"] = {
			DefaultValue = I.S.StarterPlayer.CharacterJumpHeight,
			ServerUpdate = false,
			ServerUpdateIndividual = true,
			ClientUpdate = true,
		},
	},

	["Client"] = {
		["FOV"] = {
			DefaultValue = 70,
			ClientUpdate = false,
			ClientUpdateIndividual = true,
		},
	},
}
return data
