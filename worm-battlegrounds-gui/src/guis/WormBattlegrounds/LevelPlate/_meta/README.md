# LevelPlate

**The lobby's payout and XP replay** after a match. First the diamonds it paid: **+amount** with the diamond pops up
over the player's snail on the stage and the diamonds fly from there into the diamonds slot. Then the **XP replay**,
which takes the lobby (its panels and the stage's nameplates make way): the lobby darkens and the stage (`U_Plate`)
pops up in the middle, the **rank crest** (the level in a dark middle, a rim in the prestige tier's colours) on rays and
a glow in the tier's colour that grow richer each tier, a pip per tier and the tier's name under it, the **XP bar**
with the **next reward's card** at its end (its picture, the level, a NEXT tag that turns UNLOCKED!), and the match's
XP as **tiles** along the bottom (a picture, the XP in gold, what it was for). A level-up punches the crest, slams
**LEVEL UP!** across it, and a new rank flashes white. The owner asked for the replay on 2026-11-17 ("when we come back
to lobby we want to see the progress bar filling"), for no plate at rest on 2026-11-24 (the level stands on each
snail's nameplate), and for this look on 2026-11-25 ("needs to feel like leveling up in a high end competition", "the
rewards displayed using visual stuff", "based on level it gets better", the bar "more square", "slick", its colour by
level); the payout came on 2026-11-24 ("like Brawl Stars with the trophies"). **At rest** (the owner's pick,
2026-11-25: "under the diamonds", the menu and the loadout column lowered to make room: "you can lower all this to make
the level bar fit") the replay's own thin bar stands under it ("longer and thinner than the diamond one", "make it this bar to
keep it consistent"), as wide as the diamonds plate and its + together, its fill in the tier's colours and the rank
crest on its left end, with no text but the level.

**Weapon rewards** (2026-11-24, the owner: "make sure it looks good - look how good we made the crate opening"): six levels unlock the starter weapons' looks,
Shiny Grenade (10), Shiny Shotgun (20), Shiny Bazooka (30), Golden Grenade (60), Golden Shotgun (75) and Golden Bazooka
(90). `U_Unlock` takes the whole screen over the replay once that LEVEL UP! shows: the screen goes dark, the level's
diamond pops up and charges (rattling and swelling while light flies into it), flashes white and opens into the
reward's card on turning rays with a burst of stars, **SHINY!** or **GOLDEN!** slams in under it, then the name, the
line and **TAP TO CONTINUE**, with sparkles rising round the card. The Gui tool's preview plays it (`Preview.lua`:
pick the reward and the moment, or press **Play the unlock**). Both variants' lines say "+5% damage" (the owner: "so
players dont feel scammed").

**Look.** The game's screens (the code folder's `practices.md` → Guis), as Primitive nodes. The crest copies the weapon
unlock's diamond (a square turned 45° with a light sweeping it), its rim painted by `I.G_Progression.ApplyFrame` as the
prestige frames are, round a dark middle (52, 54, 74 to 20, 20, 30) whose box fits three digits; the rays and glow are
the crate result's pictures. The bar is a thin dark slot (13, 13, 20, a dark outline and the grey 130 line), cut in
five by faint ticks, its fill in the tier's colours with a darker lower half and a bright leading edge, the crates'
glow riding its end while it fills; the XP stands over its right end. The card, the tiles and the tags copy the
confirmation dialog's dark panel (25, 25, 35, a dark outline and the grey 130 line inside) and the crate card's BEST
tag; the tiles' pictures are the ui glyphs' gamepad and crosshair and the badges' crown. Londrina Solid Heavy Italic with
scaled black outlines (0.06 on titles, 0.07 on the rest). The diamonds' "+amount" is the same font in blue
(86, 184, 255), the diamond's picture after it. `U_Unlock` copies the crate opening: the crate result's glow, rays and
big card (`Crates` gui's `PREFAB | Card` pictures and sizes), the loadout cards' Shiny foil and Golden rim (`S_Foil`,
`S_Gold`), the crate card's BEST tag for the level, LEVEL UP!'s gradient for the title and TAP TO OPEN's look for the
prompt; the weapon is its 3D model in the card's view, gilded when Golden as Combat gilds a held one. Laid out by screen
fractions: the stage is 0.74 of the screen high and 1.2 times as wide, its pieces placed by its height.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LevelPlate"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `LevelPlate`: `Enabled` off, `DisplayOrder` 3, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Replay`, `U_Plate` and `U_Unlock` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Rest` | Frame, top right | The level at rest, under the diamonds: a copy of the Currency gui's `U_Bar` row (its box, right-aligned list and stand-ins sized as its diamonds plate and +), so it lines up with them on any screen; hidden while the replay plays |
| `U_Rest` › `S_RestTrack` | Frame | The replay's bar (slot, ticks, fill, shade, edge) under the diamonds plate: from its left edge to the +'s right edge (1.3698 of the plate), 0.4 of the plate high, its middle 1.52 plates down (halfway to the menu) |
| `S_RestTrack` › `S_RestFill` (`S_RestFillGradient`) | Frame | The fill (scale X, from `REST_FILL_START` past the crest) in the tier's colours |
| `S_RestTrack` › `S_RestTierGradient`, `S_RestLevel` | UIGradient, TextLabel | The crest on the bar's left end: its rim's tier colours and the level |
| `U_Replay` | Frame, hidden | The replay's layer, the whole screen |
| `U_Replay` › `S_Dim`, `S_Flash` | Frame | The lobby's dimming, and a new rank's white flash |
| `U_Replay` › `S_Gain` | Frame, hidden | The diamonds' "+amount", placed by code over the player's stage snail (its anchor at its bottom middle) |
| `S_Gain` › `S_GainScale` | UIScale | Pops it up and away |
| `S_Gain` › `S_GainText`, `S_GainIcon` | TextLabel, ImageLabel | "+100", and the diamond's picture (code sets the Currency module's icon) |
| `U_Replay` › `S_Particles` | Frame | The sparks and stars, and the flying diamonds (`I.UIEmitter`), over the stage |
| `U_Plate` | Frame in `U_Replay`, hidden | The stage, shown only while the XP plays back |
| `U_Plate` › `S_Pop` | UIScale, 0 at rest | Pops the stage up, and away after |
| `U_Plate` › `S_Rays`, `S_RaysBack`, `S_Glow` | ImageLabel | The light behind the crest: code sets its colour and how see-through it is by tier (`Utils_UISpin` turns the rays) |
| `U_Plate` › `S_Badge` (`S_BadgeScale`) | Frame | The crest, punched in on a level-up |
| `S_Badge` › `S_Rim` › `S_TierGradient` | UIGradient | The rim in the tier's colours (`I.G_Progression.ApplyFrame`) |
| `S_Badge` › `S_LevelNum` | TextLabel | The level |
| `U_Plate` › `S_LevelUp` (`S_LevelUpScale`) | TextLabel | LEVEL UP!, slammed across the crest |
| `U_Plate` › `S_Pips` | Frame of seven `Pip` frames | One per tier: code colours each `Gem` up to the player's tier |
| `U_Plate` › `S_TierName` (`S_TierNameGradient`, `S_TierNameScale`) | TextLabel | The tier's name in its colours, popped on a new rank |
| `U_Plate` › `S_Track` | Frame | The bar (code moves it to the middle when no card shows) |
| `S_Track` › `S_Fill` (`S_FillGradient`), `S_Head` | Frame, ImageLabel | The fill (scale X, in the tier's colours) and the glow at its end |
| `S_Track` › `S_Xp` | TextLabel | "into / for XP" ("Max level") |
| `U_Plate` › `S_Next` | Frame | The next reward's card, hidden when none is left |
| `S_Next` › `S_NextScale`, `S_NextGlow`, `S_NextIcon` (`S_NextRound`) | UIScale, ImageLabel, ImageLabel (UICorner) | Its pop, the glow in its colour, its picture (round for a frame reward) |
| `S_Next` › `S_NextRing` (`S_NextRingGradient`) | Frame, hidden | A frame reward's rim round the player's face |
| `S_Next` › `S_NextLevel`, `S_NextTag`, `S_NextTagGradient` | TextLabel, TextLabel, UIGradient | "Lv 30", and NEXT or UNLOCKED! in the tag's colours |
| `U_Plate` › `S_Lines` | Frame with a horizontal UIListLayout | Holds the XP tiles |
| `U_Unlock` | Frame, full screen, hidden | The weapon reward's takeover, shown by Progression's `Unlock` |
| `U_Unlock` › `S_Shade` | Frame | The dark behind it |
| `U_Unlock` › `S_Glow`, `S_Rays`, `S_RaysBack` | ImageLabel | The light behind the card in the reward's colour; the rays turn by their `Utils_UISpin` tags (`Utils_SpinSpeed` 2.3, the back rays −1.35: about 14° and 8° a second) |
| `U_Unlock` › `S_Kicker`, `S_KickerScale` | TextLabel, UIScale | "Level 90 reward", popped in |
| `U_Unlock` › `S_Orb` (`S_OrbScale`, `S_OrbGlow`, `S_OrbDiamond`, `S_OrbGradient`, `S_OrbLevel`) | Frame, hidden | The level's diamond that charges and flashes open: its scale, glow, rattle (`S_OrbDiamond` `Rotation`), colours and level |
| `U_Unlock` › `S_CardSlot` (`S_CardScale`) | Frame | The reward's card, popped in |
| `S_CardSlot` › `S_CardGlow`, `S_CardStroke` | ImageLabel | The card's glow and outline in the reward's colour |
| `S_CardSlot` › `S_Foil`, `S_Gold` | Frame, hidden | The Shiny foil or the Golden rim, shown by variant |
| `S_CardSlot` › `S_Model` | ViewportFrame, hidden | The weapon's model (gilded when Golden), turned by its `Utils_Motion` Turn tag |
| `S_CardSlot` › `S_Icon` | ImageLabel | The weapon's picture, while it has no model |
| `S_CardSlot` › `S_CardName`, `S_LevelTagText`, `S_LevelTagGradient` | TextLabel, UIGradient | The weapon's name, "Level 90" and the tag's colours |
| `U_Unlock` › `S_Title`, `S_TitleGradient`, `S_TitleScale` | TextLabel, UIGradient, UIScale | "Shiny!" or "Golden!" in the variant's gradient, slammed in |
| `U_Unlock` › `S_Name`, `S_Perk` (`S_NameScale`, `S_PerkScale`) | TextLabel | "Golden Bazooka unlocked" and what it does in a match |
| `U_Unlock` › `S_Tap` | TextLabel, hidden | "Tap to continue", pulsing |
| `U_Unlock` › `S_Fx`, `S_Flash` | Frame | The particles (`I.UIEmitter`) and the white flash |

## Prefabs

| Prefab | What |
| --- | --- |
| `PREFAB \| XpLine` | One XP tile, in `U_Plate`: `S_Icon` (its picture), `S_Amount` ("+50", gold), `S_Label` ("Victory"), `S_Scale` to pop it in |

## Driven by

The game's `Progression` module (its `Client.lua`, `Scripts/Client/Payout.lua` for the diamonds and
`Scripts/Client/Unlock.lua` for the weapon unlock) finds it as
`I.UserInterface.UI["LevelPlate"]`. The Lobby module turns it on with the lobby's other screens (Lobby's `LOBBY_GUIS`).
The diamonds fly into the `Currency` gui's diamonds slot (`S_Diamonds`), which `Payout` holds at the old count until they land.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui. A restyled copy keeps its `Name`,
its Ids and the `PREFAB | XpLine` prefab.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Skip the XP replay (not the diamonds) | Click | Tap | A | Progression (`UserInputService.InputBegan`) |
| Close the weapon unlock (once TAP TO CONTINUE shows) | Click | Tap | A | Progression's `Unlock` (`UserInputService.InputBegan`) |

