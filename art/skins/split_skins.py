"""Cuts each rigged skin's Body into its pieces: the body, the hat and the neck piece (Blender 5).

Inputs: the FBXs `rig_skins.py` wrote (`<in>/SnailSkin_<Skin>.fbx`). Each Body is the artist's body joined with their
accessories, and the join kept one material per source object, so a piece is a set of materials (PIECES). Run headless:

    blender -b --factory-startup --python split_skins.py -- <in_dir> <out_dir>

It writes `<out>/SnailPieces_<Skin>.fbx` for each skin: the same skeleton and `Shell`, the `Body` without its
accessories, and a skinned `Hat` and `Neck` where the skin has them, each keeping its vertices' weights, so they stay on
the head and neck when they're worn on another snail. Then it imports each written FBX again and checks the bones and
every vertex against the source.
"""
import os
import sys

import bpy
from mathutils.kdtree import KDTree

# Each skin's pieces, by the material numbers on its Body (the rest is the body). A skin missing a piece has it baked
# into its body: the Devil's horns and wings, the Robot's collar
PIECES = {
    "Clown": {"Hat": (3, 4), "Neck": (1, 2)},  # top hat with the hair and nose; the ruff with its pom-poms
    "Cowboy": {"Hat": (2,), "Neck": (1,)},
    "Devil": {"Neck": (1,)},
    "Knight": {"Hat": (1,), "Neck": (2,)},
    "Ninja": {"Hat": (1,)},
    "Pirate": {"Hat": (1,), "Neck": (2,)},
    "Robot": {},
    "Skeleton": {"Hat": (1,)},
    "Soldier": {"Hat": (1,), "Neck": (2,)},
}

FBX_EXPORT = dict(object_types={"ARMATURE", "MESH"}, apply_scale_options="FBX_SCALE_UNITS", add_leaf_bones=False,
                  bake_anim=False, use_armature_deform_only=False, path_mode="STRIP", mesh_smooth_type="OFF",
                  use_mesh_modifiers=False, primary_bone_axis="Y", secondary_bone_axis="X")


def load(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=path, primary_bone_axis="Y", secondary_bone_axis="X",
                             automatic_bone_orientation=False, ignore_leaf_bones=False)
    return {o.name: o for o in bpy.data.objects}


def separate(body, materials, name):
    """Moves the faces of some materials off the body into a mesh of their own, named `name`."""
    bpy.ops.object.mode_set(mode="OBJECT")
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    body.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    for p in body.data.polygons:
        p.select = p.material_index in materials
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.separate(type="SELECTED")
    bpy.ops.object.mode_set(mode="OBJECT")
    piece = next(o for o in bpy.context.selected_objects if o is not body)
    piece.name = name
    piece.data.name = name
    # The vertex groups go with the faces, so each piece keeps its weights
    for mesh in (body, piece):
        bpy.context.view_layer.objects.active = mesh
        bpy.ops.object.material_slot_remove_unused()
    bpy.ops.object.select_all(action="DESELECT")
    return piece


def points(objects):
    out = []
    for o in sorted(objects, key=lambda o: o.name):
        mw = o.matrix_world
        out += sorted(tuple(round(c, 4) for c in (mw @ v.co)) for v in o.data.vertices)
    return sorted(out)


def bones(objects):
    arm = next(o for o in objects if o.type == "ARMATURE")
    return {b.name: [round(x, 4) for row in (arm.matrix_world @ b.matrix_local) for x in row] for b in arm.data.bones}


def split(skin, in_dir, out_dir):
    src = os.path.join(in_dir, f"SnailSkin_{skin}.fbx")
    objs = load(src)
    meshes_before = points([o for o in objs.values() if o.type == "MESH"])
    bones_before = bones(objs.values())
    body = objs["Body"]
    # By name: separating drops the body's unused material slots, which renumbers the rest
    slots = [m.name for m in body.data.materials]
    for name, materials in PIECES[skin].items():
        wanted = {slots[i] for i in materials}
        separate(body, {i for i, m in enumerate(body.data.materials) if m.name in wanted}, name)
    out = os.path.join(out_dir, f"SnailPieces_{skin}.fbx")
    for o in bpy.context.view_layer.objects:
        o.select_set(o.type in ("ARMATURE", "MESH"))
    bpy.context.view_layer.objects.active = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    bpy.ops.export_scene.fbx(filepath=out, use_selection=True, **FBX_EXPORT)

    # The check: the same skeleton and the same vertices, now spread over the pieces
    again = load(out)
    names = sorted(o.name for o in again.values() if o.type == "MESH")
    meshes_after = points([o for o in again.values() if o.type == "MESH"])
    # Every source vertex is still where it was (to 0.001 stud, past the FBX's float rounding), and none was added
    tree = KDTree(len(meshes_after))
    for i, p in enumerate(meshes_after):
        tree.insert(p, i)
    tree.balance()
    worst = max(tree.find(p)[2] for p in meshes_before)
    same_bones = bones(again.values()) == bones_before
    ok = worst < 0.001 and len(set(meshes_after)) == len(set(meshes_before)) and same_bones
    print(f"  {skin}: furthest vertex moved {worst:.6f}, bones {'same' if same_bones else 'moved'}")
    for o in again.values():
        if o.type == "MESH":
            unweighted = sum(1 for v in o.data.vertices if not v.groups)
            if unweighted:
                ok = False
                print(f"  {skin}.{o.name}: {unweighted} vertices without weights")
    print(f"SPLIT {skin}: {names} {'OK' if ok else 'MISMATCH'}")
    return ok


def main():
    args = sys.argv[sys.argv.index("--") + 1:]
    in_dir, out_dir = args[0], args[1]
    os.makedirs(out_dir, exist_ok=True)
    results = [split(skin, in_dir, out_dir) for skin in PIECES]
    print("ALL OK" if all(results) else "SOME FAILED")


if __name__ == "__main__":
    main()
