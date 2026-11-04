# ScreenScale

Sizes the game's panels to the screen. Every gui made for the game lays its panels out for a 1080 px tall screen and
gives each one a UIScale named `S_ScreenScale`; this module sets each of them to the screen's height / 1080, ×1.3 on
Mobile screens shorter than 500 px, at start, when the screen changes size and when the platform changes. ume's own
guis (Settings, HoverInfo) scale themselves.

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
| `SMALL_SCREEN`, `MOBILE_BOOST` | `500`, `1.3` | Mobile screens shorter than this are scaled up by this much more |

## Network

No remotes or Topics.
