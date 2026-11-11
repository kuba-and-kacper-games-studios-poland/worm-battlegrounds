"""The bots' avatar pictures: voxel snail headshots in the game's snail look (its pink voxel body, big white eyes with
block pupils, thin eyestalks threaded with dark beads, purple spots, a tan shell with a brown swirl), each bot a
personality of its own: its own colour and something to wear. Rendered like a Roblox avatar headshot (head and
shoulders, three-quarter, transparent background).

Run inside Blender 5 (the MCP's code tool: load this file and call render_all(out_dir)), or
`blender --background --python make_bot_heads.py -- <out dir>`. Writes <out>/Bot_<Name>.png (512 x 512).
"""

import math
import os
import sys

import bmesh
import bpy
from mathutils import Vector

V = 0.07  # voxel size: about the game's snail's
BOUNDS = ((-1.45, 1.45), (-1.25, 2.4), (-0.75, 4.15))

INK = "#1b1530"


def rgb(h):
    h = h.lstrip("#")
    srgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb)


def lerp(a, b, t):
    return tuple(x + (y - x) * t for x, y in zip(a, b))


def noise(x, y, z, s=1.0):
    """Cheap repeatable value noise for camo and fur patches."""
    v = math.sin(x * 12.9898 * s + y * 78.233 * s + z * 37.719 * s) * 43758.5453
    return v - math.floor(v)


def blob(x, y, z, s=2.2):
    return (math.sin(x * s * 3.1 + 1.3) + math.sin(y * s * 2.3 + z * s * 1.7) + math.sin(z * s * 2.9 + x * s * 1.1)) / 3


# ------------------------------------------------------------------------------------------------- the snail


def in_ellipsoid(p, c, r):
    return sum(((p[i] - c[i]) / r[i]) ** 2 for i in range(3)) <= 1.0


def snail_body(p):
    """The head and neck: a column that narrows a little to a domed top, its foot curving back at the bottom."""
    x, y, z = p
    if z < -0.7 or z > 3.2:
        return False
    top = 2.45
    if z > top:
        return in_ellipsoid(p, (0, 0.02, top), (0.7, 0.66, 0.55))
    k = (z + 0.7) / (top + 0.7)
    rx = 0.86 - 0.16 * k
    ry = 0.8 - 0.14 * k
    yc = 0.18 * (1 - k) ** 2
    return (x / rx) ** 2 + ((y - yc) / ry) ** 2 <= 1.0


EYES = [(-0.31, 1.98), (0.31, 1.98)]  # x, z of each eye's centre
EYE_R = (0.26, 0.35)


def eye_bulge(p):
    x, y, z = p
    for ex, ez in EYES:
        if in_ellipsoid(p, (ex, -0.6, ez), (EYE_R[0], 0.2, EYE_R[1])):
            return True
    return False


def eye_colour(p):
    """White eyes with block pupils near their inner edge, looking a little to the front-left."""
    x, y, z = p
    for side, (ex, ez) in zip((-1, 1), EYES):
        if ((x - ex) / EYE_R[0]) ** 2 + ((z - ez) / EYE_R[1]) ** 2 <= 1.02 and y < -0.42:
            px = ex + 0.06 * -side - 0.03
            if abs(x - px) < 0.085 and abs(z - (ez - 0.04)) < 0.17:
                return INK
            return "#ffffff"
    return None


def shell(p):
    """The shell behind the head, its swirl on its side."""
    c = (0.0, 1.35, 1.6)
    return in_ellipsoid(p, c, (0.62, 1.1, 1.1))


def shell_colour(p):
    y, z = p[1] - 1.35, p[2] - 1.6
    r = math.hypot(y, z)
    a = math.atan2(z, y)
    band = (r - 0.17 * (a + math.pi)) % 0.34
    return "#9a5b2c" if band < 0.09 and r > 0.12 else "#f1d29a"


def stalk_points(side, top=3.75):
    a = Vector((side * 0.2, -0.08, 2.72))
    b = Vector((side * 0.46, -0.16, top))
    return a, b


def in_stalk(p, side, top=3.75, r=0.075):
    a, b = stalk_points(side, top)
    q = Vector(p)
    ab = b - a
    t = max(0.0, min(1.0, (q - a).dot(ab) / ab.length_squared))
    return (q - (a + ab * t)).length <= r


# --------------------------------------------------------------------------------------------- personalities
# Each returns (colour or None) for a point: an accessory voxel, or None to leave the snail as it is. `solid` adds
# voxels outside the snail.


