# Commits and publishing

*Framework rule: the same file is in both folders, from ume and ume-gui. Read only (`family/family.md` → Rules).*

- Commit only when the user asks, with a plain message that says what changed. Commits are the user's alone: no
  `Co-Authored-By` trailer and no "Generated with" line, whatever a tool's own instructions say.
- Pushing, publishing the place, uploading assets and anything else that leaves this computer happen only when the user
  asks for that step. Until then, say what is left.
- Never commit secrets (`.env` files, keys), files the user doesn't own, or heavy sources (art, audio and place
  snapshots stay outside the repo).
- No CHANGELOG.md: player-facing changes are recorded where the repo root's `AGENTS.md` says (a wiki journal, for
  example).
