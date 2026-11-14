# Cosmetics

Skins and emotes. Owned skins and emotes are Inventory items; this module saves which skin is worn, gives every player
the starter skin and emote, sells emotes for coins once the player's level is high enough, and plays emotes for
everyone. The client draws the `Skins` widget (every skin with a 3D preview; pressing an owned one equips it), the `EmoteShop` widget, the
emote row in the lobby's `Loadout` panel, the emote wheel in `MatchHud`, and a played emote's icon in a thought cloud
over the player's snail (in a match and on the lobby's stage) and beside their name in the lobby's party list.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Cosmetics` |
| Runs on | Server, Client, Global · both maps |
| Exposes | `I.Cosmetics` (server), `I.G_Cosmetics` (both) |
| Uses | `I.Inventory`, `I.G_Inventory`, `I.Currency`, `I.Progression`, `I.Replicator`, `I.WidgetManager`, `I.Rarity`, `I.Interact`, `I.Console`, `I.SnailRig` |
| Saves | `Profile.Cosmetics` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starter items, equipping, buying and playing emotes, the skin a match uses |
| `Global.lua` | The skin and emote rows |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Skins.lua` | The full-screen `Skins` widget (the lobby's STYLE): every skin as a tile with a 3D preview (its snail in its idle pose), the worn one first in the selected look, owned ones by rarity, unowned ones locked; pressing an owned skin equips it, and the SKINS category shows the worn skin's name |
| `Scripts/Client/EmoteShop.lua` | The `EmoteShop` widget: a card per emote (`PREFAB \| EmoteCard`: its icon, name and rarity badge), cheapest first; one not owned wears the locked cover with its price in coins and the level it needs ("Any level" from level 1), and a press buys it |
| `Scripts/Client/Emotes.lua` | The emote row, the emote wheel (it closes on a pick, a click or tap anywhere but a button, and when the hud hides the emote button; on a pad it holds the selection while open, `I.Console.Focus`, and B closes it), and playing played emotes on every screen: the player's snail plays it (`I.SnailRig.Emote`: in a match, or on the lobby's stage), its icon pops up in a thought cloud over that snail's head (`I.ChatBubbles.ShowIcon`, in their chat stack: in a match, and on the lobby's stage), and in the lobby also in a speech bubble beside their name on their party card (`I.ChatBubbles.BuildIconBubble`, its tail pointing at the name) |
| `Settings.lua` | `Cosmetics_Settings` |
| `Data/Skins/<SkinId>.lua` | `Cosmetics_SkinData`: `Model` (in `Assets.Skins`), `Source`, `Animations`, `VoiceSet` |
| `Data/Emotes/<EmoteId>.lua` | `Cosmetics_EmoteData`: `Level`, `Coins`, `AnimationId`, `VoiceSound` |

## API

### Server: `I.Cosmetics`

| Function | Returns | What it does |
| --- | --- | --- |
| `Equip(player, skinId: string)` | `boolean` | Wears an owned skin in the next match |
| `BuyEmote(player, emoteId: string)` | `boolean` | Buys an emote with coins when the level is high enough |
| `PlayEmote(player, emoteId: string)` | `boolean` | Plays an owned emote for everyone, at most once every `EMOTE_COOLDOWN` seconds |
| `PlaySnailEmote(snailId: string, emoteId: string)` | `boolean` | Plays an emote on a match snail with no player behind it (a bot's, by its snail's id) for everyone, at most once every `EMOTE_COOLDOWN` seconds per snail: bots taunt with it |
| `GetSkin(player)` | `string, boolean` | The worn skin's model name and whether it's shiny (falls back to `DEFAULT_SKIN`) |

### Global: `I.G_Cosmetics`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetSkin(skinId: string)` / `GetEmote(emoteId: string)` | row or nil | One row; warns when missing |
| `GetSkins()` / `GetEmotes()` | `{ [string]: row }` | Every row, by item id |

## Network

### Server

**Receive: RemoteEvents**

- `Cosmetics_Equip @ (player: Player, skinId: string)`. Rate limit 2 per second.
- `Cosmetics_PlayEmote @ (player: Player, emoteId: string)`. Rate limit 1 per second.

**Receive: RemoteFunctions**

- `Cosmetics_BuyEmote @ (player: Player, emoteId: string)`: returns whether it was bought. Rate limit 2 per second.

**Send: RemoteEvents**

- `Cosmetics_EmotePlayed @ (who: number | string, emoteId: string)`: to everyone, when an emote plays: a player's
  UserId, or a bot's snail's id (`PlaySnailEmote`)

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Cosmetics.EquippedSkin` | The worn skin's item id, `"Skin_Classic"` at first |
| Replicator `Cosmetics` | `EquippedSkin` | The same, for the client |
| Player attribute | `EquippedSkin` | The same, for every client (the lobby's party stage) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `STARTER_ITEMS` | `{ "Skin_Classic", "Emote_Wave" }` | Given on join when missing |
| `DEFAULT_SKIN` | `"Skin_Classic"` | Worn until another is equipped |
| `SHINY_COPIES` | `10` | Copies of a skin that make it shiny |
| `EMOTE_COOLDOWN` | `5` | Seconds between two emotes |
| `EMOTE_SECONDS` | `3` | How long a played emote plays on the snail, and its bubble shows beside a name in the lobby |
| `CARD_BUBBLE_GAP` | `8` | Design px between a name on a lobby party card and the emote bubble beside it |
| `WHEEL_RADIUS` | `0.38` | How far the wheel's emotes sit from its centre, as a share of its size |
| `PREVIEW_DISTANCE` | `0.6` | The skin preview camera's distance from the snail's middle, in the model's sizes (0.6 fills a tile's preview) |
| `SKINS_GUI_NAME`, `EMOTE_SHOP_GUI_NAME` | `"Skins"`, `"EmoteShop"` | The widgets |
| `LOADOUT_GUI_NAME`, `MATCH_HUD_GUI_NAME`, `PARTY_GUI_NAME` | | The guis that hold the emote row, the emote wheel and the party list |

## In the place

- Creates `Workspace.Ume.Cosmetics`; clients put the emote labels (BillboardGuis on the snail's `Root`) there.
- A skin's model is `Assets.Skins.<Model>` (in the place, `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins`):
  `Classic` and, since 2026-11-11, the artist's `Clown`, `Skeleton`, `Devil`, `Robot`, `Knight`, `Cowboy`, `Ninja`,
  `Pirate` and `Soldier`, each rigged onto Classic's skeleton so Classic's animations play on it (`art/skins`). Skin
  previews, the lobby's stage and matches clone it, falling back to the default skin's model for a skin with no model
  of its own (FBI Agent, Prisoner, VIP, Wizard): the previews and the stage through this module's `DEFAULT_SKIN` row,
  since the lobby runs without the match-only Snails module; matches through Snails' `DEFAULT_SKIN`.
- A skin model at rest has its shell floating above its back and its hands held out (Classic's rig): its animations
  put them in place, so the Skins widget's previews hold each clone in its idle pose (`I.SnailRig.Pose`).
- Emote animations and voice lines aren't made yet: each emote plays a stand-in motion made in code
  (`I.SnailRig.Emote`, the SnailRig README → Emotes), replaced by its animation once one is published under its name.
