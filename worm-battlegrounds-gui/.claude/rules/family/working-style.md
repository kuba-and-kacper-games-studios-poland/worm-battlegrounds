# Working style

*Framework rule: the same file is in both folders, from ume and ume-gui. Read only (`family/family.md` → Rules).*

The folder's own rules win wherever they are more specific. "Match the existing style" means match those rules, never
strip what they require (banners, `%` bars, `--- @class`, splits).

- **Ask** when the request leaves a product choice open (which system, environment or id, what the player sees), never
  about what a rule already decides. When a request reads more than one way, name the readings instead of picking one
  silently, and state the assumptions you make.
- **Use what the framework has.** Before writing a system, check whether a framework module or component already
  does it (a currency label is a `Currency_Slot`, so no module writes the amount; a window is a WidgetManager widget;
  a button press is `I.Interact.OnPress`), and use it the way its README says. Never re-implement one in a game module.
- **Ship the request:** no features, settings, fallbacks or abstractions nobody asked for, and no error handling for
  cases that can't happen. If 200 lines could be 50, write 50. When a simpler design would do, say so before building
  the bigger one.
- **Change surgically:** every changed line traces to the request, or to a rule on a line you had to touch. A function
  you edit follows the rules in full; the rest of the file stays as it is. Remove what your change left unused, and
  mention other dead code instead of deleting it.
- **Check before calling it done**, with a check that exists here (`ume/overview.md` → Checks in the game,
  `gui/code.md` → Checks in the guis), and say what you verified and what you couldn't.
