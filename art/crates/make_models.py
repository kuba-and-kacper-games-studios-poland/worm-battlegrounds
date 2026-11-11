"""The crates as 3D models (Blender 5), for the 3D crate opening: the same five crates as make_icons.py (Weapon,
Premium, Utility, Skin, Starter) in the game's model look: chunky bevelled shapes, flat bright colours, the stud
pattern laid on by the game (not baked here).

Every crate is built from the same moving pieces, each its own object with its origin on its hinge:

    Crate (empty)
      Base                      the plinth
      Inner                     the glowing floor inside
      Front, Back               walls hinged at their bottom edge (they fall outward)
      Left  > HatchL            side walls hinged at their bottom edge; each carries the top hatch on its side,
      Right > HatchR            hinged at the wall's top edge (the hatches swing open first)

Units are studs (1 Blender metre = 1 stud), Z up, the front facing -Y. The crate is 4 wide, 3 deep, 3.05 tall.

Run inside Blender (MCP execute or `blender --python make_models.py -- <out dir>`): it rebuilds the scene's
`Crates` collection and, with an out dir, writes `<out>/Crate_<Name>.glb` and `<out>/crates.blend`.
"""

import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

W, D = 4.0, 3.0          # outer width (x) and depth (y)
BASE_H = 0.35            # plinth height
TOP = 2.75               # walls' top
T = 0.3                  # wall and hatch thickness
SEGMENTS = 2             # bevel steps on every edge (1 for the game's lighter meshes)
HX, HY = W / 2, D / 2

# --------------------------------------------------------------------------------------------------- materials

PALETTES = {
    "Weapon": {
        "Body": "#7cab3c", "Frame": "#4f7d27", "Metal": "#a7b0ba", "Rivet": "#d6dce3", "Emblem": "#f6c623",
        "Badge": "#3f6620", "Base": "#3b4652", "Dark": "#26301c",
    },
    "Premium": {
        "Body": "#22307a", "Frame": "#f2b630", "Metal": "#f7cf5c", "Rivet": "#fff1b8", "Emblem": "#7eeaff",
        "Badge": "#162058", "Base": "#141a44", "Dark": "#0e1333", "Stripe": "#56dcff", "Gem": "#ff4d6d",
    },
    "Utility": {
        "Body": "#2fb79a", "Frame": "#1f8a72", "Metal": "#e9f1ef", "Rivet": "#ffffff", "Emblem": "#f4f8f7",
        "Badge": "#1a6f5c", "Base": "#2a3640", "Dark": "#17312b", "Cross": "#e8393f", "Hazard": "#f5c518",
        "HazardDark": "#1d1d24", "Rib": "#45d1b0",
    },
    "Skin": {
        "Body": "#ff7cc9", "Frame": "#e0509d", "Metal": "#ffd24d", "Rivet": "#fff2b0", "Emblem": "#ffd84d",
        "Badge": "#ffb3e0", "Base": "#8f2f66", "Dark": "#6b2050", "Ribbon": "#ffc83a",
    },
    "Starter": {
        "Body": "#dca15c", "Frame": "#9a6430", "Metal": "#8e98a3", "Rivet": "#cfd6dd", "Emblem": "#8fd44b",
        "Badge": "#6f4520", "Base": "#5b3a1e", "Dark": "#3d2714",
    },
}

GLOW = "#ffe9a8"


def hex_color(h):
    h = h.lstrip("#")
    srgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb]
    return (*lin, 1.0)


def material(name, color, rough=0.55, emit=0.0):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    if hasattr(mat, "use_nodes") and not mat.use_nodes:
        mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = hex_color(color)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = 0.0
    if emit > 0:
        bsdf.inputs["Emission Color"].default_value = hex_color(color)
        bsdf.inputs["Emission Strength"].default_value = emit
    mat.diffuse_color = hex_color(color)
    return mat


# ----------------------------------------------------------------------------------------------------- shapes


