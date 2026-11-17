--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Carver = require(script.Parent:FindFirstChild("Carver")) --- @type Arena_Client_Carver

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- This screen's copies of the ground falling now
local fallingFolder: Folder

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

function Module.Start(arenaFolder: Instance)
	--[[ Local Variables ]]

	fallingFolder = I.Create("Folder")({
		Name = "Falling",
		Parent = arenaFolder,
	})

	--[[ Connections ]]

	I.Network.Fired("Arena_Fall", Module._onFall)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Fall

--[[
	Draws a group cut loose falling straight down by the game's gravity, every frame on the server's clock: each part
	hides and a copy of it falls in its place, so this screen alone moves what it draws and the server's own steps
	(the server still moves the real parts, which snails stand on) never fight it. Each copy waits at the bottom until
	its part has come down there (or is gone), then the part shows again.
]]
--- @param group { BasePart }
function Module._onFall(group, drop: number, started: number)
	--[[ Local Variables ]]

	local parts = {} --- @type { BasePart }
	local copies = {} --- @type { BasePart }
	local starts = {} --- @type { CFrame }
	local cframes = {} --- @type { CFrame }

	--[[ Copying ]]

	-- By pairs, not ipairs: a part this screen hasn't streamed in arrives as nil
	for _index: number, part: BasePart in pairs(group) do
		-- The server cuts no ground while it falls, so a hole this screen cut in it ahead of the server goes
		Carver.Drop(part)

		local copy: BasePart = part:Clone()
		copy:SetAttribute("Arena_Carve", nil)
		copy.CanCollide = false
		copy.CanQuery = false
		copy.CanTouch = false
		copy.LocalTransparencyModifier = 0
		copy.Parent = fallingFolder
		part.LocalTransparencyModifier = 1
		table.insert(parts, part)
		table.insert(copies, copy)
		table.insert(starts, part.CFrame)
	end

	--[[ Checks ]]

	-- Check if any of it is on this screen
	if #parts == 0 then
		return
	end

	--[[ Falling ]]

	local fallen: number = 0

	while fallen < drop do
		I.S.RunService.RenderStepped:Wait()
		local elapsed: number = I.Match.GetDrawTime() - started
		fallen = math.min(0.5 * I.S.Workspace.Gravity * elapsed * elapsed, drop)
		for index: number, start: CFrame in ipairs(starts) do
			cframes[index] = start - Vector3.yAxis * fallen
		end
		I.S.Workspace:BulkMoveTo(copies, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end

	--[[ Landing ]]

	-- The server's part arrives a moment after the drawn one; at most PREDICT_TIMEOUT later it shows anyway
	local giveUpAt: number = os.clock() + _settings.PREDICT_TIMEOUT
	while #parts > 0 do
		for index: number = #parts, 1, -1 do
			local part: BasePart = parts[index]
			if part.Parent and part.Position.Y > starts[index].Y - drop + 0.01 and os.clock() < giveUpAt then
				continue
			end

			-- A hole this screen cut in it since it landed keeps it hidden until the server's pieces replace it
			if not Carver.IsPredicted(part) then
				part.LocalTransparencyModifier = 0
			end
			copies[index]:Destroy()
			table.remove(parts, index)
			table.remove(copies, index)
			table.remove(starts, index)
		end
		if #parts > 0 then
			I.S.RunService.RenderStepped:Wait()
		end
	end
end

return Module
