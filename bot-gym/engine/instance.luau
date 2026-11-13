--[[
	Roblox instances in plain Luau: the tree (Parent, children, FindFirstChild…), properties with their defaults,
	attributes and tags, Clone and Destroy, and what parts and models need (CFrame, Size, pivots, bounding boxes).
	Only what the game's arena, combat and bot code touch; an unknown class takes any property. The world (queries)
	is told when a part that queries can see changes (`onGeometry`).
]]

local datatypes = require("./datatypes")
local scheduler = require("./scheduler")

local Vector3 = datatypes.Vector3
local CFrame = datatypes.CFrame
local Enum = datatypes.Enum
local v3 = datatypes.v3

local NIL = newproxy(false)

local instance = {}
instance.NIL = NIL

-- Set by the world: called when the geometry queries see may have changed
instance.onGeometry = function() end

--%%%%%%%%%%%%%%%%%%%% Classes

-- name -> { Name, Base, Defaults, Getters, Setters, Methods } (each merged with its bases' at definition)
local classes = {}

local function defineClass(name: string, base: string?, defaults, getters, setters, methods)
	local parent = if base then classes[base] else nil
	local class = {
		Name = name,
		Base = parent,
		Defaults = if parent then table.clone(parent.Defaults) else {},
		Getters = if parent then table.clone(parent.Getters) else {},
		Setters = if parent then table.clone(parent.Setters) else {},
		Methods = if parent then table.clone(parent.Methods) else {},
		Lineage = if parent then table.clone(parent.Lineage) else {},
	}
	class.Lineage[name] = true
	for key, value in defaults or {} do
		class.Defaults[key] = value
	end
	for key, value in getters or {} do
		class.Getters[key] = value
	end
	for key, value in setters or {} do
		class.Setters[key] = value
	end
	for key, value in methods or {} do
		class.Methods[key] = value
	end
	classes[name] = class
	return class
end

local InstanceMeta = {}

local function isInWorkspace(inst): boolean
	local current = inst
	while current do
		if rawget(current, "_isWorkspace") then
			return true
		end
		current = current._props.Parent
		if current == NIL then
			return false
		end
	end
	return false
end
instance.IsInWorkspace = isInWorkspace

local function isPart(inst): boolean
	return inst._class.Lineage.BasePart == true
end

-- Whether queries can see the instance or anything in it
function instance.HasQueryable(inst): boolean
	if isPart(inst) and inst._props.CanQuery then
		return true
	end
	for _, child in inst._children do
		if instance.HasQueryable(child) then
			return true
		end
	end
	return false
end

local function geometryChanged(inst)
	if isInWorkspace(inst) then
		instance.onGeometry(inst)
	end
end

InstanceMeta.__index = function(self, key)
	local props = rawget(self, "_props")
	local value = props[key]
	if value ~= nil then
		if value == NIL then
			return nil
		end
		return value
	end
	local class = rawget(self, "_class")
	local getter = class.Getters[key]
	if getter then
		return getter(self)
	end
	local method = class.Methods[key]
	if method then
		return method
	end
	for _, child in rawget(self, "_children") do
		if child._props.Name == key then
			return child
		end
	end
	error(`{key} is not a valid member of {class.Name} "{props.Name}"`, 2)
end

InstanceMeta.__newindex = function(self, key, value)
	local class = rawget(self, "_class")
	if rawget(self, "_destroyed") and key == "Parent" and value ~= nil then
		error(`The Parent property of {self._props.Name} is locked`, 2)
	end
	local setter = class.Setters[key]
	if setter then
		setter(self, value)
		return
	end
	if class.Defaults[key] == nil and not class.Open then
		error(`{key} is not a valid member of {class.Name}`, 2)
	end
	self._props[key] = if value == nil then NIL else value
end

InstanceMeta.__tostring = function(self)
	return self._props.Name
end

local function new(className: string)
	local class = classes[className]
	if not class then
		-- Classes the gym doesn't know (constraints, effects…) take any property
		class = defineClass(className, "Instance")
		class.Open = true
	end
	local props = {}
	for key, value in class.Defaults do
		props[key] = value
	end
	props.Name = className
	local inst = setmetatable({
		_isInstance = true,
		_class = class,
		_props = props,
		_children = {},
		_attributes = {},
		_tags = {},
	}, InstanceMeta)
	return inst
end
instance.New = new

--%%%%%%%%%%%%%%%%%%%% Instance

local function setParent(self, parent)
	local props = self._props
	local old = props.Parent
	if old == NIL then
		old = nil
	end
	if old == parent then
		return
	end
	local wasIn = old ~= nil and isInWorkspace(self)
	if old then
		local siblings = old._children
		local index = table.find(siblings, self)
		if index then
			table.remove(siblings, index)
		end
	end
	props.Parent = if parent == nil then NIL else parent
	if parent then
		table.insert(parent._children, self)
	end
	if (wasIn or (parent ~= nil and isInWorkspace(self))) and instance.HasQueryable(self) then
		instance.onGeometry(self)
	end
	local changed = rawget(self, "_ancestryChanged")
	if changed then
		changed:Fire(self, parent)
	end
end

local function getDescendants(self, list)
	for _, child in self._children do
		table.insert(list, child)
		getDescendants(child, list)
	end
	return list
end

local function cloneInto(self, map)
	local copy = setmetatable({
		_isInstance = true,
		_class = self._class,
		_props = table.clone(self._props),
		_children = {},
		_attributes = table.clone(self._attributes),
		_tags = table.clone(self._tags),
		_rects = if rawget(self, "_rects") then table.clone(rawget(self, "_rects")) else nil,
		_source = rawget(self, "_source"),
		_text = rawget(self, "_text"),
	}, InstanceMeta)
	copy._props.Parent = NIL
	map[self] = copy
	for _, child in self._children do
		if child._props.Archivable ~= false then
			local childCopy = cloneInto(child, map)
			childCopy._props.Parent = copy
			table.insert(copy._children, childCopy)
		end
	end
	return copy
end

local function remapReferences(copy, map)
	for key, value in copy._props do
		if key ~= "Parent" and type(value) == "table" and rawget(value, "_isInstance") and map[value] then
			copy._props[key] = map[value]
		end
	end
	for _, child in copy._children do
		remapReferences(child, map)
	end
end

local function attributeSignal(self, name: string)
	local signals = rawget(self, "_attributeSignals")
	if not signals then
		signals = {}
		rawset(self, "_attributeSignals", signals)
	end
	signals[name] = signals[name] or scheduler.NewSignal()
	return signals[name]
end

defineClass("Instance", nil, {
	Name = "Instance",
	Parent = NIL,
	Archivable = true,
}, {
	ClassName = function(self)
		return self._class.Name
	end,
	AncestryChanged = function(self)
		local signal = rawget(self, "_ancestryChanged")
		if not signal then
			signal = scheduler.NewSignal()
			rawset(self, "_ancestryChanged", signal)
		end
		return signal
	end,
	Destroying = function(self)
		local signal = rawget(self, "_destroying")
		if not signal then
			signal = scheduler.NewSignal()
			rawset(self, "_destroying", signal)
		end
		return signal
	end,
	ChildAdded = function()
		return scheduler.NewSignal()
	end,
	ChildRemoved = function()
		return scheduler.NewSignal()
	end,
	DescendantAdded = function()
		return scheduler.NewSignal()
	end,
	DescendantRemoving = function()
		return scheduler.NewSignal()
	end,
	Changed = function()
		return scheduler.NewSignal()
	end,
}, {
	Parent = setParent,
}, {
	IsA = function(self, className: string): boolean
		return self._class.Lineage[className] == true
	end,
	GetChildren = function(self)
		return table.clone(self._children)
	end,
	GetDescendants = function(self)
		return getDescendants(self, {})
	end,
	FindFirstChild = function(self, name: string, recursive: boolean?)
		for _, child in self._children do
			if child._props.Name == name then
				return child
			end
		end
		if recursive then
			for _, child in self._children do
				local found = child:FindFirstChild(name, true)
				if found then
					return found
				end
			end
		end
		return nil
	end,
	WaitForChild = function(self, name: string)
		return self:FindFirstChild(name)
	end,
	FindFirstChildOfClass = function(self, className: string)
		for _, child in self._children do
			if child._class.Name == className then
				return child
			end
		end
		return nil
	end,
	FindFirstChildWhichIsA = function(self, className: string, recursive: boolean?)
		for _, child in self._children do
			if child._class.Lineage[className] then
				return child
			end
		end
		if recursive then
			for _, child in self._children do
				local found = child:FindFirstChildWhichIsA(className, true)
				if found then
					return found
				end
			end
		end
		return nil
	end,
	FindFirstAncestor = function(self, name: string)
		local current = self._props.Parent
		while current ~= NIL and current ~= nil do
			if current._props.Name == name then
				return current
			end
			current = current._props.Parent
		end
		return nil
	end,
	FindFirstAncestorOfClass = function(self, className: string)
		local current = self._props.Parent
		while current ~= NIL and current ~= nil do
			if current._class.Name == className then
				return current
			end
			current = current._props.Parent
		end
		return nil
	end,
	FindFirstAncestorWhichIsA = function(self, className: string)
		local current = self._props.Parent
		while current ~= NIL and current ~= nil do
			if current._class.Lineage[className] then
				return current
			end
			current = current._props.Parent
		end
		return nil
	end,
	IsDescendantOf = function(self, ancestor): boolean
		local current = self._props.Parent
		while current ~= NIL and current ~= nil do
			if current == ancestor then
				return true
			end
			current = current._props.Parent
		end
		return false
	end,
	IsAncestorOf = function(self, descendant): boolean
		return descendant:IsDescendantOf(self)
	end,
	GetFullName = function(self): string
		local names = {}
		local current = self
		while current ~= NIL and current ~= nil and not rawget(current, "_isGame") do
			table.insert(names, 1, current._props.Name)
			current = current._props.Parent
		end
		return table.concat(names, ".")
	end,
	Clone = function(self)
		local map = {}
		local copy = cloneInto(self, map)
		remapReferences(copy, map)
		return copy
	end,
	Destroy = function(self)
		if rawget(self, "_destroyed") then
			return
		end
		local destroying = rawget(self, "_destroying")
		if destroying then
			destroying:Fire()
		end
		for _, child in table.clone(self._children) do
			child:Destroy()
		end
		setParent(self, nil)
		rawset(self, "_destroyed", true)
	end,
	ClearAllChildren = function(self)
		for _, child in table.clone(self._children) do
			child:Destroy()
		end
	end,
	GetAttribute = function(self, name: string)
		return self._attributes[name]
	end,
	SetAttribute = function(self, name: string, value: any)
		if self._attributes[name] == value then
			return
		end
		self._attributes[name] = value
		local signals = rawget(self, "_attributeSignals")
		if signals and signals[name] then
			signals[name]:Fire()
		end
	end,
	GetAttributes = function(self)
		return table.clone(self._attributes)
	end,
	GetAttributeChangedSignal = attributeSignal,
	GetPropertyChangedSignal = function()
		return scheduler.NewSignal()
	end,
	HasTag = function(self, tag: string): boolean
		return self._tags[tag] == true
	end,
	AddTag = function(self, tag: string)
		self._tags[tag] = true
	end,
	RemoveTag = function(self, tag: string)
		self._tags[tag] = nil
	end,
	GetTags = function(self)
		local tags = {}
		for tag in self._tags do
			table.insert(tags, tag)
		end
		return tags
	end,
})

--%%%%%%%%%%%%%%%%%%%% Parts

local function rotatedExtents(cframe, size)
	-- The world box of a turned box: each world axis sums the box's half sizes along it
	local _x, _y, _z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cframe:GetComponents()
	local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
	return v3(
		2 * (math.abs(r00) * hx + math.abs(r01) * hy + math.abs(r02) * hz),
		2 * (math.abs(r10) * hx + math.abs(r11) * hy + math.abs(r12) * hz),
		2 * (math.abs(r20) * hx + math.abs(r21) * hy + math.abs(r22) * hz)
	)
end
instance.RotatedExtents = rotatedExtents

local function geometrySetter(key: string)
	return function(self, value)
		self._props[key] = value
		if isPart(self) and (self._props.CanQuery or key == "CanQuery") then
			geometryChanged(self)
		end
	end
end

defineClass("PVInstance", "Instance", {}, {}, {}, {})

defineClass("BasePart", "PVInstance", {
	CFrame = CFrame.new(),
	Size = Vector3.new(4, 1, 2),
	Anchored = false,
	CanCollide = true,
	CanQuery = true,
	CanTouch = true,
	CollisionGroup = "Default",
	Transparency = 0,
	Reflectance = 0,
	Color = datatypes.Color3.new(0.64, 0.64, 0.64),
	BrickColor = datatypes.BrickColor.new("Medium stone grey"),
	Material = Enum.Material.Plastic,
	MaterialVariant = "",
	Massless = false,
	CastShadow = true,
	Locked = false,
	AssemblyLinearVelocity = Vector3.zero,
	AssemblyAngularVelocity = Vector3.zero,
	CustomPhysicalProperties = NIL,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	LocalTransparencyModifier = 0,
}, {
	Position = function(self)
		return self._props.CFrame.Position
	end,
	Orientation = function()
		return Vector3.zero
	end,
	ExtentsSize = function(self)
		local cframe = self._props.CFrame
		if datatypes.IsAxisAligned(cframe) then
			return self._props.Size
		end
		return rotatedExtents(cframe, self._props.Size)
	end,
	ExtentsCFrame = function(self)
		return CFrame.new(self._props.CFrame.Position)
	end,
	Mass = function(self)
		local size = self._props.Size
		return size.X * size.Y * size.Z * 0.7
	end,
	AssemblyMass = function(self)
		local size = self._props.Size
		return size.X * size.Y * size.Z * 0.7
	end,
	Touched = function()
		return scheduler.NewSignal()
	end,
}, {
	CFrame = geometrySetter("CFrame"),
	Size = function(self, value)
		local old = self._props.Size
		local rects = rawget(self, "_rects")
		if rects and old.X > 0 and old.Y > 0 then
			-- A union scales its shape with its size
			local sx, sy = value.X / old.X, value.Y / old.Y
			local scaled = {}
			for i, rect in rects do
				scaled[i] = { rect[1] * sx, rect[2] * sy, rect[3] * sx, rect[4] * sy }
			end
			rawset(self, "_rects", scaled)
		end
		self._props.Size = value
		if self._props.CanQuery then
			geometryChanged(self)
		end
	end,
	Position = function(self, value)
		local cframe = self._props.CFrame
		self._props.CFrame = cframe - cframe.Position + value
		if self._props.CanQuery then
			geometryChanged(self)
		end
	end,
	Orientation = function() end,
	CanQuery = geometrySetter("CanQuery"),
	CanCollide = geometrySetter("CanCollide"),
	CollisionGroup = geometrySetter("CollisionGroup"),
	Anchored = function(self, value)
		self._props.Anchored = value
	end,
}, {
	GetPivot = function(self)
		return self._props.CFrame
	end,
	PivotTo = function(self, cframe)
		self.CFrame = cframe
	end,
	GetMass = function(self)
		return self.Mass
	end,
	SetNetworkOwner = function() end,
	SetNetworkOwnershipAuto = function() end,
	GetNetworkOwner = function()
		return nil
	end,
	ApplyImpulse = function() end,
	GetTouchingParts = function()
		return {}
	end,
})

defineClass("Part", "BasePart", { Shape = Enum.PartType.Block }, {}, { Shape = geometrySetter("Shape") }, {})
defineClass("SpawnLocation", "Part", {}, {}, {}, {})
defineClass("WedgePart", "BasePart", {}, {}, {}, {})
defineClass("MeshPart", "BasePart", { MeshId = "", TextureID = "" }, {}, {}, {})
defineClass("UnionOperation", "BasePart", {
	UsePartColor = false,
	SmoothingAngle = 0,
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionFidelity = Enum.CollisionFidelity.Default,
}, {}, {}, {})

--%%%%%%%%%%%%%%%%%%%% Models

local function getParts(self)
	local parts = {}
	for _, inst in self:GetDescendants() do
		if isPart(inst) then
			table.insert(parts, inst)
		end
	end
	return parts
end

local function boundingBox(parts)
	local low, high = nil, nil
	for _, part in parts do
		local center = part._props.CFrame.Position
		local half = part.ExtentsSize / 2
		low = if low then low:Min(center - half) else center - half
		high = if high then high:Max(center + half) else center + half
	end
	if not low then
		return CFrame.new(), Vector3.zero
	end
	return CFrame.new((low + high) / 2), high - low
end
instance.BoundingBox = boundingBox

defineClass("Model", "PVInstance", {
	PrimaryPart = NIL,
	WorldPivot = NIL,
	ModelStreamingMode = Enum.ModelStreamingMode.Default,
	LevelOfDetail = Enum.ModelLevelOfDetail.Automatic,
}, {}, {}, {
	GetPivot = function(self)
		local primary = self._props.PrimaryPart
		if primary ~= NIL then
			return primary._props.CFrame
		end
		local pivot = self._props.WorldPivot
		if pivot ~= NIL then
			return pivot
		end
		return (boundingBox(getParts(self)))
	end,
	PivotTo = function(self, cframe)
		local offset = cframe * self:GetPivot():Inverse()
		for _, part in getParts(self) do
			part.CFrame = offset * part._props.CFrame
		end
		if self._props.PrimaryPart == NIL and self._props.WorldPivot ~= NIL then
			self._props.WorldPivot = cframe
		end
	end,
	GetBoundingBox = function(self)
		return boundingBox(getParts(self))
	end,
	GetExtentsSize = function(self)
		local _cframe, size = boundingBox(getParts(self))
		return size
	end,
	SetPrimaryPartCFrame = function(self, cframe)
		self:PivotTo(cframe)
	end,
	GetPrimaryPartCFrame = function(self)
		return self:GetPivot()
	end,
	ScaleTo = function() end,
	GetScale = function()
		return 1
	end,
})
defineClass("WorldModel", "Model", {}, {}, {}, {})

--%%%%%%%%%%%%%%%%%%%% Others

defineClass("Folder", "Instance", {}, {}, {}, {})
defineClass("Configuration", "Instance", {}, {}, {}, {})
defineClass("Attachment", "Instance", {
	CFrame = CFrame.new(),
	Visible = false,
}, {
	Position = function(self)
		return self._props.CFrame.Position
	end,
	WorldCFrame = function(self)
		local parent = self._props.Parent
		if parent ~= NIL and isPart(parent) then
			return parent._props.CFrame * self._props.CFrame
		end
		return self._props.CFrame
	end,
	WorldPosition = function(self)
		return self.WorldCFrame.Position
	end,
	Axis = function(self)
		return self._props.CFrame.RightVector
	end,
	SecondaryAxis = function(self)
		return self._props.CFrame.UpVector
	end,
}, {
	Position = function(self, value)
		local cframe = self._props.CFrame
		self._props.CFrame = cframe - cframe.Position + value
	end,
	WorldPosition = function(self, value)
		local parent = self._props.Parent
		local cframe = self._props.CFrame
		local localPosition = if parent ~= NIL and isPart(parent) then parent._props.CFrame:PointToObjectSpace(value) else value
		self._props.CFrame = cframe - cframe.Position + localPosition
	end,
}, {})
defineClass("LuaSourceContainer", "Instance", {}, {}, {}, {})
defineClass("ModuleScript", "LuaSourceContainer", {}, {}, {}, {})
defineClass("Script", "LuaSourceContainer", { Enabled = true, Disabled = false }, {}, {}, {})
defineClass("LocalScript", "Script", {}, {}, {}, {})
defineClass("ValueBase", "Instance", {}, {}, {}, {})
for className, default in
	{
		StringValue = "",
		NumberValue = 0,
		IntValue = 0,
		BoolValue = false,
		ObjectValue = NIL,
		Vector3Value = Vector3.zero,
		CFrameValue = CFrame.new(),
	}
do
	defineClass(className, "ValueBase", { Value = default }, {
		Changed = function()
			return scheduler.NewSignal()
		end,
	}, {}, {})
end

instance.DefineClass = defineClass
instance.Classes = classes

--[[
	Makes an instance whose own methods and properties come from a table (services, the DataModel).
]]
function instance.NewService(className: string, members)
	local class = classes[className] or defineClass(className, "Instance")
	class.Open = true
	for key, value in members do
		if type(value) == "function" then
			class.Methods[key] = value
		end
	end
	local inst = new(className)
	inst._props.Name = className
	for key, value in members do
		if type(value) ~= "function" then
			inst._props[key] = value
		end
	end
	return inst
end

return instance
