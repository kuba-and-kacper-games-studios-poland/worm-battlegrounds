--[[
	Comparing the parity probe's reports (the Bots module's Scripts/Server/Parity, run in Studio and here): both sides
	split the report into blocks of lines, a block per map and kind of line (shot, plan, ground, liquid…) every
	`size` lines, and hash each block, so only the blocks that differ need looking at. STUDIO_SNIPPET is the same code,
	to run in Studio after the probe (README.md → Parity).
]]

local parity = {}

-- FNV-1a over a string, exact in doubles (the multiply is split so it never passes 2^53)
local function hash(text: string): string
	local h = 2166136261
	for i = 1, #text do
		h = bit32.bxor(h, string.byte(text, i))
		local low = (h * 0x0193) % 2 ^ 32
		local high = (h * 0x0100) % 2 ^ 16
		h = (low + high * 2 ^ 16) % 2 ^ 32
	end
	return string.format("%08x", h)
end

local function getBlocks(text: string, size: number)
	-- Lines grouped by "map|kind", in order, then cut every `size` lines
	local order, groups = {}, {}
	for line in text:gmatch("[^\n]+") do
		local key = line:match("^([^|]+|[^|]+)")
		if not groups[key] then
			groups[key] = {}
			table.insert(order, key)
		end
		table.insert(groups[key], line)
	end
	return order, groups
end

function parity.GetBlockHashes(text: string, size: number): string
	local order, groups = getBlocks(text, size)
	local out = {}
	for _, key in order do
		local lines = groups[key]
		for first = 1, #lines, size do
			local block = table.concat(lines, "\n", first, math.min(first + size - 1, #lines))
			table.insert(out, `{key}|{(first - 1) // size + 1}|{hash(block)}`)
		end
	end
	return table.concat(out, "\n")
end

function parity.GetBlock(text: string, key: string, index: number, size: number): string
	local _order, groups = getBlocks(text, size)
	local lines = groups[key] or {}
	local first = (index - 1) * size + 1
	return table.concat(lines, "\n", first, math.min(first + size - 1, #lines))
end

parity.Hash = hash

return parity
