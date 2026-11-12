# Shop

The shop: the 5 diamond packs and the 4 game passes, every benefit listed, prices read live from Roblox, with the player's diamonds and coins and **Back** at the top.

**Look.** The studio's `Shop` design (2026-11-12), ported 1:1 as `Primitive` nodes (its pictures, fonts and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive` ports"). It fills the screen: SHOP top left, the two balances and a red Back top right, a row of diamond pack cards over a row of game pass cards. Every price sits on a green button; an owned pass's button turns grey.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Shop"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `Shop`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding the screen) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Diamonds`, `S_Coins` | TextLabel (`Currency_Slot`) | ume's Currency writes the balances; each has a UIScale (`S_DiamondsScale`, `S_CoinsScale`) and a `Currency_UIScale` ObjectValue |
| `U_Widget` › `S_Close` | ImageButton | Back: closes the shop (its tags) |
| `U_Packs` | Frame with a horizontal UIListLayout | Holds one `Pack` per diamond pack |
| `U_Passes` | Frame with a UIGridLayout | Holds one `Pass` per game pass |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Pack` | `U_Packs` | `S_Icon`, `S_Name`, `S_Info` (diamonds), `S_Buy` (ImageButton) with `S_Price` |
| `PREFAB \| Pass` | `U_Passes` | `S_Icon`, `S_Name`, `S_Benefits`, `S_Buy` (ImageButton) with `S_RobuxIcon` and `S_Price` |

## Driven by

The game's `Shop` module draws it on `WidgetManager_Opened` with `Shop`. The Lobby module hides the lobby's own guis while it shows (`FULL_SCREEN_WIDGETS`).

## Preview

`Preview.lua` fills the wiki's packs and passes, with example prices.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Shop`, `Enabled` off. Then point each `Currency_UIScale` ObjectValue at the UIScale beside it (`S_Diamonds` › `Currency_UIScale` → `S_DiamondsScale`, `S_Coins` › `Currency_UIScale` → `S_CoinsScale`): a gui table can't hold an ObjectValue's target. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "Shop"`, or `I.WidgetManager.Open("Shop")`). A restyled copy keeps its `Name`, Ids and prefab names. Prices come from `GetProductInfoAsync`, never hard-coded.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Back | Click | Tap | B (Circle) | `S_Close` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click | Tap | Select and A | Shop connects each card's `S_Buy` |

Back shows its pad button in a `PadHint` badge on Console (`Console_Hint`, `Console_Action` `Back`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Owned pass | `Pass` › `S_Buy` › `Background.Main`, `Background.Stroke` | `Look_OwnedMainColor` (70, 70, 80) and `Look_OwnedStrokeColor` (130, 130, 130), `S_RobuxIcon` hidden and `S_Price` "Owned"; otherwise `Look_MainColor` (green) and `Look_StrokeColor` with the live price. Shop's `Client` |
