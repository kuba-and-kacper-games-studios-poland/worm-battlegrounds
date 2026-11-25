"""Voxel brick builders, materials, trees and the layer renderer used in desert_backdrop.blend (its `voxel_lib` text block).

Run inside Blender: exec(bpy.data.texts["voxel_lib"].as_string(), ns), then ns["build_voxels"](...), ns["render_layer"](...), etc.
"""

import bpy, numpy as np, math
def build_voxels(mesh_name, forms, seed, depth_max, base_rows=1, x0=-1000, x1=1000, CS=5.0, LH=4.0, ground_amp=2.0, ground_base=2.0, flat_ry=(0.32, 0.45)):
    rng = np.random.default_rng(seed)
    def sines2(x, y, n, fmax, amp):
        out = np.zeros_like(x)
        for k in range(n):
            out += amp * rng.uniform(0.5, 1) / (k + 1) ** 0.6 * np.sin(rng.uniform(-fmax, fmax) * x + rng.uniform(-fmax, fmax) * y + rng.uniform(0, 6.28))
        return out
    xs = np.arange(x0, x1, CS) + CS / 2
    ys = np.arange(0, depth_max, CS) + CS / 2
    X, Y = np.meshgrid(xs, ys)
    H = ground_base + ground_amp * sines2(X, Y, 8, 0.04, 1.0)
    for kind, cx, cy, rx, h in forms:
        ry = rx * (rng.uniform(*flat_ry) if kind in ("mesa", "bench", "dune") else rng.uniform(0.7, 1.0))
        dx, dy = (X - cx) / rx, (Y - cy) / ry
        ang = np.arctan2(dy, dx); r = np.sqrt(dx * dx + dy * dy)
        wob = 1 + 0.12 * np.sin(2 * ang + rng.uniform(0, 6.28)) + 0.07 * np.sin(3 * ang + rng.uniform(0, 6.28)) + 0.05 * np.sin(5 * ang + rng.uniform(0, 6.28))
        d = r / wob
        if kind == "dune":
            z = h * np.clip(1 - d, 0, None) ** 1.3
        elif kind == "peak":
            rag = 1 + 0.10 * np.sin(9 * ang + rng.uniform(0, 6.28)) + 0.06 * np.sin(17 * ang + rng.uniform(0, 6.28))
            z = h * np.clip(1 - d * rag, 0, None) ** 1.15
        else:
            cap_frac = 0.38 if kind != "spire" else 0.75
            talus_w = {"mesa": 0.5, "bench": 0.55, "butte": 0.7, "spire": 1.4}[kind]
            zc = np.where(d < 1.0, h, 0.0)
            s = np.clip((d - 1.0) / talus_w, 0, 1)
            z = np.maximum(zc, h * (1 - cap_frac) * (1 - s) ** 1.8 * (d >= 1.0))
        H = np.maximum(H, z)
    N = np.maximum(np.round(H / LH).astype(int), base_rows)
    ny, nx = N.shape
    verts = []; faces = []
    def quad(a, b, c, d):
        i = len(verts); verts.extend([a, b, c, d]); faces.append((i, i + 1, i + 2, i + 3))
    x0s = xs - CS / 2; x1s = xs + CS / 2; y0s = ys - CS / 2; y1s = ys + CS / 2
    for j in range(ny):
        for i in range(nx):
            n = N[j, i]; z = n * LH; xa, xb, ya, yb = x0s[i], x1s[i], y0s[j], y1s[j]
            quad((xa, ya, z), (xb, ya, z), (xb, yb, z), (xa, yb, z))
            nf = N[j - 1, i] if j > 0 else 0
            if n > nf: quad((xa, ya, nf * LH), (xb, ya, nf * LH), (xb, ya, z), (xa, ya, z))
            nb = N[j + 1, i] if j < ny - 1 else 0
            if n > nb: quad((xb, yb, nb * LH), (xa, yb, nb * LH), (xa, yb, z), (xb, yb, z))
            nl = N[j, i - 1] if i > 0 else 0
            if n > nl: quad((xa, yb, nl * LH), (xa, ya, nl * LH), (xa, ya, z), (xa, yb, z))
            nr = N[j, i + 1] if i < nx - 1 else 0
            if n > nr: quad((xb, ya, nr * LH), (xb, yb, nr * LH), (xb, yb, z), (xb, ya, z))
    me = bpy.data.meshes.get(mesh_name) or bpy.data.meshes.new(mesh_name)
    me.clear_geometry(); me.from_pydata(verts, [], faces); me.update()
    for p in me.polygons: p.use_smooth = False
    return me, len(faces)

