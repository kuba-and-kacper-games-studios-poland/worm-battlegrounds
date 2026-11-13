--[[
	Roblox's datatypes in plain Luau, for the game's code to run outside Roblox: Vector3 and CFrame (exact), Random
	(its own generator: same API, other numbers), NumberRange, Enum, and passive stand-ins for the types only settings
	and visuals build (Color3, TweenInfo, UDim2…).
]]

local sqrt = math.sqrt
local abs = math.abs

local datatypes = {}

--%%%%%%%%%%%%%%%%%%%% Vector3

local V3 = {}
local V3methods = {}

-- Roblox keeps a Vector3's parts as 32-bit floats: round each through one, so the math lands where Roblox's does
local scratch = buffer.create(4)
local writef32, readf32 = buffer.writef32, buffer.readf32
local function f32(value: number): number
	writef32(scratch, 0, value)
	return readf32(scratch, 0)
end
datatypes.f32 = f32

local function v3(x: number, y: number, z: number)
	writef32(scratch, 0, x)
	x = readf32(scratch, 0)
	writef32(scratch, 0, y)
	y = readf32(scratch, 0)
	writef32(scratch, 0, z)
	z = readf32(scratch, 0)
	return setmetatable({ X = x, Y = y, Z = z }, V3)
end

V3.__index = function(v, key)
	if key == "Magnitude" then
		return f32(sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z))
	elseif key == "Unit" then
		local m = sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
		if m == 0 then
			return v3(0 / 0, 0 / 0, 0 / 0)
		end
		return v3(v.X / m, v.Y / m, v.Z / m)
	elseif key == "x" then
		return v.X
	elseif key == "y" then
		return v.Y
	elseif key == "z" then
		return v.Z
	end
	local method = V3methods[key]
	if method == nil then
		error(`{key} is not a valid member of Vector3`, 2)
	end
	return method
end
V3.__newindex = function(_v, key)
	error(`{key} cannot be assigned to`, 2)
end
V3.__add = function(a, b)
	return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
V3.__sub = function(a, b)
	return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