class Piece:
    """One moving piece: shapes added in world coordinates, each with its own material and bevel."""

    def __init__(self, name, origin):
        self.name = name
        self.origin = Vector(origin)
        self.bm = bmesh.new()
        self.mats = []

    def _slot(self, mat):
        if mat not in self.mats:
            self.mats.append(mat)
        return self.mats.index(mat)

    def _finish(self, geom_verts, mat, bevel):
        faces = {f for v in geom_verts for f in v.link_faces}
        slot = self._slot(mat)
        for f in faces:
            f.material_index = slot
        if bevel > 0:
            edges = list({e for f in faces for e in f.edges})
            bmesh.ops.bevel(self.bm, geom=edges, offset=bevel, segments=SEGMENTS, profile=0.6, affect="EDGES",
                            clamp_overlap=True)

    def box(self, lo, hi, mat, bevel=0.05):
        lo, hi = Vector(lo), Vector(hi)
        res = bmesh.ops.create_cube(self.bm, size=1.0)
        verts = res["verts"]
        center, size = (lo + hi) / 2, hi - lo
        for v in verts:
            v.co = Vector((center.x + v.co.x * size.x, center.y + v.co.y * size.y, center.z + v.co.z * size.z))
        self._finish(verts, mat, min(bevel, min(size) * 0.45))

    def prism(self, points, origin, u, v, n, depth, mat, bevel=0.02):
        """A flat shape (points in the u, v plane at origin) pushed out along n by depth."""
        o, u, v, n = Vector(origin), Vector(u), Vector(v), Vector(n)
        verts = [self.bm.verts.new(o + u * x + v * y) for x, y in points]
        face = self.bm.faces.new(verts)
        if face.normal.dot(n) < 0:
            face.normal_flip()
        res = bmesh.ops.extrude_face_region(self.bm, geom=[face])
        moved = [e for e in res["geom"] if isinstance(e, bmesh.types.BMVert)]
        bmesh.ops.translate(self.bm, verts=moved, vec=n * depth)
        bmesh.ops.recalc_face_normals(self.bm, faces=list({f for vv in verts + moved for f in vv.link_faces}))
        self._finish(verts + moved, mat, bevel)

    def ring(self, center, u, v, n, r_out, r_in, depth, mat, seg=28, bevel=0.0, squash=1.0):
        """A flat ring (an ellipse when squash < 1) pushed out along n. No bevel: it would notch the ring."""
        c, u, v, n = Vector(center), Vector(u), Vector(v), Vector(n)
        outer, inner = [], []
        for i in range(seg):
            a = 2 * math.pi * i / seg
            d = u * math.cos(a) + v * math.sin(a) * squash
            outer.append(self.bm.verts.new(c + d * r_out))
            inner.append(self.bm.verts.new(c + d * r_in))
        faces = [self.bm.faces.new((outer[i], outer[(i + 1) % seg], inner[(i + 1) % seg], inner[i])) for i in range(seg)]
        for f in faces:
            if f.normal.dot(n) < 0:
                f.normal_flip()
        res = bmesh.ops.extrude_face_region(self.bm, geom=faces)
        moved = [e for e in res["geom"] if isinstance(e, bmesh.types.BMVert)]
        bmesh.ops.translate(self.bm, verts=moved, vec=n * depth)
        bmesh.ops.recalc_face_normals(self.bm, faces=list({f for vv in outer + inner + moved for f in vv.link_faces}))
        self._finish(outer + inner + moved, mat, bevel)

    def disc(self, center, u, v, n, r, depth, mat, seg=24, bevel=0.02):
        pts = [(r * math.cos(2 * math.pi * i / seg), r * math.sin(2 * math.pi * i / seg)) for i in range(seg)]
        self.prism(pts, center, u, v, n, depth, mat, bevel)

    def gem(self, center, r, h, mat, seg=8):
        """A cut gem: a crown over a pointed pavilion, standing on its point along +n (here the face normal)."""
        c = Vector(center)
        top = [self.bm.verts.new(c + Vector((r * 0.6 * math.cos(2 * math.pi * i / seg), r * 0.6 * math.sin(2 * math.pi * i / seg), h * 0.55))) for i in range(seg)]
        mid = [self.bm.verts.new(c + Vector((r * math.cos(2 * math.pi * (i + 0.5) / seg), r * math.sin(2 * math.pi * (i + 0.5) / seg), h * 0.3))) for i in range(seg)]
        tip = self.bm.verts.new(c)
        crown = self.bm.verts.new(c + Vector((0, 0, h * 0.62)))
        for i in range(seg):
            j = (i + 1) % seg
            self.bm.faces.new((top[i], top[j], crown))
            self.bm.faces.new((top[i], mid[i], top[j]))
            self.bm.faces.new((mid[i], mid[j], top[j]))
            self.bm.faces.new((mid[i], tip, mid[j]))
        bmesh.ops.recalc_face_normals(self.bm, faces=list({f for vv in top + mid + [tip, crown] for f in vv.link_faces}))
        self._finish(top + mid + [tip, crown], mat, 0)

    def build(self, collection, parent=None):
        mesh = bpy.data.meshes.new(self.name)
        # cube-projected UVs in studs, so the game's stud pattern runs at one size on every face
        uv = self.bm.loops.layers.uv.new("UVMap")
        self.bm.normal_update()
        for f in self.bm.faces:
            nx, ny, nz = (abs(c) for c in f.normal)
            for loop in f.loops:
                p = loop.vert.co
                loop[uv].uv = (p.y, p.z) if nx >= ny and nx >= nz else (p.x, p.z) if ny >= nz else (p.x, p.y)
        bmesh.ops.translate(self.bm, verts=self.bm.verts, vec=-self.origin)
        self.bm.to_mesh(mesh)
        self.bm.free()
        for m in self.mats:
            mesh.materials.append(m)
        for poly in mesh.polygons:
            poly.use_smooth = False
        obj = bpy.data.objects.new(self.name, mesh)
        collection.objects.link(obj)
        if parent is not None:
            obj.parent = parent
            obj.location = self.origin - parent.matrix_world.translation
        else:
            obj.location = self.origin
        obj.matrix_world  # noqa: B018 (refresh)
        bpy.context.view_layer.update()
        return obj


