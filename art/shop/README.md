# Shop pictures

Pictures for the shop's cards that the owner made or approved.

| Picture | What | Uploaded |
| --- | --- | --- |
| `2x_diamond.png` | The Double Diamonds pass card (1000 × 1000, transparent): two diamonds and a studded 2X, the owner's (2026-11-25) | Decal 110197305865795, image `rbxassetid://122604385822529`, The Snail Studio group (566704940), approved; Shop's `PASSES` |

## Uploading

Only when the owner says so: copy the picture into `../sfx/out/upload/<date>-<name>/` (Studio's approved Open Cloud
folder) with its fully see-through pixels turned black (the ink outline's colour, so no white halo shows at its edge),
upload it as a Decal to The Snail Studio group, then read its image id in Studio (`InsertService:LoadAsset(decal)`, the
Decal's `Texture`) and put that in the setting that draws it.
