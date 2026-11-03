# new-project

The template every new ume game starts from. A game is one repo with two folders: its code (a copy of
[ume](https://github.com/ume-roblox/ume)) and its guis (a copy of [ume-gui](https://github.com/ume-roblox/ume-gui)),
both syncing into one place.

## Start a game

1. On GitHub, **Use this template** and name the repo after the game, e.g. `epic-mining`. Clone it.
2. In the repo, run `./setup.ps1` with no version options, or ask an agent to set the project up. It looks up the
   newest ume and ume-gui releases on GitHub itself, so you never type a version. You need git access to both repos.
3. Check the first line it prints (`Setting up … from ume vX and ume-gui vY`) names the newest releases, then commit
   what it made.
4. In UmeSync, make a category named after the game and add both folders to it. Open the place and connect both
   projects in the Ume Roblox plugin's **Sync** tool.

After setup, `epic-mining` holds:

```
epic-mining/
	epic-mining-game/    ume, named after the game: the game's code
	epic-mining-gui/     ume-gui, named after the game, with an EpicMining theme
	epic-mining.rbxl     the place
	README.md, AGENTS.md, CLAUDE.md, .gitignore   the game's own
```

## What setup does

1. Copies the newest ume and ume-gui tags into `<name>-game/` and `<name>-gui/`, without their git history.
2. Names both projects after the game, moves ume's place to `<name>.rbxl`, and drops ume's and ume-gui's front pages.
3. Adds a short note to each folder's `AGENTS.md` pointing agents to the game's root `AGENTS.md`.
4. Adds the game's theme (`src/themes/<Name>`, extending System) and mirrors the game's libraries into the gui folder.
5. Replaces this template's files with the game's (from `template/`) and deletes `template/` and `setup.ps1`.

| Option | Default |
| --- | --- |
| `-Name epic-mining` | The repo folder's name |
| `-Title "Epic Mining"` | The name in Title Case |
| `-UmeRef <tag>`, `-UmeGuiRef <tag>` | Each repo's newest `v*` tag, looked up when setup runs. Leave these out: pass one only to pin an older version on purpose, or `main` for unreleased changes |
| `-Author Nari` | Your ume-vscode nickname, else your git identity |

No file here records a current version: the newest is whatever GitHub has when setup runs. If setup says the two
"don't fit together", the newest ume-gui needs a newer ume than the latest tag: tag ume, then run setup again.

Setup works in a temporary folder and changes the repo only once everything is ready, so a failed run leaves it as it
was. It runs once.
