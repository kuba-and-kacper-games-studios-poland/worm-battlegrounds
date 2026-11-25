"""Puts a body piece's face back on the head: its eyestalk weights below the stalks go to the head bone (Blender 5).

Bone heat gave the Ninja's Midnight body (its eyes and mask) weights on the eyestalk bones, so every pose that turns the
stalks (Idle, the walk's swing, emotes) dragged the eyes off the face (the owner, 2026-11-25). Every other body has only
the stalks' own bottoms there. Run headless on a pieces FBX (`split_skins.py`'s output):

    blender -b --factory-startup --python fix_eyes.py -- <in.fbx> <out.fbx>

It writes the same FBX with the `Body`'s vertices more than MARGIN below the stalks' bases (Bone.005.L and .R) moved off
the eyestalk bones onto their parent, the head (Bone.003), and prints how many it moved. Everything else is unchanged.
"""
import sys

import bpy

# The eyestalk bones (bases, middles and tips) and the head they hang from
STALKS = {"Bone.005.L", "Bone.005.R", "Bone.006.L", "Bone.006.R", "Bone.007.L", "Bone.007.R", "Bone.008.L", "Bone.008.R"}
HEAD = "Bone.003"

# How far under the stalks' bases a vertex must be to count as the face, in the stalks' own length (the stalks' bottoms,
# just under their bases, keep their weights, as on every other body)
MARGIN = 0.08

FBX_EXPORT = dict(object_types={"ARMATURE", "MESH"}, apply_scale_options="FBX_SCALE_UNITS", add_leaf_bones=False,
                  bake_anim=False, use_armature_deform_only=False, path_mode="STRIP", mesh_smooth_type="OFF",
                  use_mesh_modifiers=False, primary_bone_axis="Y", secondary_bone_axis="X")


def main():
    args = sys.argv[sys.argv.index("--") + 1:]
    src, out = args[0], args[1]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=src, primary_bone_axis="Y", secondary_bone_axis="X",
                             automatic_bone_orientation=False, ignore_leaf_bones=False)
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    body = bpy.data.objects["Body"]

    # The stalks' bases and their length, in world space, along the armature's up
    world = arm.matrix_world
    base = min((world @ arm.data.bones[n].head_local).z for n in ("Bone.005.L", "Bone.005.R"))
    tip = max((world @ arm.data.bones[n].tail_local).z for n in ("Bone.008.L", "Bone.008.R"))
    below = base - (tip - base) * MARGIN

    groups = {g.index: g.name for g in body.vertex_groups}
    head = body.vertex_groups.get(HEAD) or body.vertex_groups.new(name=HEAD)
    moved = 0
    for v in body.data.vertices:
        if (body.matrix_world @ v.co).z >= below:
            continue
        stalk = [(groups[g.group], g.weight) for g in v.groups if groups[g.group] in STALKS and g.weight > 0]
        if not stalk:
            continue
        total = sum(w for _, w in stalk)
        current = next((g.weight for g in v.groups if g.group == head.index), 0.0)
        for name, _w in stalk:
            body.vertex_groups[name].remove([v.index])
        head.add([v.index], current + total, "REPLACE")
        moved += 1
    print(f"FIX_EYES: base {base:.4f} tip {tip:.4f} cut {below:.4f}; moved {moved} of {len(body.data.vertices)} vertices")

    for o in bpy.context.view_layer.objects:
        o.select_set(o.type in ("ARMATURE", "MESH"))
    bpy.context.view_layer.objects.active = arm
    bpy.ops.export_scene.fbx(filepath=out, use_selection=True, **FBX_EXPORT)
    print("FIX_EYES: written", out)


if __name__ == "__main__":
    main()
