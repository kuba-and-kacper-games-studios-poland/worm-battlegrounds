"""Rigs the artist's snail skins onto the Classic snail's skeleton, so Classic's animations play on them (Blender 5).

Inputs (README → Rigging): Studio's OBJ exports of Workspace.NewSnails (`<in>/newsnails/newsnails.obj`) and of the
Classic skin (`<in>/classic/classic.obj`), and Classic's bones (`classic_bones.json`, beside this file). In Blender's
Python console (or the MCP's code tool): load this file and call run(in_dir, out_dir). It writes
`<out>/SnailSkin_<Skin>.fbx` for each skin: the skeleton, a skinned `Body` (the body, its accessories and Classic's hands)
and a skinned `Shell`.

Spaces. Studio's OBJ export is Roblox's world (y up) read by Blender's OBJ importer as (x, -z, y). The rig is built in
"import space": Blender (x, y, z) is Roblox (-x, z, y) after Roblox imports the FBX, at the snails' full size (Classic is
the same model scaled 0.45, and its animations move bones in full-size studs). Roblox's importer turns each bone 180°
about its own length, so the bones are built turned back by that much (BONE_FLIP) and come in exactly as Classic's.
"""
import json
import math
import os

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector
from mathutils.kdtree import KDTree

HERE = os.path.dirname(os.path.abspath(__file__))
SCALE = 0.45  # Classic's Model scale

# The artist's models in Workspace.NewSnails, by the material number in their part names (Material.009 is the clown),
# with each model's pivot in Studio (all turned 90° about y: their front faces -x)
MODELS = {
    "9": ("Clown", (242.875, 24.917, -439.875)),
    "8": ("Skeleton", (242.692, 25.087, -434.554)),
    "7": ("Devil", (242.814, 24.917, -429.052)),
    "6": ("Robot", (242.096, 24.917, -424.029)),
    "5": ("Knight", (242.265, 24.917, -419.125)),
    "4": ("Cowboy", (243.000, 24.917, -412.931)),
    "3": ("Ninja", (241.403, 24.869, -406.125)),
    "1": ("Pirate", (241.507, 24.917, -399.950)),
    "2": ("Soldier", (241.501, 24.917, -394.533)),
}

# Where a model's pivot sits on Classic's RootPart (Classic's scaled studs, OBJ space): found by matching the bodies,
# which are Classic's body mesh at full size
PIVOT_ON_ROOT = Vector((-0.0096, -0.572, -0.847))

# The Idle animation's offsets (bone space, full-size studs): the shell bone's carries the shell onto the back (Classic's
# rest pose has it floating above), the hand bones' bring the hands in front
SHELL_POSE = Vector((0, -5.272, 2.813))
HAND_POSE = {"Bone.014.L": Vector((2.075, -0.66, 1.769)), "Bone.014.R": Vector((-2.075, -0.66, 1.769))}

STALKS = {"Bone.005.L", "Bone.007.L", "Bone.006.L", "Bone.008.L", "Bone.005.R", "Bone.007.R", "Bone.006.R", "Bone.008.R"}
NOT_BODY = {"RootPart", "Bone.013", "Bone.014.L", "Bone.014.R"}
TO_BLENDER = Matrix(((-1, 0, 0), (0, 0, 1), (0, 1, 0)))  # Roblox -> import space
BONE_FLIP = Matrix.Rotation(math.pi, 4, "Y")


#%%%%%%%%%%%%%%%%%%%% Scene

def import_obj(path, collection):
    before = set(bpy.data.objects)
    bpy.ops.wm.obj_import(filepath=path, use_split_groups=True, use_split_objects=True)
    new = [o for o in bpy.data.objects if o not in before]
    for o in new:
        for c in list(o.users_collection):
            c.objects.unlink(o)
        collection.objects.link(o)
        o.data.transform(o.matrix_world)
        o.matrix_world = Matrix.Identity(4)
    return new


def to_import_space(objects, pivot=None):
    """Classic's parts (pivot None) or one model's parts (its Studio pivot) into import space, full size."""
    turn = Matrix.Rotation(math.pi, 4, "Z")
    if pivot is None:
        m = turn @ Matrix.Scale(1 / SCALE, 4)
    else:
        x, y, z = pivot
        m = turn @ Matrix.Translation(PIVOT_ON_ROOT / SCALE) @ Matrix.Rotation(math.radians(-90), 4, "Z") \
            @ Matrix.Translation(Vector((-x, z, -y)))
    for o in objects:
        o.data.transform(m)


