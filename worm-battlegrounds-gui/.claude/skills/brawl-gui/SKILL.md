---
name: brawl-gui
description: Make or restyle one of Worm Battlegrounds' guis in the game's GUI kit look (Brawl Stars style) on the WormBattlegroundsBrawl theme, in the gui itself or as a design option to compare, drawing any new pictures in the kit, checking it in Studio and capturing it for the owner. Use when asked to make, add, convert or restyle a gui "in the Brawl style" or "in the kit look".
argument-hint: <Gui name, e.g. Loadout>
---

# A gui in the Brawl look

**The game's look since 2026-11-04:** the owner's GUI kit (draft 4, Hazard plate windows), the
`WormBattlegroundsBrawl` theme drawing the kit's 9-slice skins. Every gui in `src/guis/WormBattlegrounds/` uses it
(`game/practices.md` → Guis). The kit's sheets are the design canvas, with the game home's
`assets/_inbox/ui_kit_brawl/README.md`.

Make or restyle `$ARGUMENTS` in the kit look: in the gui itself, or, when the owner wants looks to compare, as design
options (`src/guis/WormBattlegrounds-<Gui>/NN_<Option>/`, `gui/code.md` → Changing a gui).

## 1. Read

- The research: the game home's `assets/_reference/brawl-stars/README.md` (shapes, colours, type, motion, the
  Roblox limits table). Open the Brawl Stars screens it lists for the kind of screen you're making.
- The theme: `src/themes/WormBattlegroundsBrawl/_meta/README.md` (its styles and controls, the `Kit_*` attributes
  code reads), and the game's other guis for the sizes and controls they use.
- The gui: `src/guis/WormBattlegrounds/<Gui>/` (`init.lua`, `Preview.lua`, `_meta/README.md`), and the module in the
  code folder that drives it. Note every Id, prefab name and lookup it makes, and which lookups aren't recursive
  (`FindFirstChild(name)` on the gui or a frame): those elements must keep their parent.

## 2. Lay it out

Pick the Brawl screen that does the same job (the research's Layouts) and map the gui onto it: what becomes the hero
button, the event cards, the offer row, the plate title. Keep the gui's `Name`, `Screen`, every Id and every
prefab name, so the code that drives it keeps working.

- In the gui itself (`src/guis/WormBattlegrounds/<Gui>/`): `init.lua` with `Theme = "WormBattlegroundsBrawl"`, and
  its `Preview.lua` for what code fills in.
- As an option to compare (`src/guis/WormBattlegrounds-<Gui>/NN_<Option>/`): `init.lua`, and a `Preview.lua` that
  requires the gui's own Preview through `script:FindFirstAncestor("Guis")`, reuses its `Settings` and runs its
  `Apply` first, then only what the option shows differently. Class
  `UmeGui_Guis_WormBattlegrounds<Gui>_<NN><Option>_Preview`.

## 3. Build it from the theme

| Need | Use |
| --- | --- |
| A WidgetManager widget | `Widget` (`Small`, `Large`, `Screen`; `Royal` or `Ember` for premium or event windows) |
| A panel on the screen | `Box` `{ "Panel", "Fixed" }` with `Screen = true`; `Hud` for a match hud block, `Pill` for currencies |
| Things (items, perks, packs, rows) | `Item`, or a `Box` slot (the default) |
| People and places (players, modes, open matches) | `Box` `Card`, + `Winner`, `Event` or `Highlight` |
| A reward being won | `Item` with its rarity (`Common` … `Legendary`): the framed tile |
| The window's next step (one) | `Button` `Primary` (`Large` or `Hero` for the screen's main one) |
| Other buttons | blue (default), `Price` (any price), `Danger`, `Event`, `Tab` (selected turns blue), `Muted` |
| An icon button | `Button` `Square`, `Text = ""`, an `Icon`, `Props.Size` 96 × 96 |
| Section titles | `Label` `Heading` (a slot's `Box` `Title` is cyan) |
| Lists code fills | `Cells` (`Players`, `Slots`, or the base theme's) |

- A look the theme doesn't have yet becomes a style variant (or a control) in `WormBattlegroundsBrawl`, used by every
  gui that needs it; never a one-off value in a gui (`gui/code.md` → Same sizes and looks). Never edit the
  `WormBattlegrounds` or `System` themes for this.
- Place panels by screen fractions from a screen edge or corner, and give each its `S_ScreenScale` (a `Widget`, or
  `Screen = true` on a `Box`, `Item` or `Button`); add the gui to ScreenScale's `GUIS` list when it's new. Check it
  against the guis shown with it on PC, tablet and phone sizes (`game/practices.md` → Maps and placeholders).
- When the gui shows a picked, owned or rarity state, the code that drives it uses the kit's way: swap `Face.Image`
  from the `Kit_*` attributes, fill a slot's `Body`, colour rarity text (`game/practices.md` → Guis).
- Roblox traps: no `Divider` or other scale-height frame in a row inside an auto-height box (it grows to the screen);
  no `Box` with labels in a `Fill` row; `AutoWidth` with an `Icon` doesn't count the icon; frames can't skew (slants are
  kit images); text gets an outline, never a drop.

## 4. Pictures

A picture the kit doesn't have yet (the kit's README lists them): draw it in the game home's
`assets/_inbox/ui_kit_brawl/svg/` following that README's drawing rules, add it to `KIT_ITEMS` in `build.py`, and
rebuild (README → Rebuilding: `python build.py`, then open its `render.html` in a browser). It rewrites the theme's
`Icons.lua`. Never upload a picture, and never point the theme at an `rbxassetid://` the owner hasn't approved.

## 5. Check

1. `stamp_authorship` and `check` (ume-sync) on the Lua files you changed; `sync_status` until Studio has them.
2. In Studio: `GetErrors` and `Build` for the gui, from a fresh `ServerStorage.UmeGui:Clone()` (a cached require
   keeps old styles).
3. Capture it as `gui/code.md` → Checks says: build into `__Ume_Preview`, run its Preview `Apply` with each
   state its Settings offer (empty, full, joined…), over the lobby or match gui it sits on when it isn't a
   full-screen widget. Compare it with the Brawl screen you mapped it to; fix what's off in the table or the theme,
   never in the built copy. Destroy `__Ume_Preview` when done.
4. A gui of the game's own (not an option): export it over its copy in the place (the Gui tool's **Export to
   StarterGui**, or `UmeGui.Export`), keeping the old copy's extra attributes and children, and play-test the code
   that drives it.

## 6. Record

- The gui's `_meta/README.md`: its **Look** line and its Looks rows; for an option, the option folder's README row.
- The theme's README, when you added a style, a control, a token or an attribute code reads.
- A wiki journal entry for the change (`wiki/journal/`, `wiki/JOURNAL.md`).
- Show the owner the captures and wait for their verdict. Nothing is committed or uploaded unless they ask.

## Still to do for the kit

Not part of this skill's run, listed so it isn't forgotten: upload the kit's pictures once the owner approves (its
README → Uploading), then point the theme's `Icons.lua` at the `rbxassetid://` ids; give the Shop a picture per
diamond pack (`PACK_ICON`); remove the old option folders (`src/guis/WormBattlegrounds-<Gui>/`) when the owner says
so.
