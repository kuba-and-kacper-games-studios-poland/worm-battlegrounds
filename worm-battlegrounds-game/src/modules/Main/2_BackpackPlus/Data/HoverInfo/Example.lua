--# selene: allow(unused_variable)

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @return HoverInfo_Content?
return function(tool: Tool)
	-- Example
	return { Name = tool.Name }
end
