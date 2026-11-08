--- @class Sound_SoundsList
--- @type { [string]: { number } }
local data = {
	--[[
        ["SoundName"] = { id: number }
    ]]

	--%%%%%%%%%%%%%%%%%%%%

	--[[ BGM ]]

	["BGM"] = { 72570428790944 },
	["Ambient"] = { 71682613538847 },

	--[[ GUI ]]

	["Button_Hover"] = { 102449160880471 },
	["Button_Click"] = { 97251739784528 },
	["Button_Click-CloseWidget"] = { 120171997591157 },

	["Error"] = { 114104903915938 },

	--[[ Notifications ]]

	["Notification"] = { 128856809210456 },

	--%%%%%%%%%%%%%%%%%%%% Match (free Creator Store sounds, placeholders until the studio's own)

	--[[ Weapons: Fire_<itemId>, played where the shot leaves ]]

	["Fire_Bazooka"] = { 12222065 },
	["Fire_HomingMissile"] = { 109250662480677 },
	["Fire_Grenade"] = { 9126047023 },
	["Fire_ClusterBomb"] = { 9126047023 },
	["Fire_VarietyGrenade"] = { 9126047023 },
	["Fire_BlackHoleGrenade"] = { 9126047023 },
	["Fire_SpiderBomb"] = { 9126047023 },
	["Fire_SpartanSpear"] = { 9126047023 },
	["Fire_Dynamite"] = { 71438605239854 },
	["Fire_Shotgun"] = { 82651111765871 },
	["Fire_Uzi"] = { 77730717734962 },
	["Fire_Minigun"] = { 9117928144 },
	["Fire_BaseballBat"] = { 9113305619 },
	["Fire_OnePunch"] = { 89173266974723 },

	--[[ Utilities: Use_<itemId> ]]

	["Use_Bandage"] = { 6373199071 },
	["Use_Medkit"] = { 6373199071 },
	["Use_SpeedPotion"] = { 87458966837873 },
	["Use_LowGravityPotion"] = { 87458966837873 },
	["Use_Parachute"] = { 157822167 },
	["Use_Jetpack"] = { 102373938640985 },

	--[[ Shots ]]

	["Explosion_Big"] = { 138533090376585 },
	["Explosion_Small"] = { 139210252225248 },
	["Shot_Bounce"] = { 9120888161 },

	--[[ Snails ]]

	["Snail_Step"] = { 87295773843957, 128710847750782 },
	["Snail_Jump"] = { 2772396665 },
	["Snail_Land"] = { 122835002033356 },
	["Snail_Jetpack"] = { 102373938640985 },
	["Snail_Hurt"] = { 98330897555423 },
	["Snail_ShellBreak"] = { 9120490790 },
	["Snail_KnockedOut"] = { 9119228614 },
	["Snail_Splash"] = { 9125703162 },
	["Snail_Burn"] = { 75595659213557 },

	--[[ Turns ]]

	["Turn_Start"] = { 134414286294534 },
	["Turn_Yours"] = { 4612374036 },
	["Turn_Tick"] = { 134410911353980 },
	["Match_SuddenDeath"] = { 129496339606661 },
	["Match_Win"] = { 9067124098 },
	["Match_Lose"] = { 77067845523190 },

	--%%%%%%%%%%%%%%%%%%%%
}
return data
