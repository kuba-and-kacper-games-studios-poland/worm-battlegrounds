--- @type { [string]: Ragdoll_Preset }
local Presets = {

	--[[ Realistic ]]

	["Realistic"] = {

		--[[ Joints ]]

		Joints = {
			Default = { UpperAngle = 45, TwistLowerAngle = -20, TwistUpperAngle = 20, MaxFrictionTorque = 20 },
			Neck = { UpperAngle = 35, TwistLowerAngle = -40, TwistUpperAngle = 40, MaxFrictionTorque = 20 },
			Waist = { UpperAngle = 25, TwistLowerAngle = -15, TwistUpperAngle = 15, MaxFrictionTorque = 35 },
			Shoulder = { UpperAngle = 80, TwistLowerAngle = -45, TwistUpperAngle = 45, MaxFrictionTorque = 35 },
			Elbow = { UpperAngle = 70, TwistLowerAngle = -5, TwistUpperAngle = 5, MaxFrictionTorque = 40 },
			Wrist = { UpperAngle = 40, TwistLowerAngle = -15, TwistUpperAngle = 15, MaxFrictionTorque = 12 },
			Hip = { UpperAngle = 60, TwistLowerAngle = -25, TwistUpperAngle = 25, MaxFrictionTorque = 17 },
			Knee = { UpperAngle = 65, TwistLowerAngle = -5, TwistUpperAngle = 5, MaxFrictionTorque = 40 },
			Ankle = { UpperAngle = 25, TwistLowerAngle = -10, TwistUpperAngle = 10, MaxFrictionTorque = 19 },
		},
		Root = { UpperAngle = 45, TwistLowerAngle = -30, TwistUpperAngle = 30, MaxFrictionTorque = 30 },
		KeepUpright = false,

		--[[ Rig Sockets ]]

		LimitScale = 1,
		FrictionScale = 1,

		--[[ Launch ]]

		LaunchMultiplier = 1,
		SpinSpeed = 0,
		LimbFlail = 0,

		--[[ Collider ]]

		ColliderDensity = 1,
		ColliderFriction = 0.8,
		ColliderElasticity = 0.05,
	},

	--[[ Arcade ]]

	["Arcade"] = {

		--[[ Joints ]]

		Joints = {
			Default = { UpperAngle = 75, TwistLowerAngle = -40, TwistUpperAngle = 40, MaxFrictionTorque = 0 },
		},
		Root = { UpperAngle = 120, TwistLowerAngle = -80, TwistUpperAngle = 80, MaxFrictionTorque = 0 },
		KeepUpright = true,

		--[[ Rig Sockets ]]

		LimitScale = 1.3,
		FrictionScale = 0.3,

		--[[ Launch ]]

		LaunchMultiplier = 1,
		SpinSpeed = 10,
		LimbFlail = 6,

		--[[ Collider ]]

		ColliderDensity = 0.7,
		ColliderFriction = 0.15,
		ColliderElasticity = 0.45,
	},

	--[[ Floppy ]]

	["Floppy"] = {

		--[[ Joints ]]

		Joints = {
			Default = { UpperAngle = 120, TwistLowerAngle = -90, TwistUpperAngle = 90, MaxFrictionTorque = 0 },
		},
		Root = { UpperAngle = 150, TwistLowerAngle = -120, TwistUpperAngle = 120, MaxFrictionTorque = 0 },
		KeepUpright = false,

		--[[ Rig Sockets ]]

		LimitScale = 1.5,
		FrictionScale = 0,

		--[[ Launch ]]

		LaunchMultiplier = 1.2,
		SpinSpeed = 6,
		LimbFlail = 14,

		--[[ Collider ]]

		ColliderDensity = 0.4,
		ColliderFriction = 0.2,
		ColliderElasticity = 0.7,
	},

	--[[ Heavy ]]

	["Heavy"] = {

		--[[ Joints ]]

		Joints = {
			Default = { UpperAngle = 40, TwistLowerAngle = -15, TwistUpperAngle = 15, MaxFrictionTorque = 60 },
		},
		Root = { UpperAngle = 40, TwistLowerAngle = -20, TwistUpperAngle = 20, MaxFrictionTorque = 60 },
		KeepUpright = false,

		--[[ Rig Sockets ]]

		LimitScale = 0.6,
		FrictionScale = 2.5,

		--[[ Launch ]]

		LaunchMultiplier = 0.6,
		SpinSpeed = 2,
		LimbFlail = 0,

		--[[ Collider ]]

		ColliderDensity = 2.5,
		ColliderFriction = 1,
		ColliderElasticity = 0,
	},
}

return Presets