# --------------------------------------------------------------------------------------------------- the crates

FRONT = dict(u=(1, 0, 0), v=(0, 0, 1), n=(0, -1, 0))
BACK = dict(u=(-1, 0, 0), v=(0, 0, 1), n=(0, 1, 0))
LEFT = dict(u=(0, -1, 0), v=(0, 0, 1), n=(-1, 0, 0))
RIGHT = dict(u=(0, 1, 0), v=(0, 0, 1), n=(1, 0, 0))
UP = dict(u=(1, 0, 0), v=(0, 1, 0), n=(0, 0, 1))


def star_points(r_out, r_in, n=5, rot=math.pi / 2):
    return [((r_out if i % 2 == 0 else r_in) * math.cos(rot + math.pi * i / n),
             (r_out if i % 2 == 0 else r_in) * math.sin(rot + math.pi * i / n)) for i in range(2 * n)]


def gear_points(r_out, r_in, teeth=8):
    pts = []
    for i in range(teeth):
        a = 2 * math.pi * i / teeth
        w = math.pi / teeth * 0.55
        for ang, r in ((a - w * 1.25, r_in), (a - w * 0.7, r_out), (a + w * 0.7, r_out), (a + w * 1.25, r_in)):
            pts.append((r * math.cos(ang), r * math.sin(ang)))
    return pts


def rounded_rect(w, h, r, seg=4):
    pts = []
    for cx, cy, a0 in ((w / 2 - r, h / 2 - r, 0), (-w / 2 + r, h / 2 - r, 90), (-w / 2 + r, -h / 2 + r, 180), (w / 2 - r, -h / 2 + r, 270)):
        for i in range(seg + 1):
            a = math.radians(a0 + 90 * i / seg)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def face_point(face, x, z, out=0.0):
    """A point on a wall's outer face: x along the face (centre 0), z the height, `out` metres outward."""
    if face is FRONT:
        return Vector((x, -HY - out, z))
    if face is BACK:
        return Vector((-x, HY + out, z))
    if face is LEFT:
        return Vector((-HX - out, -x, z))
    return Vector((HX + out, x, z))


def planks(piece, face, mat_body, mat_gap, count=3, vertical=False):
    """A wall face of planks with dark gaps between them."""
    width = W if face in (FRONT, BACK) else D - 2 * T
    z0, z1 = BASE_H, TOP
    if not vertical:
        step = (z1 - z0) / count
        for i in range(count):
            lo, hi = z0 + i * step + 0.03, z0 + (i + 1) * step - 0.03
            a, b = face_point(face, -width / 2, lo, 0.0), face_point(face, width / 2, hi, 0.06)
            piece.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], mat_body, 0.035)


