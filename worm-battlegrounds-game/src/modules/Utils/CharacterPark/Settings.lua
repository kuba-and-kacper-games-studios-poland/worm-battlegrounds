--- @class CharacterPark_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Parking

	--[[
		Where avatars wait, anchored: below the arena, out of the side camera's view, and above Fall_Controller's
		MIN_POSITION, which would bring them back
	]]
	PARK_POSITION = Vector3.new(0, -60, 0),
}

return _settings
