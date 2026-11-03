# Luau tweens

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

Every tween has this shape, with a PascalCase prefix (`FadeIn`, `Show`, `FOV`) and always the suffixes `_TweenInfo`,
`_TweenGoal`, `_Tween`:

```lua
local Name_TweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
local Name_TweenGoal = {}
local Name_Tween: Tween = TweenService:Create(elem, Name_TweenInfo, Name_TweenGoal)
Name_Tween:Play()
```

- A `TweenInfo` may be defined elsewhere and reused (a module local, Settings, another function).
- The goal and the tween are made where it plays; never inline the goal table into `Create`.
