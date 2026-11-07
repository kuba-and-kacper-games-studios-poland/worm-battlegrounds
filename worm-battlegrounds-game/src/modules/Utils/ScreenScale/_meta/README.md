# ScreenScale

Sizes the game's panels to the screen. Every gui made for the game lays its panels out for a 1920 × 1080 screen,
places them by screen fractions, and gives each one a UIScale named `S_ScreenScale`; this module sets each of them to
the screen's height / 1080 (or its width / 1920 on a screen narrower than 16:9), ×1.3 on Mobile screens shorter than
500 px and never under 0.6 on other devices (so text on a small PC window stays readable), at start, when the screen
changes size and when the platform changes. The floor wins over the width rule: at 1024 × 768 the scale is 0.6, not
0.533, and the lobby's side-by-side panels are placed to fit it.

A panel sized per device carries ume's `Utils_PlatformScale` tag: that component writes the device's scale on the
same UIScale and keeps it in its `Utils_BaseScale` attribute. This module multiplies the screen's scale by that
attribute, and sets it again whenever the component writes over it. ume's own guis (Settings, HoverInfo) scale
themselves.

World labels (BillboardGuis cloned at runtime: SnailTag, DropMarker, DamagePop) are handed to it with `AddBillboard`:
their root is laid out at its design size with an `S_ScreenScale`, and this module sets that scale to the screen's
(no device scale) and the billboard's `Size` to the root's size times it, until the billboard is destroyed.

| | |
| --- | --- |
| Folder | `src/modules/Utils/ScreenScale` |
| Runs on | Client |
| Exposes | `I.ScreenScale.AddBillboard` |
| Uses | `I.UserInterface`, `I.Env.Camera`, `I.Platform` (`Platform_Changed`) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Finds the UIScales and keeps them, and the world labels added to it, in step with the screen |
| `Settings.lua` | Which guis, the design size, the Mobile boost and the floor |

## API

| Function | What |
| --- | --- |
| `AddBillboard(billboard: BillboardGui)` | Sizes a world label with the screen, now and whenever the screen changes, until it's destroyed |

## Settings

| Setting | Default | What |
| --- | --- | --- |
| `GUIS` | The game's ScreenGuis | The guis whose `S_ScreenScale` UIScales are set; a gui missing from `PlayerGui` is skipped |
| `DESIGN_HEIGHT` | `1080` | The screen height the guis are laid out for |
| `DESIGN_WIDTH` | `1920` | The screen width they're laid out for: a narrower screen scales by width / this instead, so panels side by side still fit |
| `SMALL_SCREEN`, `MOBILE_BOOST` | `500`, `1.3` | Mobile screens shorter than this are scaled up by this much more |
| `MIN_SCALE` | `0.6` | The smallest screen scale on every device but Mobile, before the device scale (the kit's 0.75 on Desktop: 0.45) |
| `BASE_SCALE_ATTRIBUTE` | `Utils_BaseScale` | The UIScale attribute `Utils_PlatformScale` keeps a panel's device scale in; the screen's scale is multiplied by it |

## Network

No remotes or Topics.
