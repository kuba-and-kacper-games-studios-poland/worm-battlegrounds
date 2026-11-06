# TextCase

Keeps the GUI kit's capitals. The kit's capitals styles (`Heading`, `Title` and `Hero` labels, buttons, box and window
titles) upper-case their text only when the gui is built, so text game code writes later used to stay in mixed case
("Your turn in 3 turns" under "YOUR TURN!"). The `WormBattlegroundsBrawl` theme tags every such text
`TextCase_Upper`, exports keep the tag, and this module's component puts whatever is written there in capitals: the
words only, never the rich-text tags (`<font color="#ff6363">`), with escapes like `&lt;` kept.

| | |
| --- | --- |
| Folder | `src/modules/Utils/TextCase` |
| Runs on | Client |
| Exposes | Nothing |
| Uses | `I.Component` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Registers `TextCase_Upper` |
| `Components/Upper.lua` | `TextCase_Upper`: on a TextLabel, writes its text in capitals now and whenever it changes |

## Components

| Tag | On | What |
| --- | --- | --- |
| `TextCase_Upper` | TextLabel | Its text in capitals. Skips the exported templates (`ReplicatedStorage`, `StarterGui`); live copies and clones build |

## Network

No remotes or Topics.