def frame(piece, face, mat, width_inset=0.0, rail=0.26, out=0.12):
    """A raised frame round a wall face: two stiles and two rails."""
    width = (W if face in (FRONT, BACK) else D - 2 * T) - width_inset
    for x0, x1, z0, z1 in ((-width / 2, -width / 2 + rail, BASE_H, TOP), (width / 2 - rail, width / 2, BASE_H, TOP),
                           (-width / 2, width / 2, BASE_H, BASE_H + rail), (-width / 2, width / 2, TOP - rail, TOP)):
        a, b = face_point(face, x0, z0, 0.0), face_point(face, x1, z1, out)
        piece.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], mat, 0.05)


def corner_plates(piece, face, mat, rivet, size=0.5, out=0.18):
    width = W if face in (FRONT, BACK) else D - 2 * T
    for sx in (-1, 1):
        for zc, sz in ((BASE_H, 1), (TOP, -1)):
            x_edge = sx * width / 2
            # an L: one bar along the edge, one along the top or bottom
            for (x0, x1, z0, z1) in ((x_edge - sx * 0.2, x_edge, zc, zc + sz * size),
                                     (x_edge - sx * size, x_edge, zc, zc + sz * 0.2)):
                a, b = face_point(face, x0, z0, 0.0), face_point(face, x1, z1, out)
                piece.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], mat, 0.04)
            p = face_point(face, x_edge - sx * 0.1, zc + sz * 0.1, out)
            piece.disc(p, **{k: face[k] for k in ("u", "v", "n")}, r=0.06, depth=0.05, mat=rivet, seg=10, bevel=0.015)


def build_crate(name, collection):
    pal = {k: material(f"{name}_{k}", c, rough=0.42 if k in ("Metal", "Rivet", "Gem", "Emblem") else 0.6) for k, c in PALETTES[name].items()}
    glow = material(f"{name}_Glow", GLOW, rough=1, emit=3.0)

    root = bpy.data.objects.new(f"Crate_{name}", None)
    collection.objects.link(root)

    base = Piece("Base", (0, 0, 0))
    base.box((-HX - 0.06, -HY - 0.06, 0), (HX + 0.06, HY + 0.06, BASE_H), pal["Base"], 0.09)
    # four feet under the corners
    for sx in (-1, 1):
        for sy in (-1, 1):
            x0, x1 = sorted((sx * (HX + 0.1), sx * (HX - 0.55)))
            y0, y1 = sorted((sy * (HY + 0.1), sy * (HY - 0.55)))
            base.box((x0, y0, -0.06), (x1, y1, 0.16), pal["Dark"], 0.05)
    base.build(collection, root)

    inner = Piece("Inner", (0, 0, BASE_H))
    inner.box((-HX + T, -HY + T, BASE_H), (HX - T, HY - T, BASE_H + 0.08), glow, 0.02)
    inner.build(collection, root)

    walls = {}
    for wname, face, origin in (("Front", FRONT, (0, -HY, BASE_H)), ("Back", BACK, (0, HY, BASE_H)),
                                ("Left", LEFT, (-HX, 0, BASE_H)), ("Right", RIGHT, (HX, 0, BASE_H))):
        p = Piece(wname, origin)
        width = W if face in (FRONT, BACK) else D - 2 * T
        # the wall's core: its inside shows once the hatches open
        a, b = face_point(face, -width / 2, BASE_H, 0.0), face_point(face, width / 2, TOP, -T)
        p.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], pal["Frame"], 0.04)
        DECOR[name](p, face, wname, pal)
        walls[wname] = (p, face)

    built = {}
    for wname, (p, _face) in walls.items():
        built[wname] = p.build(collection, root)

    for hname, side, x0, x1 in (("HatchL", "Left", -HX, -0.02), ("HatchR", "Right", 0.02, HX)):
        hinge = (side == "Left" and -HX or HX, 0, TOP)
        p = Piece(hname, hinge)
        p.box((x0, -HY, TOP), (x1, HY, TOP + T), pal["Frame"], 0.05)
        HATCH[name](p, hname, x0, x1, pal)
        p.build(collection, built[side])

    return root


