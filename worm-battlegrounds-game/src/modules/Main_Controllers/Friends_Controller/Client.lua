--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Friends_Controller"

--- @type Friends_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local friendsReplicatorDir: Folder
local boostText: string = "+0%"

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Friends_Controller_BoostChanged", { "string" })

	--- @Component
	I.Component.RegisterOnLoaded("Friends_Controller_BoostText", _components.BoostText)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Friends_Controller = {

		--[[ Methods ]]

		GetBoostText = Module.GetBoostText,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._updateDisplayedInfo()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Gets and connects replicator for updating friends boost display.
]]
function Module._connectReplicator()
	friendsReplicatorDir = I.Replicator.GetFolder("Friends")
	friendsReplicatorDir:GetAttributeChangedSignal("ActiveCount"):Connect(Module._updateDisplayedInfo)

	--[[ Initial Update ]]

	Module._updateDisplayedInfo()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Displayed Info

--[[
    Updates display of friends boost value, with the same formula and cap the server grants.
]]
function Module._updateDisplayedInfo()
	--[[ Getting Boost Value Text ]]

	local friendsCount: number = friendsReplicatorDir and friendsReplicatorDir:GetAttribute("ActiveCount") or 0
	local friendsBonus: number = math.min(friendsCount * _settings.BONUS_PER_FRIEND, _settings.MAX_BONUS)
	boostText = `+{math.round(friendsBonus * 100)}%`

	--[[ Publishing ]]

	I.Topic.Publish("Friends_Controller_BoostChanged", boostText)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Boost Text

--[[
	**CLIENT** |
	Returns the friends bonus as the labels show it (`+20%`).
]]
--- @return string
function Module.GetBoostText()
	return boostText
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
