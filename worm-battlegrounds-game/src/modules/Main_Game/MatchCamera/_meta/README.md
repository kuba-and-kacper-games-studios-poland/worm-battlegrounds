# MatchCamera

The side-on match camera. Once a map is loaded it is a scriptable camera looking along −Z from `DISTANCE` studs away
with a narrow `FOV`, so the arena reads as flat. It follows a flying shot (parts with the `Projectile` attribute)
while the player's `CameraFollowsShot` setting is on, staying on the same shot while it flies (never hopping between
a cluster bomb's bomblets), else the active snail (its `Active` attribute), else between turns the snail it followed
last, else the local player's snail, else the arena's middle, and stays inside the arena's bounds, except that the view may
rise `CEILING_EXTRA` studs above their top, so a snail high up sits mid-screen, and has no ceiling at all while it
follows a shot in flight. A flying shot is led
`LEAD_SECONDS` along its smoothed velocity (`LEAD_SMOOTH`), at most `LEAD_MAX` studs, so where it lands comes into
view sooner. After a blast it
followed a shot into (Combat's `Combat_Explosion`, while `CameraFollowsShot` is on) it stays on the blast until the
next turn starts (Match's `Match_TurnStarted`), and for at least `BLAST_HOLD` seconds, or `BIG_BLAST_HOLD` for a
blast of `BIG_BLAST_RADIUS` or more, so it moves once, to the next snail; a shot flying meanwhile takes it. Guns and
swings (Combat's `Combat_Tracer`) are too fast to follow, so the camera glides to the middle of where their bullets
landed and holds there the same way; a followed shot that ends with no blast on this screen (it sank, or this screen's
copy landed before the server's blast) holds where it ended. While it holds, a snail moving faster than `CHASE_SPEED`
(a blow sent it flying, or it fell) is followed until it slows, and the hold lasts `CHASE_HOLD` after. Moving on to a
new snail, or to where bullets landed, it glides at `TRAVEL_SPEED` (for at most `TRAVEL_MAX` seconds, or until it's
within `TRAVEL_DONE` studs) instead of snapping at `FOLLOW_SPEED`. Players pan
by dragging with the right mouse button, holding the mouse at the screen's left or right edge, two fingers on touch,
or the right stick while LT is held (the Console module's `Aim` and `CameraPan`); the pan is kept as the offset the player moved the view from where it sits
on its own (the bounds' own push near an edge never builds up in it), and resets when the camera follows another
snail. On the player's own turn
(`I.Match.IsMyTurn`) the pan is leashed: their snail stays within `LEASH` of the view's half size from its middle, and
while the snail moves faster than `RECENTER_MOVE_SPEED` the pan eases back to it at `RECENTER_SPEED`. They zoom with the mouse wheel (not over a gui that scrolls), a pinch, or the D-pad held up or down (`ZoomIn`, `ZoomOut`, bound through `I.Console`; left to a gui selection while there is one), between `ZOOM_MIN` and
`ZOOM_MAX` studs from the plane; the zoom stays for the match. When it takes the camera it sets the `FOV` buff's base (`Standard`) to `FOV`, so the FOV_Controller still adds an open widget's FOV change, and it updates at the `Camera` render priority, one step before ume's CameraShake, so Combat's blast shakes land on top of it. While the player isn't in the match (the `InMatch` Player
attribute, on the Studio map's lobby) it gives Roblox's camera back. Combat's hit stop holds the view still (`Freeze`), and a knockout blow
punches it in on the snail (`PunchIn`). It creates no remotes, Topics or saved data; it listens to Combat's `Combat_Explosion` and `Combat_Tracer`, and
Match's `Match_TurnStarted`.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchCamera` |
| Runs on | Client |
| Exposes | `I.MatchCamera` (client) |
| Uses | `I.Snails` (client), `I.Match` (client: `IsMyTurn`), `I.Buff` (the `FOV` buff), `I.PlayerSettings`, `I.Console` (client: the pad's buttons), `UserInputService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Following, leading shots, panning, zooming, clamping to the bounds, the hit stop and the punch-in; `I.MatchCamera` |
| `Settings.lua` | `MatchCamera_Settings`: the view, the blast hold, the lead and punch-in, and panning |

## API

### Client: `I.MatchCamera`

| Function | Returns | What it does |
| --- | --- | --- |
| `Freeze(seconds)` | | Holds the view where it is for that many seconds (a later end wins over an earlier one); nothing while the camera hasn't taken the view yet. Combat's hit stop uses it |
| `PunchIn(point)` | | Moves the view to `point` (plus the player's pan) and zooms to `PUNCH_ZOOM` of the player's zoom for `PUNCH_SECONDS`, then goes back to what it followed. Combat uses it on a knockout blow |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `FOV` | `30` | Field of view, before an open widget's FOV change |
| `DISTANCE` | `110` | How far in front of the plane the camera sits at start |
| `ZOOM_MIN`, `ZOOM_MAX` | `45`, `200` | The nearest and farthest the zoom goes, in studs from the plane |
| `ZOOM_STEP`, `ZOOM_SPEED` | `0.15`, `10` | Each wheel notch changes the distance by this share of itself; how quickly the zoom eases there |
| `PAD_ZOOM_RATE` | `0.9` | Holding D-pad up or down zooms by this share of the distance each second |
| `FOLLOW_SPEED` | `6` | How quickly it catches up with what it follows |
| `TRAVEL_SPEED`, `TRAVEL_MAX`, `TRAVEL_DONE` | `2.5`, `1.5`, `1.5` | Moving on to the next snail, or to where bullets landed, it glides this quickly (slower than `FOLLOW_SPEED`, so the move reads) for at most this many seconds, or until it's within this many studs |
| `CEILING_EXTRA` | `60` | How many studs above the map's `Bounds` top the view may rise (none while it follows a shot in flight) |
| `LEASH`, `RECENTER_SPEED`, `RECENTER_MOVE_SPEED` | `0.7`, `2.5`, `3` | On the player's own turn: the pan keeps their snail within this share of the view's half size from its middle, and eases back to it this quickly (higher is snappier) while the snail moves faster than this many studs a second |
| `BLAST_HOLD`, `BIG_BLAST_HOLD`, `BIG_BLAST_RADIUS` | `1`, `1.6`, `6` | The least seconds it stays on a blast (it stays until the next turn starts), for small blasts and for blasts at least `BIG_BLAST_RADIUS` studs big; `BLAST_HOLD` also for where bullets landed and a shot that ended without a blast |
| `CHASE_SPEED`, `CHASE_HOLD` | `25`, `0.6` | While it holds after a shot, a snail moving faster than this many studs a second is followed, and the hold lasts this many seconds after it slows |
| `LEAD_SECONDS`, `LEAD_MAX`, `LEAD_SMOOTH` | `0.35`, `18`, `8` | A flying shot is led this many seconds along its flight, at most this many studs, its velocity smoothed this quickly (higher is snappier) |
| `PUNCH_ZOOM`, `PUNCH_SECONDS` | `0.65`, `0.9` | A knockout's punch-in: this share of the player's zoom, for this many seconds |
| `STICK_PAN_SPEED` | `60` | Right-stick panning speed at full lean, in studs per second |
| `EDGE_PAN_MARGIN`, `EDGE_PAN_SPEED` | `0.015`, `60` | The mouse this close to the screen's left or right edge (a share of its height) pans the view sideways, in studs per second; not while the left button is held (an aim) |
| `STICK_DEADZONE` | `0.2` | How far the right stick must lean |

## In the place

Reads `Workspace.Ume.Arena.Markers.Bounds` (the loaded map's play area), `Workspace.Ume.Snails` and
`Workspace.Ume.Combat`.