# ---------------------------------------------------------------------------------------- each crate's details


def wall_common(p, face, pal, plank_count=3):
    planks(p, face, pal["Body"], pal["Frame"], plank_count)
    frame(p, face, pal["Frame"])


def weapon_wall(p, face, wname, pal):
    wall_common(p, face, pal)
    corner_plates(p, face, pal["Metal"], pal["Rivet"])
    f = {k: face[k] for k in ("u", "v", "n")}
    zc = (BASE_H + TOP) / 2
    if wname in ("Front", "Back"):
        c = face_point(face, 0, zc, 0.06)
        p.disc(c, **f, r=0.66, depth=0.07, mat=pal["Badge"], seg=32)
        p.ring(face_point(face, 0, zc, 0.13), **f, r_out=0.5, r_in=0.39, depth=0.07, mat=pal["Emblem"], seg=32)
        for dx, dz, w, h in ((0, 0.52, 0.13, 0.36), (0, -0.52, 0.13, 0.36), (0.52, 0, 0.36, 0.13), (-0.52, 0, 0.36, 0.13)):
            pts = rounded_rect(w, h, 0.05)
            p.prism(pts, face_point(face, dx, zc + dz, 0.13), **f, depth=0.08, mat=pal["Emblem"])
        p.disc(face_point(face, 0, zc, 0.13), **f, r=0.1, depth=0.08, mat=pal["Emblem"], seg=16)
    else:
        p.prism(rounded_rect(0.9, 0.32, 0.14), face_point(face, 0, zc + 0.25, 0.06), **f, depth=0.05, mat=pal["Dark"])
        p.prism(rounded_rect(0.8, 0.14, 0.06), face_point(face, 0, zc + 0.25, 0.11), **f, depth=0.07, mat=pal["Metal"])


def weapon_hatch(p, hname, x0, x1, pal):
    for i in range(3):
        y0 = -HY + 0.12 + i * (D - 0.24) / 3
        p.box((x0 + 0.12, y0 + 0.03, TOP + T), (x1 - 0.12, y0 + (D - 0.24) / 3 - 0.03, TOP + T + 0.06), pal["Body"], 0.03)
    outer = x0 if hname == "HatchL" else x1
    sx = 1 if hname == "HatchL" else -1
    for y in (-HY + 0.45, HY - 0.45):
        p.box((min(outer, outer + sx * 0.6), y - 0.18, TOP + T), (max(outer, outer + sx * 0.6), y + 0.18, TOP + T + 0.1), pal["Metal"], 0.04)
        p.disc((outer + sx * 0.42, y, TOP + T + 0.1), **UP, r=0.055, depth=0.04, mat=pal["Rivet"], seg=10, bevel=0.01)


def premium_wall(p, face, wname, pal):
    planks(p, face, pal["Body"], pal["Frame"], 1)
    frame(p, face, pal["Frame"], rail=0.22, out=0.14)
    f = {k: face[k] for k in ("u", "v", "n")}
    width = W if face in (FRONT, BACK) else D - 2 * T
    zc = (BASE_H + TOP) / 2
    # the cyan band across every wall, under the frame
    a, b = face_point(face, -width / 2 + 0.22, zc + 0.42, 0.0), face_point(face, width / 2 - 0.22, zc + 0.62, 0.1)
    p.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], pal["Stripe"], 0.02)
    corner_plates(p, face, pal["Metal"], pal["Rivet"], size=0.42, out=0.2)
    if wname == "Front":
        p.prism(rounded_rect(0.62, 0.48, 0.1), face_point(face, 0, zc + 0.52, 0.1), **f, depth=0.1, mat=pal["Frame"])
        p.disc(face_point(face, 0, zc + 0.52, 0.2), **f, r=0.08, depth=0.03, mat=pal["Dark"], seg=12, bevel=0.005)
        gem = [(0, -0.62), (0.42, 0.06), (0.24, 0.3), (-0.24, 0.3), (-0.42, 0.06)]
        p.prism(gem, face_point(face, 0, zc - 0.32, 0.06), **f, depth=0.16, mat=pal["Emblem"], bevel=0.03)
    elif wname in ("Left", "Right"):
        p.prism([(0, 0.26), (0.16, 0), (0, -0.26), (-0.16, 0)], face_point(face, 0, zc - 0.3, 0.06), **f, depth=0.1, mat=pal["Emblem"])


