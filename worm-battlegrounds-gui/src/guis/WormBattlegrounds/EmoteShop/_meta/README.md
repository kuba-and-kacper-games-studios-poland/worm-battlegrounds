# EmoteShop

The **EMOTES** panel, opened from the lobby Loadout's + by the emote row: a card per emote (its rarity badge, icon and
name), three across. An emote not owned yet wears a locked cover with its price in coins and the level it needs, and
a press buys it.

**Look.** Ported 1:1 from the gui maker's `Emotes` design (2026-11-11, built from the studio's Customise cards) as
`Primitive` nodes laid out by screen fractions with aspect-ratio constraints (no `S_ScreenScale`, not in ScreenScale's
`GUIS`): the panel stands in the Loadout's place on the right (the Lobby module hides Loadout while it's open, its
`PANEL_WIDGETS`). Added to the design: the locked cover (the Skins tile's `S_Locked`, with the lock), the price under
the lock (white Londrina with the coin, as Loadout's locked slot) and the level at its top right in yellow, and a close
button (the Party card's red kick button), since the design has none. Before, it was the GUI kit's list window.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/EmoteShop"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `EmoteShop`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape, holding `Content` › `Right`, the panel) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens |
| `U_Widget` › `Content` › `Right` | Frame | The panel: `Title` (EMOTES), `Items` (a ScrollingFrame) and `S_Close` |
| `U_Emotes` | Frame, in `Items` (a grid, three across) | Holds one `EmoteCard` per emote, between `Items`' `TopGap` and `BottomTail` spacers |
| `S_Close` | ImageButton | Closes the widget (its tags), or B on a pad |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| EmoteCard` | `U_Emotes` | An ImageButton (the design's card): `Background`, `S_Rarity` (the badge, tinted with the rarity's colour), `S_Icon`, `S_Name`, and `S_Locked` (hidden: the dark cover and lock, `S_Price` with its coin icon, `S_Level`) |

## Driven by

The game's `Cosmetics` module (`Scripts/Client/EmoteShop.lua`) draws it on `WidgetManager_Opened` with `EmoteShop`,
and again while it's open when the inventory changes.

## Preview

`Preview.lua` fills the 8 emotes from the wiki.

| Setting | What it does |
| --- | --- |
| `S_Owned` (Slider, 0 to 8) | How many are owned (the rest show the locked cover) |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `EmoteShop`, `Enabled` off. WidgetManager
opens it: the Loadout gui's `S_Shop` (+) toggles it (its tags). It keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click X, or + again | Tap | B | `S_Close` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click a locked card | Tap | Select and A | Cosmetics (`I.Interact.OnPress` on each card) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Cards, `S_Close` | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Rarity | `S_Rarity` | `I.Rarity.GetLook(rarity).Base`, white without a rarity |
| Not owned | `S_Locked` | Shown; `S_Price` the coins (Free at 0), `S_Level` "Level N" ("Any level" up to level 1) |
