# Ume place

What a game keeps in the place, and where its modules put what they make in the world.

- **Templates code clones are named `PREFAB | Name`**, in the place as in gui templates (ume-gui's
  `gui/format.md` → Naming). Collectibles and anything found by a data id keep that id as their name. A setting names
  the prefab in full (`PLOT_PREFAB = "PREFAB | Plot"`), and code renames each clone to the plain name.
- **A template that would show at 0, 0, 0 sits on a holder part:** a BillboardGui on the Attachment of a small part,
  emitters and Attachments under one. Code finds the template anywhere in its folder (`FindFirstChild(name, true)`)
  and clones only it, never the holder.
- **What a module makes in the world goes in its own folder, `Workspace.Ume.<Module>`**, never straight in Workspace or
  the camera. The module's server creates it in `Init` (`I.Create("Folder")` named `_localName` under
  `I.Dirs.UmeWorkspace`); clients find it with `I.Dirs.UmeWorkspace:WaitForChild(_localName)` and parent what they
  make there. A tool script in `src/global_data` uses the folder of the module whose feature it serves. A Highlight
  never sits in Workspace itself: with no Adornee it outlines its parent, the whole map.
- **Lighting presets live in the place**, made with the Ume plugin's Lighting Manager: each is `Lighting.Presets.<Id>`
  (a `__config` with Lighting's properties as attributes, plus its Sky, Atmosphere and post effects), and the active
  one is Lighting itself. The Lighting module reads them at start, and code applies one by id
  (`I.Lighting.SetActivePreset(id)`). Lua presets in `src/global_data/Lighting/Presets/` are the template's and those
  the place can't hold.