def render_layer(scn, cam, x0, x1, v0, v1, tiles, px_per_tile, pitch_deg, out_pattern):
    p = math.radians(pitch_deg)
    cam.rotation_euler = (math.radians(90) - p, 0, 0)
    tw = (x1 - x0) / tiles
    cam.data.ortho_scale = tw
    vc = (v0 + v1) / 2
    scn.render.resolution_x = px_per_tile
    scn.render.resolution_y = int(round(px_per_tile * (v1 - v0) / tw))
    paths = []
    for t in range(tiles):
        cam.location = (x0 + tw * (t + 0.5), -800, (vc - (-800) * math.sin(p)) / math.cos(p))
        scn.render.filepath = out_pattern.format(t + 1)
        bpy.ops.render.render(write_still=True, scene=scn.name)
        paths.append(scn.render.filepath)
    return paths


def lin(r, g, b):
    c = lambda v: (v / 255) / 12.92 if v / 255 <= 0.04045 else ((v / 255 + 0.055) / 1.055) ** 2.4
    return (c(r), c(g), c(b), 1.0)

def setup_scene(name, world_rgb, world_strength, sun_energy=4.0):
    """A scene of its own with its world light, the camera-side sun and the layer camera (copies of Desert's)."""
    scn = bpy.data.scenes.get(name) or bpy.data.scenes.new(name)
    base = bpy.data.scenes["DesertBackdrop"]
    scn.render.engine = base.render.engine
    scn.view_settings.view_transform = "Standard"
    scn.render.film_transparent = True
    scn.render.image_settings.file_format = "PNG"; scn.render.image_settings.color_mode = "RGBA"
    scn.eevee.taa_render_samples = 64
    try: scn.eevee.use_raytracing = True
    except Exception: pass
    w = bpy.data.worlds.get(name + "World") or bpy.data.worlds.new(name + "World")
    w.use_nodes = True
    bg = next(n for n in w.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs[0].default_value = (*world_rgb, 1); bg.inputs[1].default_value = world_strength
    scn.world = w
    for ob_name in ("Sun", "LayerCam"):
        src_ob = bpy.data.objects[ob_name]
        ob = bpy.data.objects.get(name + "_" + ob_name)
        if not ob:
            ob = src_ob.copy(); ob.data = src_ob.data.copy(); ob.name = name + "_" + ob_name
            scn.collection.objects.link(ob)
    scn.camera = bpy.data.objects[name + "_LayerCam"]
    bpy.data.objects[name + "_Sun"].data.energy = sun_energy
    return scn

def brick_material(name, palette, top_rgb, snow=None, snow_rgb=(244, 248, 252)):
    """A copy of the sandstone brick material in other colours: each brick row a palette shade, sides and tops.
    snow = (snowline, spread): sides above the snowline (ragged) and every top above half of it turn snow_rgb (white snow,
    or a grass cap)."""
    m = bpy.data.materials.get(name)
    if m: bpy.data.materials.remove(m)
    m = bpy.data.materials["Sandstone"].copy(); m.name = name
    nt = m.node_tree; N = nt.nodes; L = nt.links
    ramp = next(n for n in N if n.type == "VALTORGB").color_ramp
    for el, (p, c) in zip(ramp.elements, palette): el.position = p; el.color = lin(*c)
    for n in N:
        if n.type == "MIX" and n.blend_type == "MULTIPLY" and not n.inputs[6].is_linked:
            n.inputs[6].default_value = lin(*top_rgb)
    if snow:
        snowline, spread = snow
        ao = next(n for n in N if n.type == "AMBIENT_OCCLUSION")
        topm = ao.inputs["Color"].links[0].from_node
        tc = next(n for n in N if n.type == "TEX_COORD")
        sep = N.new("ShaderNodeSeparateXYZ"); L.new(tc.outputs["Object"], sep.inputs[0])
        nz = N.new("ShaderNodeTexNoise"); nz.inputs["Scale"].default_value = 0.05; L.new(tc.outputs["Object"], nz.inputs["Vector"])
        jag = N.new("ShaderNodeMath"); jag.operation = "MULTIPLY_ADD"
        L.new(nz.outputs["Fac"], jag.inputs[0]); jag.inputs[1].default_value = spread * 2; L.new(sep.outputs["Z"], jag.inputs[2])
        side = N.new("ShaderNodeMapRange"); L.new(jag.outputs[0], side.inputs["Value"])
        side.inputs["From Min"].default_value = snowline - 1; side.inputs["From Max"].default_value = snowline + 1
        geo = N.new("ShaderNodeNewGeometry"); gs = N.new("ShaderNodeSeparateXYZ"); L.new(geo.outputs["Normal"], gs.inputs[0])
        hi = N.new("ShaderNodeMapRange"); L.new(sep.outputs["Z"], hi.inputs["Value"])
        hi.inputs["From Min"].default_value = snowline * 0.45; hi.inputs["From Max"].default_value = snowline * 0.55
        topsnow = N.new("ShaderNodeMath"); topsnow.operation = "MULTIPLY"
        L.new(gs.outputs["Z"], topsnow.inputs[0]); L.new(hi.outputs["Result"], topsnow.inputs[1])
        fac = N.new("ShaderNodeMath"); fac.operation = "MAXIMUM"; fac.use_clamp = True
        L.new(side.outputs["Result"], fac.inputs[0]); L.new(topsnow.outputs[0], fac.inputs[1])
        mix = N.new("ShaderNodeMix"); mix.data_type = "RGBA"
        L.new(fac.outputs[0], mix.inputs["Factor"]); L.new(topm.outputs[2], mix.inputs[6]); mix.inputs[7].default_value = lin(*snow_rgb)
        L.new(mix.outputs[2], ao.inputs["Color"])
        aomix = next(n for n in N if n.type == "MIX" and n.inputs[6].is_linked and n.inputs[6].links[0].from_node == topm and n is not mix)
        L.new(mix.outputs[2], aomix.inputs[6])
    return m

def flat_material(name, rgb, rough=0.85):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Base Color"].default_value = lin(*rgb); b.inputs["Roughness"].default_value = rough
    return m

def voxel_blob(name, puffs, vs, material, collection, offset=(0, 0, 0), zmin=None):
    """A blocky blob: every vs-sized cube whose centre is inside one of the (x, y, z, r) spheres; zmin cuts it flat."""
    xs = [p[0] - p[3] for p in puffs] + [p[0] + p[3] for p in puffs]
    ys = [p[1] - p[3] for p in puffs] + [p[1] + p[3] for p in puffs]
    zs = [p[2] - p[3] for p in puffs] + [p[2] + p[3] for p in puffs]
    gx = np.arange(min(xs), max(xs) + vs, vs); gy = np.arange(min(ys), max(ys) + vs, vs); gz = np.arange(min(zs), max(zs) + vs, vs)
    X, Y, Z = np.meshgrid(gx, gy, gz, indexing="ij")
    occ = np.zeros(X.shape, bool)
    for (px, py, pz, r) in puffs:
        occ |= (X - px) ** 2 + (Y - py) ** 2 + (Z - pz) ** 2 < r * r
    if zmin is not None:
        occ &= Z >= zmin
    verts, faces = [], []
    def quad(a, b_, c, d):
        i = len(verts); verts.extend([a, b_, c, d]); faces.append((i, i + 1, i + 2, i + 3))
    pad = np.pad(occ, 1); h = vs / 2
    ox, oy, oz = offset
    for (i, j, k) in zip(*np.nonzero(occ)):
        x, y, z = gx[i] + ox, gy[j] + oy, gz[k] + oz
        if not pad[i + 1, j + 1, k + 2]: quad((x - h, y - h, z + h), (x + h, y - h, z + h), (x + h, y + h, z + h), (x - h, y + h, z + h))
        if not pad[i + 1, j + 1, k]: quad((x - h, y + h, z - h), (x + h, y + h, z - h), (x + h, y - h, z - h), (x - h, y - h, z - h))
        if not pad[i + 1, j, k + 1]: quad((x - h, y - h, z - h), (x + h, y - h, z - h), (x + h, y - h, z + h), (x - h, y - h, z + h))
        if not pad[i + 1, j + 2, k + 1]: quad((x + h, y + h, z - h), (x - h, y + h, z - h), (x - h, y + h, z + h), (x + h, y + h, z + h))
        if not pad[i, j + 1, k + 1]: quad((x - h, y + h, z - h), (x - h, y - h, z - h), (x - h, y - h, z + h), (x - h, y + h, z + h))
        if not pad[i + 2, j + 1, k + 1]: quad((x + h, y - h, z - h), (x + h, y + h, z - h), (x + h, y + h, z + h), (x + h, y - h, z + h))
    me = bpy.data.meshes.new(name); me.from_pydata(verts, [], faces); me.update(); me.materials.append(material)
    o = bpy.data.objects.new(name, me); collection.objects.link(o)
    return o

def box(name, x0, y0, z0, sx, sy, sz, material, collection):
    m = bpy.data.meshes.new(name)
    v = [(x0, y0, z0), (x0 + sx, y0, z0), (x0 + sx, y0 + sy, z0), (x0, y0 + sy, z0), (x0, y0, z0 + sz), (x0 + sx, y0, z0 + sz), (x0 + sx, y0 + sy, z0 + sz), (x0, y0 + sy, z0 + sz)]
    f = [(0, 1, 2, 3), (4, 7, 6, 5), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]
    m.from_pydata(v, [], f); m.update(); m.materials.append(material)
    o = bpy.data.objects.new(name, m); collection.objects.link(o)
    return o

def ground_z(scn, x, y):
    dg = bpy.context.evaluated_depsgraph_get()
    hit, loc, *_ = scn.ray_cast(dg, (x, y, 600), (0, 0, -1))
    return loc.z if hit else 0.0

def pine(scn, name, x, y, h, wood, leaves, collection, snow_mat=None):
    """A blocky pine: a short trunk under four shrinking green tiers (white-tipped with snow_mat)."""
    z0 = ground_z(scn, x, y) - 0.5
    tw = max(1.5, h * 0.12)
    box(name + "_trunk", x - tw / 2, y - tw / 2, z0, tw, tw, h * 0.3, wood, collection)
    for k, (wf, zf, hf) in enumerate([(0.62, 0.2, 0.25), (0.48, 0.4, 0.22), (0.34, 0.58, 0.2), (0.2, 0.76, 0.22)]):
        w_ = h * wf
        box(f"{name}_t{k}", x - w_ / 2, y - w_ / 2, z0 + h * zf, w_, w_, h * hf, leaves, collection)
        if snow_mat is not None:
            box(f"{name}_s{k}", x - w_ / 2 + 0.3, y - w_ / 2 + 0.3, z0 + h * (zf + hf), w_ - 0.6, w_ - 0.6, h * 0.04, snow_mat, collection)

def oak(scn, name, x, y, h, wood, leaves, collection, seed=0):
    """A blocky oak: a trunk under a round voxel canopy."""
    rng = np.random.default_rng(seed)
    z0 = ground_z(scn, x, y) - 0.5
    tw = max(2.0, h * 0.14)
    box(name + "_trunk", x - tw / 2, y - tw / 2, z0, tw, tw, h * 0.55, wood, collection)
    r = h * 0.32
    puffs = [(0, 0, 0, r)] + [(rng.uniform(-r, r) * 0.7, rng.uniform(-r, r) * 0.4, rng.uniform(-r, r) * 0.3, r * rng.uniform(0.6, 0.8)) for _ in range(4)]
    voxel_blob(name + "_crown", puffs, max(2.0, h * 0.09), leaves, collection, offset=(x, y, z0 + h * 0.62))