V3.__mul = function(a, b)
	if type(a) == "number" then
		return v3(a * b.X, a * b.Y, a * b.Z)
	elseif type(b) == "number" then
		return v3(a.X * b, a.Y * b, a.Z * b)
	end
	return v3(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V3.__div = function(a, b)
	if type(b) == "number" then
		return v3(a.X / b, a.Y / b, a.Z / b)
	elseif type(a) == "number" then
		return v3(a / b.X, a / b.Y, a / b.Z)
	end
	return v3(a.X / b.X, a.Y / b.Y, a.Z / b.Z)
end
V3.__idiv = function(a, b)
	if type(b) == "number" then
		return v3(a.X // b, a.Y // b, a.Z // b)
	end
	return v3(a.X // b.X, a.Y // b.Y, a.Z // b.Z)
end
V3.__unm = function(a)
	return v3(-a.X, -a.Y, -a.Z)
end
V3.__eq = function(a, b)
	return a.X == b.X and a.Y == b.Y and a.Z == b.Z
end
V3.__tostring = function(a)
	return `{a.X}, {a.Y}, {a.Z}`
end

function V3methods.Dot(a, b)
	return f32(a.X * b.X + a.Y * b.Y + a.Z * b.Z)
end
function V3methods.Cross(a, b)
	return v3(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
end
function V3methods.Min(a, ...)
	local x, y, z = a.X, a.Y, a.Z
	for _, b in { ... } do
		x, y, z = math.min(x, b.X), math.min(y, b.Y), math.min(z, b.Z)
	end
	return v3(x, y, z)
end
function V3methods.Max(a, ...)
	local x, y, z = a.X, a.Y, a.Z
	for _, b in { ... } do
		x, y, z = math.max(x, b.X), math.max(y, b.Y), math.max(z, b.Z)
	end
	return v3(x, y, z)
end
function V3methods.Lerp(a, b, t)
	return v3(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t, a.Z + (b.Z - a.Z) * t)
end
function V3methods.FuzzyEq(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return abs(a.X - b.X) <= epsilon and abs(a.Y - b.Y) <= epsilon and abs(a.Z - b.Z) <= epsilon
end
function V3methods.Abs(a)
	return v3(abs(a.X), abs(a.Y), abs(a.Z))
end
function V3methods.Floor(a)
	return v3(math.floor(a.X), math.floor(a.Y), math.floor(a.Z))
end
function V3methods.Ceil(a)
	return v3(math.ceil(a.X), math.ceil(a.Y), math.ceil(a.Z))
end
function V3methods.Sign(a)
	return v3(math.sign(a.X), math.sign(a.Y), math.sign(a.Z))
end
function V3methods.Angle(a, b)
	local m = sqrt((a.X * a.X + a.Y * a.Y + a.Z * a.Z) * (b.X * b.X + b.Y * b.Y + b.Z * b.Z))
	return if m == 0 then 0 else math.acos(math.clamp((a.X * b.X + a.Y * b.Y + a.Z * b.Z) / m, -1, 1))
end

local Vector3 = {
	new = function(x: number?, y: number?, z: number?)
		return v3(x or 0, y or 0, z or 0)
	end,
	zero = v3(0, 0, 0),
	one = v3(1, 1, 1),
	xAxis = v3(1, 0, 0),
	yAxis = v3(0, 1, 0),
	zAxis = v3(0, 0, 1),
}
datatypes.Vector3 = Vector3
datatypes.Vector3Meta = V3
datatypes.v3 = v3

--%%%%%%%%%%%%%%%%%%%% Vector2

local V2 = {}
local function v2(x: number, y: number)
	return setmetatable({ X = x, Y = y }, V2)
end
V2.__index = function(v, key)
	if key == "Magnitude" then
		return sqrt(v.X * v.X + v.Y * v.Y)
	elseif key == "Unit" then
		local m = sqrt(v.X * v.X + v.Y * v.Y)
		return v2(v.X / m, v.Y / m)
	elseif key == "Dot" then
		return function(a, b)
			return a.X * b.X + a.Y * b.Y
		end
	elseif key == "Lerp" then
		return function(a, b, t)
			return v2(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t)
		end
	end
	error(`{key} is not a valid member of Vector2`, 2)
end
V2.__add = function(a, b)
	return v2(a.X + b.X, a.Y + b.Y)
end
V2.__sub = function(a, b)
	return v2(a.X - b.X, a.Y - b.Y)
end
V2.__mul = function(a, b)
	if type(a) == "number" then
		return v2(a * b.X, a * b.Y)
	elseif type(b) == "number" then
		return v2(a.X * b, a.Y * b)
	end
	return v2(a.X * b.X, a.Y * b.Y)
end
V2.__div = function(a, b)
	if type(b) == "number" then
		return v2(a.X / b, a.Y / b)
	end
	return v2(a.X / b.X, a.Y / b.Y)
end
V2.__unm = function(a)
	return v2(-a.X, -a.Y)
end
V2.__eq = function(a, b)
	return a.X == b.X and a.Y == b.Y
end
V2.__tostring = function(a)
	return `{a.X}, {a.Y}`
end
datatypes.Vector2 = {
	new = function(x: number?, y: number?)
		return v2(x or 0, y or 0)
	end,
	zero = v2(0, 0),
	one = v2(1, 1),
	xAxis = v2(1, 0),
	yAxis = v2(0, 1),
}

--%%%%%%%%%%%%%%%%%%%% CFrame

-- A CFrame is its position and the rotation matrix's rows (R00 … R22), as CFrame:GetComponents gives them
local CF = {}
local CFmethods = {}
local function cf(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
	return setmetatable({ _x = f32(x), _y = f32(y), _z = f32(z), r00, r01, r02, r10, r11, r12, r20, r21, r22 }, CF)
end
local function isIdentityRotation(c)
	return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 0 and c[5] == 1 and c[6] == 0 and c[7] == 0 and c[8] == 0 and c[9] == 1
end
datatypes.IsAxisAligned = isIdentityRotation

CF.__index = function(c, key)
	if key == "Position" or key == "p" then
		return v3(c._x, c._y, c._z)
	elseif key == "X" then
		return c._x
	elseif key == "Y" then
		return c._y
	elseif key == "Z" then
		return c._z
	elseif key == "Rotation" then
		return cf(0, 0, 0, c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9])
	elseif key == "LookVector" then
		return v3(-c[3], -c[6], -c[9])
	elseif key == "RightVector" or key == "XVector" then
		return v3(c[1], c[4], c[7])
	elseif key == "UpVector" or key == "YVector" then
		return v3(c[2], c[5], c[8])
	elseif key == "ZVector" then
		return v3(c[3], c[6], c[9])
	end
	local method = CFmethods[key]
	if method == nil then
		error(`{key} is not a valid member of CFrame`, 2)
	end
	return method
end
CF.__newindex = function(_c, key)
	error(`{key} cannot be assigned to`, 2)
end
CF.__mul = function(a, b)
	if getmetatable(b) == V3 then
		return v3(
			a._x + a[1] * b.X + a[2] * b.Y + a[3] * b.Z,
			a._y + a[4] * b.X + a[5] * b.Y + a[6] * b.Z,
			a._z + a[7] * b.X + a[8] * b.Y + a[9] * b.Z
		)
	end
	return cf(
		a._x + a[1] * b._x + a[2] * b._y + a[3] * b._z,
		a._y + a[4] * b._x + a[5] * b._y + a[6] * b._z,
		a._z + a[7] * b._x + a[8] * b._y + a[9] * b._z,
		a[1] * b[1] + a[2] * b[4] + a[3] * b[7],
		a[1] * b[2] + a[2] * b[5] + a[3] * b[8],
		a[1] * b[3] + a[2] * b[6] + a[3] * b[9],
		a[4] * b[1] + a[5] * b[4] + a[6] * b[7],
		a[4] * b[2] + a[5] * b[5] + a[6] * b[8],
		a[4] * b[3] + a[5] * b[6] + a[6] * b[9],
		a[7] * b[1] + a[8] * b[4] + a[9] * b[7],
		a[7] * b[2] + a[8] * b[5] + a[9] * b[8],
		a[7] * b[3] + a[8] * b[6] + a[9] * b[9]
	)
end
CF.__add = function(a, v)
	return cf(a._x + v.X, a._y + v.Y, a._z + v.Z, a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9])
end
CF.__sub = function(a, v)
	return cf(a._x - v.X, a._y - v.Y, a._z - v.Z, a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9])
end
CF.__eq = function(a, b)
	for i = 1, 9 do
		if a[i] ~= b[i] then
			return false
		end
	end
	return a._x == b._x and a._y == b._y and a._z == b._z
end
CF.__tostring = function(c)
	return `{c._x}, {c._y}, {c._z}, {c[1]}, {c[2]}, {c[3]}, {c[4]}, {c[5]}, {c[6]}, {c[7]}, {c[8]}, {c[9]}`
end

function CFmethods.Inverse(c)
	-- The transpose of the rotation, and the position turned back
	local r00, r01, r02, r10, r11, r12, r20, r21, r22 = c[1], c[4], c[7], c[2], c[5], c[8], c[3], c[6], c[9]
	return cf(
		-(r00 * c._x + r01 * c._y + r02 * c._z),
		-(r10 * c._x + r11 * c._y + r12 * c._z),
		-(r20 * c._x + r21 * c._y + r22 * c._z),
		r00,
		r01,
		r02,
		r10,
		r11,
		r12,
		r20,
		r21,
		r22
	)
end
function CFmethods.PointToObjectSpace(c, v)
	local dx, dy, dz = v.X - c._x, v.Y - c._y, v.Z - c._z
	return v3(c[1] * dx + c[4] * dy + c[7] * dz, c[2] * dx + c[5] * dy + c[8] * dz, c[3] * dx + c[6] * dy + c[9] * dz)
end
function CFmethods.PointToWorldSpace(c, v)
	return c * v
end
function CFmethods.VectorToObjectSpace(c, v)
	return v3(c[1] * v.X + c[4] * v.Y + c[7] * v.Z, c[2] * v.X + c[5] * v.Y + c[8] * v.Z, c[3] * v.X + c[6] * v.Y + c[9] * v.Z)
end
function CFmethods.VectorToWorldSpace(c, v)
	return v3(c[1] * v.X + c[2] * v.Y + c[3] * v.Z, c[4] * v.X + c[5] * v.Y + c[6] * v.Z, c[7] * v.X + c[8] * v.Y + c[9] * v.Z)
end
function CFmethods.ToWorldSpace(c, other)
	return c * other
end
function CFmethods.ToObjectSpace(c, other)
	return c:Inverse() * other
end
function CFmethods.GetComponents(c)
	return c._x, c._y, c._z, c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9]
end
CFmethods.components = CFmethods.GetComponents
function CFmethods.Lerp(a, b, t)
	-- shortcut: position lerps, rotation snaps halfway; nothing the gym runs lerps a rotation
	local p = a.Position:Lerp(b.Position, t)
	local r = if t < 0.5 then a else b
	return cf(p.X, p.Y, p.Z, r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9])
end

local function fromColumns(pos, rx, ry, rz)
	return cf(pos.X, pos.Y, pos.Z, rx.X, ry.X, rz.X, rx.Y, ry.Y, rz.Y, rx.Z, ry.Z, rz.Z)
end

local function angles(rx: number, ry: number, rz: number)
	-- Roblox's CFrame.Angles: rotate about Z, then Y, then X (the matrix is Rx * Ry * Rz)
	local cx, sx, cy, sy, cz, sz = math.cos(rx), math.sin(rx), math.cos(ry), math.sin(ry), math.cos(rz), math.sin(rz)
	local rotX = cf(0, 0, 0, 1, 0, 0, 0, cx, -sx, 0, sx, cx)
	local rotY = cf(0, 0, 0, cy, 0, sy, 0, 1, 0, -sy, 0, cy)
	local rotZ = cf(0, 0, 0, cz, -sz, 0, sz, cz, 0, 0, 0, 1)
	return rotX * rotY * rotZ
end

local CFrame = {
	new = function(a, b, c, ...)
		if a == nil then
			return cf(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		elseif type(a) == "number" then
			if select("#", ...) == 9 then
				return cf(a, b, c, ...)
			end
			return cf(a, b, c, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		elseif b == nil then
			return cf(a.X, a.Y, a.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		end
		-- From a position looking at a point
		local look = (b - a).Unit
		local right = look:Cross(Vector3.yAxis)
		if right.Magnitude < 1e-6 then
			right = Vector3.xAxis
		end
		right = right.Unit
		local up = right:Cross(look)
		return fromColumns(a, right, up, -look)
	end,
	fromMatrix = function(pos, vX, vY, vZ)
		vZ = vZ or vX:Cross(vY).Unit
		return fromColumns(pos, vX, vY, vZ)
	end,
	lookAlong = function(pos, direction, up)
		up = up or Vector3.yAxis
		local look = direction.Unit
		local right = look:Cross(up)
		if right.Magnitude < 1e-6 then
			right = Vector3.xAxis
		end
		right = right.Unit
		return fromColumns(pos, right, right:Cross(look), -look)
	end,
	Angles = angles,
	fromEulerAnglesXYZ = angles,
	fromOrientation = function(rx, ry, rz)
		return angles(0, ry, 0) * angles(rx, 0, 0) * angles(0, 0, rz)
	end,
	identity = cf(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}
datatypes.CFrame = CFrame
datatypes.CFrameMeta = CF
datatypes.cf = cf

--%%%%%%%%%%%%%%%%%%%% Random

-- xoshiro128**, seeded through splitmix32: Roblox's Random's API, not its numbers
local RandomMeta = {}
RandomMeta.__index = RandomMeta

local function splitmix(state: number)
	state = bit32.band(state + 0x9E3779B9, 0xFFFFFFFF)
	local z = state
	z = bit32.bxor(z, bit32.rshift(z, 16))
	z = (z * 0x85EBCA6B) % 2 ^ 32
	z = bit32.bxor(z, bit32.rshift(z, 13))
	z = (z * 0xC2B2AE35) % 2 ^ 32
	z = bit32.bxor(z, bit32.rshift(z, 16))
	return state, z
end

local function mul32(a: number, b: number)
	-- The low 32 bits of a * b, exact in doubles: split b in halves
	local low = (a * bit32.band(b, 0xFFFF)) % 2 ^ 32
	local high = (a * bit32.rshift(b, 16)) % 2 ^ 16
	return (low + high * 2 ^ 16) % 2 ^ 32
end

function RandomMeta:_next(): number
	local s = self._s
	local result = mul32(bit32.lrotate(mul32(s[2], 5), 7), 9)
	local t = bit32.lshift(s[2], 9)
	s[3] = bit32.bxor(s[3], s[1])
	s[4] = bit32.bxor(s[4], s[2])
	s[2] = bit32.bxor(s[2], s[3])
	s[1] = bit32.bxor(s[1], s[4])
	s[3] = bit32.bxor(s[3], t)
	s[4] = bit32.lrotate(s[4], 11)
	return result
end
function RandomMeta:NextNumber(min: number?, max: number?): number
	local unit = (self:_next() + self:_next() / 2 ^ 32) / 2 ^ 32
	if min == nil then
		return unit
	end
	return min + (max - min) * unit
end
function RandomMeta:NextInteger(min: number, max: number): number
	if max < min then
		min, max = max, min
	end
	return min + math.floor(self:NextNumber() * (max - min + 1))
end
function RandomMeta:NextUnitVector()
	local z = self:NextNumber(-1, 1)
	local a = self:NextNumber(0, 2 * math.pi)
	local r = sqrt(1 - z * z)
	return v3(r * math.cos(a), r * math.sin(a), z)
end
function RandomMeta:Shuffle(t)
	for i = #t, 2, -1 do
		local j = self:NextInteger(1, i)
		t[i], t[j] = t[j], t[i]
	end
end
function RandomMeta:Clone()
	return setmetatable({ _s = table.clone(self._s) }, RandomMeta)
end

local seedCounter = 0
datatypes.Random = {
	new = function(seed: number?)
		if seed == nil then
			seedCounter += 1
			seed = os.time() * 1000 + math.floor((os.clock() * 1e6) % 1000) + seedCounter * 7919
		end
		local state = math.floor(seed) % 2 ^ 32
		local s = {}
		for i = 1, 4 do
			state, s[i] = splitmix(state)
		end
		if s[1] == 0 and s[2] == 0 and s[3] == 0 and s[4] == 0 then
			s[1] = 1
		end
		return setmetatable({ _s = s }, RandomMeta)
	end,
}
datatypes.RandomMeta = RandomMeta

--%%%%%%%%%%%%%%%%%%%% NumberRange

local NumberRangeMeta = { __index = {} }
datatypes.NumberRange = {
	new = function(min: number, max: number?)
		return setmetatable({ Min = min, Max = max or min }, NumberRangeMeta)
	end,
}
datatypes.NumberRangeMeta = NumberRangeMeta

--%%%%%%%%%%%%%%%%%%%% Enum

-- Enum.<Type>.<Item>: one table per item, so items compare by identity as Roblox's do
local enumItems = {}
local EnumItemMeta = {
	__tostring = function(item)
		return `Enum.{item.EnumType}.{item.Name}`
	end,
}
local Enum = setmetatable({}, {
	__index = function(_enum, typeName)
		local items = enumItems[typeName]
		if not items then
			items = setmetatable({}, {
				__index = function(t, itemName)
					local item = setmetatable({ Name = itemName, EnumType = typeName, Value = 0 }, EnumItemMeta)
					rawset(t, itemName, item)
					return item
				end,
			})
			enumItems[typeName] = items
		end
		return items
	end,
})
datatypes.Enum = Enum
datatypes.EnumItemMeta = EnumItemMeta

--%%%%%%%%%%%%%%%%%%%% Passive types

-- Types only settings and visuals build: they keep what they were made with and do nothing
local passive = {}
local function passiveType(name: string)
	local meta = { __type = name }
	meta.__index = function(value, key)
		local args = rawget(value, "_args")
		if key == "R" then
			return args[1] or 0
		elseif key == "G" then
			return args[2] or 0
		elseif key == "B" then
			return args[3] or 0
		end
		return nil
	end
	local function make(...)
		return setmetatable({ _args = { ... } }, meta)
	end
	passive[meta] = name
	return setmetatable({ new = make }, {
		__index = function()
			return make
		end,
	})
end
for _, name in
	{
		"Color3",
		"TweenInfo",
		"UDim",
		"UDim2",
		"BrickColor",
		"ColorSequence",
		"ColorSequenceKeypoint",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"PhysicalProperties",
		"Font",
		"Rect",
		"Region3",
		"Faces",
		"Axes",
		"DateTime",
	}
do
	datatypes[name] = passiveType(name)
end
datatypes.PassiveMetas = passive

--%%%%%%%%%%%%%%%%%%%% typeof

function datatypes.typeof(value: any): string
	local meta = getmetatable(value)
	if meta == V3 then
		return "Vector3"
	elseif meta == CF then
		return "CFrame"
	elseif meta == V2 then
		return "Vector2"
	elseif meta == RandomMeta then
		return "Random"
	elseif meta == NumberRangeMeta then
		return "NumberRange"
	elseif meta == EnumItemMeta then
		return "EnumItem"
	elseif type(meta) == "table" and passive[meta] then
		return passive[meta]
	elseif type(value) == "table" and rawget(value, "_isInstance") then
		return "Instance"
	end
	return typeof(value)
end

return datatypes
