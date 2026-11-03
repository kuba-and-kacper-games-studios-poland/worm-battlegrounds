<h1 align="center">Module README</h1>

<p align="center">
Every module and library has a <code>_meta/README.md</code>: what it does, what it exposes on <code>I</code> on each side, what it sends and saves, and which instances its components go on. It is the only place a module is described; nothing describes the module above <code>local Module = {}</code>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[🎯 Rule](#rule)** | Pointer to the README rule. |
| **[📋 Module template](#module)** | The sections of a module README, in order. |
| **[📚 Library template](#library)** | The shorter shape for a library. |
| **[🔎 Examples](#examples)** | Network and Currency. |
| **[🔗 Related](#related)** | Events, components, types. |

---

<span id="rule"></span>

## 🎯 Rule

When a README is required, what it must list and when it is updated: [`.claude/rules/luau/readme.md`](../../.claude/rules/luau/readme.md). `/readme <module folder>` writes or refreshes one from the code.

The file is `<Module>/_meta/README.md`. `.md` files never sync into Studio, and `protect.lua` hides `_meta` folders anyway, so a README costs nothing at runtime.

---

<span id="module"></span>

## 📋 Module template

Sections in this order. Leave out any section that would be empty; never write "None".

| # | Section | Holds |
| --- | --- | --- |
| 1 | `# <Module>` + overview | One paragraph: what the module does, which side writes and which reads, how its pieces connect. |
| 2 | Facts table | `Folder`, `Runs on` (the entry scripts it has), `Exposes` (`I.<Name>` and `I.G_<Name>`, with sides), `Uses` (the `I.*` modules and libraries it calls), `Saves` (the profile key, when it has one). |
| 3 | `## Files` | Every file in the module and what it controls: entry scripts, `Settings.lua`, `Scripts/**` handlers and helpers, `Components/*`, `Data/`. |
| 4 | `## API` | One `###` per side that assigns `I`: `Server: I.<Name>`, `Client: I.<Name>`, `Global: I.G_<Name>`. A table of `Function` (with its parameters), `Returns`, `What it does`, in the order of the `I` table. When the client has the same getters without `player`, say so in a sentence instead of repeating the table. |
| 5 | `## Usage` | The few calls another module makes, as a short `lua` block. |
| 6 | `## Network` | One `###` per side (`Server`, `Client`), with **Topics**, **Receive: RemoteEvents**, **Receive: RemoteFunctions**, **Send: RemoteEvents**, **Send: RemoteFunctions** groups in that order, one bullet per name: `` `Name @ (arg: type, …)` ``, then when it fires. Only names this module creates (`.claude/rules/ume/events.md`). Say in one line when the module uses no remotes and why. |
| 7 | `## Data` | Profile keys from the template the entry script writes, Replicator folders and attributes, session data other modules read: `Where`, `Key`, `What`. |
| 8 | `## Settings` | Every `Settings.lua` key: `Key`, default, `What`. For a table of entries (`CURRENCIES[name]`), the entry's keys with the shipped entry's values. |
| 9 | `## In the place` | Instances the module creates or expects outside its own folder (folders, remotes, guis, `S_` elements), with the attributes it sets on them. |
| 10 | `## Components` | One `###` per tag: `` `Tag` (`Components/File.lua`) ``, a sentence on what it does, a table of `Tag on` (instance class), `Side` (`Register` / `RegisterOnLoaded`), `Needs` (required children, guis), then an attribute table (`Attribute`, `Type`, `Default`, `What`) and an ObjectValue table (`ObjectValue child`, `Points to`, `What`). A tag with only a manifest says which script handles it. |
| 11 | `## Commands` | From `Scripts/AdminPanel/CommandBar/`: the command name and side, then `Subcommand`, `Arguments` (optional ones in `[ ]`). |
| 12 | `## Dashboard` | From `Scripts/AdminPanel/Dashboard/`: the panel's id, Scope (a Game page or sections on every player's page) and level, then a table of `Section` and its `Blocks`. |

Write from the code, not from memory: the `I` table, the functions behind it, `Settings.lua`, `*.comp.json` and the `GetAttribute` calls, every `I.Topic.Register` and `I.Network.Get*`, the profile template, `I.AdminPanel_CommandBar.Register`, `I.AdminPanel_Dashboard.Register`.

---

<span id="library"></span>

## 📚 Library template

A library (`src/libs/Internal/<Lib>`, `src/libs/External/<Lib>`) uses sections 1 to 5 and then **Types**:

| # | Section | Holds |
| --- | --- | --- |
| 1 | `# <Library>` + overview | What it is for. For an external library, where it comes from and what was changed. |
| 2 | Facts table | `Folder`, `Exposes` (`I.<Name>`: several libraries are renamed, such as `I.BN` for BigNum), `Runs on` (both sides, or server only). |
| 3 | `## Files` | `init.lua`, `Scripts/`, `Data/`, `Components/`. |
| 4 | `## API` | `Function`, `Returns`, `What it does`, grouped by job. Constructors and objects get their own table of methods. |
| 5 | `## Usage` | A short `lua` block. |
| 6 | `## Types` | The classes in `_meta/_types.lua` a caller passes or receives. |

---

<span id="examples"></span>

## 🔎 Examples

- [Network](../../src/modules_ume/Ume/Network/_meta/README.md): a framework module that is all API, with settings and instances in the place.
- [Currency](../../src/modules/Main/2_Currency/_meta/README.md): a game module with server, client and global APIs, Topics, profile and Replicator data, a component and a command.

---

<span id="related"></span>

## 🔗 Related

- [Events](events.md): remotes, `argTypes` and Topics.
- [Component Structure](component-structure.md): components and `*.comp.json`.
- [Types](types.md): `_meta/_types.lua`, which stays next to the README.
