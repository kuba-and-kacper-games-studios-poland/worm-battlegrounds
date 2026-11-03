--[[
	Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Instance = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Emitter = require(_scripts:FindFirstChild("Emitter")) --- @type UIEmitter_Emitter
local Scheduler = require(_scripts:FindFirstChild("Scheduler")) --- @type UIEmitter_Scheduler

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

--- @class Ume_Library_UIEmitter : Ume_Library
local UIEmitter = {

	--[[ Constructor ]]

	new = Emitter.new,
}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Forwards Ume to the scheduler and assigns this library onto it.
]]
--- @param umeInstance Ume
function UIEmitter._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Forwarding ]]

	Scheduler.InjectUme(I)

	--[[ Assigning ]]

	I.UIEmitter = UIEmitter --- @type Ume_Library_UIEmitter
end

return UIEmitter
