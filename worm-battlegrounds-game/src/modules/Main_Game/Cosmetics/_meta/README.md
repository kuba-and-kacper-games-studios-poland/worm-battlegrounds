# Cosmetics

The snail's pieces and emotes. A snail wears four pieces, one per slot: a hat, a neck piece, a body and a shell
(since 2026-11-14; before, a whole skin). Pieces come in sets, each set one of the artist's skins cut apart (Wild West
was the Cowboy skin). Owned pieces and emotes are Inventory items; this module saves the outfit worn, gives every
player the starter pieces and emote, swaps the whole skins a player owned for their sets' pieces once, builds a snail in
any outfit for every screen, sells emotes for diamonds (coins until 2026-11-25) once the player's level is high enough, and plays emotes for
everyone. The client draws the `Skins` widget (the lobby's STYLE: a deck per slot, the snail in the middle, the open
slot's pieces; pressing an owned piece wears it), the `EmoteShop` widget (opened from the lobby `Loadout` panel's
EMOTES button; pressing an owned emote plays it), the emote wheel in `MatchHud`, and a played emote's icon in a thought cloud
over the player's snail (in a match and on the lobby's stage) and over their avatar in the lobby's party list.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Cosmetics` |
| Runs on | Server, Client, Global · both maps |
| Exposes | `I.Cosmetics` (server), `I.G_Cosmetics` (both) |
| Uses | `I.Inventory`, `I.G_Inventory`, `I.Currency`, `I.Progression`, `I.WidgetManager`, `I.Rarity`, `I.Interact`, `I.Console`, `I.SnailRig`, `I.Crates` (client: the Style screen's GET), `I.Match`, `I.Utils` (client: the wheel), `I.ChatBubbles`, `ContextActionService` |
| Saves | `Profile.Cosmetics`; publishes the `Outfit` Player attribute and the `Seen` Replicator value |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starter items, giving a set's pieces for an owned skin (once), equipping pieces, buying and playing emotes, the outfit a match uses |
| `Global.lua` | The set, piece and emote rows; outfits read from and written to text; building a snail in an outfit (`BuildSnail`) and framing a piece on it (`GetPieceShot`) |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Skins.lua` | The full-screen `Skins` widget (the lobby's STYLE): a deck per slot on the left (its owned count, the worn piece, its first three pieces on cards that fan out while it's open), the open slot's pieces on the right (no hat or neck piece first, then owned by rarity, then locked with where to get them; the tiles stay while the list does, so wearing a piece only changes their looks), and the picked piece in a detail bar with EQUIP, WORN or GET (opens the Skin crate). NEW tags on the lobby's STYLE button, the decks and the tiles show owned pieces the player hasn't seen; leaving a deck, or closing the screen, sees its pieces (`Cosmetics_See`) |
| `Scripts/Client/SkinsStage.lua` | The snail in the middle of the Style screen, with the player's name under it: a drag (mouse or finger) spins it all the way round, and the camera eases to the open or picked slot's view (`STAGE_FOCUS`): round to the shell, down onto the hat, in on the neck piece, back for the body. The camera moves only while it has somewhere to go, and only while the screen shows |
| `Scripts/Client/EmoteShop.lua` | The `EmoteShop` widget: a card per emote (`PREFAB \| EmoteCard`: its icon, name and rarity badge), cheapest first; one not owned wears the locked cover with its price in diamonds ("Free" for none) and the level it needs ("Any level" from level 1), and a press buys it; a press on an owned one closes the panel and plays it (the lobby's only place to pick an emote, since 2026-11-15) |
| `Scripts/Client/Emotes.lua` | The match's emote wheel (2026-11-17): a ring of slices, one per emote in a fixed order (by the level that unlocks it, then its price, as the emote shop), each its Inventory row's picture; one not owned yet greyed under a lock and its level (`WHEEL_LEVEL_TEXT`). Holding `WHEEL_KEY` (T, bound with ContextActionService at High while the HUD's emote button shows) or the pad's X (the Console module's `Emotes`, read with `I.Console.IsAction`) opens it round the middle of the screen, spinning in with `Emote_WheelOpen`; the mouse's direction from the middle, or the left stick's (`Move`), points at a slice, which lights in the player's match colour and grows with `Emote_WheelHover`, its name in the middle (and for one not owned what opens it); letting go plays it, and a press shorter than `WHEEL_TAP_SECONDS` plays the last emote again (`WHEEL_BUTTON_EMOTE` before any). The HUD's emote button (its picture `WHEEL_BUTTON_EMOTE`'s) opens the wheel to pick from with a click or a tap (on a pad, with the selection: `I.Console.Focus`, B closes it). It stays shut while the emote button is hidden or the player's snail is hit or thrown (`I.SnailRig.CanEmote`), and closes on a pick, a click or tap anywhere but a button, and when the button hides. Playing played emotes on every screen: the player's snail plays it (`I.SnailRig.Emote`: in a match, or on the lobby's stage), its icon pops up in a thought cloud over that snail's head (`I.ChatBubbles.ShowIcon`, in their chat stack: in a match, and on the lobby's stage), and in the lobby also in a speech bubble over the top right corner of their party card's avatar (`I.ChatBubbles.BuildIconBubble`, its tail pointing down at the picture), inside the avatar so the column's layout and scale carry it, `CARD_BUBBLE_SIZE` of the avatar tall; it turns the avatar's `ClipsDescendants` off |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `cosmetics` command, and the `Cosmetics_SetIds` dictionary |
| `Settings.lua` | `Cosmetics_Settings` |
| `Data/Sets/<SetId>.lua` | `Cosmetics_SetData`: `Name`, `LayoutOrder`, `Model` (the snail in `Assets.Skins` holding its pieces), `Skin` (the whole skin it was) |
| `Data/Pieces/<PieceId>.lua` | `Cosmetics_PieceData`: `Slot` (`Hat`, `Neck`, `Body`, `Shell`), `Set`. Its name, picture and rarity are its Inventory row's (`Data/Items/<Slot>/`) |
| `Data/Emotes/<EmoteId>.lua` | `Cosmetics_EmoteData`: `Level`, `Diamonds` (the price, an integer string: Wave 0, Thumbs up 50, Laugh 125, Dance 250, Flex 450, Taunt 700, Cry 950, Backflip 1200, Victory Trumpet 1500), `AnimationId`, `VoiceSound` |

## API

### Server: `I.Cosmetics`

| Function | Returns | What it does |
| --- | --- | --- |
| `Equip(player, slot: string, pieceId: string)` | `boolean` | Wears an owned piece in its slot, or takes the hat or neck piece off (`""`) |
| `See(player, slot: string)` | `boolean` | Marks every piece of a slot the player owns as seen (no longer NEW) |
| `BuyEmote(player, emoteId: string)` | `boolean` | Buys an emote with diamonds when the level is high enough |
| `PlayEmote(player, emoteId: string)` | `boolean` | Plays an owned emote for everyone, at most once every `EMOTE_COOLDOWN` seconds |
| `PlaySnailEmote(snailId: string, emoteId: string)` | `boolean` | Plays an emote on a match snail with no player behind it (a bot's, by its snail's id) for everyone, at most once every `EMOTE_COOLDOWN` seconds per snail: bots taunt with it |
| `GetOutfit(player)` | `Cosmetics_Outfit, boolean` | The worn outfit (a piece they no longer own falls back to `DEFAULT_OUTFIT`'s) and whether it's shiny (a piece with `SHINY_COPIES` copies) |

### Global: `I.G_Cosmetics`

| Function | Returns | What it does |
| --- | --- | --- |
| `BuildSnail(outfit: Cosmetics_Outfit)` | `Model?` | A clone of the body piece's snail from `Assets.Skins` with the outfit's shell, hat and neck piece moved onto it (In the place, below) |
| `GetSet(setId)` / `GetPiece(pieceId)` / `GetEmote(emoteId)` | row or nil | One row; warns when missing |
| `GetSets()` / `GetPieces()` / `GetEmotes()` | `{ [string]: row }` | Every row, by id |
| `GetSetPieces(setId: string)` | `{ [string]: string }` | A set's pieces by slot |
| `GetOutfit(text: string?)` | `Cosmetics_Outfit` | An outfit from the `Outfit` attribute's text; an empty or wrong slot takes `DEFAULT_OUTFIT`'s |
| `GetOutfitText(outfit: Cosmetics_Outfit)` | `string` | The attribute's text: the pieces in `SLOTS` order, comma-separated, `""` for none |
| `GetShowcase(pieceId: string)` | `Cosmetics_Outfit` | `DEFAULT_OUTFIT` wearing one piece: how a tile or a crate card shows it |
| `GetPieceShot(model: Model, pieceId: string)` | `CFrame` | Where a camera stands to show a piece on a posed snail (`PIECE_SHOTS`), then slid sideways and up or down (its angle and distance kept) until the posed snail's bones are in the middle of the view (2026-11-24) |

## Network

### Server

**Receive: RemoteEvents**

- `Cosmetics_Equip @ (player: Player, slot: string, pieceId: string)`. Rate limit 4 per second.
- `Cosmetics_See @ (player: Player, slot: string)`: the Style screen leaving a deck that had NEW pieces. Rate limit 4
  per second.
- `Cosmetics_PlayEmote @ (player: Player, emoteId: string)`. Rate limit 1 per second.

**Receive: RemoteFunctions**

- `Cosmetics_BuyEmote @ (player: Player, emoteId: string)`: returns whether it was bought. Rate limit 2 per second.

**Send: RemoteEvents**

- `Cosmetics_EmotePlayed @ (who: number | string, emoteId: string)`: to everyone, when an emote plays: a player's
  UserId, or a bot's snail's id (`PlaySnailEmote`)

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Cosmetics.Outfit` | The worn outfit: `{ Hat, Neck, Body, Shell }` piece ids, `""` for no hat or neck piece; `DEFAULT_OUTFIT` at first |
| Profile | `Cosmetics.PiecesGiven` | Whether the whole skins the player owned were swapped for pieces (once, on their first join since 2026-11-14): each set's pieces get the skin's copies, the worn skin becomes the worn outfit (a set with no body keeps the starter one), and `Cosmetics.EquippedSkin`, the old worn skin, is cleared. The skins stay in the inventory |
| Profile | `Cosmetics.SeenPieces` | `{ [pieceId]: true }`, the pieces the player has seen; the starter pieces are seen from the start |
| Replicator `Cosmetics` | `Seen` | The same, comma-separated, for the player's Style screen and lobby NEW tags |
| Player attribute | `Outfit` | The worn outfit as text (`GetOutfitText`), for the player's own Style screen and every client's lobby stage |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `STARTER_ITEMS` | `{ "Body_GardenPink", "Shell_GardenSwirl", "Emote_Wave" }` | Given on join when missing |
| `SLOTS` | `{ "Hat", "Neck", "Body", "Shell" }` | The slots, in the `Outfit` attribute's order |
| `DEFAULT_OUTFIT` | Garden Pink body, Garden Swirl shell, no hat or neck piece | Worn until the player picks otherwise, and in any slot they don't own |
| `SHINY_COPIES` | `10` | Copies of a piece that make it shiny |
| `EMOTE_COOLDOWN` | `5` | Seconds between two emotes |
| `EMOTE_SECONDS` | `3` | How long a played emote plays on the snail, and its bubble shows beside a name in the lobby |
| `EMOTE_BUY_INTERVAL` | `0.55` | The emote shop sends one buy at a time, at most one every this many seconds, so fast presses stay under `Cosmetics_BuyEmote`'s rate limit (2 a second) |
| `CARD_BUBBLE_ANCHOR`, `CARD_BUBBLE_SIZE` | `(0.84, 0.1)`, `0.62` | The lobby party card's emote bubble: where its tail's tip stands on the avatar (shares of it across and down, inside its top right corner), and its height as a share of the avatar's |
| `WHEEL_BUTTON_EMOTE` | `"Emote_Wave"` | The HUD emote button's picture, and what a quick tap plays before any other |
| `WHEEL_KEY`, `WHEEL_TAP_SECONDS` | `T`, `0.25` | The keyboard key held to open the wheel (the pad's is the Console module's `Emotes`, X); a press shorter than this plays the last emote again |
| `WHEEL_STICK_DEADZONE` | `0.5` | How far the left stick leans to point at a slice |
| `WHEEL_ICON_RADIUS`, `WHEEL_DEAD_RADIUS`, `WHEEL_SLICE_GAP` | `0.32`, `0.17`, `2` | The ring, in shares of the wheel's size: where the icons sit, the middle that points at nothing; the degrees between two slices |
| `WHEEL_HOVER_SCALE`, `WHEEL_HOVER_TWEENINFO` | `1.06`, 0.12 s quad out | The slice pointed at grows to this |
| `WHEEL_OPEN_SPIN`, `WHEEL_OPEN_SCALE`, `WHEEL_OPEN_TWEENINFO` | `-40`, `0.6`, 0.28 s back out | Opening, the wheel spins in from this many degrees and grows from this share of its size |
| `WHEEL_LEVEL_TEXT`, `WHEEL_LOCKED_TEXT`, `WHEEL_SHOP_TEXT` | `"Lv %d"`, `"Unlocks at level %d"`, `"Get it in the emote shop"` | Under a slice not owned yet (above level 1), and in the middle under its name: the level it unlocks at, or once reached, where to buy it |
| `PIECE_SHOTS` | by slot | How a tile, a deck card or a crate card frames a piece: the height looked at (above the posed piece, or the snail's middle for a body) and the distance, both in the whole snail's sizes so the camera stays outside it, and how far it turns (the shell from behind) |
| `PIECE_BONES` | head `Bone.003`, neck `Bone.002`, shell `Bone.013` | The bone each piece rides; a tile looks at the piece where the pose put it |
| `VIEWPORT_REDRAW_DELAY` | `0.45` | Seconds after a draw before the small viewports are drawn again (Roblox skips a viewport that changed while it moved, like the fanning deck cards) |
| `STAGE_FOCUS` | by slot | The Style screen's camera for each slot: `Yaw` (degrees round, 0 the front), `Pitch` (degrees above), `Zoom` (share of `STAGE_DISTANCE`) and `Height` (share of the snail up from its middle) |
| `STAGE_DISTANCE` | `0.8` | The whole snail's distance from the stage camera, in its sizes |
| `STAGE_EASE`, `STAGE_DRAG_SPEED` | `9`, `0.45` | How fast the camera eases to a new view (a drag turns it at once), and degrees of spin per pixel dragged |
| `STAGE_PITCH` | `-10` to `55` | How low and high a drag tilts the camera, in degrees |
| `SKINS_GUI_NAME`, `EMOTE_SHOP_GUI_NAME` | `"Skins"`, `"EmoteShop"` | The widgets |
| `LOBBY_GUI_NAME` | `"Lobby"` | The gui whose STYLE button (`S_Style` › `S_New`) shows NEW while a piece is unseen |
| `MATCH_HUD_GUI_NAME`, `PARTY_GUI_NAME` | | The guis that hold the emote wheel (and its button) and the party list |

## In the place

- Creates `Workspace.Ume.Cosmetics`; clients put the emote labels (BillboardGuis on the snail's `Root`) there.
- Binds the CAS action `Cosmetics_EmoteWheel` (`WHEEL_KEY`, at High) while the match HUD's emote button shows, and
  clones `MatchHud`'s `PREFAB | WheelSlice` into its wheel's `S_Slices`, one per emote.
- Each set's pieces sit on one snail in `Assets.Skins` (in the place, `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins`),
  named by its row's `Model`: `Classic` (Garden), and the artist's `Clown`, `Cowboy`, `Devil`, `Knight`, `Ninja`,
  `Pirate`, `Robot`, `Skeleton` and `Soldier`, all on Classic's skeleton (`art/skins`). Its `Body` is the set's body
  piece (with the hands), its `Shell` the shell, and its `Hat` and `Neck` parts the hat and neck piece, each a skinned
  MeshPart on a Motor6D from the RootPart. `BuildSnail` clones the body piece's snail, takes off the hat and neck
  parts it doesn't wear, and clones the outfit's shell, hat and neck parts onto it with copies of their Motor6Ds:
  every snail shares one skeleton, so a part from one follows another's bones.
- Since 2026-11-14 every set snail holds its cut pieces (`art/skins` → Pieces; the whole skins are kept in
  `ServerStorage.!dump.Skins_Whole_2026-11-14`). A snail without a `Hat` or `Neck` part would still work: `BuildSnail`
  then wears that set's whole `Body` for its hat or neck piece (the hat's set first).
- A snail at rest has its shell floating above its back and its hands held out (Classic's rig): its animations put
  them in place, so previews hold each clone in its idle pose (`I.SnailRig.Pose`).
- Emote animations and voice lines aren't made yet: each emote plays a stand-in motion made in code
  (`I.SnailRig.Emote`, the SnailRig README → Emotes), replaced by its animation once one is published under its name.

## Commands

`cosmetics` (server, level 255):

| Subcommand | Arguments | What |
| --- | --- | --- |
| `give_skin` | `player`, `setId` (autocompleted from `Cosmetics_SetIds`) | Gives one more copy of each piece of a set, a whole skin |
| `unlock_skins` | `player` | Gives one copy of every piece the player doesn't own yet |
| `unlock_emotes` | `player` | Gives one copy of every emote the player doesn't own yet |

Giving one piece or emote, or more copies of it, is the Inventory's `inventory add_standard player itemId quantity?`.
