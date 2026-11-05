# Cosmetics

Skins and emotes. Owned skins and emotes are Inventory items; this module saves which skin is worn, gives every player
the starter skin and emote, sells emotes for coins once the player's level is high enough, and plays emotes for
everyone. The client draws the `Skins` widget (a 3D preview per owned skin, **Equip**), the `EmoteShop` widget, the
emote row in the lobby's `Loadout` panel, the emote wheel in `MatchHud`, and a played emote's name over the player's
worm in a match or beside their name in the lobby's party list.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Cosmetics` |
| Runs on | Server, Client, Global · both maps |
| Exposes | `I.Cosmetics` (server), `I.G_Cosmetics` (both) |
| Uses | `I.Inventory`, `I.G_Inventory`, `I.Currency`, `I.Progression`, `I.Replicator`, `I.WidgetManager`, `I.Rarity`, `I.Interact` |
| Saves | `Profile.Cosmetics` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starter items, equipping, buying and playing emotes, the skin a match uses |
| `Global.lua` | The skin and emote rows |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Skins.lua` | The `Skins` widget and the lobby's skin button (`Lobby` › `U_Skins`) |
| `Scripts/Client/EmoteShop.lua` | The `EmoteShop` widget |
| `Scripts/Client/Emotes.lua` | The emote row, the emote wheel, and showing played emotes |
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

- `Cosmetics_EmotePlayed @ (userId: number, emoteId: string)`: to everyone, when an emote plays

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Cosmetics.EquippedSkin` | The worn skin's item id, `"Skin_Classic"` at first |
| Replicator `Cosmetics` | `EquippedSkin` | The same, for the client |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `STARTER_ITEMS` | `{ "Skin_Classic", "Emote_Wave" }` | Given on join when missing |
| `DEFAULT_SKIN` | `"Skin_Classic"` | Worn until another is equipped |
| `SHINY_COPIES` | `10` | Copies of a skin that make it shiny |
| `EMOTE_COOLDOWN` | `5` | Seconds between two emotes |
| `EMOTE_SECONDS` | `2.5` | How long a played emote's label shows |
| `WHEEL_RADIUS` | `0.38` | How far the wheel's emotes sit from its centre, as a share of its size |
| `PREVIEW_DISTANCE` | `1.6` | The skin preview camera's distance, in the model's sizes |
| `SKINS_GUI_NAME`, `EMOTE_SHOP_GUI_NAME` | `"Skins"`, `"EmoteShop"` | The widgets |
| `LOADOUT_GUI_NAME`, `LOBBY_GUI_NAME`, `MATCH_HUD_GUI_NAME`, `PARTY_GUI_NAME` | | The guis that hold the emote row, the skin button, the emote wheel and the party list |

## In the place

- Creates `Workspace.Ume.Cosmetics`; clients put the emote labels (BillboardGuis on the worm's `Root`) there.
- Skin previews clone `Assets.Skins.<Model>`, falling back to the Worms module's `DEFAULT_SKIN` model while a skin
  has no model of its own.
- Emote animations and voice lines aren't played yet: a label shows the emote's name instead.
