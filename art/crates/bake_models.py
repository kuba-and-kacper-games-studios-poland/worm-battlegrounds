"""The crates for the game (Blender 5): make_models.py's crates with one bevel step, each crate's colours and the stud
pattern baked into one texture (as the game's weapon models carry theirs), and its eight moving pieces exported as
one FBX. Writes <out>/Crate_<Name>.fbx and <out>/Crate_<Name>.png (1024 x 1024).

Run inside Blender: bake_models.main(r"<out dir>") after loading this file (the MCP's code tool), or
`blender --background --python bake_models.py -- <out dir>`. It rebuilds the scene's Crates collection one crate at a
time, so every piece keeps its plain name (Base, Inner, Front, Back, Left, Right, HatchL, HatchR): the game finds
them by those names.
"""

import importlib.util
import os
import sys

import bpy

HERE = os.path.dirname(os.path.abspath(__file__))
SIZE = 1024
TAG = "WB_bake_"  # nodes this script adds, so a second run replaces them


def load_models():
    spec = importlib.util.spec_from_file_location("make_models", os.path.join(HERE, "make_models.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def stud_image(out_dir):
    """The Roblox stud, as the preview draws it: a faint L in each tile and darker right and bottom edges. Saved as a
    file and loaded back, since a generated image's pixels are made again when it's rendered."""
    old = bpy.data.images.get("WB_Stud")
    if old:
        bpy.data.images.remove(old)
    img = bpy.data.images.new("WB_Stud", 128, 128, alpha=False)
    px = [1.0] * (128 * 128 * 4)

    def put(x, y, v):
        i = ((127 - y) * 128 + x) * 4  # image rows run bottom to top
        px[i] = px[i + 1] = px[i + 2] = v

    for y in range(128):
        for x in range(128):
            v = 1.0
            if y >= 124 or x >= 124:
                v = 0.93
            if (30 <= x <= 37 and 27 <= y <= 81) or (30 <= x <= 85 and 74 <= y <= 81):
                v = 0.84
            put(x, y, v)
    img.pixels[:] = px
    path = os.path.join(out_dir, "stud.png")
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)
    img = bpy.data.images.load(path)
    img.name = "WB_Stud"
    img.colorspace_settings.name = "sRGB"
    return img


def setup_material(mat, stud, target):
    nt = mat.node_tree
    for n in [n for n in nt.nodes if n.name.startswith(TAG)]:
        nt.nodes.remove(n)
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    color = tuple(bsdf.inputs["Base Color"].default_value)
    for link in list(bsdf.inputs["Base Color"].links):
        nt.links.remove(link)
    uv = nt.nodes.new("ShaderNodeUVMap")
    uv.name = TAG + "uv"
    uv.uv_map = "UVMap"
    mapping = nt.nodes.new("ShaderNodeMapping")
    mapping.name = TAG + "map"
    mapping.inputs["Scale"].default_value = (2.0, 2.0, 1.0)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.name = TAG + "stud"
    tex.image = stud
    mix = nt.nodes.new("ShaderNodeMix")
    mix.name = TAG + "mix"
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 0.0 if "_Glow" in mat.name else 1.0
    mix.inputs[6].default_value = color
    nt.links.new(uv.outputs["UV"], mapping.inputs["Vector"])
    nt.links.new(mapping.outputs["Vector"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], mix.inputs[7])
    nt.links.new(mix.outputs[2], bsdf.inputs["Base Color"])
    bake = nt.nodes.new("ShaderNodeTexImage")
    bake.name = TAG + "target"
    bake.image = target
    nt.nodes.active = bake


def bake_crate(mm, name, out_dir, stud):
    roots = mm.rebuild(names=[name], segments=1)
    root = roots[0]
    root.location = (0, 0, 0)
    bpy.context.view_layer.update()
    pieces = [o for o in root.children_recursive if o.type == "MESH"]

    # flatten the hinges (the game moves each piece itself) and give every piece a second UV set for the bake
    for o in pieces:
        world = o.matrix_world.copy()
        o.parent = None
        o.matrix_world = world
        if "Bake" not in o.data.uv_layers:
            o.data.uv_layers.new(name="Bake")
        o.data.uv_layers.active = o.data.uv_layers["Bake"]

    bpy.ops.object.select_all(action="DESELECT")
    for o in pieces:
        o.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.004, scale_to_bounds=False)
    bpy.ops.uv.pack_islands(margin=0.004, rotate=True)
    bpy.ops.object.mode_set(mode="OBJECT")

    target = bpy.data.images.get(f"Bake_{name}")
    if target:
        bpy.data.images.remove(target)
    target = bpy.data.images.new(f"Bake_{name}", SIZE, SIZE, alpha=False)
    target.generated_color = (0.0, 0.0, 0.0, 1.0)
    mats = {m for o in pieces for m in o.data.materials}
    for m in mats:
        setup_material(m, stud, target)

    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 4
    scene.cycles.device = "CPU"
    # one bake over every piece: clearing would wipe the pieces baked before
    bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, margin=6, use_clear=False)
    target.filepath_raw = os.path.join(out_dir, f"Crate_{name}.png")
    target.file_format = "PNG"
    target.save()

    # the game reads the first UV set: keep only the bake's
    for o in pieces:
        o.data.uv_layers.remove(o.data.uv_layers["UVMap"])
    bpy.ops.object.select_all(action="DESELECT")
    for o in pieces:
        o.select_set(True)
    bpy.ops.export_scene.fbx(filepath=os.path.join(out_dir, f"Crate_{name}.fbx"), use_selection=True,
                             object_types={"MESH"}, use_mesh_modifiers=True, mesh_smooth_type="FACE",
                             apply_unit_scale=True, bake_space_transform=True, path_mode="STRIP",
                             add_leaf_bones=False)
    return {o.name: sum(len(p.vertices) - 2 for p in o.data.polygons) for o in pieces}


def main(out_dir, names=None):
    mm = load_models()
    os.makedirs(out_dir, exist_ok=True)
    stud = stud_image(out_dir)
    report = {}
    for name in names or list(mm.PALETTES):
        report[name] = bake_crate(mm, name, out_dir, stud)
    return report


if __name__ == "__main__":
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    print(main(argv[0] if argv else os.path.join(HERE, "out", "roblox")))
