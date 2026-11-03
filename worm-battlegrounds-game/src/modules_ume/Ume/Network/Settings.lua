--- @class Network_Settings
local _settings = {

	-- Allowed remote types.
	REMOTE_TYPES = {
		"RemoteEvent",
		"RemoteFunction",
		"UnreliableRemoteEvent",
	},

	-- Obfuscate all remote names.
	OBFUSCATE = true,

	-- Seconds a server Invoke waits for the client before it gives up.
	INVOKE_CLIENT_TIMEOUT = 10,

	-- Seconds between two warns about rejected calls from one player on one remote.
	REJECT_WARN_INTERVAL = 5,

	--%%%%%%%%%%%%%%%%%%%% Argument Scan

	-- Maximum length of a string sent to the server
	MAX_STRING_LENGTH = 200,

	-- Maximum size length of a table sent to the server
	MAX_TABLE_SIZE = 100,

	-- Maximum depth of a table sent to the server.
	MAX_TABLE_DEPTH = 10,
}
return _settings
