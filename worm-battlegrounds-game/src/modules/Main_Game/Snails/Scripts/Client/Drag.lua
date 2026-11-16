--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local DragHelper = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Drag")) --- @type Snails_Drag

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The snails a black hole drags through the air now, which this screen draws drifting
local dragged = {} --- @type { [Model]: boolean }

-- Whether the step is bound: before the camera (and Gear), so the camera aims at where the snail is this frame
local stepping: boolean = false

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

--- @class Snails_Client_Drag
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Starts drawing a snail's drift whenever a black hole starts dragging it through the air (its DragStart changes),
	and stops when it lets go.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Connections ]]

	model:GetAttributeChangedSignal("DragStart"):Connect(function()
		Module._refresh(model)
	end)
	model.Destroying:Connect(function()
		dragged[model] = nil
		Module._refreshLoop()
	end)

	--[[ Refreshing ]]

	Module._refresh(model)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws a snail drifting while its Drag attributes are set, and stops once they're cleared (the server's ball takes
	over).
]]
--- @param model Model
function Module._refresh(model)
	--[[ Saving ]]

	dragged[model] = if model:GetAttribute("DragStart") then true else nil

	--[[ Refreshing ]]

	Module._refreshLoop()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Loop

--[[
	Steps the drifting snails every frame while one drifts, and stops when none does.
]]
function Module._refreshLoop()
	--[[ Connections ]]

	if next(dragged) and not stepping then
		stepping = true
		I.S.RunService:BindToRenderStep("Snails_Drag", Enum.RenderPriority.Camera.Value - 2, Module._step)
	elseif not next(dragged) and stepping then
		stepping = false
		I.S.RunService:UnbindFromRenderStep("Snails_Drag")
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves each drifting snail's anchored ball along its drift on the server's clock, before the frame is drawn, the way
	the server moves it.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = I.Match.GetDrawTime()

	--[[ Stepping ]]

	for model: Model in pairs(dragged) do
		local root: BasePart? = model.PrimaryPart
		local position: Vector3? = DragHelper.GetPosition(model, now)
		if root and position and root.Anchored and model:GetAttribute("Alive") ~= false then
			root.CFrame = CFrame.new(position) * root.CFrame.Rotation
		end
	end
end

return Module