def build_armature(collection):
    bones = json.load(open(os.path.join(HERE, "classic_bones.json")))
    arm = bpy.data.objects.new("Armature", bpy.data.armatures.new("SnailArmature"))
    collection.objects.link(arm)
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    eb = arm.data.edit_bones
    root = eb.new("RootPart")
    root.head, root.tail = (0, 0, 0), (0, 1, 0)
    root.matrix = TO_BLENDER.to_4x4()
    root.length = 1

    def mat(w):
        r = Matrix(((w[3], w[4], w[5]), (w[6], w[7], w[8]), (w[9], w[10], w[11])))
        m = (TO_BLENDER @ r).to_4x4()
        m.translation = TO_BLENDER @ (Vector(w[0:3]) / SCALE)
        return m

    mats = {n: mat(v["w"]) for n, v in bones.items()}
    children = {}
    for n, v in bones.items():
        children.setdefault(v["parent"], []).append(n)
    order = []

    def walk(n):
        for c in children.get(n, []):
            order.append(c)
            walk(c)

    walk("RootPart")
    for n in order:
        b = eb.new(n)
        b.head, b.tail = (0, 0, 0), (0, 1, 0)
        b.matrix = mats[n] @ BONE_FLIP
        length = 0.6
        for c in children.get(n, []):
            loc = mats[n].inverted() @ mats[c].translation
            if loc.y > 0.05 and abs(loc.x) < 0.05 * loc.y and abs(loc.z) < 0.05 * loc.y:
                length = loc.y
        b.length = length
        b.parent = eb[bones[n]["parent"]]
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


#%%%%%%%%%%%%%%%%%%%% Weights

def copy_obj(src, name):
    o = src.copy()
    o.data = src.data.copy()
    o.name = o.data.name = name
    o.vertex_groups.clear()
    for c in src.users_collection:
        c.objects.link(o)
    return o


def heat_proxy(arm, body):
    """The body with its vertices merged (one connected surface), weighted by bone heat to the body's bones."""
    for b in arm.data.bones:
        b.use_deform = b.name not in NOT_BODY
    proxy = copy_obj(body, body.name + "_proxy")
    bm = bmesh.new()
    bm.from_mesh(proxy.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.002)
    bm.to_mesh(proxy.data)
    bm.free()
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    proxy.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")
    for b in arm.data.bones:
        b.use_deform = True
    names = {g.index: g.name for g in proxy.vertex_groups}
    weights = [{names[g.group]: g.weight for g in v.groups if g.weight > 0} for v in proxy.data.vertices]

    # Bone heat leaves pieces it can't solve unweighted (the Devil's wings); in Roblox an unweighted vertex flies to the
    # world's origin, so each takes the weights of the nearest weighted vertex
    weighted = [i for i, w in enumerate(weights) if w]
    near = KDTree(len(weighted))
    for j, i in enumerate(weighted):
        near.insert(proxy.data.vertices[i].co, j)
    near.balance()
    for i, w in enumerate(weights):
        if not w:
            _co, j, _d = near.find(proxy.data.vertices[i].co)
            weights[i] = dict(weights[weighted[j]])

    kd = KDTree(len(proxy.data.vertices))
    for i, v in enumerate(proxy.data.vertices):
        kd.insert(v.co, i)
    kd.balance()
    bpy.data.objects.remove(proxy, do_unlink=True)
    return weights, kd


def set_weights(obj, weights):
    """Each vertex's 4 largest weights, normalized (Roblox skins with up to 4 bones a vertex)."""
    groups = {}
    for i, wd in enumerate(weights):
        top = sorted(wd.items(), key=lambda t: -t[1])[:4]
        total = sum(x for _, x in top) or 1
        for g, x in top:
            if g not in groups:
                groups[g] = obj.vertex_groups.get(g) or obj.vertex_groups.new(name=g)
            groups[g].add([i], x / total, "REPLACE")


def transfer(obj, weights, kd, near, stalks_to_head=False):
    """Weights from the proxy's nearest vertices; an accessory's eyestalk weights go to the head (a hat stays on it)."""
    out = []
    for v in obj.data.vertices:
        acc = {}
        total = 0
        for _co, idx, d in kd.find_n(v.co, near):
            f = 1 / max(d, 1e-4) ** 2
            total += f
            for g, x in weights[idx].items():
                g = "Bone.003" if stalks_to_head and g in STALKS else g
                acc[g] = acc.get(g, 0) + x * f
        out.append({g: x / total for g, x in acc.items()})
    set_weights(obj, out)


#%%%%%%%%%%%%%%%%%%%% Hands

def body_texture(obj):
    for m in obj.data.materials:
        for n in (m.node_tree.nodes if m and m.node_tree else []):
            if n.type == "TEX_IMAGE" and n.image and "_diff" in n.image.name.lower():
                return n.image
    return None