def premium_hatch(p, hname, x0, x1, pal):
    p.box((x0 + 0.14, -HY + 0.14, TOP + T), (x1 - 0.14, HY - 0.14, TOP + T + 0.04), pal["Body"], 0.02)
    edge = x1 if hname == "HatchL" else x0
    for y0, y1 in ((-HY, -HY + 0.2), (HY - 0.2, HY)):
        p.box((x0, y0, TOP + T), (x1, y1, TOP + T + 0.09), pal["Frame"], 0.03)
    outer = x0 if hname == "HatchL" else x1 - 0.2
    p.box((outer, -HY, TOP + T), (outer + 0.2, HY, TOP + T + 0.09), pal["Frame"], 0.03)
    # half of the gold plate with the red gem sits on each hatch's seam edge
    sx = -1 if hname == "HatchL" else 1
    half = [(0, 0.5), (sx * 0.5, 0), (0, -0.5)] if sx > 0 else [(0, -0.5), (-0.5, 0), (0, 0.5)]
    p.prism(half, (edge, 0, TOP + T), **UP, depth=0.1, mat=pal["Frame"], bevel=0.02)
    p.prism([(0, 0.24), (sx * 0.24, 0), (0, -0.24)] if sx > 0 else [(0, -0.24), (-0.24, 0), (0, 0.24)], (edge, 0, TOP + T + 0.1), **UP, depth=0.08, mat=pal["Gem"], bevel=0.015)
    p.prism([(0, 0.1), (0.07, 0), (0, -0.1), (-0.07, 0)], ((x0 + x1) / 2 + sx * -0.2, -0.8, TOP + T + 0.04), **UP, depth=0.05, mat=pal["Stripe"], bevel=0.01)


def utility_wall(p, face, wname, pal):
    width = W if face in (FRONT, BACK) else D - 2 * T
    a, b = face_point(face, -width / 2, BASE_H, 0.0), face_point(face, width / 2, TOP, 0.05)
    p.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], pal["Body"], 0.05)
    f = {k: face[k] for k in ("u", "v", "n")}
    ribs = 7 if face in (FRONT, BACK) else 5
    for i in range(ribs):
        x = -width / 2 + (i + 0.5) * width / ribs
        p.prism(rounded_rect(0.2, 1.55, 0.09), face_point(face, x, BASE_H + 1.3, 0.05), **f, depth=0.07, mat=pal["Rib"], bevel=0.02)
    # the hazard band along the bottom
    a, b = face_point(face, -width / 2, BASE_H, 0.0), face_point(face, width / 2, BASE_H + 0.36, 0.1)
    p.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], pal["HazardDark"], 0.03)
    n = int(width / 0.36)
    for i in range(n):
        x = -width / 2 + (i + 0.5) * width / n
        p.prism([(-0.13, -0.15), (0.0, -0.15), (0.13, 0.15), (0.0, 0.15)], face_point(face, x, BASE_H + 0.18, 0.1), **f, depth=0.025, mat=pal["Hazard"], bevel=0.005)
    if wname == "Front":
        zc = BASE_H + 1.35
        p.prism(rounded_rect(1.7, 1.45, 0.22), face_point(face, 0, zc, 0.05), **f, depth=0.1, mat=pal["Badge"], bevel=0.03)
        p.prism(gear_points(0.58, 0.44, 8), face_point(face, 0, zc, 0.15), **f, depth=0.06, mat=pal["Emblem"], bevel=0.015)
        p.disc(face_point(face, 0, zc, 0.21), **f, r=0.36, depth=0.03, mat=pal["Emblem"], seg=28, bevel=0.01)
        for w, h in ((0.44, 0.15), (0.15, 0.44)):
            p.prism(rounded_rect(w, h, 0.03), face_point(face, 0, zc, 0.24), **f, depth=0.05, mat=pal["Cross"], bevel=0.01)
        for sx in (-1, 1):
            p.prism(rounded_rect(0.34, 0.5, 0.07), face_point(face, sx * 1.35, TOP - 0.25, 0.05), **f, depth=0.1, mat=pal["Metal"], bevel=0.02)
            p.box(tuple(face_point(face, sx * 1.35 - 0.1, TOP - 0.36, 0.15)), tuple(face_point(face, sx * 1.35 + 0.1, TOP - 0.3, 0.18)), pal["HazardDark"], 0.0)


