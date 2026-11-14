# ChatBubbles

Chat bubbles over snails (the owner's pick, 2026-11-10: "Bubble Style B"). When a player's chat message reaches this
client (TextChatService's `MessageReceived`: player messages only, never the system's, with the text as filtered
for this player), the client shows it in a bubble over that player's snail: while the local player is in a match
(the `InMatch` Player attribute) over their snail there (`I.Snails.Get`), standing over its SnailTag's name and
health bar (the tag's `S_Stack`, followed as the turn marker and level come and go, and kept while the tag
hides as its snail moves or aims) and never on it; in the lobby
over their snail on this screen's party stage (`I.Lobby.GetStageSnail`), over the top of its model. A player with no
snail on this screen (or a knocked-out one) gets no bubble. Each speaker has one billboard, the `ChatBubble` gui,
holding up to `MAX_BUBBLES` bubbles, the newest at the bottom with the tail and older ones above it; a fourth
message pushes the oldest out. A bubble pops in, stays `BUBBLE_SECONDS` plus `BUBBLE_SECONDS_PER_LETTER` a letter
(`BUBBLE_MAX_SECONDS` at most), then fades out, and the billboard goes with its last bubble. Billboards are on top of
everything (`AlwaysOnTop`) and sized with the screen by `I.ScreenScale.AddBillboard`. The client turns Roblox's own
bubble chat off (`TextChatService.BubbleChatConfiguration.Enabled`), which would float over the avatars parked out of
sight. The server only makes the module's world folder. Other modules post a picture in the same stack with
`I.ChatBubbles.ShowIcon`: an emote's icon (Cosmetics), in a thought cloud (the owner's pick, 2026-11-11, from Worms'
thought bubble) with a trail of two small puffs down to the snail's head on the newest; or build a speech bubble
holding a picture to place themselves (a lobby party card) with `I.ChatBubbles.BuildIconBubble`.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/ChatBubbles` |
| Runs on | Server, Client |
| Exposes | `I.ChatBubbles` (client) |
| Uses | `TextChatService`, `TextService`, `I.Snails` (match), `I.Lobby` (lobby, client), `I.ScreenScale`, `I.Settings["Snails"]` (`TAG_OFFSET`), `I.Dirs.Assets` |

## API

### Client: `I.ChatBubbles`

| Function | Returns | What it does |
| --- | --- | --- |
| `ShowIcon(who: number \| string, image: string)` | | Shows a picture in a thought cloud (`PREFAB \| Thought`) over a player's snail (by UserId) or a bot's (by its snail's id), in their chat stack (the newest, with its trail of puffs), for `ICON_SECONDS`, when this screen shows their snail: in a match, or on the lobby's stage |
| `BuildIconBubble(image: string, tailLeft: boolean?)` | `Frame` | A bubble holding a picture (`S_Icon`, the text hidden), `ICON_SIZE` big, its tail under it or on its left (to point at a name beside it); the caller parents it, pops it (`S_Pop`) and removes it |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Makes `Workspace.Ume.ChatBubbles` |
| `Client.lua` | Turns Roblox's bubble chat off, listens for messages, finds where the speaker's snail stands on this screen, builds and stacks the bubbles (each body sized to its text with `TextService:GetTextBoundsAsync` at its design size, wrapped at `TEXT_MAX_WIDTH`) and the pictures' thought clouds, lifts them over the snail's tag, pops them in and fades every drawn part of them out |
| `Settings.lua` | `ChatBubbles_Settings` |
| `_meta/_types.lua` | `ChatBubbles_Speaker` (a speaker's billboard, bubbles and tag watch), `ChatBubbles_Anchor` (where their bubbles stand) |

## Network

No remotes: the messages come through TextChatService, which filters them for each player.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TEMPLATE` | `"U_ChatBubble"` | The bubbles' billboard in `Assets.ChatBubbles` |
| `TEXT_MAX_WIDTH` | `170` | A bubble's text wraps past this width (design px), measured at its `TextSize` (17) |
| `TEXT_ROOM` | `1.06` | Scaled text draws about 5% bigger than TextService measures it: the text box gets this much more room |
| `MAX_BUBBLES` | `3` | The most bubbles over one snail; a newer message takes the oldest one's place |
| `BUBBLE_SECONDS`, `BUBBLE_SECONDS_PER_LETTER`, `BUBBLE_MAX_SECONDS` | `4`, `0.06`, `10` | How long a bubble stays: 4 s plus 0.06 s a letter, 10 s at most |
| `ICON_SIZE`, `ICON_SECONDS` | 64 × 58, `3.5` | A speech bubble holding a picture (`BuildIconBubble`): its body in design px; and how long a picture's thought cloud stays (`ShowIcon`) |
| `POP_FROM`, `POP_TWEENINFO` | `0.6`, 0.2 s back out | A new bubble pops in from 0.6 times its size, from its tail |
| `FADE_TWEENINFO` | 0.35 s quad in | How a bubble whose time is up fades out |
| `TAG_GAP` | `6` | In a match, design px between the snail's tag and the lowest bubble |
| `STAGE_GAP` | `0.6` | On the lobby's stage, studs between the top of the snail's `Body` (its eyestalks) and the lowest bubble |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.ChatBubbles` | Made by the server at start; each client parents its speakers' billboards here (`ChatBubble_<UserId>`), on its own screen only |
| `Workspace.Ume.ReplicatedStorage_Assets/ChatBubbles/PREFAB \| ChatBubble` | The billboard's holder (`Assets.ChatBubbles` at runtime): a Model with an invisible 1 × 1 × 1 `RootPart`, its `Attachment`, and the exported `ChatBubble` gui under it as the BillboardGui `U_ChatBubble` (260 × 600, `LightInfluence` 0), with its two prefabs, `PREFAB \| Bubble` and `PREFAB \| Thought`. Clients clone only the billboard |
| SnailTag › `S_Stack` | The tag's stack (name, health bar, level, turn marker): the bubbles stand its height and `TAG_GAP` over the tag's bottom edge, which they share (`TAG_OFFSET`, `SizeOffset` (0, 0.5)) |
| `TextChatService.BubbleChatConfiguration` | `Enabled` set false on each client |
