# Favorite

The "add to favorites" prompt, from either side. The client shows Roblox's favorite prompt for an item or for this game, and skips it when the player already favorited that item; the server asks a player's client to show it, and can wait for the client's answer. Only one prompt is open at a time.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Favorite` |
| Runs on | Server, Client |
| Exposes | `I.Favorite` (server, client) |
| Uses | `AvatarEditorService`, `I.Network`, `I.Config.PlaceLoader` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Asks a client to prompt, by event or by invoke |
| `Client.lua` | Shows the prompt, one at a time |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `favorite` command |

## API

### Server: `I.Favorite`

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptSetFavorite(player, assetId: number, itemType: Enum.AvatarItemType?, invoke: boolean?)` | `boolean \| string` | Asks the player's client to prompt for the item and returns `true`. With `invoke`, waits for the client's answer (at most Network's `INVOKE_CLIENT_TIMEOUT`): `true` when the prompt opened, `"AlreadyFavorited"` when it was skipped, `false` when it failed, timed out or the client sent anything else. |
| `PromptGameSetFavorite(player, invoke: boolean?)` | `boolean \| string` | The same for this game's place |

The invoke answer comes from the client, so an exploiter can send any of the three values: don't gate rewards on it.

### Client: `I.Favorite`

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptSetFavorite(itemId: number, itemType: Enum.AvatarItemType?)` | `boolean \| string` | Opens the prompt (an `Asset` by default) and returns `true`; `"AlreadyFavorited"` without prompting when `AvatarEditorService:GetFavoriteAsync` says the player already favorited it; `false` when another prompt is open or it failed |
| `PromptGameSetFavorite()` | `boolean \| string` | The same for this game's place |

## Usage

```lua
-- Server, after a first win
I.Favorite.PromptGameSetFavorite(player)
```

## Network

### Server

**Send: RemoteEvents**

- `Favorite_PromptSetFavorite @ (player: Player, assetId: number, itemType: EnumItem?)`, `Favorite_PromptGameSetFavorite @ (player: Player)`

**Send: RemoteFunctions**

- `Favorite_PromptSetFavorite-Return @ (player: Player, assetId: number, itemType: EnumItem?)`, `Favorite_PromptGameSetFavorite-Return @ (player: Player)`: the `invoke` forms.

### Client

**Receive: RemoteEvents**

- `Favorite_PromptSetFavorite @ (assetId: number, itemType: EnumItem?)`, `Favorite_PromptGameSetFavorite @ ()`

**Receive: RemoteFunctions**

- `Favorite_PromptSetFavorite-Return @ (assetId: number, itemType: EnumItem?)`, `Favorite_PromptGameSetFavorite-Return @ ()`: return `true`, `false` or `"AlreadyFavorited"`.

## Commands

`favorite` (server):

| Subcommand | Arguments |
| --- | --- |
| `prompt_id` | `player assetId` |
| `prompt_game` | `player` |
