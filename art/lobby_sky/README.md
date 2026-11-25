# Lobby sky

A calm cartoon skybox for the lobby stage, so the snails stand out against it. It's a soft, slightly desaturated blue
sky, pale haze at the horizon and a clearer blue higher up, with a few puffy cartoon clouds low down, a far pale
range of snowy mountains and soft blue-green hills on the horizon. Below the horizon it fades into a flat pale mist,
which the stage's ground mostly hides. The horizon band goes all the way round, so the sky works whichever way the
camera faces.

Everything is drawn by `sky.py`. No images are downloaded.

## Build

```
python -I sky.py              # 1024 x 1024 faces, about 30 s
python -I sky.py --size 512   # quick draft
python -I sky.py --yaw 0      # point the preview at SkyboxFt instead of SkyboxBk
```

It writes to `out/`:

- `sky_ft.png`, `sky_bk.png`, `sky_lf.png`, `sky_rt.png`, `sky_up.png`, `sky_dn.png`: the six faces
- `preview_cross.png`: the faces unfolded as Roblox folds them
- `preview_view.png`: a 1600 x 900 view, 50° vertical field of view, pitched 5° down, looking toward +Z (the lobby
  stage camera's direction)

The sky is a function of view direction. Each face pixel is turned into its direction with the face's orientation
below, so the faces meet at their edges by construction. The script also compares the colour step across each of
the 12 cube edges with the step one pixel inside the faces, and prints the result. A ratio of about 1 means no seam.

The colours, mountains, hills and clouds are at the top of `sky.py` (`ZENITH`, `MID`, `HAZE`, the peak and cloud
lists in `build_world`).

## Face convention

Roblox's Sky, unfolded with every image upright as it is uploaded:

```
            Up
Lf  Bk  Rt  Ft
            Dn
```

Seen from inside, moving right along the strip turns you right. Up's bottom edge meets Rt's top edge, and Dn's top
edge meets Rt's bottom edge. Compared with the usual cubemap (px, nx, py, ny, pz, nz) this is px → Rt, nx → Lf,
pz → Bk, nz → Ft, py → Up turned 90° clockwise, ny → Dn turned 90° anticlockwise.

Sources: the DevForum threads "Mapping of the Roblox skybox" (the layout above) and "Custom skyboxes 101" (the
mapping and rotations). The two agree.

In `sky.py` Ft looks toward −Z, Lf toward +X, Bk toward +Z and Rt toward −X, with +Y up. The edges are right by
construction whatever the world axes. Checked in Studio on 2026-11-24: it reads right with the Sky's default
`SkyboxOrientation`.

## In the game

Since 2026-11-24 it is the lobby's sky: Lighting's own Sky, renamed `Lobby Sky`, with `CelestialBodiesShown` off. The
lobby's lighting preset is Lighting itself (`Lighting_Id` `Lobby`); the match presets in `Lighting.Presets` keep their
`Clear Sky`. The old Sky is in `ServerStorage.!dump`.

## Uploading

Nothing is uploaded until the owner approves the look. Then:

1. Upload the six faces to The Snail Studio group (566704940) as Decals/Images, through Open Cloud.
2. Set the lobby Sky's `SkyboxFt`, `SkyboxBk`, `SkyboxLf`, `SkyboxRt`, `SkyboxUp` and `SkyboxDn` to their ids, each
   face to its own property.
3. Look at it from the stage camera. If the mountains you want behind the snails are on another side, turn the
   Sky's `SkyboxOrientation` (Y) rather than repainting.

The 2026-11-24 set (the owner approved it; all six passed moderation, uploaded as Decals to the group):

| Face | Decal | Image id |
| --- | --- | --- |
| Ft | 98482051733700 | 108018160280554 |
| Bk | 79777643059758 | 133625916790072 |
| Lf | 140328674696769 | 70689795946418 |
| Rt | 99637182544741 | 139691351368902 |
| Up | 79094380953746 | 117300372109518 |
| Dn | 116447435939752 | 103856729202511 |
