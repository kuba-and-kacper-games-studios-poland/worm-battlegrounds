# Docs

*Framework rule: the same file is in both folders, from ume and ume-gui. Read only (`family/family.md` → Rules).*

- **Tone:** plain, short, factual. Describe what exists; label planned work as planned.
- **Decisions** about how the game uses the framework, or how it looks, go in the code folder's
  `.claude/rules/game/practices.md`, and their story in its `docs/game/lessons.md`, in the same change.
- **`docs/`** in each folder is ume's or ume-gui's reference (guides, architecture, ADRs): read only, like the
  framework rules (`family/family.md` → Rules). The game's own docs go in `docs/game/`.
- **Words:** UmeSync syncs projects into Studio; say "Rojo" only for the project file format (`*.project.json`,
  `*.model.json`).