def glasses(p):
    x, y, z = p
    for ex, ez in EYES:
        d = math.hypot((x - ex) / 1.0, (z - ez) / 1.12)
        if 0.3 <= d <= 0.39 and -0.9 <= y <= -0.74:
            return INK
    if abs(x) <= 0.07 and abs(z - 2.0) <= 0.035 and -0.88 <= y <= -0.74:
        return INK
    if 0.62 <= abs(x) <= 0.72 and abs(z - 2.02) <= 0.04 and -0.78 <= y <= 0.35:
        return INK
    return None


def helmet(p):
    x, y, z = p
    if z >= 2.2 and in_ellipsoid(p, (0, 0.0, 2.42), (0.86, 0.82, 0.74)):
        base = "#5f6f2e"
        b = blob(x, y, z, 2.6)
        return "#3f4a1d" if b > 0.32 else "#7c8a3f" if b < -0.4 else base
    if 2.18 <= z <= 2.3 and (x / 0.98) ** 2 + (y / 0.94) ** 2 <= 1.0:
        return "#4d5a24"
    if 0.66 <= abs(x) <= 0.76 and 1.45 <= z <= 2.2 and -0.1 <= y <= 0.1:
        return "#2f2a20"
    return None


def shades(p):
    x, y, z = p
    if 0.06 <= abs(x) <= 0.62 and 1.8 <= z <= 2.12 and -0.92 <= y <= -0.76:
        # a white glint across each lens
        u = (abs(x) - 0.06) / 0.56
        w = (z - 1.8) / 0.32
        if 0.06 < (u + w) % 1.0 < 0.16 and x < 0:
            return "#d9f3ff"
        return INK
    if abs(x) <= 0.07 and 1.96 <= z <= 2.06 and -0.9 <= y <= -0.76:
        return INK
    if 0.6 <= abs(x) <= 0.7 and abs(z - 2.02) <= 0.04 and -0.8 <= y <= 0.35:
        return INK
    # a cap worn backwards: the crown on the head, the peak out behind
    if z >= 2.4 and in_ellipsoid(p, (0, 0.04, 2.5), (0.76, 0.72, 0.5)):
        return "#ffffff" if abs(x) < 0.05 else "#e8413b"
    if 2.42 <= z <= 2.52 and 0.3 <= y <= 1.25 and abs(x) <= 0.52 - (y - 0.3) * 0.15:
        return "#c62f2a"
    return None


def pirate(p):
    x, y, z = p
    if z >= 2.25 and in_ellipsoid(p, (0, 0.02, 2.45), (0.76, 0.72, 0.62)):
        if noise(round(x / 0.21), round(y / 0.21), round(z / 0.21)) > 0.82:
            return "#ffffff"
        return "#d42b33"
    # the knot and its tails at the back
    if in_ellipsoid(p, (0.42, 0.62, 2.35), (0.16, 0.16, 0.14)):
        return "#b4232b"
    for tz, ty in ((2.12, 0.86), (1.96, 0.98)):
        if abs(z - tz) <= 0.05 and abs(y - ty) <= 0.12 and 0.38 <= x <= 0.56:
            return "#b4232b"
    # the eyepatch over the left eye and its strap
    ex, ez = EYES[0]
    if ((x - ex) / 0.24) ** 2 + ((z - ez) / 0.3) ** 2 <= 1 and -0.86 <= y <= -0.7:
        return INK
    # the strap: on the head's surface only, from the patch up and over to the right
    on_skin = snail_body(p) and not snail_body((x * 1.12, y * 1.12, z))
    if on_skin and abs((z - 2.32) - (x - ex) * 0.55) <= 0.05 and z > ez + 0.2:
        return INK
    return None


def cowboy(p):
    x, y, z = p
    # the crown, pinched in front, with its band
    if 2.6 <= z <= 3.2 and (x / 0.6) ** 2 + ((y - 0.05) / 0.56) ** 2 <= 1.0:
        if z > 3.08 and abs(x) < 0.12:
            return None
        return "#3b2414" if z <= 2.72 else "#8a5426"
    # the brim, curling up at the sides
    lift = 0.32 * (abs(x) / 1.3) ** 3
    if abs(z - (2.58 + lift)) <= 0.05 and (x / 1.32) ** 2 + ((y - 0.05) / 1.1) ** 2 <= 1.0:
        return "#7a4a21"
    # the neckerchief and its knot in front
    if 0.85 <= z <= 1.18 and snail_body((x * 0.9, y * 0.9, z)) is False and snail_body((x * 0.82, y * 0.82, z)):
        return "#d8382f"
    if -1.0 <= y <= -0.72 and z <= 1.02 and z >= 0.55 and abs(x) <= (z - 0.55) * 0.55:
        return "#d8382f"
    return None


