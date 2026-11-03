# 0002: Component tags are authored; code writes attributes

**Status:** Accepted
**Date:** 2026-11-02
**Deciders:** Nari

## Context

Three things went wrong in My Tree Farm while code added and removed component tags:

- **Template copies built too** (2026-10-26). With `Currency_Slot` set in an exported gui, the copy in `StarterGui`
  carried the tag as well, and the component built on it beside the live copy.
- **A removed tag put old colours back** (2026-11-01). The Nametag and Titles modules stopped a scrolling name by
  removing `Utils_UIGradientMove`, wrote new colours, and added the tag back for a moving look. The new colours could
  reach the client before the removal, and the component's `Destroy` then restored the gold it had saved, under the
  new letters. `Rarity_Gradient` did the same on every change of rarity.
- **A look that changes with game data** (2026-11-02). A title's effects change with the player's level, so a tag set
  in the gui table couldn't say which effect a label shows, and `ApplyLook` added the tag at runtime.

## Decision

**Tags are authored where the element is made** (a gui's node `Tags`, or the instance in the place), and code never
adds or removes a component's tag at runtime.

- An effect that depends on game data keeps its tag, with attributes that leave it off. Code turns it on and off by
  writing those attributes (`Utils_MoveSpeed` 0 stops a scroll; `Utils_LetterText` and `Utils_TextShine` do nothing
  while their attributes are off).
- A component follows its attributes for as long as it is bound (`Utils_UIGradientMove` follows `Utils_SourceColor`),
  so changes arriving in any order leave the right look.
- A component whose tag guis export sets `IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }`.

Rule: `ume/components.md` → Tags and loading.

## Options considered

| | A: authored tags, attributes from code (chosen) | B: code adds and removes tags |
| --- | --- | --- |
| Order of replicated changes | Any order ends right | A removal after new colours restores old ones |
| Where to see what an element runs | In the gui table or the place | Only by reading the code |
| Cost of an effect that is off | A bound component that does nothing | None |
