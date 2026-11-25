# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, where nothing saves, it marks the whole tutorial done instead, `I.Tutorial.Skip`, unless the
Workspace attribute `StudioTutorial` is true; with it true, the Lobby map alone, which can't start the match, marks
only the match played, so the crate and loadout steps still play); offers
a player who dropped out of a running match to go back; and puts a player who pressed PLAY AGAIN on a match's
knockout screen (their profile's `Match.PlayAgain`, still within its `Until`) straight into another match like it
(`I.MatchBoard.PlayAgain`), on join and, on the Studio map, as `InMatch` turns false. Behind the lobby's panels the camera looks at a stage, as
Fortnite's lobby does: the player's snail stands on the front pod in the pieces they wear, and the rest of their party
in this server stand on the pods around it, each in their own (the `Outfit` Player attribute Cosmetics
writes), by user id; empty pods hold no snail. In a custom lobby (`I.MatchBoard.GetCustomRoom`) its members stand instead on the
eight pods of `PREFAB | CustomPods`, in the lobby's order, and the camera backs off just enough to fit them all (the
owner, 2026-11-16). Every snail on the stage holds the Bazooka (`STAGE_WEAPON`) and strikes one of `STAGE_POSES` at
random, never the one it had, picked again when the members change or the player comes back from a match. Each client builds its own snails, so everyone sees themselves in front.
Over every stage snail stands the studio's nameplate (2026-11-24: the names and levels left the party cards and the
top of the screen for it): the level in its badge, the display name over the @username, kept up to date when the
`Level` Player attribute changes; the rest of the party's are smaller than the player's own. Over each pod still free floats a small, faded "+" bubble (a copy of the party
column's + card) while the player may invite (no party, its leader, or in a custom lobby) and isn't in a match:
pressing it opens the party invite (`PartyInvite`), or the custom lobby's window while they're in one.
The client shows the lobby's panels and holds the camera on the stage except while the player is in a match (the
`InMatch` Player attribute, which only changes on the Studio map), and hides the panels while a full-screen widget
(`FULL_SCREEN_WIDGETS`: Skins, Crates, Shop, and since 2026-11-25 the match setups, FriendsMatch, CustomLobby and MatchSetup) is open (the stage's nameplates and "+" bubbles too, through `Stage.SetLabelsShown`), or the guis a widget stands in for (`PANEL_WIDGETS`: the emote
shop over Loadout; the weapon picker and the free crate
dialog and the party invite over the top row and the board), from WidgetManager's `WidgetManager_Opened` and `WidgetManager_Closed` Topics.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map, Studio map |
| Exposes | `I.Lobby` (client) |
| Uses | `I.G_Progression` (`GetWeaponVariant`: the stage weapon's look), `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface`, `I.G_Cosmetics`, `I.SnailRig`, `I.G_Arsenal` (the stage's weapon), `I.Buff` (the `FOV` buff), `I.Interact` (the + bubbles), Party's settings (`MAX_PARTY` and its widgets' names), the `PartyId`, `PartyLeader`, `Outfit` and `Level` Player attributes (Party, Cosmetics, Progression), MatchBoard's `MatchBoard_RoomChanged` Topic |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer, Play again, `Workspace.Ume.Lobby` (where clients stand the party's snails) |
| `Client.lua` | Shows `LOBBY_GUIS` outside matches and while no full-screen widget is open, closes a lobby window still open when a match starts (the Studio map's custom lobby), asks "Rejoin your match?" |
| `Scripts/Client/Stage.lua` | The stage: the camera on its marker outside matches (set there at once, then eased to where it frames the stage, `STAGE_CAMERA_EASE`, from where it was held, never from the live camera, which Roblox moves as the avatar loads: 2026-11-17; in a custom lobby backed off along its look to fit every snail, `STAGE_FIT_MARGIN`), and the party's snails on its pods, or a custom lobby's on the `CustomPods` swapped in for them, each holding `STAGE_WEAPON` (`I.SnailRig.Hold`) in the look the member picked on the loadout's look tab, up to what their level opened for it or an admin gave (`I.G_Loadout.GetWornLook`, again when the `WeaponLooks` attribute changes; Progression's `WEAPON_REWARDS`: Shiny at 30, Golden at 90, `STAGE_WEAPON_LOOKS`, dressed as Combat dresses a held one: `I.G_Arsenal.Gild`, a ForceField sheen and a Highlight outline; the snail is dressed again when a `Level` or `WeaponVariants` change changes the look, 2026-11-24) in a random one of `STAGE_POSES` (looped from a random point, over the idle), rebuilt when someone joins or leaves the party or the custom lobby (`MatchBoard_RoomChanged`) or changes skin, and posed again when the members change or the player is back from a match (`InMatch`); each snail's nameplate (a clone of `NAMEPLATE_NAME`, made with the snail and parented to it, `NAMEPLATE_SCALE` times its design size, and `NAMEPLATE_OTHER_SCALE` times that again over anyone but the local player, `NAMEPLATE_GAP` studs from the snail's top as measured before it holds its weapon, relabelled on `Level`); the "+" bubbles over the free pods (clones of `INVITE_NAME` in the PlayerGui, so they can be pressed, adorned to each pod's `Snail` marker `INVITE_HEIGHT` studs up; one per pod past the members up to the party's or the custom lobby's places, hidden while the player can't invite or is in a match); `GetSnail` (`I.Lobby.GetStageSnail`), which ChatBubbles stands a member's chat bubbles over |
| `Settings.lua` | `Lobby_Settings` |

