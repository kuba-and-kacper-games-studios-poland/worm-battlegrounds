---
name: audit-and-fix
description: Audit a module or a directory of modules for bugs, leaks, performance, security and data safety, report the findings, then fix them. Run only when the user invokes it with a target.
argument-hint: <target path>
disable-model-invocation: true
---

# Audit and fix

*Framework skill: read only in a game (`.claude/rules/family/family.md` → Rules).*

Run on: $ARGUMENTS. If no target was given, ask for one before reading any code.

The rules in `.claude/rules/` still apply; this file is the job plan. If a step here and a rule disagree, the rule wins.

**Goal:** Read the target, report bugs, leaks, performance, security, and data-safety issues, then apply a prioritized fix plan. Authoring-style nits belong to the `refactor-to-framework` skill, not this pass.

---

## 1. Scope

The user names the target. “All scripts” means every `.lua` file **in that target**. Do not sample. Do not audit the rest of the repo.

- **One module:** that folder only (`Server.lua`, `Client.lua`, `Global.lua`, `Scripts/`, `Components/`, `Data/`, `Settings.lua`, `_meta/_types.lua`, `_meta/README.md`).
- **A directory of modules** (for example `src/modules/Main_Game`): every module under it. One report for the whole directory, not one report per module.

Do **not** expand into siblings outside the named path. When a finding depends on a `require` outside the target, read that required file and cite it. Do not audit the foreign module.

Static `Data/` rows still get opened. If a folder is only static tables, say so once with the file count.

### Framework vs game

- **`src/modules` and `src/global_data`:** flag bugs and framework misuse. Do not redesign framework modules (`src/modules_ume`, `src/core`, `src/libs`) to fix a game-code finding.
- **`src/modules_ume`, `src/core`, `src/libs`, or `src/actors`:** flag bugs in that code. Do not file comment, naming, or rail nits. Those are the refactor task.
- The inbound scanner in `src/modules_ume/Ume/Network/Settings.lua` is framework behavior. Do not re-flag it. Still check that a handler does not trust the client beyond what that scanner and `argTypes` already reject.

---

## 2. Hard constraints

- `profileData` and `I.Player.ProfileTemplate` are persistent. Do not change their structure, keys, types, values, or defaults. No migrations, no key renames, no new profile fields, no ensure or repair of saved profile data. A proposed fix that needs a schema change is invalid. Say so and skip it.
- Session data (`sessionProfileData`, in-memory maps, replicator attributes) may change.
- Fixes stay backward compatible with existing saved player data.
- Do not modify, rename, or delete files during the read. Report first, then edit.

---

## 3. Report

Write this in the chat before editing. Cite file and line for every claim. No speculation as fact. Mark uncertain items **unverified** and say what would confirm them. No duplicate findings: one ID, with a file list when the same pattern repeats.

If the user names priority bugs (file + line), analyze those first as separate top-level entries. Verify the line against the file. Do not swap line numbers. For each: the exact expression, the nil or wrong value, why it happens, the call path, and the minimal fix.

Then these sections, in this order:

1. **Errors / Bugs** — runtime errors, nil indexing, races, logic errors, unhandled yields, wrong API usage.
2. **Memory leaks** — undisconnected connections, uncleaned instances, tables that grow without bound, per-player data left on leave, loops that outlive their owner.
3. **Bottlenecks / Performance** — heavy loops, Heartbeat / RenderStepped work, repeated `GetDescendants` / `FindFirstChild` scans, unnecessary replication, excess remote traffic, avoidable per-frame allocations.
4. **Security / Exploits** — anything a client can abuse. Check:
   - Remote handlers missing argument type, range, and nil checks beyond the existing `argTypes` and Network scanner
   - Missing server ownership, permission, cost, and cooldown checks
   - Remote spam with no rate limit (crash, lag, or duplicate rewards)
   - Server trusting client position, damage, currency, plot ownership, or item ids
   - RemoteFunctions that can yield forever on the server
   - Unbounded tables or strings from the client
   - Dupe, race, and double-purchase paths
   - Exposed BindableEvents, attributes, or values the client can write
5. **Data safety** — paths that read or write `profileData` in a way that can corrupt it, plus confirmation that the fixes do not reshape it.

Each finding:

- **ID** — `BUG-01`, `LEAK-02`, `PERF-03`, `SEC-04`, `DATA-05`
- **File and lines**
- **Severity** — Critical / High / Medium / Low
- **What the code does**, with the evidence
- **Failure or exploit**
- **Proposed fix** — concise, not applied yet
- **profileData impact** — `none` or `must confirm` (existing keys only)

End the report with a **prioritized fix plan**: severity first, then risk of the change, with dependencies. Skip any item that would touch `profileData` shape.

---

## 4. Fix

Apply that plan in the same turn. Ume authoring rules still apply to every Lua edit. Read the matching guide from `.claude/rules/ume/overview.md` when the edit touches that artifact (`docs/guides/module-structure.md`, `docs/guides/comments.md`, `docs/guides/types.md`, plus the row for components, settings, data, events, or actors).

- Smallest change that removes the finding. No new features, no drive-by cleanup, no authoring restyle.
- Server authority for damage, currency, rewards, ownership, and zone. Do not trust client-supplied multipliers, prices, or positions.
- Rate-limit or cap client-driven remotes that can be spammed. A roll the server owns must run on a server clock (hit gap, shot gap), not on an unbounded client fire.
- Nil-guard a lookup only when this audit showed it can be missing. Do not add warn-and-skip around GUI that is required to exist. The ScreenGui `Enabled` check stays.
- Player-keyed session maps: clear them on leave.
- Disconnect connections you add. Do not rewrite an existing `Destroy` disconnect loop; add cleanup below it (`.claude/rules/ume/components.md`).
- If this edit is what pushes a file past the line band, split it (`.claude/rules/luau/file.md` → When to split, `.claude/rules/ume/structure.md` → Handlers). Do not split a file that was already past it unless this edit is what crosses the line.
- If tags or `*.comp.json` change, extract them (`.claude/rules/ume/tooling.md`).
- After Lua edits, stamp the files you wrote (`.claude/rules/luau/authorship.md`), update the unit's `_meta/README.md` where a fix changes what it lists, and run the checks in `.claude/rules/ume/overview.md` → Checks.

---

## 5. Finish

Confirm on the diff. Do not narrate the checklist.

- No `profileData` key, type, default, or migration change.
- Every new or edited function keeps the `%` header and `--[[ Phase ]]` body (lifecycle exceptions unchanged).
- The reply lists what was fixed, what was skipped because it would touch saved data, and anything left **unverified**.
