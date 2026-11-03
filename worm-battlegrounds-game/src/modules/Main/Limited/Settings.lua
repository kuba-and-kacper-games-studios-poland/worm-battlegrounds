--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Limited_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% DataStore

	-- Name of the DataStore used to persist the global sold-count for each limited.
	DATASTORE_NAME = I.Env.IsStudio and "Limited_Stock_Test" or "Limited_Stock",

	--%%%%%%%%%%%%%%%%%%%% Refresh

	-- Seconds between reloads of every sold count from the DataStore (catches sales and give-backs on other servers).
	REFRESH_INTERVAL = 60,

	-- MessagingService topic each sale is published on, so other servers update right away.
	MESSAGING_TOPIC = "Limited_Sold",

	--%%%%%%%%%%%%%%%%%%%% Holds

	-- MemoryStore hash map holding copies while purchase prompts are open.
	HOLD_MAP_NAME = I.Env.IsStudio and "Limited_Holds_Test" or "Limited_Holds",

	-- Seconds a copy stays held for a player after the purchase prompt opens.
	HOLD_TIME = 120,
}
return _settings
