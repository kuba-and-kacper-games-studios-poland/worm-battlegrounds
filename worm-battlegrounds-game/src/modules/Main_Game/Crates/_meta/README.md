# Crates

The lobby's crates. The server opens a crate, a 3-pack or a 10-pack: it checks the crate takes the currency (or VIP's
free daily crate), refuses diamond prices where the player's policy restricts paid random items, takes the pack's
price from the crate's row, rolls each item by the crate's odds, gives it, and reports which copies just made an item
shiny. The client draws the full-screen Crates widget (a tab per crate, the balance of the currencies it takes, its
odds by rarity, the crate on its pedestal in the crate's colours, and the x1, x3 and x10 buy buttons) and plays the
opening on the same screen, laid out like CS2's case opening: the shop makes way, the bought crates drop onto the
screen as 3D models (one, three or ten) and wait for a tap, then rattle, spring their hatches, drop their walls and send
up a ball of light that flashes into the reels. A reel of item cards rolls under a fixed line (three stacked bands for a
3-pack, ten columns for a 10-pack) and slows onto each result, then the results are revealed. A legendary first lands
as a gold ★ card; then a golden crate drops in and is tapped open, a golden reel picks which legendary (when the crate
holds more than one), and the legendary plays its own drop. The tutorial crate is a hidden, fixed crate that opens once, while
`Tutorial` says it waits: its tab is then the only one.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Crates` |
| Runs on | Server, Client, Global · Lobby map |
| Exposes | `I.Crates` (server), `I.G_Crates` (both) |
| Uses | `I.Currency`, `I.Inventory`, `I.G_Inventory`, `I.Policy`, `I.Shop`, `I.Tutorial`, `I.Random`, `I.Rarity`, `I.WidgetManager`, `I.Replicator`, `I.Notify`, `I.Interact`, `I.Format`, `I.Console` (client: the pad's tab buttons), `I.Sound`, `I.UIEmitter` (client: every particle), `I.Topic`, `I.G_Cosmetics`, `I.SnailRig`, `I.Utils` (client: the skin snails on cards) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | `Open`: checks, paying, rolling, giving |
| `Global.lua` | The crate rows and pack prices; warns at start when a crate's odds don't add up to 100 or name an unknown item |
| `Client.lua` | Starts the client handlers |
| `Scripts/Client/Panel.lua` | The Crates widget: tabs (on a pad LB and RB step through them while it's open, the Console module's `TabPrevious` and `TabNext`), the paying currency, the buy buttons (tinted by the currency they pay with), the lobby menu's Weapons and Skins buttons and badge, opening |
| `Scripts/Client/Odds.lua` | The Crates widget's odds list, by rarity; a skin with a snail shows it live on its card (`SkinModels`) |
| `Scripts/Client/SkinModels.lua` | The skins' snails on cards: `Put` shows an item's snail (its skin row's `Model` in `Assets/Skins`), posed in its idle frame (`I.SnailRig.Pose`), in a card's `S_Model` viewport, framed as the Skins window frames it (Cosmetics' `PREVIEW_DISTANCE`); `Release` takes it off; spare snails wait in a pool by model. While the widget is open it draws a card's snail again once the card holds still where it's seen (`SKIN_REDRAW_FRAMES`): Roblox doesn't draw a viewport that changed while it moved or was hidden until it changes again where it's seen |
| `Scripts/Client/Showcase.lua` | The crate on its pedestal: its 3D model (the row's `Model`) in `U_Crate`'s viewport, dressed in the crate's `Look` (glow, rays, beam, ring, ambient particles, STANDARD or PREMIUM tag, name plate; the premium crate's halo and violet backdrop), turning rays, a bob, a sway and a breathing glow while the widget is open, a pop when the crate changes, and the leap off the pedestal when a crate is bought |
| `Scripts/Client/Reel.lua` | The reels: builds them from the results (strips of cards with the winner placed by CS2's rules), rolls them on CS2's curve with ticks as cards pass the line, skips, settles onto the card's centre, and builds the golden reel. Makes and fills every card (a card with no name centres its picture; a reel card caps its name's size, `CARD_NAME_TEXT`): a skin with a snail shows it live (`SkinModels`), except on a reel card, which shows the snail's picture (`SKIN_PICTURES`, preloaded at start) |
| `Scripts/Client/Effects.lua` | Every gui effect: bursts, rings, confetti, streams (flames, bubbles, rain, vortex, orbit), flashes, tints, shakes and each rarity's reveal burst, drawn with `I.UIEmitter` on the result's back and front layers |
| `Scripts/Client/Drops.lua` | The legendaries' own drops (`LEGENDARY_DROPS`): the black hole opens over the reels with its disk turning, pulls the whole opening into itself (`S_Swallow`) with streaks of light, and implodes, the variety grenade bursts into confetti and smileys, the skeleton rises green in flames, the low gravity potion floats up in bubbles; any other legendary gets the plain legendary reveal |
| `Scripts/Client/Stage3D.lua` | The 3D crates: clones the crate's model (its row's `Model`) into the stage's ViewportFrame in the pack's layout, drops them in, waits for the tap (not with Quick open), and opens them: a rattle with the hatches straining, the hatches springing open, the walls falling outward (each piece turned about its hinge in code), and a Neon ball of light rising and swelling into the flash. Draws the 2D effects at points projected from its camera, and dresses the legendary's golden crate (gold light, gold rays, sparkles). Preloads the models at start |
| `Scripts/Client/Result.lua` | The result's drawing: the big card (its entrances, rays, words and copies bar), a pack's card names, the pack's summary, and the result loop (turning and rainbow rays, the black hole's disk, a floating card) |
| `Scripts/Client/Reveal.lua` | The opening from start to end: the intro (the shop making way, then `Stage3D`), the reels, the heartbeat under an epic or legendary, the gold moment (the gold card, the golden crate, the golden reel or a rising card, the drop), the reveal of one big card or a pack's row or grid, Skip, Quick open, Open again and Continue |
| `Settings.lua` | `Crates_Settings` |
| `Data/Crates/<CrateId>.lua` | One row per crate (`Crates_CrateData`): `Weapon`, `Premium`, `Utility`, `Skin`, `Tutorial` |

## API

### Server: `I.Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Open(player, crateId: string, count: number, payWith: string)` | `{ Crates_Result }?` | Opens 1, 3 or 10 crates (`COUNTS`) paid in `"Coins"`, `"Diamonds"` or `"VipDaily"`; nil when it can't |

### Global: `I.G_Crates`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(crateId: string)` | `Crates_CrateData?` | A crate's row; warns when it has none |
| `GetAll()` | `{ [string]: Crates_CrateData }` | Every row, by id |
| `GetPrice(crateId: string, currency: string, count: number)` | `string?` | What a pack costs: the row's `One`, `Three` or `Ten` in that currency; nil when the crate doesn't take it |

## Network

### Server

**Topics**

- `Crates_Opened @ (player: Player, crateId: string, results: { Crates_Result })`: after a crate gave its items (Tutorial listens)

**Receive: RemoteFunctions**

- `Crates_Open @ (player: Player, crateId: string, count: number, payWith: string)`: returns the results, or nil. Rate limit 2 per second.

## Data

Owned items are Inventory items. The widget reads three Replicator folders other modules write:

| Where | Key | What |
| --- | --- | --- |
| Replicator `Shop` | `VipCrateReady` | Makes the Skin crate's x1 free (FREE, paid with `VipDaily`) and the badge FREE |
| Replicator `Tutorial` | `CrateReady` | Shows the tutorial crate's tab alone, and the badge FREE |
| Replicator `Policy` | `ArePaidRandomItemsRestricted` | Hides the diamonds chip (and the Premium crate's tab) while not `false` |

A crate row: `Name`, `TabName` (its tab's text), `LayoutOrder` (its tab's place), `Hidden` (no tab unless
it's the waiting tutorial crate; opens only one at a time), `Prices` (`{ [currency]: { One, Three, Ten } }`),
`OddsByCurrency` (`{ [currency]: { [itemId]: percent } }`, each adding up to 100), `Fixed` (items always given, in
place of a roll), and its look: `Glow` (the showcase's glow, rays and beam, and its reel band's lines), `Accent` (the
premium ring's colour), `Ambient` (`Crates_Ambient`: the particles around it, `"Embers"`, `"Glints"`, `"Bubbles"` or
`"Sparkles"`), `Premium` (the PREMIUM tag, the halo, the violet backdrop and the premium reel's line) and `Model` (the
3D crate on the pedestal and the one the opening drops in: `PREFAB | Crate_<Name>` in `ReplicatedStorage_Assets/Crates`;
the tutorial crate uses `Crate_Starter`). The models are `art/crates`' (its README → Uploading has the ids).

| Crate | Prices (1, 3, 10) | Odds | Look |
| --- | --- | --- | --- |
| `Weapon` | 100, 300, 900 coins | Uzi, Golf Club, Dynamite, Spartan Spear 14.75 % each; Cluster Bomb, Spider Bomb, Minigun 10 %; Homing Missile, One Punch 5 %; Variety Grenade, Black Hole Grenade 0.5 % | Amber glow, embers |
| `Premium` | 250, 750, 2,250 diamonds | Cluster, Spider, Minigun 26 % each; Homing, One Punch 10 %; Variety, Black Hole 1 % | Cyan glow, gold accent, glints, premium |
| `Utility` | 100, 300, 900 coins or 200, 600, 1,800 diamonds | Coins: Parachute, Bandage 27.5 %; Jetpack, Speed 15 %; Medkit 10 %; Low Gravity 5 %. Diamonds: 15, 15, 20, 20, 20, 10 | Mint glow, bubbles |
| `Skin` | 100, 300, 900 coins or 50, 150, 450 diamonds | Soldier, Pirate, Cowboy 20 % each; Ninja, Knight, Clown 10 %; Devil 7 %; Robot 2 %; Skeleton 1 % | Pink glow, sparkles |
| `Tutorial` | 100 coins (one only) | Fixed: Grenade and Shotgun. Hidden | Green glow, sparkles |

A 3-pack costs three single crates (no discount, unlike the 10-pack's 10 %).

## Opening

What the client plays, in order:

1. **Intro.** The tabs and balance slide up, the odds left, the buttons down (`INTRO_TWEENINFO`); the screen dims
   (`BACKDROP_OPEN_*`), and the showcase's crate leaps up off the pedestal and fades (`SHOWCASE_LIFT_TWEENINFO`) as
   the 3D crates drop in.
2. **The 3D crates.** The bought crates drop in over the crate's glow and turning rays (`STAGE_LAYOUTS`: one in the
   middle; three as one in front and two behind; ten as a pyramid of 1, 2, 3 and 4 rows), back ones first, each
   landing with a thud (`Crate_Settle`) and a puff (`STAGE_DROP_*`). They bob while TAP TO OPEN (TAP TO OPEN ALL)
   beats under them, their hatches lifting on the beat. A tap anywhere (or A or Space) opens them all, front first
   (`STAGE_OPEN_GAP`): a rattle with the hatches straining (`STAGE_RATTLE_SECONDS`, `Crate_Shake`), the hatches
   springing open (`STAGE_HATCH_*`, `Crate_Unlock`, sparks), the walls falling outward with the hatches riding the
   side walls (`STAGE_WALL_*`, a ring), and a ball of light rising and swelling (`STAGE_SWELL*`) into a white flash
   (`Crate_Land`). A ten-pack runs light (`STAGE_LIGHT_COUNT`): the front crate alone puffs, sparks and rings,
   wider, and the stage's glow swells behind the pack in place of the balls of light.
3. **Reels.** One result is one band with a lens over the line (`LENS_*`); two or three results stack bands
   (`BAND_*`); ten results stand as ten columns (`COLUMN_*`) under a horizontal line. Each strip has `STRIP_CARDS`
   (`COLUMN_CARDS`) cards with the winner at `WIN_CARD` (`COLUMN_WIN_CARD`), the filler drawn by the crate's odds and
   never a legendary (unless every item is one). The reel rolls on CS2's curve (`ROLL_CURVE`) for `ROLL_SECONDS`, the
   rarest result stopping last (`ROLL_STAGGER`), lands at a random point across the card (`LAND_SPREAD`), then glides
   onto its centre (`SETTLE_*`). A tick (`Crate_Tick`) plays as each card passes the line, at most every `TICK_GAP`.
   A skin's card shows its snail's picture (`SKIN_PICTURES`): a rolling reel can't draw that many live snails (each
   snail costs Roblox 3 to 4 ms the first time its viewport draws it, and a viewport isn't redrawn while it moves).
4. **Tease.** When an epic or better is coming (`TEASE_FROM_RARITY`), `TEASE_SECONDS` before it lands a heartbeat
   plays (`Crate_Tease`), letterbox bars slide in, the line burns brighter and the screen dims on each beat.
5. **Gold moment.** A legendary lands as a gold ★ card (`Crate_GoldHit`). The reels give way to a golden crate: the
   same crate lit gold (`STAGE_GOLD_*`) on gold rays with sparkles, over TAP TO OPEN and LEGENDARY CRATE, which opens
   as the first did. When the crate holds more than one legendary, a golden reel of them rolls (`GOLDEN_SECONDS`) to
   say which; else the legendary's card rises out of the crate. Then `Drops` plays its drop (`LEGENDARY_DROPS`).
6. **Reveal.** One result is one big card with its rarity's rays and burst (`REVEAL_RAYS`, `Reveal_<Rarity>`), its
   rarity bar, name and copies to shiny. A pack's cards fly from the reels to a row of three (`TRIO_*`) or a grid of
   five by two (`TEN_*`) and are named in turn (`TRIO_STEP`, `TEN_STEP`), NEW and BEST tags on them, each legendary
   holding the middle first (`PACK_LEGENDARY_HOLD`); a summary counts the rarities and new items. A skin's card here,
   like the odds list's, shows its snail live.
7. **Buttons.** Open again (the same pack in the same currency; hidden for VIP's daily crate and hidden crates) and
   Continue, which brings the shop back.

Skip brings every reel in at once (`SKIP_SECONDS`). Quick open (the shop's toggle) opens the 3D crates without the tap
and faster (`STAGE_QUICK_*`), skips their rattle sound, and shortens the intro, the rolls (`QUICK_*`) and the golden
reel. Closing the widget ends an opening at once.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `COUNTS` | `{ 1, 3, 10 }` | Pack sizes the server accepts, one buy button each (`U_BuyX<count>`) |
| `SHINY_COPIES` | `10` | Copies that make an item shiny |
| `PAID_CURRENCIES` | `{ "Diamonds" }` | Currencies bought with Robux: rolls with them are paid random items |
| `VIP_CRATE`, `VIP_ODDS` | `"Skin"`, `"Coins"` | VIP's free daily crate, and which odds it rolls |
| `TUTORIAL_CRATE` | `"Tutorial"` | The hidden crate the tutorial gives once |
| `INTRO_TWEENINFO`, `QUICK_INTRO_TWEENINFO` | 0.56 s, 0.26 s | The shop making way |
| `STAGE_LAYOUTS` | 1, 3 and 10 (`Crates_StageLayout`) | Where the 3D crates stand by pack size (studs; the camera looks along +Z at their fronts), their scale and turn, the camera and the point it looks at |
| `STAGE_FOV`, `STAGE_ASPECT` | `26`, 16 / 9 | The stage camera's field of view, and the screen shape the layouts are framed for (a narrower screen backs the camera off) |
| `STAGE_DROP_SECONDS`, `STAGE_QUICK_DROP_SECONDS`, `STAGE_DROP_HEIGHT`, `STAGE_DROP_GAP` | `0.62`, `0.36`, `9`, `{ [1] = 0, [3] = 0.11, [10] = 0.055 }` | A crate's drop, with Quick open, from how high, and how much later each next one drops |
| `STAGE_RATTLE_SECONDS`, `STAGE_HATCH_SECONDS`, `STAGE_WALL_SECONDS`, `STAGE_SWELL_SECONDS` | `0.52`, `0.3`, `0.38`, `0.24` | The opening's steps: the rattle, the hatches, the walls, the light's swell |
| `STAGE_OPEN_GAP`, `STAGE_QUICK_SPEED` | `{ [1] = 0, [3] = 0.12, [10] = 0.06 }`, `0.55` | How much later each next crate opens, and Quick open's share of the opening's time |
| `STAGE_HATCH_DEGREES`, `STAGE_WALL_DEGREES`, `STAGE_SWELL` | `129`, `93`, `{ [1] = 1.8, [3] = 1, [10] = 0.5 }` | How far the hatches and walls swing, and how much the light swells by pack size |
| `STAGE_GOLD_AMBIENT`, `STAGE_GOLD_LIGHT` | warm gold, pale gold | The golden crate's viewport light |
| `STAGE_LIGHT_COUNT` | `10` | From this many crates the stage runs light: no balls of light (the stage's glow swells instead), and one set of effects for the pack, from the front crate |
| `ROLL_SECONDS`, `ROLL_STAGGER` | `{ [1] = 6, [2] = 5, [3] = 5, [10] = 3.9 }`, `{ 0, 0.62, 0.62, 0.28 }` | How long the reels roll by pack size, and how much later each next one stops |
| `QUICK_ROLL_SECONDS`, `QUICK_ROLL_STAGGER` | `{ 1.7, 1.3, 1.3, 1.1 }`, `{ 0, 0.23, 0.23, 0.095 }` | The same while Quick open is on |
| `ROLL_CURVE` | `{ 0.075, 0.82, 0.165, 1 }` | The reels' cubic bezier (CS2's) |
| `LAND_SPREAD` | `0.1` to `0.9` | Where across the winning card the line stops |
| `STRIP_CARDS`, `WIN_CARD`, `COLUMN_CARDS`, `COLUMN_WIN_CARD` | `38`, `33`, `26`, `4` | Cards on a band and a column, and the winner's place |
| `BAND_HEIGHT`, `BAND_Y` | `{ 300, 228, 228 }`, `{ { 480 }, { 414, 666 }, { 314, 566, 818 } }` | Band heights and middles, in pixels of a 1920 × 1080 screen |
| `COLUMN_SIZE`, `COLUMN_GAP`, `COLUMN_Y` | 150 × 660, `12`, `540` | The ten-pack's columns |
| `CARD_FILL`, `COLUMN_CARD_FILL`, `CARD_ASPECT`, `CARD_GAP` | `0.7`, `0.92`, `1.1169`, `0.08` | A card's size in its band or column, its shape, and the gap between cards |
| `CARD_NAME_TEXT` | `0.1` | The tallest a reel card's name gets, as a share of the card's height: short names stay this size, long ones wrap and shrink |
| `SKIN_PICTURES` | ten image ids, by snail model | The pictures a rolling reel's cards show for the skins' snails (`art/skins` → Pictures); a snail missing here keeps its item picture there |
| `SKIN_REDRAW_FRAMES` | `2` | Frames a card with a live snail holds still where it's seen before its snail is drawn again |
| `LENS_WIDTH`, `LENS_ZOOM`, `LENS_DIM` | `1.5`, `1.06`, `0.45` | The one-crate reel's lens: width in cards, zoom, and the dim beside it |
| `TICK_GAP`, `TICK_PITCH` | `0.042`, `0.975` to `1.035` | Fewest seconds between ticks, and their pitch spread |
| `SKIP_SECONDS`, `SETTLE_DELAY`, `SETTLE_SECONDS` | `0.38`, `0.24`, `0.38` | A skip, and the glide onto the card's centre |
| `TEASE_FROM_RARITY`, `TEASE_SECONDS`, `TEASE_BEATS` | `"Epic"`, `2.6`, seven beats | The heartbeat before a rare result lands |
| `GOLDEN_SECONDS`, `QUICK_GOLDEN_SECONDS` | `3.2`, `1.5` | The golden reel |
| `MARKER_COLOR`, `PREMIUM_MARKER_COLOR`, `GOLDEN_BAND_COLOR`, `GOLDEN_LINE_COLOR` | gold, pale gold, dark amber, gold | The line, the premium crate's line, the golden reel's band and lines |
| `LEGENDARY_DROPS` | Black hole, Variety, Skeleton, Low gravity | Each legendary's own drop, by item id |
| `REVEAL_RAYS` | Common `1` to Legendary `0.4` | The reveal rays' transparency by rarity |
| `TRIO_CARD_WIDTH`, `TRIO_Y`, `TRIO_SPACING` | `380`, `420`, `450` | The 3-pack's row of cards |
| `TEN_CARD_WIDTH`, `TEN_ROWS_Y`, `TEN_SPACING` | `228`, `{ 268, 588 }`, `300` | The 10-pack's grid |
| `TRIO_STEP`, `TEN_STEP`, `PACK_LEGENDARY_HOLD` | `0.42`, `0.11`, `2.2` | Seconds between naming a pack's cards, and a pack legendary's moment |
| `FX_TEXTURES` | eight image ids | The effects' pictures: spark, star, glow, ring, coin, smiley, bone, bubble |
| `CONFETTI_COLORS`, `VORTEX_COLORS` | seven, three colours | The variety grenade's confetti and the black hole's swirl |
| `DISK_GRID`, `DISK_FRAME`, `DISK_FPS` | 4 × 8, 256 × 128, `18` | The black hole disk's flipbook |
| `RAYS_SPIN_SECONDS`, `HALO_SPIN_SECONDS`, `BOB_SECONDS`, `BOB_HEIGHT` | `46`, `26`, `3.2`, `0.012` | The showcase's turning rays and halo, and the crate's bob |
| `SHOWCASE_CAMERA`, `SHOWCASE_FOCUS`, `SHOWCASE_FOV` | (0, 5.2, −10.8), (0, 1.25, 0), `26` | The pedestal crate's camera (studs, looking along +Z at its front) and field of view |
| `SHOWCASE_YAW`, `SHOWCASE_SWAY`, `SHOWCASE_SWAY_SECONDS` | `-0.45`, `0.4`, `7` | The pedestal crate's turn (radians), and how far and how slowly it sways either side of it |
| `SHOWCASE_LIFT_TWEENINFO` | 0.32 s, Quad In | The pedestal crate leaping off when a crate is bought |
| `BACKDROP_PREMIUM_COLOR`, `BACKDROP_PREMIUM_TRANSPARENCY`, `BACKDROP_LIGHT_TRANSPARENCY` | violet, `0.35`, `0.45` | The premium crate's backdrop and light |
| `BACKDROP_OPEN_COLOR`, `BACKDROP_OPEN_TRANSPARENCY`, `BACKDROP_TWEENINFO` | near black, `0.12`, 0.6 s | The dim while a crate opens |
| `GUI_NAME` | `"Crates"` | The widget it drives |
| `PAY_CURRENCIES` | `{ "Coins", "Diamonds" }` | The currencies crates are paid in, one balance chip each (`U_Pay<currency>`); a crate pays in the first it takes until another is picked |
| `PRICE_FREE` | `"FREE"` | The x1 price while VIP's daily crate is free |
| `LOBBY_GUI_NAME`, `BADGE_FREE`, `BADGE_MAX` | `"Lobby"`, `"FREE"`, `9` | The gui with the corner menu, and the badge on its Weapons button: `BADGE_FREE` while a free crate waits, else how many crates the coins open, `9+` past `BADGE_MAX` |

## Sounds

Played by name from `SoundsList.lua` (its Crates category), in the `SFX` group: `Crate_Shake` (the 3D crates' rattle),
`Crate_Unlock` (their hatches),
`Crate_Spin`, `Crate_Tick`, `Crate_Land` (also the flash out of the 3D crates), `Crate_Settle` (also a 3D crate
landing), `Crate_Tease`, `Crate_GoldHit` (the gold card, and the golden crate landing), `Crate_Premium` (the premium
crate stepping onto the pedestal), `Card_Flip`, `Results_Open`, `Reveal_<Rarity>` (Common to Legendary),
`Reveal_Shiny`, and the drops' `Legend_BlackHole`, `Legend_Variety`, `Legend_Skeleton`, `Legend_LowGravity`. They come
from `art/sfx/make_crates.py` (the sound kit's README). The tap that opens the 3D crates plays `Button_Click` (`UI`
group).

## In the place

Drives the `Crates` widget, which WidgetManager opens. The shop: `U_Tabs` › `PREFAB | CrateTab`, `U_PayCoins` /
`U_PayDiamonds`, `U_Center` (the showcase: `U_Crate`, a ViewportFrame for the 3D crate, `S_Glow`, `S_Rays`, `S_Beam`, `S_Halo`, `S_Pedestal`,
`S_PedestalRing`, `S_Particles`, `S_Tier`, `S_Plate`), `U_BuyX1`, `U_BuyX3`, `U_BuyX10`, `U_Quick`, `U_Odds` ›
`PREFAB | RaritySection` › `PREFAB | OddsItem`, and `U_Backdrop`. The 3D crates: `U_Stage` (`S_Glow`, `S_Rays`,
`S_Viewport`, `S_Tap` › `S_TapScale`, `S_TapSub`, and the full-screen tap `S_Hit`). The opening: `U_Open` (`S_Swallow`, the UIScale the black hole shrinks it with, `S_Title`, `U_Reels` with
`PREFAB | Band`, `PREFAB | Column` and `PREFAB | Card`, the letterbox bars, `U_Skip`) and `U_Result` (`S_FxBack`,
`S_FxFront`, `S_Tint`, `S_Flash`, the black hole's `S_Disk` and `S_Core`, the big card `U_Single`, the pack's
`U_Cards` › `PREFAB | ResultInfo`, `U_Summary` › `PREFAB | SummaryChip`, `U_Buttons` › `U_Again`, `U_Continue`). The
gui's README lists every element, prefab and `Look_*` attribute.

The `Lobby` gui's corner menu opens it: `U_Menu` › `S_Weapons` and `S_Skins` (each with a `Crates_CrateId` attribute,
`"Weapon"` and `"Skin"`) select that crate's tab, then `I.WidgetManager.Open("Crates")`. The badge on Weapons
(`U_Menu` › `S_Badge` › `S_Count`) reads FREE while the tutorial crate or VIP's daily crate waits, else how many of
the cheapest coin crate the player's coins open (`9+` past 9, hidden at none), redrawn on `Currency_Changed`. The old
`CrateOpen` and `CrateOdds` guis are no longer used.

The 3D crates are `PREFAB | Crate_Weapon`, `_Premium`, `_Utility`, `_Skin` and `_Starter` in
`Workspace.Ume.ReplicatedStorage_Assets.Crates` (read at runtime from `I.Dirs.Assets.Crates`). Each is a Model of eight
MeshParts (`Base`, `Inner`, `Front`, `Back`, `Left`, `Right`, `HatchL`, `HatchR`, `PrimaryPart` `Base`) with its
crate's baked texture (`Inner` is Neon, coloured at runtime), anchored, with no collision, queries, touches or shadow,
and its pivot in the middle of its floor. Stage3D and Showcase put the models in a WorldModel they make in their
viewport (`S_Viewport`, `U_Crate`), beside its Camera: a part moved straight in a ViewportFrame redraws every mesh in
it. Stage3D turns the walls on their bottom edges and the hatches on the side walls' top edges (`HINGES` in the handler: the models' measurements, which change only with new models).

The skins' snails are the Cosmetics skins' models in `Assets/Skins` (`I.Dirs.Assets.Skins`), named by each skin row's
`Model`; a skin whose model isn't there (FBI Agent, Prisoner, VIP, Wizard) keeps its item picture. `PREFAB | Card` and
`PREFAB | OddsItem` each have an `S_Model` ViewportFrame over the picture's place, lit like the cards, which
`SkinModels` fills; a reel card leaves it hidden and shows the picture in `S_Icon`.