## API

### Client: `I.Lobby`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetTakeover(on: boolean)` | | Lets a moment take the whole screen (Progression's XP replay): every lobby gui but `TAKEOVER_GUIS` hides, with the stage's nameplates and "+" bubbles, until it's called with false |
| `GetStageSnail(player: Player)` | `Model?` | The snail the player stands as on this screen's stage (its `PrimaryPart` is the skin's RootPart), or nil when they stand on none |

## Network

### Server

**Receive: RemoteEvents**

- `Lobby_Rejoin @ (player: Player, accept: boolean)`: the answer to the offer. Rate limit 1 per second.

**Send: RemoteEvents**

- `Lobby_RejoinOffer @ (secondsLeft: number)`: when the player's saved match is still running

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Match.Rejoin` | `false`, or `{ PlaceId, AccessCode, Until }` from the match the player dropped out of; cleared on join |
| Profile | `Match.PlayAgain` | `false`, or `{ Kind, Mode, Difficulty, Until }` from a match's PLAY AGAIN; cleared when read |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `LOBBY_GUIS` | Lobby, MatchBoard, Party, Loadout, Currency, LevelPlate | The guis the client shows outside matches |
| `TAKEOVER_GUIS` | Currency, LevelPlate | The guis that stay while a takeover holds the screen (`SetTakeover`: the XP replay, and the diamonds it fills) |
| `FULL_SCREEN_WIDGETS` | Skins, Crates, Shop, FriendsMatch, CustomLobby, MatchSetup | The widgets that cover the whole screen: `LOBBY_GUIS` hide while one is open |
| `PANEL_WIDGETS` | EmoteShop: Loadout · LoadoutPicker, FreeCrateDialog, PartyInvite: Lobby, MatchBoard, Currency, LevelPlate | The widgets that stand in some lobby guis' place, by widget: those guis hide while one is open (the weapon picker's tall window takes the top row, FREE WEAPONS with the menu, and the board) |
| `STAGE_PREFAB`, `PODS_FOLDER`, `POD_PREFIX`, `CAMERA_MARKER`, `SNAIL_MARKER` | `"PREFAB \| Stage"`, `"Pods"`, `"Pod_"`, `"Camera"`, `"Snail"` | The stage's prefab in Lobby's assets, its pods (`Pod_1` the player's), and the markers the camera and each snail stand on |
| `STAGE_FOV` | `50` | The stage camera's field of view (the `FOV` buff's base) |
| `STAGE_SNAIL_SCALE` | `1.9` | How much bigger the stage's snails are than in a match (`Model:ScaleTo` on the built snail); each is lifted by what grew under its pivot, so its feet stay on its pod. 1.5 until 2026-11-24, bigger on the small pads (the owner: "the snails are a bit bigger, near each other") |
| `CUSTOM_PODS_PREFAB` | `"PREFAB \| CustomPods"` | The custom lobby's eight pods in Lobby's assets, stood in the stage on its pivot while the player is in a custom lobby |
| `STAGE_FIT_MARGIN`, `STAGE_CAMERA_EASE` | `0.82`, `0.08` | In a custom lobby the camera backs off (and rises with its look) just as far as every snail needs to fit this share of the screen; it eases there by the second's share of the way each 1/60 s |
| `STAGE_WEAPON` | `"Bazooka"` | What every snail on the stage holds (its Arsenal model, scaled with the snail) |
| `STAGE_WEAPON_LOOKS` | `Shiny`, `Golden` (`Lobby_WeaponLook`) | The stage weapon's look by the member's level reward, Combat's `VARIANT_LOOKS` held values: `Gild` and `GildCover` (Golden), `Sheen` (the ForceField copy's colour, still), `Outline` and `OutlineTransparency` |
| `STAGE_COVER_GROW`, `STAGE_SHEEN_GROW` | `1.015`, `1.04` | How much bigger the gold cover and the sheen copy are than their part |
| `STAGE_WEAPON_SCALE` | `0.72` | The stage weapon's size against its match model, as the studio's posed snail holds it (matches draw it bigger to read) |
| `STAGE_POSES` | `LobbyPose1` to `LobbyPose4` | The poses stage snails strike (Animations in `Assets/Snails/Animations`, the studio's bazooka poses; the owner, 2026-11-16: "make it feel organic and natural"). A pose with no `AnimationId` yet is skipped: until the owner uploads them, the snails idle |
| `NAMEPLATE_NAME`, `NAMEPLATE_SCALE`, `NAMEPLATE_GAP` | `"U_Nameplate"`, `2.3`, `-0.9` | The nameplate over each stage snail (the BillboardGui in Lobby's assets, `PREFAB \| Nameplate`): its size against its design size in studs, and its height in studs from the snail's top without its weapon (its point, the billboard's middle, 0.9 under the top) |
| `NAMEPLATE_OTHER_SCALE` | `0.75` | The party's other snails wear their nameplates this much smaller than the player's own (the owner, 2026-11-24) |
| `INVITE_NAME`, `INVITE_HEIGHT` | `"U_InviteBubble"`, `5` | The "+" bubble over each free pod (the BillboardGui in Lobby's assets, `PREFAB \| InviteBubble`), and how many studs over the pod's `Snail` marker it floats |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"TutorialMeadow"`, `"Tutorial"` | The tutorial match: Training Meadow, against the tutorial bot |
| `STUDIO_TUTORIAL_ATTRIBUTE` | `"StudioTutorial"` | The Workspace attribute that plays the tutorial in Studio (set it to true); without it Studio skips all of it and saves it as done in Studio's store, so a tester who already skipped it needs their `Tutorial` flags cleared to see it |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| Stage"]` | The stage: since 2026-11-15 the owner's `NewSpawn` (the studio's meadow, `Spawn_New`), moved so its meadow stands exactly where the 2026-11-12 stage's did (beyond the baseplate's +Z edge, the front snail at (0, 2.5, 1200.9), the camera at (0, 7, 1180)). **Since 2026-11-24 it is a calm background** (the owner: "the rest is just a background", so the snails carry the colour): its decorations, lanterns, fences, hedges, stone ring, path, waterfall and voxel clouds, the trees near the pods and the brick cliff walls are gone, and a `Backdrop` folder of stepped, Lego-like hills stands behind it instead (two near hills framing the sides, a tree on each, a rolling ridge with a dip in the middle, a hazier far line and a far ground slab); its colours are the original ones (muting the greens was tried that day and undone); the pods are rebuilt Fortnite-style, small pads, the player's front pad glowing cyan with a light and the free ones smaller, darker and faded; the camera marker is lower and flatter. The originals (the 2026-11-12 stage, the `NewSpawn` it was made from, and what the 2026-11-24 pass took out) are in `ServerStorage.!dump`. At runtime it's in `I.Dirs.Assets.Lobby`, and each client clones it into `Workspace.Ume.Lobby` as `Stage`: `Markers.Camera` (the camera's spot, looking along its front), and `Pods` › `Pod_1` to `Pod_4` (front, the one behind on the camera's left, the one behind on its right, then the back one, raised so its snail shows over the front snail's head: the owner, 2026-11-15), each with an invisible `Snail` marker over its top that the snail's pivot goes to, facing the camera, and that the "+" bubble floats over. Move the pods or the camera in Studio to change the layout; more pods stand more of a party (`MAX_PARTY` is 4) |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| Nameplate"]` | The nameplate's holder (2026-11-24): an invisible `RootPart` › `Attachment` › `U_Nameplate`, the BillboardGui exported from the gui folder's `Nameplate` gui. Clients clone only the BillboardGui, over each stage snail |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| InviteBubble"]` | The "+" bubble's holder (2026-11-24): `RootPart` › `Attachment` › `U_InviteBubble`, the BillboardGui exported from the gui folder's `InviteBubble` gui (its button `U_Invite`). Clients clone only the BillboardGui, over each free pod |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| CustomPods"]` | The custom lobby's pods (2026-11-16), authored 300 studs beside the stage: `Pods` › `Pod_1` to `Pod_8` (three in front, two raised behind them, three higher at the back, packed close), each with a `Snail` marker as the stage's pods have. Each client clones it as `CustomPods`, puts its pivot on the stage's and parents it to the stage in place of the stage's own `Pods` while the player is in a custom lobby |
| `Workspace.Ume.Lobby` | Made by the server at start; each client parents its stage's snails here, on its own screen only |
