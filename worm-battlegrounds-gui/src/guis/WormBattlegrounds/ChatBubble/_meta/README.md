# ChatBubble

The chat bubbles over a snail whose player chats: in a match over their snail, in the lobby over their snail on the
party stage. Each message is a bubble; the newest sits at the bottom with the tail, older ones above it, three at most.

**Look.** The owner's pick, 2026-11-10 ("Bubble Style B"): a white rounded bubble (corner 14 px) with a 3 px ink
outline (`rgb(25, 25, 42)`, the badge icons' outline), its text in Londrina Solid Black, 17 px, in the same ink, 7 px
from the top and bottom and 12 px from the sides, at most 170 px wide before it wraps. The newest bubble has a small
tail centred under it: a 10 px white square on its corner with the same outline, half hidden behind the body, and a
white `S_Joint` over the body's outline where they meet, so the outline runs on down the tail. `Primitive` nodes
only, like the studio's world labels (SnailTag, DamagePop); 260 × 600 at design scale, scaled with the screen like
the hud.

An emote's icon comes in a **thought cloud** instead (the owner's pick, 2026-11-11, from Worms' thought bubble): four
round white puffs in a cloud, 96 × 72, outlined in the same ink by the same puffs 3 px bigger behind them (so the
outline runs only round the cloud's edge), the icon 44 px in the middle, and under the newest a trail of two small
outlined puffs (14 and 8 px) down toward the snail's head.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/ChatBubble"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` (unused: `Primitive` nodes only) |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `ChatBubble` (a template), moved into its `PREFAB \| ChatBubble` holder as `U_ChatBubble` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Bubbles` | Frame | 260 × 600, the billboard's design size; a bottom-aligned UIListLayout stacks the bubbles. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Bubbles` › `S_Clearance` | UIPadding | `PaddingBottom`: the snail's tag height and a gap, so the bubbles stand over its name and health bar (0 on the lobby's stage) |
| `PREFAB \| Bubble` | Frame (in `U_Bubbles`) | One message. Sized to its body plus its outline, and the tail's room on the newest; `LayoutOrder` is its message's count, so the newest is lowest |
| `PREFAB \| Bubble` › `S_Pop` | UIScale | Pops the bubble in from its tail (its root's anchor, bottom centre) |
| `PREFAB \| Bubble` › `S_Body` | Frame (UICorner, UIStroke) | Sized to the text measured at its `TextSize` and 170 px wide at most; its bottom 12 px over the bubble's (the tail's room), 3 px without the tail |
| `S_Body` › `S_Text` | TextLabel (UIPadding, UITextSizeConstraint 100) | The message |
| `S_Body` › `S_Icon` | ImageLabel, hidden | A picture in place of the text (an emote's icon beside a lobby party card's name): `I.ChatBubbles.BuildIconBubble` hides `S_Text` and shows it |
| `PREFAB \| Bubble` › `S_Tail`, `S_Joint` | Frames | Shown on the newest bubble only |
| `PREFAB \| Thought` | Frame (in `U_Bubbles`) | An emote's icon in a thought cloud, 96 × 104 with its trail, 96 × 72 without; `LayoutOrder` as a bubble's |
| `PREFAB \| Thought` › `S_Pop` | UIScale | Pops the cloud in from its trail (its root's anchor, bottom centre) |
| `PREFAB \| Thought` › `S_Icon` | ImageLabel | The emote's icon, set by `I.ChatBubbles.ShowIcon` |
| `PREFAB \| Thought` › `S_Trail` | Frame | The two small puffs under the cloud; shown on the newest only |

## Driven by

The game's `ChatBubbles` module clones it over a snail when its player chats or plays an emote (`I.ChatBubbles.ShowIcon`, from Cosmetics).

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `ChatBubble` in StarterGui), then move it into its holder in place
of the old one (or move the export's children into the holder's BillboardGui and set its `Size` to 260 × 600):
`Workspace.Ume.ReplicatedStorage_Assets/ChatBubbles/PREFAB | ChatBubble` › `RootPart` › `Attachment`, renamed
`U_ChatBubble`, with `LightInfluence` 0 (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it over
parts; the clone's `Adornee`, `StudsOffset`, `AlwaysOnTop` and `SizeOffset` (0, 0.5: the stack's bottom edge on the
point) are set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's
scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never
under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui
tool previews it at 260 × 600 (`Preview`), with one to three sample messages (`Preview.lua`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| A new message | `S_Pop` | `Scale` from ChatBubbles' `POP_FROM` to 1 (`POP_TWEENINFO`) |
| Older messages | `S_Tail`, `S_Joint`; a cloud's `S_Trail` | Hidden; the bubble loses the tail's room, the cloud its trail's |
| Its time is up | Every drawn part of the bubble or cloud: filled frames, `UIStroke`s, `S_Text`, `S_Icon` | Fade to 1 (`FADE_TWEENINFO`), then the bubble goes, and the billboard with its last bubble |
