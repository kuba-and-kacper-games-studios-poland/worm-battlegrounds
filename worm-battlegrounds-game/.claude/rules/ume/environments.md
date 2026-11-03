# Ume environments

What a game module's functions add for the environment they run on, on top of `luau/comments.md`. Longer examples:
`docs/guides/comments.md`.

## The environment mark

- `**SERVER** |` or `**CLIENT** |` goes on its own line at the top of the summary only when the function is on `I`
  (PascalCase, no leading `_`) and that `I.ModuleName.Name` exists on that environment alone. It is the one summary
  line that may start with `*`.
- No mark when the same `I.ModuleName.Name` is assigned on both sides (Global), even with different signatures.
- `Module._doSomething` and `local function`s never get it, even in `Server.lua` or `Client.lua`.

## Server

- A server function whose first parameter is `player` opens with this guard, before any phase, even without a mark.
  It returns the function's failure value: `false` for a boolean, `nil` for optional data.

  ```lua
  -- Check if player is valid | SERVER
  if not I.Player.Valid(player) then
  	return false
  end
  ```

- In `--[[ Data ]]`, `profileData` / `sessionData` (and the `moduleData` / `moduleSessionData` taken from them) come
  first, with a blank line after them.

```lua
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

--[[
	**SERVER** |
	Adds an amount to the player's stored value.
]]
--- @return boolean
function Module.AddAmountToPlayer(player: Player, amount: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if amount is a positive integer
	if not I.Number.IsIntegerString(amount) or amount <= 0 then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["ModuleName"]

	--[[ Saving ]]

	moduleData["Current"] += amount

	--[[ Publishing ]]

	I.Topic.Publish("ModuleName_AmountChanged", player, moduleData["Current"])

	--[[ Returning ]]

	return true
end
```

## Client

- Refresh and display functions open with `--[[ Checks ]]` and return while the module gui isn't `Enabled`. No player
  guard.
- Populating a prefab runs `Local Variables` → `Cloning` → `Elements` (every `FindFirstChild`) → the apply phases,
  named for the work (`Texts`, `Visibility`, `Background Color`) → `Saving`.

## Global

- When a Global function runs on the server with `player` first, the server guard still comes first.