def ninja(p):
    x, y, z = p
    slit = 1.66 <= z <= 2.32
    inside = snail_body(p) or eye_bulge(p)
    if not slit and inside and z > 0.7:
        return "#24212e"
    # the headband over the slit, its tails flying out behind
    if 2.32 <= z <= 2.46 and snail_body((x * 0.93, y * 0.93, z)) is False and snail_body((x * 0.86, y * 0.86, z)):
        return "#d42b33"
    for tz, ty0 in ((2.42, 0.6), (2.28, 0.72)):
        if abs(z - tz) <= 0.05 and ty0 <= y <= ty0 + 0.55 and 0.5 <= x <= 0.6 + (y - ty0) * 0.5:
            return "#d42b33"
    return None


def king(p):
    x, y, z = p
    # the crown: a gold band with five tall points, each tipped with a ball, and red jewels on the band
    r = math.hypot(x / 0.66, (y - 0.02) / 0.62)
    a = math.atan2(y, x)
    if 0.78 <= r <= 1.0 and 2.62 <= z <= 2.9:
        if abs(z - 2.76) <= 0.07 and abs(((a / (2 * math.pi) * 5) % 1) - 0.5) <= 0.12:
            return "#e8373f"
        return "#f6c429" if z > 2.68 else "#c9951a"
    if 0.76 <= r <= 0.98 and 2.9 < z <= 3.38:
        tip = 1 - abs(((a / (2 * math.pi) * 5 + 0.5) % 1) - 0.5) * 2
        if z - 2.9 <= tip * 0.48:
            return "#ffe06a" if z > 3.15 else "#f6c429"
    # an ermine collar on the shoulders
    if 0.55 <= z <= 0.95 and snail_body((x * 0.86, y * 0.86, z)) is False and snail_body((x * 0.74, y * 0.74, z)):
        return INK if noise(round(x / 0.14), round(y / 0.14), round(z / 0.14)) > 0.9 else "#fbf6ee"
    return None


def viking(p):
    x, y, z = p
    if z >= 2.3 and in_ellipsoid(p, (0, 0.02, 2.42), (0.82, 0.78, 0.72)):
        if abs(x) <= 0.07 or abs(z - 2.36) <= 0.05:
            return "#c6a24a"
        return "#9aa3ae"
    # the horns, curving up and out
    for side in (-1, 1):
        for t in [i / 14 for i in range(15)]:
            cx = side * (0.72 + 0.5 * t)
            cz = 2.62 + 0.75 * t ** 1.6
            rr = 0.15 * (1 - t) + 0.04
            if (x - cx) ** 2 + y ** 2 + (z - cz) ** 2 <= rr * rr:
                return "#f4ecd2" if t < 0.75 else "#d9cfae"
    # a big orange beard under the eyes
    if y <= -0.35 and 0.55 <= z <= 1.62 and (x / 0.66) ** 2 + ((z - 1.18) / 0.6) ** 2 <= 1.0:
        if in_ellipsoid(p, (0, -0.55, 1.15), (0.68, 0.42, 0.62)):
            if abs(x) <= 0.2 and 1.42 <= z <= 1.52:
                return "#7c2f16"
            return "#e4772a" if noise(round(x / 0.07), round(y / 0.07), round(z / 0.07)) > 0.3 else "#c95d1c"
    return None


def bare(_p):
    return None


BOTS = {
    # name: (snail colour, its spots, accessory, mouth). The game shows Default for every bot (the owner, 2026-11-11);
    # the personalities wait for the rare bots, which get their own skins and avatars
    "Default": ("#f6a6d6", "#9b4fd0", bare, "smile"),
    "Brainy": ("#f6a6d6", "#9b4fd0", glasses, "smile"),
    "Sarge": ("#f7b26a", "#b4612b", helmet, "flat"),
    "Shades": ("#79b9ff", "#3d63c9", shades, "grin"),
    "Captain": ("#ffd65e", "#d18a1a", pirate, "grin"),
    "Tex": ("#8de3b8", "#2f9a6c", cowboy, "smile"),
    "Shadow": ("#b48aff", "#6a3fc4", ninja, None),
    "King": ("#ff9fc4", "#c93f86", king, "smile"),
    "Viking": ("#b5e271", "#5f9a28", viking, None),
}


