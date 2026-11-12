--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Gui ]]

local moduleGui: ScreenGui
local edges = {} --- @type { Frame }

--[[ State ]]

-- The aura attachments streaming on each snail now, by snail, then by potion attribute
local auras = {} --- @type { [Model]: { [string]: { Attachment } } }

-- Whether the vignette shows now
local shown: boolean = false

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

--- @class Snails_Client_Potions
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI["PotionVignette"]
	for _index: number, edge: Instance in ipairs(moduleGui:FindFirstChild("U_Vignette", true):GetChildren()) do
		if edge:IsA("Frame") then
			edge.BackgroundTransparency = 1
			table.insert(edges, edge)
		end
	end

	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Looks again at a snail's potions whenever its state, its turn or a potion attribute changes, and drops its auras
	once it's gone.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Connections ]]

	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Alive" or attribute == "Ghost" or attribute == "Active" or _settings.POTION_AURAS[attribute] then
			Module._refresh(model)
		end
	end)
	model.Destroying:Connect(function()
		auras[model] = nil
		if shown and not I.Snails.GetMine() then
			Module._setVignette(nil)
		end
	end)

	--[[ Refreshing ]]

	Module._refresh(model)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Streams each potion's aura around a snail while its attribute is set and the snail is in play, stops the rest, and
	sets the vignette when it's the player's own snail.
]]
--- @param model Model
function Module._refresh(model)
	--[[ Local Variables ]]

	local streaming = auras[model] or {} --- @type { [string]: { Attachment } }
	local inPlay: boolean = model:GetAttribute("Alive") == true and not model:GetAttribute("Ghost")
	local root: BasePart? = model.PrimaryPart

	--[[ Auras ]]

	for attribute: string, prefabName: string in pairs(_settings.POTION_AURAS) do
		local show: boolean = inPlay and root ~= nil and model:GetAttribute(attribute) ~= nil
		if show and not streaming[attribute] then
			streaming[attribute] = Module._startAura(prefabName, root)
		elseif not show and streaming[attribute] then
			Module._stopAura(streaming[attribute])
			streaming[attribute] = nil
		end
	end
	auras[model] = if next(streaming) then streaming else nil

	--[[ Vignette ]]

	-- Check if it's the player's own snail
	if model ~= I.Snails.GetMine() then
		return
	end

	local mine: boolean = inPlay and model:GetAttribute("Active") == true
	local speed: boolean = mine and model:GetAttribute("SpeedMultiplier") ~= nil
	local lowGravity: boolean = mine and model:GetAttribute("LowGravity") ~= nil
	Module._setVignette(if speed and lowGravity then _settings.POTION_VIGNETTE_BOTH elseif speed then _settings.POTION_VIGNETTE_SPEED elseif lowGravity then _settings.POTION_VIGNETTE_LOW_GRAVITY else nil)
end

--%%%%%%%%%%%%%%%%%%%% Start Aura

--[[
	Copies an aura prefab's attachments onto a snail's ball and turns their emitters on.
]]
--- @return { Attachment }
function Module._startAura(prefabName: string, root: BasePart)
	--[[ Data ]]

	local prefab: BasePart? = I.Vfx.Get(prefabName)

	--[[ Local Variables ]]

	local attachments = {} --- @type { Attachment }

	--[[ Building ]]

	if prefab then
		for _index: number, source: Instance in ipairs(prefab:GetChildren()) do
			if not source:IsA("Attachment") then
				continue
			end
			local attachment: Attachment = source:Clone()
			for _index2: number, emitter: Instance in ipairs(attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
			attachment.Parent = root
			table.insert(attachments, attachment)
		end
	end

	--[[ Returning ]]

	return attachments
end

--%%%%%%%%%%%%%%%%%%%% Stop Aura

--[[
	Turns an aura's emitters off and removes its attachments once their last particles are gone.
]]
--- @param attachments { Attachment }
function Module._stopAura(attachments)
	--[[ Local Variables ]]

	local longest: number = 0

	--[[ Stopping ]]

	for _index: number, attachment: Attachment in ipairs(attachments) do
		for _index2: number, emitter: Instance in ipairs(attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
				longest = math.max(longest, emitter.Lifetime.Max)
			end
		end
	end

	--[[ Cleaning ]]

	task.delay(longest, function()
		for _index: number, attachment: Attachment in ipairs(attachments) do
			attachment:Destroy()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Set Vignette

--[[
	Fades the vignette in, tinted, or out with nil; it changes colour smoothly while it shows.
]]
function Module._setVignette(color: Color3?)
	--[[ Checks ]]

	-- Check if there's nothing to change
	if not color and not shown then
		return
	end

	--[[ Applying ]]

	shown = color ~= nil
	if color then
		moduleGui.Enabled = true
	end
	for _index: number, edge: Frame in ipairs(edges) do
		local Fade_TweenGoal = { BackgroundTransparency = if color then 0 else 1, BackgroundColor3 = color or edge.BackgroundColor3 }
		local Fade_Tween: Tween = I.S.TweenService:Create(edge, _settings.POTION_VIGNETTE_TWEENINFO, Fade_TweenGoal)
		Fade_Tween:Play()
	end

	--[[ Hiding ]]

	if not color then
		task.delay(_settings.POTION_VIGNETTE_TWEENINFO.Time, function()
			if not shown then
				moduleGui.Enabled = false
			end
		end)
	end
end

return Module