def utility_hatch(p, hname, x0, x1, pal):
    p.box((x0 + 0.1, -HY + 0.1, TOP + T), (x1 - 0.1, HY - 0.1, TOP + T + 0.05), pal["Body"], 0.03)
    edge = x1 if hname == "HatchL" else x0
    sx = -1 if hname == "HatchL" else 1
    lo, hi = (edge - 0.55, edge) if sx < 0 else (edge, edge + 0.55)
    p.box((lo, -0.3, TOP + T + 0.05), (hi, 0.3, TOP + T + 0.1), pal["Metal"], 0.03)
    if sx < 0:
        p.box((edge - 0.4, -0.06, TOP + T + 0.1), (edge - 0.1, 0.06, TOP + T + 0.13), pal["Cross"], 0.0)
    else:
        p.box((edge + 0.1, -0.06, TOP + T + 0.1), (edge + 0.4, 0.06, TOP + T + 0.13), pal["Cross"], 0.0)
        p.box((edge + 0.19, -0.15, TOP + T + 0.1), (edge + 0.31, 0.15, TOP + T + 0.13), pal["Cross"], 0.0)


def skin_wall(p, face, wname, pal):
    wall_common(p, face, pal, plank_count=4)
    f = {k: face[k] for k in ("u", "v", "n")}
    width = W if face in (FRONT, BACK) else D - 2 * T
    # the ribbon: down the middle of each wall
    a, b = face_point(face, -0.32, BASE_H, 0.0), face_point(face, 0.32, TOP, 0.16)
    p.box([min(a[k], b[k]) for k in range(3)], [max(a[k], b[k]) for k in range(3)], pal["Ribbon"], 0.04)
    for i in range(7):
        x = -width / 2 + 0.4 + i * (width - 0.8) / 6
        z = BASE_H + 0.5 + (i * 0.73) % 1.6
        if abs(x) > 0.5:
            p.disc(face_point(face, x, z, 0.06), **f, r=0.07, depth=0.03, mat=pal["Badge"], seg=12, bevel=0.01)
    if wname == "Front":
        zc = BASE_H + 1.0
        p.disc(face_point(face, 0, zc, 0.16), **f, r=0.42, depth=0.08, mat=pal["Emblem"], seg=28, bevel=0.03)
        p.ring(face_point(face, 0, zc, 0.24), **f, r_out=0.26, r_in=0.18, depth=0.04, mat=pal["Frame"], seg=24, bevel=0.01)
        p.disc(face_point(face, 0, zc, 0.24), **f, r=0.07, depth=0.04, mat=pal["Frame"], seg=12, bevel=0.01)


def skin_hatch(p, hname, x0, x1, pal):
    for i in range(3):
        y0 = -HY + 0.12 + i * (D - 0.24) / 3
        p.box((x0 + 0.12, y0 + 0.03, TOP + T), (x1 - 0.12, y0 + (D - 0.24) / 3 - 0.03, TOP + T + 0.06), pal["Body"], 0.03)
    p.box((x0, -0.32, TOP + T), (x1, 0.32, TOP + T + 0.12), pal["Ribbon"], 0.04)
    # half the bow on each hatch: a loop leaning out from the seam, and half the knot
    edge = x1 if hname == "HatchL" else x0
    sx = -1 if hname == "HatchL" else 1
    # half the bow on each hatch: a looped ribbon tilted up and out from the seam, and half the knot
    tilt = math.radians(28)
    u = Vector((sx * math.cos(tilt), 0, math.sin(tilt)))
    v = Vector((-sx * math.sin(tilt), 0, math.cos(tilt)))
    centre = Vector((edge + sx * 0.5, 0.16, TOP + T + 0.42))
    p.ring(centre, u, v, (0, -1, 0), 0.5, 0.3, 0.32, pal["Ribbon"], seg=28, squash=0.62)
    tail = [(0, 0), (sx * 0.16, -0.02), (sx * 0.62, -0.62), (sx * 0.42, -0.72), (sx * 0.3, -0.5), (0, -0.2)]
    if sx < 0:
        tail = list(reversed(tail))
    p.prism(tail, (edge, -0.32, TOP + T + 0.12), (1, 0, 0), (0, 1, 0), (0, 0, 1), 0.06, pal["Ribbon"], bevel=0.02)
    lo, hi = sorted((edge, edge + sx * 0.2))
    p.box((lo, -0.2, TOP + T + 0.1), (hi, 0.22, TOP + T + 0.56), pal["Metal"], 0.06)


