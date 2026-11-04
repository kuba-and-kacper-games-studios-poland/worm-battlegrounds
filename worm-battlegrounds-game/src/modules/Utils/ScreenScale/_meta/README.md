# ScreenScale

Sizes the game's panels to the screen. Every gui made for the game lays its panels out for a 1920 × 1080 screen,
places them by screen fractions, and gives each one a UIScale named `S_ScreenScale`; this module sets each of them to
the screen's height / 1080 (or its width / 1920 on a screen narrower than 16:9), ×1.3 on Mobile screens shorter than
500 px, at start, when the screen changes size and when the platform changes.

A panel sized per device carries ume's `Utils_PlatformScale` tag: that component writes the device's scale on the
same UIScale and keeps it in its `Utils_BaseScale` attribute. This module multiplies the screen's scale by that
attribute, and sets it again whenever the component writes over it. ume's own guis (Settings, HoverInfo) scale
themselves.

| | |
| --- | --- |
| Folder | `src/modules/Utils/ScreenScale` |
| Runs on | Client |
| Exposes | Nothing |
| Uses | `I.UserInterface`, `I.Env.Camera`, `I.Platform` (`Platform_Changed`) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Finds the UIScales and keeps them in step with the screen |
| `Settings.lua` | Which guis, the design height and the Mobile boost |

## Settings

| Setting | Default | What |
| --- | --- | --- |
| `GUIS` | The game's ScreenGuis | The guis whose `S_ScreenScale` UIScales are set; a gui missing from `PlayerGui` is skipped |
| `DESIGN_HEIGHT` | `1080` | The screen height the guis are laid out for |
| `DESIGN_WIDTH` | `1920` | The screen width they're laid out for: a narrower screen scales by width / this instead, so panels side by side still fit |
| `SMALL_SCREEN`, `MOBILE_BOOST` | `500`, `1.3` | Mobile screens shorter than this are scaled up by this much more |
| `BASE_SCALE_ATTRIBUTE` | `Utils_BaseScale` | The UIScale attribute `Utils_PlatformScale` keeps a panel's device scale in; the screen's scale is multiplied by it |

## Network

No remotes or Topics.
