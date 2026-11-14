--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local _data: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local sets = {} --- @type { [string]: Cosmetics_SetData }
local pieces = {} --- @type { [string]: Cosmetics_PieceData }
local emotes = {} --- @type { [string]: Cosmetics_EmoteData }

-- Each set's pieces, by slot
local setPieces = {} --- @type { [string]: { [string]: string } }

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
	----------- DATA -----------
	----------------------------

	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Sets"):GetChildren()) do
		sets[row.Name] = require(row)
		setPieces[row.Name] = {}
	end
	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Pieces"):GetChildren()) do
		local piece = require(row) --- @type Cosmetics_PieceData
		pieces[row.Name] = piece
		setPieces[piece.Set][piece.Slot] = row.Name
	end
	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Emotes"):GetChildren()) do
		emotes[row.Name] = require(row)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Cosmetics = {

		--[[ Control ]]

		BuildSnail = Module.BuildSnail,

		--[[ Methods ]]

		GetSet = Module.GetSet,
		GetSets = Module.GetSets,
		GetSetPieces = Module.GetSetPieces,
		GetPiece = Module.GetPiece,
		GetPieces = Module.GetPieces,
		GetOutfit = Module.GetOutfit,
		GetOutfitText = Module.GetOutfitText,
		GetShowcase = Module.GetShowcase,
		GetPieceShot = Module.GetPieceShot,
		GetEmote = Module.GetEmote,
		GetEmotes = Module.GetEmotes,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build Snail

--[[
	Clones a snail wearing an outfit: the body piece's snail from Assets.Skins, with the shell, hat and neck piece of
	the outfit's sets moved onto it. A set whose snail isn't cut into pieces yet (no Hat or Neck part) wears its whole
	Body for its hat or neck piece, as the skin it was.
]]
--- @param outfit Cosmetics_Outfit
--- @return Model?
function Module.BuildSnail(outfit)
	--[[ Data ]]

	local skins: Folder = I.Dirs.Assets:FindFirstChild("Skins")
	local bodyName: string = Module._getModelName(outfit.Body)
	local extras = {} --- @type { [string]: BasePart }

	--[[ Hat And Neck ]]

	-- The neck first, so a hat still on its whole body wins over a neck piece still on its own
	for _index: number, slot: string in ipairs({ "Neck", "Hat" }) do
		if outfit[slot] ~= "" then
			local source: Model = skins:FindFirstChild(Module._getModelName(outfit[slot]))
			local part: BasePart? = source:FindFirstChild(slot)
			if part then
				extras[slot] = part
			else
				bodyName = source.Name
			end
		end
	end

	--[[ Checks ]]

	-- Check if the body's snail is in the place
	local base: Instance? = skins:FindFirstChild(bodyName)
	if not base or not base:IsA("Model") or not base.PrimaryPart then
		warn(`[{_localName}::{script.Name}]: Snail ({bodyName}) is missing from Assets.Skins!`)
		return nil
	end

	--[[ Building ]]

	local model: Model = base:Clone()
	for _index: number, slot: string in ipairs({ "Hat", "Neck" }) do
		if model:FindFirstChild(slot) and not extras[slot] then
			Module._removePart(model, model:FindFirstChild(slot))
		end
	end
	local shell: BasePart = skins:FindFirstChild(Module._getModelName(outfit.Shell)):FindFirstChild("Shell")
	if shell.Parent ~= base then
		Module._removePart(model, model:FindFirstChild("Shell"))
		Module._attachPart(model, shell)
	end
	for slot: string, part: BasePart in pairs(extras) do
		if part.Parent ~= base then
			Module._removePart(model, model:FindFirstChild(slot))
			Module._attachPart(model, part)
		end
	end

	--[[ Returning ]]

	return model
end

--%%%%%%%%%%%%%%%%%%%% Attach Part

--[[
	Clones a part of another snail onto this one, on a copy of the Motor6D that held it there: every snail shares one
	skeleton, so its skinned mesh follows this snail's bones.
]]
function Module._attachPart(model: Model, part: BasePart)
	--[[ Local Variables ]]

	local copy: BasePart = part:Clone()
	local motor: Motor6D? = Module._getMotor(part.Parent, part)

	--[[ Building ]]

	copy.Parent = model
	if motor then
		local joint: Motor6D = motor:Clone()
		joint.Part0 = model.PrimaryPart
		joint.Part1 = copy
		joint.Parent = if motor.Parent == part then copy else model.PrimaryPart
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove Part

--[[
	Takes a part off a snail, with the Motor6D that holds it.
]]
function Module._removePart(model: Model, part: Instance?)
	--[[ Checks ]]

	-- Skip a part the snail doesn't have
	if not part then
		return
	end

	--[[ Removing ]]

	local motor: Motor6D? = Module._getMotor(model, part)
	if motor then
		motor:Destroy()
	end
	part:Destroy()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Set

--[[
	Returns a set's row by its id.
]]
--- @return Cosmetics_SetData?
function Module.GetSet(setId: string)
	--[[ Checks ]]

	-- Check if the set has a row
	if not sets[setId] then
		warn(`[{_localName}::{script.Name}]: Set ({setId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return sets[setId]
end

--%%%%%%%%%%%%%%%%%%%% Get Sets

--[[
	Returns every set row, by id.
]]
--- @return { [string]: Cosmetics_SetData }
function Module.GetSets()
	return sets
end

--%%%%%%%%%%%%%%%%%%%% Get Set Pieces

--[[
	Returns a set's pieces by slot; a slot the set has no piece for is missing.
]]
--- @return { [string]: string }
function Module.GetSetPieces(setId: string)
	return setPieces[setId] or {}
end

--%%%%%%%%%%%%%%%%%%%% Get Piece

--[[
	Returns a piece's row by its item id.
]]
--- @return Cosmetics_PieceData?
function Module.GetPiece(pieceId: string)
	--[[ Checks ]]

	-- Check if the piece has a row
	if not pieces[pieceId] then
		warn(`[{_localName}::{script.Name}]: Piece ({pieceId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return pieces[pieceId]
end

--%%%%%%%%%%%%%%%%%%%% Get Pieces

--[[
	Returns every piece row, by item id.
]]
--- @return { [string]: Cosmetics_PieceData }
function Module.GetPieces()
	return pieces
end

--%%%%%%%%%%%%%%%%%%%% Get Outfit

--[[
	Reads an outfit from its text (the Outfit attribute: the pieces in SLOTS order, comma-separated). A slot left empty,
	or holding something that isn't a piece of that slot, takes DEFAULT_OUTFIT's.
]]
--- @return Cosmetics_Outfit
function Module.GetOutfit(text: string?)
	--[[ Local Variables ]]

	local outfit = table.clone(_settings.DEFAULT_OUTFIT) --- @type Cosmetics_Outfit
	local parts = string.split(text or "", ",") --- @type { string }

	--[[ Reading ]]

	for index: number, slot: string in ipairs(_settings.SLOTS) do
		local pieceId: string = parts[index] or ""
		if pieces[pieceId] and pieces[pieceId].Slot == slot then
			outfit[slot] = pieceId
		end
	end

	--[[ Returning ]]

	return outfit
end

--%%%%%%%%%%%%%%%%%%%% Get Outfit Text

--[[
	Writes an outfit as the Outfit attribute's text: its pieces in SLOTS order, comma-separated, "" for none.
]]
--- @param outfit Cosmetics_Outfit
--- @return string
function Module.GetOutfitText(outfit)
	--[[ Local Variables ]]

	local parts = {} --- @type { string }

	--[[ Writing ]]

	for _index: number, slot: string in ipairs(_settings.SLOTS) do
		table.insert(parts, outfit[slot])
	end

	--[[ Returning ]]

	return table.concat(parts, ",")
end

--%%%%%%%%%%%%%%%%%%%% Get Showcase

--[[
	Returns the outfit that shows one piece on its own: DEFAULT_OUTFIT wearing it.
]]
--- @return Cosmetics_Outfit
function Module.GetShowcase(pieceId: string)
	--[[ Local Variables ]]

	local outfit = table.clone(_settings.DEFAULT_OUTFIT) --- @type Cosmetics_Outfit

	--[[ Applying ]]

	outfit[pieces[pieceId].Slot] = pieceId

	--[[ Returning ]]

	return outfit
end

--%%%%%%%%%%%%%%%%%%%% Get Piece Shot

--[[
	Returns where a camera stands to show a piece on a posed snail (PIECE_SHOTS): looking at the piece where the pose
	put it (its part's middle carried by the bone it rides, PIECE_BONES), or at the whole snail for a body, always at a
	share of the whole snail's size away, so the camera never ends up inside the head; turned round for a shell.
]]
--- @return CFrame
function Module.GetPieceShot(model: Model, pieceId: string)
	--[[ Local Variables ]]

	local slot: string = pieces[pieceId].Slot
	local shot = _settings.PIECE_SHOTS[slot] --- @type Cosmetics_Shot
	local part: BasePart? = if slot ~= "Body" then model:FindFirstChild(slot) else nil
	local bone: Bone? = if part then model:FindFirstChild(_settings.PIECE_BONES[slot], true) else nil
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()

	-- A skinned part sits where its rest pose has it; the bone it rides carries its middle to where the pose put it
	local middle: Vector3 = if part and bone then bone.TransformedWorldCFrame:PointToWorldSpace(bone.WorldCFrame:PointToObjectSpace(part.Position)) else box.Position
	local target: Vector3 = middle + Vector3.new(0, size.Y * shot.Height, 0)

	-- A little from above: a fifth of a stud up for each stud back
	local distance: number = size.Magnitude * shot.Distance
	local offset: Vector3 = CFrame.Angles(0, math.rad(shot.Turn), 0) * Vector3.new(0, distance * 0.2, -distance)

	--[[ Returning ]]

	return CFrame.lookAt(target + offset, target)
end

--%%%%%%%%%%%%%%%%%%%% Get Emote

--[[
	Returns an emote's row by its item id.
]]
--- @return Cosmetics_EmoteData?
function Module.GetEmote(emoteId: string)
	--[[ Checks ]]

	-- Check if the emote has a row
	if not emotes[emoteId] then
		warn(`[{_localName}::{script.Name}]: Emote ({emoteId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return emotes[emoteId]
end

--%%%%%%%%%%%%%%%%%%%% Get Emotes

--[[
	Returns every emote row, by item id.
]]
--- @return { [string]: Cosmetics_EmoteData }
function Module.GetEmotes()
	return emotes
end

--%%%%%%%%%%%%%%%%%%%% Get Model Name

--[[
	Returns the name of the snail in Assets.Skins that holds a piece: its set's Model.
]]
--- @return string
function Module._getModelName(pieceId: string)
	return sets[pieces[pieceId].Set].Model
end

--%%%%%%%%%%%%%%%%%%%% Get Motor

--[[
	Returns the Motor6D under a snail (or a part) that holds a part.
]]
--- @return Motor6D?
function Module._getMotor(holder: Instance, part: Instance)
	--[[ Searching ]]

	for _index: number, joint: Instance in ipairs(holder:GetDescendants()) do
		if joint:IsA("Motor6D") and joint.Part1 == part then
			return joint
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
