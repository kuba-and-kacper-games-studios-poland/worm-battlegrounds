--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

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

--- @class Arena_Client_Falling
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.Network.Fired("Arena_Fall", Module._onFall)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Fall

--[[
	Draws a group cut loose falling straight down by the game's gravity, every frame on the server's clock, so it
	moves smoothly rather than in the server's replicated steps; it ends where the server leaves it.
]]
--- @param group { BasePart }
function Module._onFall(group, drop: number, started: number)
	--[[ Local Variables ]]

	-- By part, not by index: a part this screen hasn't streamed in arrives as nil
	local starts = {} --- @type { [BasePart]: CFrame }
	for _index: number, part: BasePart in pairs(group) do
		starts[part] = part.CFrame
	end
	local fallen: number = 0

	--[[ Falling ]]

	while fallen < drop do
		I.S.RunService.RenderStepped:Wait()
		local elapsed: number = I.S.Workspace:GetServerTimeNow() - started
		fallen = math.min(0.5 * I.S.Workspace.Gravity * elapsed * elapsed, drop)
		for part: BasePart, start: CFrame in pairs(starts) do
			part.CFrame = start - Vector3.yAxis * fallen
		end
	end
end

return Module
