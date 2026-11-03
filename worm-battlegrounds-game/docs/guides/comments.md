<h1 align="center">Comments</h1>

<p align="center">
How functions are commented in ume: <code>%</code> headings, summary blocks, <code>**SERVER** |</code> / <code>**CLIENT** |</code> for environment-only APIs on <code>I</code>, internal <code>--[[ ... ]]</code> phases, and nested short bars. Pair with <a href="types.md">Types</a> for Luau inline types vs <code>--- @type</code> / <code>--- @param</code> / <code>--- @return</code>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[💬 Commenting principles (high level)](#commenting-principles-high-level)** | Inside vs outside functions and shared templates. |
| **[✍️ Header](#how-to-comment-a-module-function-step-by-step)** | `%` bars, summaries, `@param`, and `@return`. |
| **[🪜 Body](#body)** | Phases, `Checks`, and inline comments. |
| **[🖥️ Server](#server)** | Player guard, profile data, and the finished server example. |
| **[💻 Client](#client)** | Gui `Enabled` checks, prefabs, and UI phases. |
| **[🌐 Global](#global)** | Shared `I` names, and the server guard when `player` is first. |
| **[📑 Nested `%` bars inside large functions](#nested-bars-inside-large-functions)** | Category rails and scanning discipline. |
| **[📚 More examples (module, component, local function)](#more-examples-module-component-local-function)** | Patterns for helpers, components, and teardown. |
| **[🔗 Related](#related)** | Links to types, module structure, and components. |

---

<span id="commenting-principles-high-level"></span>

## 💬 Commenting principles (high level)

1. Use **`--[[ ... ]]`** sections inside functions to show flow.
2. Put a **`--`** line on each guard, and on any step whose purpose is not obvious from the next line.
3. Keep comments **short**.
4. Write comments so the **flow** of the function is obvious.

All modules follow the shared templates ([Module structure](module-structure.md), [Component Structure](component-structure.md)).

**Outside functions**, there should be **no** free-form comments — only structural markers: **`%`** region bars, **`--[[ ... ]]`** section labels where the template allows, and the **`Init` / `Start`** section dividers. (Those do not count as “random” comments.)

Header, body, server, client, and global rules below apply to every new or edited function, including locals and one-liners.

---

<span id="how-to-comment-a-module-function-step-by-step"></span>

## ✍️ Header

Start from a **category rail** (for example **Control**) and a placeholder short bar:

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% ###

function Module.AddAmountToPlayer(player: Player, amount: number) end
```

Rename the short **`%`** bar to **Title Case words** matching the function (drop a leading **`_`**; `Module._getSorted` → **Get Sorted**). One bar per function. Under **Local Functions**, each `local function` gets its own bar (`createDirectory` → **Create Directory**). A shared name such as **Helper Functions** is not a function title.

```lua
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

function Module.AddAmountToPlayer(player: Player, amount: number) end
```

```lua
-- BAD
--%%%%%%%%%%%%%%%%%%%% Helper Functions

local function createDirectory() end
local function renameScopeScripts() end

-- GOOD
--%%%%%%%%%%%%%%%%%%%% Create Directory

local function createDirectory() end

--%%%%%%%%%%%%%%%%%%%% Rename Scope Scripts

local function renameScopeScripts() end
```

Add the summary (one or two sentences, high level only). Plain text. Do not start a summary line with **`*`**. If the function returns a value, add **`--- @return`**.

Do **not** add a summary block (or `--- @return`) above **`Module.Init`**, **`Module.Start`**, **`Component.new`**, **`Component:Init`**, or **`Component:Destroy`**. Those keep the short **`%`** title only. Body `--[[ Phase ]]` sections inside `Init` / `Destroy` are still allowed.

### 🏷️ Parameters

Colon types on the signature are primitives and Roblox instances (`player: Player`, `amount: number`, `message: string?`).

Custom classes, arrays (`{ T }`), and dictionaries (`{ [K]: V }`) use **`--- @param`** above the function. Do not put those types on the colon. Full table-type rules: [Types](types.md).

```lua
-- BAD
function Module.AddAmountToPlayer(player: Player, amount: number, options: ModuleName_AddOptions)
function Module.AddAmountToPlayer(player: Player, amount: number, options: { string })

-- GOOD
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

--[[
	Adds an amount to the player's stored value.
]]
--- @param options ModuleName_AddOptions
--- @param ids { string }
--- @return boolean
function Module.AddAmountToPlayer(player: Player, amount: number, options, ids)
```

`**SERVER** |` / `**CLIENT** |` go on their own line above the summary only when that function is assigned to **`I`**. Assigned functions are PascalCase with no leading **`_`** (`Module.AddSomething`). **`Module._doSomething`** and a **`local function`** never get the mark, even in `Client.lua` or `Server.lua`. Also omit the mark when that same `I` name exists on both client and server. Those asterisks are the environment mark. See [Server](#server), [Client](#client), and [Global](#global).

Public APIs on **`I`** are **PascalCase** (`Module.AddAmountToPlayer`). Functions used only inside this script are **`Module._camelCase`** (`Module._getSorted`) — see [Module structure](module-structure.md).

---

<span id="body"></span>

## 🪜 Body

Name each **`--[[ Phase ]]`** after the work in that block (`Checks`, `Data`, `Calculating`, `Saving`, `Publishing`, `Applying`, `Finding`, `Returning`, …). Line comments sit under a phase. They do not replace it.

**Inline comments.** Each guard gets a `--` line immediately above it. One short clause that names the check, skip, or cap (`-- Check if amount is a positive integer`, `-- Skip server-only libraries on the client`). Do not add a second sentence of system rationale. Core tasks under `src/core/game_instance/Start/tasks/` do not comment the `I.Started` guard. `if I.Started then return end` stands alone, with no `--[[ Checks ]]` around it. A cap, a skip, or any other step whose purpose is not obvious from the next line gets one too. Straight property writes inside one UI apply phase stay uncommented. A `--` line comment inside a function has a blank line above it. No blank line between that comment and the statement it describes.

**`--[[ Checks ]]`** is any guard. Use it before data (bad input, unknown type, invalid filter, gui not `Enabled`) and again after data (missing row, wrong loaded value). A function may have more than one `Checks` block. Short `if`s that `return` (and may `warn`) have **no** blank lines inside the `if` (`warn` then `return` on consecutive lines).

Do **not** put `--[[ Returning ]]` inside a short guard `if`. Those early `return`s stay under `--[[ Checks ]]` (or whichever phase they belong to). `--[[ Returning ]]` is for the function’s actual result path.

A function whose body is one line — a single `return` — has no `--[[ Phase ]]` section. Keep the `%` title, the summary, and `--- @return`. Any other work (`Checks`, `Data`, a second statement) still uses phases.

```lua
--%%%%%%%%%%%%%%%%%%%% Get Rarities

--[[
	Returns copy of Rarity names table.
]]
--- @return { string }
function Module.GetRarities()
	return I.Table.DeepCopy(_settings.RARITY_NAMES)
end
```

**`--[[ Data ]]`** is domain lookups: **`GetData`**, **`profileData`** / **`sessionData`** / **`moduleData`**, replicator rows — not settings numbers, counts, sizes, or UI helpers like **`GetColor`**. A short `if not value then return` with no `--` line comment sits flush under the local that produced it.

**`--[[ Local Variables ]]`** is counts, sizes, settings keys, derived UI values, and other non-domain locals.

Writes and loops that follow **`--[[ Data ]]`** or **`--[[ Local Variables ]]`** get their own phase (`Calculating`, `Saving`, `Applying`, …). Do not leave them under those setup locals. A **`for`** body uses **`--[[ Phase ]]`** sections. A line comment does not replace them.

Leave a **blank line** between a run of locals and a **loop** or a **long** `if` (body does more than `warn` / `return`). Consecutive writes **inside the same UI apply phase** (`Texts`, `Strokes`, `Weights`) have **no** blank lines between lines. Blank lines stay **between phases**, not between every property.

Do **not** extract one-line wrappers (`setVisible`, `setText`, `setImage`, `clonePrefab`) that only hide a property write. Do **not** wrap `IsA` / nil checks around expected GUI instances — assign `.Text` / `.Visible` directly. Prefer `instance.UIGradient.Color = I.Gradient.GetColor(name)` over `FindFirstChild("UIGradient")` or an apply-gradient helper unless asked.

### 🧪 Logic only (still messy)

Same function as the header, with the work present and the phases still missing:

```lua
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

--[[
	**SERVER** |
	Adds an amount to the player's stored value.
	Publishes when the stored value changes.
]]
--- @param options ModuleName_AddOptions
--- @return boolean
function Module.AddAmountToPlayer(player: Player, amount: number, options)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	-- Check if amount is a positive integer
	if not I.Number.IsIntegerString(amount) or amount <= 0 then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["ModuleName"]

	local currencyData = I.Currency.GetData(options.CurrencyId)

	-- Check if that currency exists
	if not currencyData then
		warn(`[{_localName}::{script.Name}]: Currency ({options.CurrencyId}) is missing!`)
		return false
	end

	local currentAmount = moduleData["Current"]
	local finalAmount = currentAmount + amount

	-- Cap at the currency maximum when one is set
	if currencyData.Max and finalAmount > currencyData.Max then
		finalAmount = currencyData.Max
	end

	moduleData["Current"] = finalAmount

	-- Skip the topic when the stored value did not change
	if finalAmount ~= currentAmount then
		I.Topic.Publish("ModuleName_AmountChanged", player, finalAmount)
	end

	return true
end
```

### 🏷️ Inline Luau types where they help

Use **inline** types for primitives and Instances; use **`--- @type`** for custom classes (see [Types](types.md)).

```lua
	--[[ Calculating ]]

	local currentAmount: number = moduleData["Current"]
	local finalAmount: number = currentAmount + amount
```

---

<span id="server"></span>

## 🖥️ Server

Any server function whose first parameter is **`player`** starts with this guard, before any `--[[ Phase ]]`. Return that function's failure value (`false` when it returns a boolean, `nil` when it returns optional data). The sample returns `false` because that function returns a boolean. The guard is required even when the summary has no **`**SERVER** |`** mark.

```lua
-- Check if player is valid | SERVER
if not I.Player.Valid(player) then
	return false
end
```

The mark is only for a function assigned to **`I`** (`Module.AddAmountToPlayer`, no leading `_`) that exists on the server alone. **`Module._addAmount`** in the same file does not get it:

```lua
--[[
	**SERVER** |
	Adds an amount to the player's stored value.
]]
```

On **server** functions, if you load **`profileData`** (`I.Player.GetProfile(player).Data`) or **`sessionData`** (`I.Player.Sessions[player].Data`), those locals (and `moduleData` / `moduleSessionData` from them) come **first** in `--[[ Data ]]`. Always leave a **blank line** after `moduleData` / `moduleSessionData` before the next Data local. Other domain lookups (`GetData`, folders, etc.) go under that.

### 🪜 Add the phases

`Checks` runs once on the input, then again after the currency lookup. The cap and the publish skip keep their line comments.

```lua
--%%%%%%%%%%%%%%%%%%%% Add Amount To Player

--[[
	**SERVER** |
	Adds an amount to the player's stored value.
	Publishes when the stored value changes.
]]
--- @param options ModuleName_AddOptions
--- @return boolean
function Module.AddAmountToPlayer(player: Player, amount: number, options)
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

	local currencyData = I.Currency.GetData(options.CurrencyId)

	--[[ Checks ]]

	-- Check if that currency exists
	if not currencyData then
		warn(`[{_localName}::{script.Name}]: Currency ({options.CurrencyId}) is missing!`)
		return false
	end

	--[[ Calculating ]]

	local currentAmount = moduleData["Current"]
	local finalAmount = currentAmount + amount

	-- Cap at the currency maximum when one is set
	if currencyData.Max and finalAmount > currencyData.Max then
		finalAmount = currencyData.Max
	end

	--[[ Saving ]]

	moduleData["Current"] = finalAmount

	--[[ Publishing ]]

	-- Skip the topic when the stored value did not change
	if finalAmount ~= currentAmount then
		I.Topic.Publish("ModuleName_AmountChanged", player, finalAmount)
	end

	--[[ Returning ]]

	return true
end
```

---

<span id="client"></span>

## 💻 Client

**`**CLIENT** |`** only on a function assigned to **`I`** (`Module.Refresh`, no leading `_`) when that name exists only on the client. **`Module._refreshRows`** in the same file does not get the mark.

Refresh and display functions open with **`--[[ Checks ]]`** and return when the module gui is not **`Enabled`**. There is no **`I.Player.Valid`** guard.

Prefab populate order: **`Local Variables`** → **`Cloning`** → **`Elements`** (all `FindFirstChild` lookups) → apply (`Texts`, `Button`, …) → **`Saving`** (not `Cache`).

Name UI apply phases for the work (`Texts`, `Visibility`, `Background Color`).

```lua
--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	**CLIENT** |
	Refreshes the open module gui.
]]
function Module.Refresh()
	--[[ Checks ]]

	-- Check if the module gui is open
	if not moduleGui.Enabled then
		return
	end
end
```

---

<span id="global"></span>

## 🌐 Global

Omit **`**CLIENT** |`** / **`**SERVER** |`** when the same `I.ModuleName.Name` is assigned on both client and server (for example `I.ModuleName.GetData`). Signatures may differ (`player` on server, local replicator on client). The shared name is what matters. A **`Module._`** helper still never gets the mark.

Header and body rules still apply. When that function runs on the server and its first parameter is **`player`**, the server valid guard still comes first.

A one-line function still has no `--[[ Phase ]]` section (see [Get Rarities](#body)). A cache **`Get*`** that takes an id is not one line: it warns in **`--[[ Checks ]]`** when the id is missing. The miss **`return`** stays under **`Checks`**. Which value to return is the cache **`Get*`** rule in [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). This is the comment shape:

```lua
--%%%%%%%%%%%%%%%%%%%% Get Data

--[[
	Returns the row for an id.
]]
--- @return ModuleName_Row?
function Module.GetData(id: string)
	--[[ Checks ]]

	-- Check if the row exists
	if not rows[id] then
		warn(`[{_localName}::{script.Name}]: Row ({id}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return rows[id]
end
```

```lua
--%%%%%%%%%%%%%%%%%%%% Get Model

--[[
	Returns the model for an id.
]]
--- @return Model?
function Module.GetModel(id: string)
	--[[ Checks ]]

	-- Check if the model exists
	if not models[id] then
		if models["Default"] then
			warn(`[{_localName}::{script.Name}]: Model ({id}) is missing - using Default.`)
			return models["Default"]
		end
		if models["Missing"] then
			warn(`[{_localName}::{script.Name}]: Model ({id}) is missing - using Missing.`)
			return models["Missing"]
		end
		warn(`[{_localName}::{script.Name}]: Model ({id}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return models[id]
end
```

When **`GetData`** runs on the server and its first parameter is **`player`**, the valid guard still comes first. There is still no environment mark, because the name exists on both sides:

```lua
--%%%%%%%%%%%%%%%%%%%% Get Data

--[[
	Returns the row for an id.
]]
--- @return ModuleName_Row?
function Module.GetData(player: Player, id: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Checks ]]

	-- Check if the row exists
	if not rows[id] then
		warn(`[{_localName}::{script.Name}]: Row ({id}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return rows[id]
end
```

---

<span id="nested-bars-inside-large-functions"></span>

## 📑 Nested `%` bars inside large functions

For bigger routines, reuse **short `%` bars** inside the body as strong separators (same style as the function title bar):

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows notification for player.
]]
function Module.Show(message: string, gradientId: string?, duration: number?, soundId: string?)
	--%%%%%%%%%%%%%%%%%%%% Display

	local newMessage: TextLabel = prefabs["Message"]:Clone()
	newMessage.Visible = true
	newMessage.Parent = elems["Container"]

	--[[ Updating Properties ]]

	newMessage.Text = `{message}`
	newMessage.UIGradient.Color = I.Gradient.GetColor(gradientId)

	--[[ Playing Sound ]]

	I.Sound.Play({
		Name = soundId or "Notification_Default",
		Volume = 1,
		Location = nil,
		SoundGroup = "SFX",

		PitchMin = 0.95,
		PitchMax = 1,
	})

	--%%%%%%%%%%%%%%%%%%%% Animation

	newMessage.UIScale.Scale = 0

	--[[ Tweening ]]

	local Show_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local Show_TweenGoal = { Scale = 1 }
	local Show_Tween: Tween = I.S.TweenService:Create(newMessage.UIScale, Show_TweenInfo, Show_TweenGoal)
	Show_Tween:Play()

	--[[ Removing ]]

	task.delay(tonumber(duration) or 3, function()
		local Hide_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local Hide_TweenGoal = { Scale = 0 }
		local Hide_Tween: Tween = I.S.TweenService:Create(newMessage.UIScale, Hide_TweenInfo, Hide_TweenGoal)
		Hide_Tween:Play()

		-- Destroying on Tween ended
		Hide_Tween.Completed:Wait()
		newMessage:Destroy()
	end)
end
```

---

<span id="more-examples-module-component-local-function"></span>

## 📚 More examples (module, component, local function)

### 🔍 `_getElements`-style

Assign the module **`ScreenGui`** onto the General local (not a function-scoped `local`).

```lua
--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	notificationsGui = I.UserInterface.UI["Notifications"]

	--[[ General ]]

	elems["Container"] = notificationsGui:FindFirstChild("S_Container", true) --- @type Frame

	--[[ Prefabs ]]

	prefabs["Message"] = elems["Container"]:FindFirstChild("PREFAB | Message", true) --- @type TextLabel

	-- Hiding Prefabs
	prefabs["Message"].Visible = false
end
```

### 🧩 Component method

```lua
--%%%%%%%%%%%%%%%%%%%% Update Value

--[[
	Updates the abbreviation and tweens the currency value.
]]
function Component:UpdateValue()
	--[[ Getting Value ]]

	local amount: string = self.CurrencyDir:GetAttribute(self.CurrencyName) or "0"

	--[[ Updating ]]

	local value: string | number, suffix: string = I.BN.AbbreviationConvert(amount, 2, true)
	self.Abbreviation = suffix

	--[[ Tweening ]]

	local Value_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0)
	local Value_TweenGoal = { Value = I.Number.ToNumberOr(value, 0) }
	local Value_Tween: Tween = TweenService:Create(self.CurrencyValue, Value_TweenInfo, Value_TweenGoal)
	Value_Tween:Play()
end
```

### 🧹 Module teardown (`RemoveEffect`-style)

Nested short `%` bar mid-body, `--[[ Checks ]]` for the guard, then line comments for each teardown step. Example:

```lua
--%%%%%%%%%%%%%%%%%%%% Remove Effect

--[[
	Removes Effect slot.
]]
function Module.RemoveEffect(effectName: string)
	--[[ Checks ]]

	-- Check if the effect exists
	if not createdEffects[effectName] then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Removing

	-- Removing Connections
	if createdEffects[effectName].UpdateConnection then
		createdEffects[effectName].UpdateConnection:Disconnect()
	end
	if createdEffects[effectName].InteractConnection then
		createdEffects[effectName].InteractConnection:Disconnect()
	end

	-- Removing Effect
	if createdEffects[effectName].Instance then
		createdEffects[effectName].Instance:Destroy()
	end

	-- Clearing
	createdEffects[effectName] = nil
end
```

### 📝 Inline comments under phases

Line comments stay under a phase. A local helper can use more of them when each step is its own action.

```lua
--%%%%%%%%%%%%%%%%%%%% Get Tween For Widget

--[[
	Returns a Tween and a function to translate the widget before playing the Tween.
]]
--- @return Tween, function
local function getTweenForWidget(widget: Frame, tweenName: string)
	--[[ Checks ]]

	-- Check if the tween preset exists
	if not tweenPresets[tweenName] then
		warn(`[{_localName}::{script.Name}]: Invalid tween ({tweenName}); using Default.`)
		tweenName = "Default"
	end

	--[[ Finding ]]

	-- Getting Widget UUID
	local widgetUUID: string = widget:GetAttribute("WidgetManager_TweenUUID")
	if not widgetUUID then
		widgetUUID = I.Obfuscate.GetRandomString(16)
		widget:SetAttribute("WidgetManager_TweenUUID", widgetUUID)
	end

	-- Return existing Tween and PreTranslate function.
	if storedTweens[widgetUUID] and storedTweens[widgetUUID][tweenName] then
		return storedTweens[widgetUUID][tweenName], tweenPresets[tweenName].PreTranslate
	end

	--[[ Saving ]]

	-- Create Table for `widget` Instance.
	if not storedTweens[widgetUUID] then
		storedTweens[widgetUUID] = {}
	end

	-- Creates new Tween and return it with PreTranslate function.
	storedTweens[widgetUUID][tweenName] = TweenService:Create(widget, tweenPresets[tweenName].Info, tweenPresets[tweenName].PostTranslate)

	--[[ Returning ]]

	return storedTweens[widgetUUID][tweenName], tweenPresets[tweenName].PreTranslate
end
```

### 🧹 Server loop (`RemoveAll`-style)

Multiple returns use one **`--- @return`** each. Copy the ids before the loop that mutates the source table. Leave a blank line between that run of locals and the loop.

```lua
--%%%%%%%%%%%%%%%%%%%% Remove All

--[[
	**SERVER** |
	Removes all Tools for player.
]]
--- @return boolean
--- @return { string }?
function Module.RemoveAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Removing ]]

	-- Copy ids first so Remove can change CreatedTools
	local removedTools = {} --- @type { string }
	local toolUUIDs = {} --- @type { string }

	for toolUUID: string in pairs(moduleSessionData.CreatedTools) do
		table.insert(toolUUIDs, toolUUID)
	end

	for _, toolUUID: string in ipairs(toolUUIDs) do
		if Module.Remove(player, toolUUID) then
			table.insert(removedTools, toolUUID)
		end
	end

	--[[ Returning ]]

	return true, removedTools
end
```

---

<span id="related"></span>

## 🔗 Related

- [Types](types.md) — Luau vs annotations, `@class`, `_types.lua`
- [Module structure](module-structure.md)
- [Component Structure](component-structure.md)
- [Data Structure](data-structure.md)
- [Settings Structure](settings-structure.md)
- [Events](events.md)