def mouth(p, kind):
    x, y, z = p
    if not kind or y > -0.5:
        return None
    if kind == "smile" and abs(x) <= 0.28 and abs(z - (1.42 + 1.3 * x * x)) <= 0.045:
        return INK
    if kind == "grin" and abs(x) <= 0.3:
        top = 1.52 + 0.6 * x * x
        if top - 0.16 + 0.9 * x * x <= z <= top:
            return "#ffffff" if z > top - 0.06 else "#7d1f3d"
    if kind == "flat" and abs(x) <= 0.2 and abs(z - 1.48 - 0.25 * x) <= 0.04:
        return INK
    return None


# -------------------------------------------------------------------------------------------------- building


def voxelize(name):
    body_col, spot_col, accessory, mouth_kind = BOTS[name]
    nx = int((BOUNDS[0][1] - BOUNDS[0][0]) / V)
    ny = int((BOUNDS[1][1] - BOUNDS[1][0]) / V)
    nz = int((BOUNDS[2][1] - BOUNDS[2][0]) / V)
    grid = {}
    no_stalks = name in ("Sarge", "Shadow", "Viking")
    stalk_top = 3.75 if name not in ("Tex", "King") else 3.85
    for i in range(nx):
        x = BOUNDS[0][0] + (i + 0.5) * V
        for j in range(ny):
            y = BOUNDS[1][0] + (j + 0.5) * V
            for k in range(nz):
                z = BOUNDS[2][0] + (k + 0.5) * V
                p = (x, y, z)
                col = accessory(p)
                if col is not None:
                    grid[(i, j, k)] = col
                    continue
                if snail_body(p) or eye_bulge(p):
                    c = eye_colour(p) or mouth(p, mouth_kind) or body_col
                    grid[(i, j, k)] = c
                elif not no_stalks and (in_stalk(p, -1, stalk_top) or in_stalk(p, 1, stalk_top)):
                    grid[(i, j, k)] = body_col
                elif shell(p):
                    grid[(i, j, k)] = shell_colour(p)
    return grid


def build_mesh(name, grid, collection):
    """Only the voxels' outer faces, each with its own UVs (one voxel tile) and colour."""
    bm = bmesh.new()
    col_layer = bm.loops.layers.color.new("Col")
    uv = bm.loops.layers.uv.new("UVMap")
    dirs = [((1, 0, 0), [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)]),
            ((-1, 0, 0), [(0, 1, 0), (0, 0, 0), (0, 0, 1), (0, 1, 1)]),
            ((0, 1, 0), [(1, 1, 0), (0, 1, 0), (0, 1, 1), (1, 1, 1)]),
            ((0, -1, 0), [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)]),
            ((0, 0, 1), [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)]),
            ((0, 0, -1), [(0, 1, 0), (1, 1, 0), (1, 0, 0), (0, 0, 0)])]
    cache = {}
    for (i, j, k), hexc in grid.items():
        c = cache.get(hexc) or cache.setdefault(hexc, (*rgb(hexc), 1.0))
        ox = BOUNDS[0][0] + i * V
        oy = BOUNDS[1][0] + j * V
        oz = BOUNDS[2][0] + k * V
        for (dx, dy, dz), corners in dirs:
            if (i + dx, j + dy, k + dz) in grid:
                continue
            verts = [bm.verts.new((ox + a * V, oy + b * V, oz + cc * V)) for a, b, cc in corners]
            f = bm.faces.new(verts)
            for loop, (u, w) in zip(f.loops, ((0, 0), (1, 0), (1, 1), (0, 1))):
                loop[col_layer] = c
                loop[uv].uv = (u, w)
    mesh = bpy.data.meshes.new(f"Bot_{name}")
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(f"Bot_{name}", mesh)
    collection.objects.link(obj)
    obj.data.materials.append(voxel_material())
    return obj


def tile_image():
    """One voxel's face: a soft light rim at the top left and a darker one at the bottom right, as the game's voxels."""
    path = os.path.join(bpy.app.tempdir, "wb_voxel_tile.png")
    old = bpy.data.images.get("WB_VoxelTile")
    if old:
        return old
    img = bpy.data.images.new("WB_VoxelTile_gen", 32, 32, alpha=False)
    px = []
    for yy in range(32):
        for xx in range(32):
            v = 0.93
            if xx <= 2 or yy >= 29:
                v = 1.0
            if xx >= 29 or yy <= 2:
                v = 0.8
            px += [v, v, v, 1.0]
    img.pixels[:] = px
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)
    img = bpy.data.images.load(path)
    img.name = "WB_VoxelTile"
    return img


