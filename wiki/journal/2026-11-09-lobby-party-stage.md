---
title: "The lobby is a party stage: your snail in front, your party on the pods around it"
date: 2026-11-09
status: open
kind: changed
pages: ["Lobby", "Party", "Lobby & meta modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds.rbxl
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Server.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** The owner asked for a Fortnite-style lobby (2026-11-09). The blurred bot match behind the lobby's
panels is gone. The camera looks at a stage with four pods: the player's snail stands on the front pod in their
equipped skin, idling. When friends join their party, they stand on the pods around it, each in their own skin. Empty
pods stay bare. Every player sees themselves in front on their own screen. Leaving the party, or another member
changing skin, updates the stage at once. Nothing is blurred any more.

**Where.** The stage is the Model `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB | Stage"]` (the old
`LobbyStage`, moved there on the owner's ask so it can be edited by hand in Studio). It stands beyond the baseplate's
+Z edge, its grass top at Y 0, around Z 1280. At runtime it's in `ReplicatedStorage.Ume.Assets.Lobby`, and each
client clones it into `Workspace.Ume.Lobby` as `Stage`. `ServerStorage.Ume.PlaceLoader_Workspace.Lobby` is now empty.
It has `Pods` with four pods, filled in this order:

- `Pod_1`: front. The player's own snail.
- `Pod_2`: right, 5 studs back and slightly raised.
- `Pod_3`: back, 13 studs back on a tall pedestal, so it shows over the front snail.
- `Pod_4`: left, 5 studs back and slightly raised. It fills last because the setup panel hangs over it.

Each pod has an invisible `Snail` marker. The `Markers.Camera` marker sits low and close, at (0, 7, 1180), looking at
(0, 3.6, 1204): the owner found the first, higher camera's view from above odd.

The code is Lobby's client `Scripts/Client/Stage.lua`. It orders the party by user id after the player, and builds
the snails in `Workspace.Ume.Lobby`. Lobby's new settings are `STAGE_PREFAB` "PREFAB | Stage", `PODS_FOLDER` "Pods",
`POD_PREFIX` "Pod_", `CAMERA_MARKER` "Camera", `SNAIL_MARKER` "Snail" and `STAGE_FOV` 50. Every `BACKDROP_*` setting
and both `Backdrop` scripts are removed.

The solo or party setup and the waiting room (MatchBoard's `U_Setup` and `U_WaitingRoom`) moved so they don't cover
the player's snail. Before, they hung from the bottom middle of the screen (anchor 0.5, 1 at 0.55, 0.978). Now they
hang from the bottom left, beside Party (anchor 0, 1 at 0.105, 0.978). The MatchBoard gui was exported again.

Cosmetics now also writes each player's skin as the `EquippedSkin` Player attribute, so party members see each
other's skins.

The place changed in Studio. It needs saving and publishing to both places.

**How to check.** Play the Studio map. The camera sits on the stage at FOV 50, your snail is on the front pod, and
three empty pods show between the Party and Loadout panels. This was checked in Studio on 2026-11-09 with one player:
no errors. A party with real players wasn't tested (it needs several clients).

**For the wiki.** Lobby: the background is now the party stage, which replaces the blurred bot match. Party: party
members appear on the stage. Architecture: the stage is Lobby's `PREFAB | Stage` in `ReplicatedStorage_Assets`, cloned by each client, and the lobby has no client bot
simulation.

**Still unsure.** On small phones the setup panel takes about half the screen's width, so it still partly covers
the front pod there. Phones and tablets weren't checked in Studio, only worked out from ScreenScale's numbers.

Supersedes 2026-11-07-lobby-bot-match: none of its backdrop holds any more.
