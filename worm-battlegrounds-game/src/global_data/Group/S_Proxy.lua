--[[
    Created By:     Nari
]]

--- @class Group_S_Proxy
---
--- # General #
---
--- @field Enabled boolean
---
--- # Request #
---
--- @field Url string
--- @field MaxRank number
local data = {

	--[[ General ]]

	-- Re-read membership through the proxy when a client asks for a refresh after a join prompt (needs HTTP Requests on).
	Enabled = true,

	--[[ Request ]]

	-- Roles of a user in all of their groups; `%d` is replaced by the user id.
	Url = "https://groups.roproxy.com/v2/users/%d/groups/roles",

	-- Highest rank the proxy's answer is trusted for.
	MaxRank = 10,
}
return data