def voxel_material():
    mat = bpy.data.materials.get("WB_Voxel")
    if mat:
        return mat
    mat = bpy.data.materials.new("WB_Voxel")
    if hasattr(mat, "use_nodes") and not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    attr = nt.nodes.new("ShaderNodeVertexColor")
    attr.layer_name = "Col"
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = tile_image()
    tex.interpolation = "Closest"
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0
    nt.links.new(attr.outputs["Color"], mix.inputs[6])
    nt.links.new(tex.outputs["Color"], mix.inputs[7])
    nt.links.new(mix.outputs[2], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.55
    return mat


def glossy(name, hexc, rough=0.25):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    if hasattr(mat, "use_nodes") and not mat.use_nodes:
        mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (*rgb(hexc), 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    return mat


def add_sphere(collection, loc, r, mat):
    mesh = bpy.data.meshes.new("Bead")
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=r)
    bm.to_mesh(mesh)
    bm.free()
    for poly in mesh.polygons:
        poly.use_smooth = True
    obj = bpy.data.objects.new("Bead", mesh)
    obj.location = loc
    obj.data.materials.append(mat)
    collection.objects.link(obj)


def build_bot(name, collection):
    grid = voxelize(name)
    build_mesh(name, grid, collection)
    body_col, spot_col, _acc, _m = BOTS[name]
    # beads on the eyestalks and spots on the body: the game's snail has round ones
    if name not in ("Sarge", "Shadow", "Viking"):
        top = 3.75 if name not in ("Tex", "King") else 3.85
        bead = glossy("WB_Bead", "#2a2378")
        for side in (-1, 1):
            a, b = stalk_points(side, top)
            for t in (0.25, 0.5, 0.75, 0.98):
                add_sphere(collection, a + (b - a) * t + Vector((0, -0.02, 0)), 0.1, bead)
    spot = glossy(f"WB_Spot_{name}", spot_col, 0.35)
    for sx, sz in ((-0.62, 1.05), (0.48, 0.62), (-0.3, 0.3), (0.66, 1.35)):
        if name == "Shadow" and sz > 0.7:
            continue
        if name == "Viking" and abs(sx) < 0.6 and sz > 0.5:
            continue
        y = -math.sqrt(max(0.0, 1 - (sx / 0.8) ** 2)) * 0.74
        add_sphere(collection, (sx, y, sz), 0.085, spot)


# ------------------------------------------------------------------------------------------------- rendering


def setup_scene():
    scene = bpy.context.scene
    try:
        scene.render.engine = "BLENDER_EEVEE"
    except TypeError:
        scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = scene.render.resolution_y = 512
    scene.render.film_transparent = True
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    world = scene.world or bpy.data.worlds.new("World")
    scene.world = world
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs[0].default_value = (0.55, 0.58, 0.66, 1)
    bg.inputs[1].default_value = 0.9
    cam = bpy.data.objects.get("BotCam") or bpy.data.objects.new("BotCam", bpy.data.cameras.new("BotCam"))
    if cam.name not in scene.collection.objects:
        scene.collection.objects.link(cam)
    cam.data.lens = 74
    target = Vector((0.18, 0.25, 2.22))
    cam.location = Vector((-3.6, -8.7, 3.05))
    cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    for lname, energy, rot, colour in (("BotKey", 3.2, (52, 0, -38), (1, 0.97, 0.92)),
                                       ("BotRim", 2.4, (60, 0, 150), (0.85, 0.9, 1.0)),
                                       ("BotFill", 0.8, (75, 0, 25), (1, 1, 1))):
        light = bpy.data.objects.get(lname) or bpy.data.objects.new(lname, bpy.data.lights.new(lname, "SUN"))
        if light.name not in scene.collection.objects:
            scene.collection.objects.link(light)
        light.data.energy = energy
        light.data.color = colour
        light.rotation_euler = tuple(math.radians(a) for a in rot)
    return scene


def render_all(out_dir, names=None):
    os.makedirs(out_dir, exist_ok=True)
    scene = setup_scene()
    col = bpy.data.collections.get("BotHeads")
    if not col:
        col = bpy.data.collections.new("BotHeads")
        scene.collection.children.link(col)
    others = [c for c in scene.collection.children if c.name != "BotHeads"]
    hidden = {c.name: c.hide_render for c in others}
    for c in others:
        c.hide_render = True
    done = []
    for name in names or list(BOTS):
        for obj in list(col.objects):
            bpy.data.objects.remove(obj, do_unlink=True)
        build_bot(name, col)
        scene.render.filepath = os.path.join(out_dir, f"Bot_{name}.png")
        bpy.ops.render.render(write_still=True)
        done.append(name)
    for c in others:
        c.hide_render = hidden[c.name]
    return done


if __name__ == "__main__":
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    print(render_all(argv[0] if argv else os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")))
