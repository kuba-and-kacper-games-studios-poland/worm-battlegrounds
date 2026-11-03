--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Prompts created by using command
local command_CreatedPrompts = {} --- @type { [string]: Attachment }

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

--- @class Interact_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function createTestPrompt(player: Player, promptName: string, holdDuration: boolean?, decayTime: number, mappingsName: string?)
		decayTime = tonumber(decayTime) or 180

		--[[ Checks ]]

		if #command_CreatedPrompts >= 50 then
			return false, `Cannot create more than $|cr$|50#| Prompts`
		end

		if decayTime > 3600 then
			return false, `Decay time cannot be greater than $|cr$|3600s#|`
		end

		--[[ Getting Player Position ]]

		local character: Model = player.Character
		local charPos: CFrame = character and character:GetPivot()
		if not charPos then
			return false, `Failed to find $|cr$|{player.Name}#|'s Character`
		end

		--[[ Creating Prompt ]]

		-- Creating attachment
		local promptAtt: Attachment = Instance.new("Attachment")
		promptAtt.CFrame = charPos + charPos.LookVector * 5
		promptAtt.Parent = I.S.Workspace

		-- Creating prompt
		local newPrompt: ProximityPrompt = I.Interact.CreatePrompt(promptName, mappingsName, 7.5, "Test Prompt", "Some text")
		if holdDuration then
			newPrompt.HoldDuration = 2
		end

		newPrompt.Parent = promptAtt

		-- Delaying destroy
		task.delay(decayTime, function()
			-- Return if already destroyed
			if not promptAtt then
				return
			end

			-- Removing from table
			local tablePos: number = table.find(command_CreatedPrompts, promptAtt)
			if tablePos then
				table.remove(command_CreatedPrompts, tablePos)
			end

			-- Destroying
			promptAtt:Destroy()
		end)

		-- Saving
		table.insert(command_CreatedPrompts, promptAtt)

		-- Returning
		return true, `Created Prompt $|cr$|{promptName}#| for $|cr$|{player.Name}#|. Decay time: $|cr$|{I.Format.Text(decayTime, "time")}#|`
	end

	local function clearSpawned()
		-- Clearing existing
		for _: number, promptAtt: Attachment in ipairs(command_CreatedPrompts) do
			if promptAtt then
				promptAtt:Destroy()
			end
		end

		-- Clearing table
		table.clear(command_CreatedPrompts)

		-- Returning
		return true, `Cleared all created Prompts`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "create_test_prompt" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "promptName", types = { "string" }, dict = "Interact_PromptNames", requireDict = true },
				{ name = "holdDuration", types = { "boolean" }, optional = true },
				{ name = "decayTime", types = { "number" }, optional = true },
				{ name = "mappingsName", types = { "string" }, dict = "Interact_MappingNames", requireDict = true, optional = true },
			},
			Callback = createTestPrompt,
		},
		{
			Aliases = { "clear_spawned" },
			Callback = clearSpawned,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Interact_Server", {
		Aliases = { "interact" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allPromptNames = {} --- @type { string }
	local allMappingNames = {} --- @type { string }

	for _, promptStyleModule: ModuleScript in ipairs(I.Dirs.GlobalData.Interact.PromptStyles:GetChildren()) do
		table.insert(allPromptNames, promptStyleModule.Name)
	end

	for _index: number, mappingsModule: ModuleScript in ipairs(I.Dirs.GlobalData.Interact.Mappings:GetChildren()) do
		table.insert(allMappingNames, mappingsModule.Name)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Interact_PromptNames`, allPromptNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Interact_MappingNames`, allMappingNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
