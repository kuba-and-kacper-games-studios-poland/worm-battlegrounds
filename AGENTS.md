# AGENTS.md

Guide for AI agents working in this repo.

## What this is

This repo is either the **new-project template** (`ume-roblox/new-project`) or a **new game made from it that isn't
set up yet**: `setup.ps1` and `template/` are still here. Setup turns it into the game's repo, with the game's code in
`<name>-game/` (a copy of ume) and its guis in `<name>-gui/` (a copy of ume-gui). `README.md` explains it for people.

## Setting a game up

When the user asks to set the project or the game up:

1. **Check where you are.** If `git remote get-url origin` is `ume-roblox/new-project`, this is the template itself:
   stop and tell the user to make a repo from it first (setup refuses there too).
2. **Confirm the name.** Setup names the game after this folder (`epic-mining` → "Epic Mining"). If the folder name
   isn't the game's name, ask, then pass `-Name` and `-Title`.
3. **Run it with no version options:** `./setup.ps1` (PowerShell 7), plus `-Name`/`-Title` from step 2 if needed.
   It looks up each repo's newest `v*` tag on GitHub itself and needs git access to `github.com/ume-roblox/ume` and
   `ume-gui`.
   - **Never pass `-UmeRef` or `-UmeGuiRef` yourself.** Don't take a version from a README, a doc, a sibling checkout,
     a changelog or your memory: those go stale. Don't clone or copy ume or ume-gui by hand either; setup does it.
   - Pass a version only when the user names one in chat (`-UmeRef v1.4.3`), or `main` when they ask for unreleased
     changes.
4. **Check the versions.** The first line setup prints is `Setting up … from ume vX and ume-gui vY`. Compare them with
   the newest tags:

   ```powershell
   git ls-remote --tags --refs --sort=-v:refname https://github.com/ume-roblox/ume "v*" | Select-Object -First 1
   git ls-remote --tags --refs --sort=-v:refname https://github.com/ume-roblox/ume-gui "v*" | Select-Object -First 1
   ```

   Keep `--sort=-v:refname`: without it tags sort as text, and `v3.9.0` comes after `v3.10.0`. If setup used anything
   older without the user asking for it, say so. Setup also warns when a passed ref is older than the newest tag.
   - **If setup says the two "don't fit together"**, the newest ume-gui needs a ume that isn't tagged yet. Stop and
     tell the user, quoting the error. Don't retry with older tags: the fix is a new ume tag, or `-UmeRef main` if
     the user agrees.
5. **Report** what it printed, with both versions. Commit only when the user asks.
6. **UmeSync.** If the `mcp__ume-sync__*` tools are available, create a category named after the game
   (`create_category`) and add both folders to it (`add_project` with `category`). Otherwise tell the user to do it in
   the UmeSync app.

After setup this file is replaced by the game's own `AGENTS.md`.

## Changing the template (in ume-roblox/new-project)

| Path | What |
| --- | --- |
| `setup.ps1` | The setup script |
| `template/` | The game's root files: `README.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore`. Setup fills `{{Name}}`, `{{Title}}`, `{{Theme}}`, `{{UmeRef}}` and `{{UmeGuiRef}}` |
| ume's and ume-gui's `.game/` | Not here: each folder's agent files in a game (`AGENTS.md`, `CLAUDE.md`, `.claude/rules/family/`, the starter game rules). Setup swaps them in for the repos' own |
| `README.md`, `AGENTS.md`, `CLAUDE.md` | This template's own files, replaced in a game |

Test a change by copying the repo into the scratchpad (without `.git`), naming the copy like a game, and running
`./setup.ps1 -UmeRef main -UmeGuiRef main` there. Never run setup in this repo.

The ume family's shared rules (`family/family.md` in any sibling repo) describe how new-project fits with ume, ume-gui
and the other repos. This repo keeps no `.claude/rules` of its own: a game gets the rules inside its two folders.