def skin_uv(body, img, points):
    """A UV on the body's texture showing the commonest colour of the body faces nearest the given points."""
    w, h = img.size
    px = np.empty(w * h * 4, dtype=np.float32)
    img.pixels.foreach_get(px)
    px = px.reshape(h, w, 4)
    uv = body.data.uv_layers.active.data
    polys = list(body.data.polygons)
    kd = KDTree(len(polys))
    for i, p in enumerate(polys):
        kd.insert(p.center, i)
    kd.balance()
    found = {}
    for point in points:
        for _co, idx, _d in kd.find_n(point, 40):
            p = polys[idx]
            u = sum(uv[li].uv.x for li in p.loop_indices) / p.loop_total
            v = sum(uv[li].uv.y for li in p.loop_indices) / p.loop_total
            colour = tuple((px[min(h - 1, int(v * h)), min(w - 1, int(u * w)), :3] * 32).astype(int))
            found.setdefault(colour, []).append((u, v))
    return max(found.values(), key=len)[0]


#%%%%%%%%%%%%%%%%%%%% Rig

def rig(arm, skin, parts, hands):
    """One skin's Body (body + accessories + Classic's hands) and Shell, skinned to the armature."""
    by_size = sorted(parts, key=lambda o: len(o.data.vertices), reverse=True)
    body_src = next(o for o in parts if abs(o.dimensions.z - 9.22) < 0.2 and o.dimensions.y > 7)
    shell_src = next(o for o in parts if o is not body_src and abs(o.dimensions.y - 5.52) < 0.3
                     and abs(o.dimensions.z - 5.52) < 0.3)
    accessories = [o for o in by_size if o not in (body_src, shell_src)]

    weights, kd = heat_proxy(arm, body_src)
    body = copy_obj(body_src, skin + "_Body")
    transfer(body, weights, kd, near=1)
    joined = [body]
    for acc in accessories:
        o = copy_obj(acc, acc.name + "_w")
        transfer(o, weights, kd, near=6, stalks_to_head=True)
        joined.append(o)

    # Classic's hands, each on the hand bone beside it, in the body's colour where they rest in the Idle pose
    rest = []
    for hand in hands:
        h = copy_obj(hand, skin + "_" + hand.name)
        centre = sum((v.co for v in h.data.vertices), Vector()) / len(h.data.vertices)
        bone = min(HAND_POSE, key=lambda n: (arm.data.bones[n].head_local - centre).length)
        set_weights(h, [{bone: 1.0}] * len(h.data.vertices))
        b = arm.data.bones[bone].matrix_local @ BONE_FLIP
        rest.append(b @ Matrix.Translation(HAND_POSE[bone]) @ b.inverted() @ centre)
        joined.append(h)
    u, v = skin_uv(body_src, body_texture(body_src), rest)
    for h in joined[-2:]:
        for loop in h.data.uv_layers.active.data:
            loop.uv = (u, v)
        h.data.materials.clear()
        for m in body.data.materials:
            h.data.materials.append(m)

    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in joined:
        o.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.join()

    # The shell, moved back by the Idle animation's shell offset, all on the shell bone
    shell = copy_obj(shell_src, skin + "_Shell")
    b = arm.data.bones["Bone.013"].matrix_local @ BONE_FLIP
    shell.data.transform(b @ Matrix.Translation(-SHELL_POSE) @ b.inverted())
    set_weights(shell, [{"Bone.013": 1.0}] * len(shell.data.vertices))

    for o in (body, shell):
        o.parent = arm
        o.modifiers.new("Armature", "ARMATURE").object = arm
    return body, shell


def export(arm, body, shell, path):
    names = body.name, shell.name
    body.name, shell.name = "Body", "Shell"  # the FBX's node names become the MeshParts' names
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in (arm, body, shell):
        o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, object_types={"ARMATURE", "MESH"},
                             apply_scale_options="FBX_SCALE_UNITS", add_leaf_bones=False, bake_anim=False,
                             use_armature_deform_only=False, path_mode="STRIP", mesh_smooth_type="OFF",
                             use_mesh_modifiers=False, primary_bone_axis="Y", secondary_bone_axis="X")
    body.name, shell.name = names


def run(in_dir, out_dir, skins=None):
    scene = bpy.data.scenes.new("SnailSkins")
    bpy.context.window.scene = scene
    source = bpy.data.collections.new("Source")
    scene.collection.children.link(source)
    classic = import_obj(os.path.join(in_dir, "classic", "classic.obj"), source)
    to_import_space(classic)
    hands = [o for o in classic if o.name.lower().startswith(("lefthand", "righthand"))]
    models = {}
    for o in import_obj(os.path.join(in_dir, "newsnails", "newsnails.obj"), source):
        key = o.name.split("material00")[1][0]
        models.setdefault(key, []).append(o)
    for key, parts in models.items():
        to_import_space(parts, MODELS[key][1])
    arm = build_armature(scene.collection)
    os.makedirs(out_dir, exist_ok=True)
    made = []
    for key, (skin, _pivot) in MODELS.items():
        if skins and skin not in skins:
            continue
        body, shell = rig(arm, skin, models[key], hands)
        export(arm, body, shell, os.path.join(out_dir, f"SnailSkin_{skin}.fbx"))
        made.append(skin)
    source.hide_viewport = True
    return made
