--[[
	Created By: 	Nari
]]

--- @type { [string]: Utils_ButtonScaleAnimation }
local data = {

	--[[ Plain ]]

	["Default"] = {
		Hover = {
			{ Scale = 1, Time = 0.075, EasingStyle = Enum.EasingStyle.Circular, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.14, EasingStyle = Enum.EasingStyle.Quint, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.075, EasingStyle = Enum.EasingStyle.Circular, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1, Time = 0.14, EasingStyle = Enum.EasingStyle.Quint, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Snappy"] = {
		Hover = {
			{ Scale = 1, Time = 0.04, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.05, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.03, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.02, Time = 0.04, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.04, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Soft"] = {
		Hover = {
			{ Scale = 1, Time = 0.3, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
		},
		Leave = {
			{ Scale = 1, Time = 0.35, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
		},
		Press = {
			{ Scale = 1, Time = 0.2, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1, Time = 0.35, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
		},
	},
	["Heavy"] = {
		Hover = {
			{ Scale = 1, Time = 0.2, EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.25, EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.14, EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1, Time = 0.45, EasingStyle = Enum.EasingStyle.Bounce, EasingDirection = Enum.EasingDirection.Out },
		},
	},

	--[[ Bouncy ]]

	["Bouncy"] = {
		Hover = {
			{ Scale = 1.03, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.99, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 0.98, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 0.97, Time = 0.06, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.06, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.07, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.97, Time = 0.09, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.01, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Spring"] = {
		Hover = {
			{ Scale = 1, Time = 0.35, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.3, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.08, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1, Time = 0.6, EasingStyle = Enum.EasingStyle.Elastic, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Jelly"] = {
		Hover = {
			{ Scale = 1.05, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.97, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.02, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 0.99, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 0.97, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.02, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 0.96, Time = 0.07, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.01, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.06, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.1, Time = 0.09, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.94, Time = 0.09, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.05, Time = 0.09, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 0.98, Time = 0.09, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Pop"] = {
		Hover = {
			{ Scale = 1, Time = 0.06, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.05, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.15, Time = 0.07, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.18, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Squish"] = {
		Hover = {
			{ Scale = 1, Time = 0.15, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.15, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.2, EasingStyle = Enum.EasingStyle.Quint, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.08, Time = 0.08, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.3, EasingStyle = Enum.EasingStyle.Bounce, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Pulse"] = {
		Hover = {
			{ Scale = 1.04, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.99, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
		},
		Leave = {
			{ Scale = 1, Time = 0.15, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.08, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.1, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 0.98, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.04, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Time = 0.14, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Rubber"] = {
		Hover = {
			{ Scale = 1, Time = 0.45, EasingStyle = Enum.EasingStyle.Elastic, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.4, EasingStyle = Enum.EasingStyle.Elastic, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Time = 0.07, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.12, Time = 0.08, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.7, EasingStyle = Enum.EasingStyle.Elastic, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Slam"] = {
		Hover = {
			{ Scale = 1, Time = 0.18, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Time = 0.12, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 0.92, Time = 0.05, EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.In },
			{ Scale = 1, Time = 0.08, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.18, Time = 0.06, EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Time = 0.25, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
	},

	--[[ Rotating ]]

	["Wiggle"] = {
		Hover = {
			{ Scale = 1.02, Rotation = -4, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.01, Rotation = 4, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = -2, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Rotation = 0, Time = 0.12, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Rotation = 0, Time = 0.06, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.06, Rotation = 5, Time = 0.07, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.02, Rotation = -5, Time = 0.08, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 2, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.07, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Tilt"] = {
		Hover = {
			{ Scale = 1, Rotation = 5, Time = 0.15, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Rotation = 0, Time = 0.15, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Rotation = -3, Time = 0.06, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.03, Rotation = -2, Time = 0.06, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1, Rotation = 0, Time = 0.18, EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Swing"] = {
		Hover = {
			{ Scale = 1.02, Rotation = 8, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.01, Rotation = -6, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 4, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = -2, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.12, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Rotation = 0, Time = 0.15, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Rotation = 0, Time = 0.07, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.04, Rotation = -6, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
			{ Scale = 1.01, Rotation = 4, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = -2, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.1, EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
		},
	},
	["Shake"] = {
		Hover = {
			{ Scale = 1.01, Rotation = -3, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.01, Rotation = 3, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = -2, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 2, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.05, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Leave = {
			{ Scale = 1, Rotation = 0, Time = 0.1, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Press = {
			{ Scale = 1, Rotation = 0, Time = 0.05, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
		Release = {
			{ Scale = 1.04, Rotation = 6, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.03, Rotation = -6, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.02, Rotation = 5, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1.01, Rotation = -4, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 2, Time = 0.04, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut },
			{ Scale = 1, Rotation = 0, Time = 0.05, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
		},
	},
}
return data
