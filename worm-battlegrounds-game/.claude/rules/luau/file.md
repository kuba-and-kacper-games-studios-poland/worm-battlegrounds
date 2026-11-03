# Luau files

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

How every Luau ModuleScript is laid out, named and split. Each repo's structure rule adds its regions, lifecycle
functions and return value: `ume/structure.md` in ume (a game's code folder), `gui/code.md` in ume-gui (its gui
folder), `plugin/structure.md` in ume-rbx.

## Skeleton

In this order, skipping empty regions:

1. The author header (`luau/authorship.md`).
2. The repo's top lines: `ume/structure.md` → Top of the file in ume, `_localName` in ume-gui and ume-rbx.
3. Require regions, each under a full-width `--%%%…%%% Name` bar, in the structure rule's order. Services come the
   repo's way (`ume/structure.md` → Services in ume, the **Services** region in ume-gui and ume-rbx); never
   `game:GetService` inside a function.
4. **Local Variables**, grouped with `--[[ Section ]]` labels when there are two or more groups.
5. **Local Functions**.
6. The ASCII "Module" banner between two full-width bars.
7. `--- @class ClassName` directly above `local Module = {}` (names: `ume/classes.md`, `gui/code.md`, `plugin/classes.md`). Nothing
   describes the module there, neither a summary block nor `--` lines: that is the unit's `_meta/README.md`.
8. Lifecycle functions, then the rails.
9. The return value.

```lua
-- BAD: a description above the class
--[[
	Adds items to a player's inventory and saves them.
]]
--- @class Inventory_Server_Add
local Module = {}
```

Requires never use `WaitForChild`.

## Rails

After the lifecycle functions, functions sit on rails, each under a full-width bar (ume adds rails before these:
`ume/structure.md`).

- **Control** does work, usually returning nothing (`Set*`, `Apply*`, `Add`, `Refresh`, `_refreshRows`); an action's
  success `boolean` stays here. A `Get*` / `Can*` / `Is*` stays in Methods even when only Control calls it.
- **Methods** return data: `Get*`, then `Is*` / `Can*`, then other queries. A setter stays in Control even when it is
  public.
- In a rail, public functions come first, in the order the public table lists them, then private helpers.

## Names

- Public functions are PascalCase with no leading `_` (`Module.GetData`, `Mounting.Mount`).
- Private ones are `Module._camelCase`, lowercase after the `_`.
- Functions that return data are `Get*` (`GetPrice`, never `LabelText`); predicates are `Can*` / `Is*`.
- A `local function` under **Local Functions** is for work called from two or more places. A single call site stays
  inline, or becomes a `Module._camelCase` helper when inlining makes the caller hard to read.

## When to split

- A file that runs more than one system splits: one handler or side file per system, even a short one.
- One system but long: around 800 lines, decide whether a split helps; past 1000, split. The structure rule names any
  exception.
- A split file can become a folder whose `init.lua` is the ModuleScript, so requires keep working. Side files never
  require their `init.lua`, and there are no require cycles.

## Fail fast

- Treat every project module, settings key and API that must exist as existing, and call it directly. No chain-checks
  (`I and I.Currency and I.Currency.HasEnough`, `Tool and Tool.Open and Tool.Open()`). A call that fails because
  something isn't ready yet is fixed in the loading order.
- Validate only input that can really be wrong: a designer-typed id, saved data, user-typed text, instances found in
  the place. An unknown id warns inside the `Get*` that owns the lookup.

## GUI writes

Assign properties directly on the named instances, with no one-line wrappers that only set `.Text` or `.Visible`.
Every named gui element exists: don't `if` the lookup, `and`-chain `FindFirstChild`, or warn and skip, so a missing one
errors. Guard an element only when it can really be absent (place content, destroyed rows) or when told it may be.

```lua
-- BAD
local function setText(instance: Instance?, text: string)
	if instance and (instance:IsA("TextLabel") or instance:IsA("TextButton")) then
		instance.Text = text
	end
end
setText(container:FindFirstChild("S_HeaderText", true), name)

-- GOOD
local header: TextLabel = container:FindFirstChild("S_HeaderText", true)
header.Text = name
```
