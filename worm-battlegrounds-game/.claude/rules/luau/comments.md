# Luau comments

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

## Function headers

Every function, new or edited (public, private, local or nested, one-liners too), has:

1. A `%` title bar in Title Case, named after it without a leading `_` (`Module._getSorted` → **Get Sorted**). One bar
   per function, never one over several (`Helper Functions`).
2. A summary block of one or two plain sentences. No line starts with `*` (ume's environment mark aside:
   `ume/environments.md`).
3. `--- @param` for every parameter typed with a `@class`, an array or a dictionary (`luau/types.md` → Table types).
4. `--- @return`, one per returned value, when it returns.

```lua
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

--[[
	Adds an amount to the player's stored value.
]]
--- @param options ModuleName_AddOptions
--- @param ids { string }
--- @return boolean
function Module.AddAmountToPlayer(player: Player, amount: number, options, ids)
```

Lifecycle functions (ume's `Module.Init` / `Module.Start` and `Component.new` / `Component:Init` / `Component:Destroy`,
ume-rbx's `Init` / `Start` / `Stop` / `Create` / `Destroy`) keep only the title bar: no summary, `--- @param` for a class or table parameter, `--- @return` only when callers read it. Their
bodies still have phases.

## Function bodies

Bodies are split into `--[[ Phase ]]` sections named after their work (`Checks`, `Data`, `Local Variables`,
`Calculating`, `Saving`, `Publishing`, `Applying`, `Building`, `Connections`, `Returning`, …). Line comments sit under
a phase; they never replace one.

- **`Checks`**: any guard (bad input, unknown id, a gui that isn't open, a missing row). A function may have several.
  Each guard has a one-clause `--` line right above it (`-- Check if amount is a positive integer`,
  `-- Skip ignored services`), with no second sentence of rationale.
- **`Data`**: domain lookups (`GetData`, profile, session and module data, Replicator rows, saved sections). A short
  `if not value then return` with no comment may sit right under its local.
- **`Local Variables`**: counts, sizes, settings keys, derived ui values, other non-domain locals.
- Writes and loops after `Data` or `Local Variables` get a phase of their own, and a `for` body of several steps has
  phases too.
- **`Returning`** is the real result path, never nested in a short guard `if`: that `return` stays under its phase.
- A function whose body is one `return` has no phase.
- Any step whose purpose the next line doesn't show gets a `--` line, with a blank line above it unless it is first
  under its phase label, and none below. Straight property writes in one ui apply phase stay uncommented and unspaced.
- No blank lines inside a short `if` / `warn` / `return`; one between a run of locals and a loop or a long `if`.
- Long builders (`Create`, `Build`, `ApplyTheme`) may split their body with short `%` bars (`--%%%%%%%%%%%%%%%%%%%%
  Header`), and group related ui under one phase instead of labelling every `Instance.new`.

```lua
--%%%%%%%%%%%%%%%%%%%% Set Service Enabled

--[[
	Changes whether one visible top-level service is included in scans.
]]
--- @param enabledServices { [string]: boolean }
--- @return boolean
function Module.SetServiceEnabled(gameRef: DataModel, serviceName: string, enabled: boolean, enabledServices)
	--[[ Checks ]]

	-- Check if the service exists in this place
	if not gameRef:FindFirstChild(serviceName) then
		return false
	end

	--[[ Saving ]]

	enabledServices[serviceName] = enabled

	--[[ Returning ]]

	return true
end
```

## Outside functions

Only structural markers: `%` region bars, the Module banner, `--[[ Section ]]` labels in tables and Local Variables,
and the dividers a template shows (`INITIALIZATION`, `REGISTRY`…). The one free-form comment is a short note on a
setting or table key whose purpose isn't obvious:

- One line is `-- text`. Two or more lines are a `--[[ ]]` block with the text indented one tab, never stacked `--`
  lines.
- The comment, the key's `--- @type` when it has one, and the key touch; anything else gets a blank line above it, so
  no comment or `--- @type` sits right under the line before.

```lua
	-- BAD
	PRESS_TRANSPARENCY = 0.85,
	-- Hovering and pressing fade the highlight in;
	-- leaving and releasing fade it back out
	PRESS_TWEENINFO = TweenInfo.new(0.075),

	-- GOOD
	PRESS_TRANSPARENCY = 0.85,

	--[[
		Hovering and pressing fade the highlight in;
		leaving and releasing fade it back out
	]]
	PRESS_TWEENINFO = TweenInfo.new(0.075),
```

A `Settings.lua` adds its own layout: `ume/settings.md` in ume, `plugin/settings.md` in ume-rbx.
