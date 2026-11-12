--- @class Sound_SoundsList
--- @type { [string]: { number } }
local data = {
	--[[
        ["SoundName"] = { id: number }
    ]]

	--%%%%%%%%%%%%%%%%%%%% Music (the studio's own, uploaded to The Snail Studio; each carries its place's ambience)

	--[[ Lobby ]]

	["BGM"] = { 112211761861428 },

	--[[ Maps: Music_<MapId>, and its sudden-death version ]]

	["Music_PicnicPlains"] = { 137510858152490 },
	["Music_PicnicPlains_SuddenDeath"] = { 92872423963988 },
	["Music_Desert"] = { 71795470444674 },
	["Music_Desert_SuddenDeath"] = { 73282690663044 },
	["Music_RockslideRidge"] = { 83665320995374 },
	["Music_RockslideRidge_SuddenDeath"] = { 105098553957434 },

	-- shortcut: Desert's tracks until the sound kit (art/sfx) makes Volcano Isle's own and the owner approves them
	["Music_VolcanoIsle"] = { 71795470444674 },
	["Music_VolcanoIsle_SuddenDeath"] = { 73282690663044 },

	--%%%%%%%%%%%%%%%%%%%% GUI (Roblox's classic 2009 sounds, and the studio's own)

	["Button_Hover"] = { 12221976 },
	["Button_Click"] = { 12221967 },
	["Button_Click-CloseWidget"] = { 12222183 },
	["Window_Open"] = { 137701655016536 },

	["Error"] = { 12221944 },

	--[[ Notifications ]]

	["Notification"] = { 12221990 },

	--[[ Teleports ]]

	["Teleport_Out"] = { 125905830146432 },
	["Teleport_In"] = { 123941447478946 },

	--%%%%%%%%%%%%%%%%%%%% Crates (the studio's own, uploaded to The Snail Studio: the reel crisp, the rest classic)

	--[[ The reel and the crate ]]

	["Crate_Tick"] = { 108530914762133 },
	["Crate_Land"] = { 135642087964327 },
	["Crate_Settle"] = { 84951644309074 },
	["Crate_Shake"] = { 75834896895314 },
	["Crate_Unlock"] = { 106177105409403 },
	["Crate_Spin"] = { 92475912978339 },
	["Crate_Tease"] = { 134922992618449 },
	["Crate_GoldHit"] = { 131075717781769 },
	["Crate_Premium"] = { 73544841591177 },

	--[[ Reveals: Reveal_<Rarity>, and the copy that turns an item shiny ]]

	["Reveal_Common"] = { 82924467863413 },
	["Reveal_Uncommon"] = { 137718839190082 },
	["Reveal_Rare"] = { 83470903795378 },
	["Reveal_Epic"] = { 131931591248695 },
	["Reveal_Legendary"] = { 122878232061677 },
	["Reveal_Shiny"] = { 82930831375833 },

	--[[ Legendary drops: Legend_<Drop> ]]

	["Legend_BlackHole"] = { 95019284860778 },
	["Legend_Variety"] = { 140228478426007 },
	["Legend_Skeleton"] = { 94753726140918 },
	["Legend_LowGravity"] = { 89701452966731 },

	--[[ Pack results ]]

	["Card_Flip"] = { 106213717285815 },
	["Results_Open"] = { 125147629457908 },

	--%%%%%%%%%%%%%%%%%%%% Match (Roblox's classic 2009 sounds, and the studio's own uploaded to The Snail Studio)

	--[[ Weapons: Fire_<itemId>, played where the shot leaves ]]

	["Fire_Bazooka"] = { 12222065 },
	["Fire_HomingMissile"] = { 94209886160879 },
	["Fire_Grenade"] = { 12222103 },
	["Fire_ClusterBomb"] = { 12222103 },
	["Fire_VarietyGrenade"] = { 12222103 },
	["Fire_BlackHoleGrenade"] = { 12222103 },
	["Fire_SpiderBomb"] = { 12222103 },
	["Fire_SpartanSpear"] = { 12222103 },
	["Fire_Dynamite"] = { 116344910255456 },
	["Fire_Shotgun"] = { 118799477525243 },
	["Fire_Uzi"] = { 102554652606535 },
	["Fire_Minigun"] = { 122007230038097 },
	["Fire_BaseballBat"] = { 88702359947355 },
	["Fire_OnePunch"] = { 128739545630371 },

	--[[ Utilities: Use_<itemId> ]]

	["Use_Bandage"] = { 118142450893826 },
	["Use_Medkit"] = { 118142450893826 },
	["Use_SpeedPotion"] = { 98006089023309 },
	["Use_LowGravityPotion"] = { 98006089023309 },
	["Use_Parachute"] = { 129203225743766 },
	["Use_Jetpack"] = { 94374737209403 },

	--[[ Shots ]]

	["Explosion_Big"] = { 12222084 },
	["Explosion_Small"] = { 12221984 },
	["Shot_Bounce"] = { 12222046 },
	["Shot_Whistle"] = { 116922447743708 },

	--[[ Snails ]]

	["Snail_Step"] = { 12222152 },
	["Snail_Jump"] = { 12222124 },
	["Snail_Land"] = { 71082125667012 },
	["Snail_Jetpack"] = { 135875715949879 },
	["Snail_Hurt"] = { 12222058 },
	["Snail_KnockedOut"] = { 79348298352567 },
	["Snail_Splash"] = { 130526667411981 },
	["Snail_Burn"] = { 136097066776614 },
	["Snail_Ghost"] = { 103005755191352 },

	--[[ World ]]

	["Liquid_Obsidian"] = { 89229600584007 },

	--[[ Wind ]]

	-- A loop per map, as loud as the match's wind, and its gusts (Fight and Ride Animals' zone ambience)
	["Wind_OpenAir"] = { 9112832297 },
	["Wind_Desert"] = { 9114057104 },
	["Wind_Howl"] = { 9113286969 },
	["Wind_Gust"] = { 94321371111141 },

	--[[ Turns ]]

	["Turn_Start"] = { 124997372774741 },
	["Turn_Yours"] = { 106047322621411 },
	["Turn_Tick"] = { 12221976 },
	["Turn_TimeUp"] = { 77230352839380 },
	["Turn_Whoosh"] = { 12222200 },
	["Turn_Next"] = { 108490405748541 },
	["Match_SuddenDeath"] = { 115349814948977 },
	["Match_Knockout"] = { 73293630314274 },
	["Match_WaterRise"] = { 112740376118104 },
	["Match_Win"] = { 96177429150503 },
	["Match_Lose"] = { 123846876335583 },

	--%%%%%%%%%%%%%%%%%%%%
}
return data
