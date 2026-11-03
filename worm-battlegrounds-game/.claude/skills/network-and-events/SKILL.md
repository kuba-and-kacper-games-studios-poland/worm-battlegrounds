---
name: network-and-events
description: Align one module's remotes, Topics and the Network section of its _meta/README.md with the events rule. Run only when the user invokes it with a target.
argument-hint: <target path>
disable-model-invocation: true
---

# Network and events

*Framework skill: read only in a game (`.claude/rules/family/family.md` → Rules).*

Run on: $ARGUMENTS. If no target was given, ask for one before reading any code.

The rules in `.claude/rules/` still apply; this file is the job plan. If a step here and a rule disagree, the rule wins.

**Goal:** The named module’s remotes, Topics, and the Network section of its `_meta/README.md` match the events rule. The diff is that registry alignment, not new features.

---

## 1. Scope

The user names the module. Inventory and edits stay inside that module (`Server.lua`, `Client.lua`, `Global.lua`, `Scripts/`, `Components/`, `_meta/README.md`).

A foreign remote or Topic is cited, not rewritten, unless that owner module is also the target. Do not add another module’s names to this module’s README.

---

## 2. Read (use the Read tool)

- `.claude/rules/ume/events.md` — who may `Get*`, inbound `argTypes`, Topics, the README's Network section
- `.claude/rules/ume/structure.md` — `Init` / `Start` placement, and who assigns `I`
- `docs/guides/events.md` — call shapes and the Network section template
- `docs/architecture/networking.md` — remotes versus Replicator
- `docs/architecture/module-communication.md` — when the work is same-environment `I.ModuleName` versus `I.Topic`

---

## 3. Inventory

Before editing, list every use inside the named module:

- `GetEvent` / `GetFunction` / `GetUEvent`
- `Fire` / `FireAll` / `Invoke` / `UFire` / `UFireAll`
- `Fired` / `OnInvoke` / `UFired`
- `Topic.Register` / `Topic.Publish` / `Topic.Subscribe` / `Topic.IsRegistered`
- Every name already written in the Network section of this module’s `_meta/README.md`

For each remote name, note which environment creates it, which listens, and which only sends. For each Topic, note who `Register`s it.

---

## 4. Pick the channel

Use the architecture docs. Do not add a second channel table here.

- **Remotes** (`I.Network`): client ↔ server **actions** and messages. Events are one-way. Functions return a value. Unreliable events are for high-frequency or loss-tolerant traffic.
- **Replicator**: the server sets **attributes** on per-player folders; the client reads them. Prefer this when values update often or you are mirroring a stable set of fields. Commands stay on remotes.
- **Topics** (`I.Topic`): **same environment only**. They do not cross the network. Use `I.ModuleName` when another module should **call** this one. Use a Topic when other modules should **react** to a change.

The server must create remotes so the instances exist and replicate. Clients subscribe or invoke after those instances are available.

---

## 5. Classify each remote

Owning rule: `.claude/rules/ume/events.md` (Who creates, the side table, schema placement, the Global wrap, call shapes). Call timing: `.claude/rules/ume/structure.md` (Init and Start).

Apply that table to every name from the inventory. For each name, decide: owner or foreign, which env listens, which only sends. Then fix the call sites so each one matches its row — move create + schema onto the owner receive path, drop `Get*` from send-only, foreign-listen, and `Components/` code, and move foreign sibling `Fired` / `Subscribe` into `Start`.

### Topics

Owning rule: the Topics section of `.claude/rules/ume/events.md`. Check each Topic from the inventory: bare owner `Publish`, `Register` above any `Publish` in the same `Init`, `IsRegistered` only for optional Topics, foreign same-directory `Subscribe` in `Start`.

---

## 6. Rewrite the README's Network section

Owning rule: the Network section part of `.claude/rules/ume/events.md`. Template and payload spelling: `docs/guides/events.md`. Do not paste a second template here.

Rebuild the file from the inventory, not from its old contents: drop names that no longer exist in code or belong to another module, add every remote or Topic this module creates on the env that sends or receives it.

---

## 7. Finish

Confirm these on the diff. Do not narrate them.

- Each remote matches the classify table. Schema lives on the first owner `Get*` that listens, and its `argTypes` match exactly what the sender fires. Send-only create has no schema. Send-only and foreign listen have no `Get*`.
- The README's Network section matches the code. It lists only this module’s remotes and Topics.
- Owner `Publish` is bare. `Register` is above any Publish in the same `Init`.
- The diff is registry alignment, not new features.
- After Lua edits, stamp the files you wrote (`.claude/rules/luau/authorship.md`) and run the checks in `.claude/rules/ume/overview.md` → Checks.
