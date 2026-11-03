# CharacterAnimation

Animations on the local character, by asset id. The client loads each animation onto the character's `Animator` once, keeps the track under its id, and plays or stops it with the given settings; the server asks a player's client to do the same, so the animation replicates from the owner as Roblox expects.

| | |
| --- | --- |
| Folder | `src/modules/Main/CharacterAnimation` |
| Runs on | Client, Server |
| Exposes | `I.CharacterAnimation` (client, server) |
| Uses | `ContentProvider`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Preloading, loading tracks on the character, playing and stopping them (one or all) |
| `Server.lua` | Asks a player's client to play or stop an animation, or stop them all |
| `_meta/_types.lua` | `CharacterAnimation_AnimationSettings` |

## API

### Client: `I.CharacterAnimation`

| Function | Returns | What it does |
| --- | --- | --- |
| `PreloadAnimation(animationIds: { string })` | | Preloads the animation assets in the background |
| `PlayAnimation(animationId: string, animationSettings: CharacterAnimation_AnimationSettings?, autoPlay: boolean?)` | `AnimationTrack` | Loads (once) and plays the animation with `Looped`, `Speed`, `Priority`, `TimePosition`; it fades in over `FadeInTime` (0.1 s by default), and when the animation is still playing (or fading out) a fresh track starts while the old one freezes and fades out over the same time, so the pose blends; with `FadeOutAt` (seconds into the animation) it freezes there and fades out over `FadeOutTime` (0.1 s by default) into the animations under it, unless it was played again or stopped first; `autoPlay = false` returns the track without playing |
| `StopAnimation(animationId: string, fadeTime: number?)` | | Stops it |
| `StopAllAnimations(fadeTime: number?)` | | Stops every loaded track that is playing |

### Server: `I.CharacterAnimation`

| Function | Returns | What it does |
| --- | --- | --- |
| `PlayAnimation(player, animationId, animationSettings?)` | | Asks the player's client to play it |
| `StopAnimation(player, animationId, fadeTime?)` | | Asks it to stop |
| `StopAllAnimations(player, fadeTime?)` | | Asks it to stop every playing animation |

## Usage

```lua
I.CharacterAnimation.PlayAnimation(player, "rbxassetid://123", { Looped = true, Speed = 1, Priority = Enum.AnimationPriority.Action, TimePosition = 0 })
```

## Network

### Server

**Send: RemoteEvents**

- `CharacterAnimation_PlayAnimation @ (player: Player, animationId: string, animationSettings: table?)`
- `CharacterAnimation_StopAnimation @ (player: Player, animationId: string, fadeTime: number?)`
- `CharacterAnimation_StopAllAnimations @ (player: Player, fadeTime: number?)`

### Client

**Receive: RemoteEvents**

- `CharacterAnimation_PlayAnimation @ (animationId: string, animationSettings: table?)`
- `CharacterAnimation_StopAnimation @ (animationId: string, fadeTime: number?)`
- `CharacterAnimation_StopAllAnimations @ (fadeTime: number?)`