### Looks

| Look | Value | Set by |
| --- | --- | --- |
| Frame colours | `FRAME_TIERS` | Progression's Settings, through `I.G_Progression.ApplyFrame` |
| The crest's light and stars by tier | `REPLAY_TIER_LOOKS`, `PIP_OFF_COLOR` | Progression's Settings |
| The level-up | `CREST_PUNCH`, `RANK_FLASH`, `LEVEL_UP_TWEENINFO`, `RANK_FLASH_TWEENINFO` | Progression's Settings |
| The reward card and the tiles | `REWARD_*`, `TRACK_X`, `XP_ICONS` | Progression's Settings |
| The stage's scale in the replay | `REPLAY_SCALE` (its place and size are the gui's `U_Plate`) | Progression's Settings |
| Tweens | `PLATE_TWEENINFO`, `PLATE_BACK_TWEENINFO` (the stage), `DIAMOND_POP_TWEENINFO`, `DIAMOND_HIDE_TWEENINFO` ("+amount") | Progression's Settings |
| Dimming | `REPLAY_DIM` | Progression's Settings |
| The weapon unlock | `UNLOCK_LOOKS` (each variant's colours, gradients and title sound), `UNLOCK_*` timings, rests, model framing and gilding | Progression's Settings |
| The flying diamonds | `DIAMONDS_PER_ICON`, `DIAMOND_ICONS_MAX`, `DIAMOND_ICON_SIZE`, `DIAMOND_BURST_DELAY`, `DIAMOND_TICK_CLIMB` | Progression's Settings |