def starter_wall(p, face, wname, pal):
    wall_common(p, face, pal, plank_count=4)
    f = {k: face[k] for k in ("u", "v", "n")}
    width = W if face in (FRONT, BACK) else D - 2 * T
    # a diagonal brace across each wall, as on a wooden crate
    if wname in ("Left", "Right", "Back"):
        ln = math.hypot(width - 0.5, TOP - BASE_H - 0.5)
        ang = math.atan2(TOP - BASE_H - 0.5, width - 0.5)
        pts = [(-ln / 2, -0.13), (ln / 2, -0.13), (ln / 2, 0.13), (-ln / 2, 0.13)]
        pts = [(x * math.cos(ang) - y * math.sin(ang), x * math.sin(ang) + y * math.cos(ang)) for x, y in pts]
        p.prism(pts, face_point(face, 0, (BASE_H + TOP) / 2, 0.06), **f, depth=0.07, mat=pal["Frame"], bevel=0.02)
    if wname == "Front":
        p.prism(star_points(0.78, 0.36), face_point(face, 0, (BASE_H + TOP) / 2 - 0.02, 0.06), **f, depth=0.12, mat=pal["Emblem"], bevel=0.04)
    for sx in (-1, 1):
        for zz in (BASE_H + 0.13, TOP - 0.13):
            p.disc(face_point(face, sx * (width / 2 - 0.13), zz, 0.12), **f, r=0.06, depth=0.04, mat=pal["Rivet"], seg=10, bevel=0.01)


def starter_hatch(p, hname, x0, x1, pal):
    for i in range(3):
        y0 = -HY + 0.12 + i * (D - 0.24) / 3
        p.box((x0 + 0.12, y0 + 0.03, TOP + T), (x1 - 0.12, y0 + (D - 0.24) / 3 - 0.03, TOP + T + 0.06), pal["Body"], 0.03)
    for y0, y1 in ((-HY, -HY + 0.24), (HY - 0.24, HY)):
        p.box((x0, y0, TOP + T), (x1, y1, TOP + T + 0.1), pal["Frame"], 0.03)


DECOR = {"Weapon": weapon_wall, "Premium": premium_wall, "Utility": utility_wall, "Skin": skin_wall, "Starter": starter_wall}
HATCH = {"Weapon": weapon_hatch, "Premium": premium_hatch, "Utility": utility_hatch, "Skin": skin_hatch, "Starter": starter_hatch}


# --------------------------------------------------------------------------------------------------------- main


def rebuild(out_dir=None, names=None, segments=2):
    global SEGMENTS
    SEGMENTS = segments
    names = names or list(PALETTES)
    col = bpy.data.collections.get("Crates")
    if col:
        for obj in list(col.all_objects):
            bpy.data.objects.remove(obj, do_unlink=True)
    else:
        col = bpy.data.collections.new("Crates")
        bpy.context.scene.collection.children.link(col)
    for mesh in [m for m in bpy.data.meshes if m.users == 0]:
        bpy.data.meshes.remove(mesh)
    roots = []
    for i, name in enumerate(names):
        root = build_crate(name, col)
        root.location = ((i - (len(names) - 1) / 2) * 6.0, 0, 0)
        roots.append(root)
    bpy.context.view_layer.update()
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
        for root in roots:
            loc = root.location.copy()
            root.location = (0, 0, 0)
            bpy.ops.object.select_all(action="DESELECT")
            root.select_set(True)
            for child in root.children_recursive:
                child.select_set(True)
            bpy.context.view_layer.objects.active = root
            bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, f"{root.name}.glb"), export_format="GLB",
                                      use_selection=True, export_apply=True, export_yup=True)
            root.location = loc
        bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out_dir, "crates.blend"), copy=True)
    return roots


if __name__ == "__main__":
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    rebuild(argv[0] if argv else None)
