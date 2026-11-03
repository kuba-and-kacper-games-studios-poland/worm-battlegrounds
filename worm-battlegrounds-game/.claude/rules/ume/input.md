# Ume input

How a game takes keys and chat commands.

- **Number keys belong to the hotbar** (BackpackPlus reads them unless the game already used them). A widget that uses
  keys binds them with ContextActionService at `Enum.ContextActionPriority.High`, returns `Sink` while it shows, and
  unbinds them when it closes (follow the gui's `Enabled`).
- **Admin and development tools put nothing on players' screens**: no button, gear or launcher. They open from key
  combinations or commands, as the AdminPanel's windows do (its README).
- **Chat commands are `TextChatCommand`s made on the server** (`Triggered` there), which then tell the sender's client
  what to do. One made on the client lets its message reach the chat (with `PlatformIntegratedChat` on), and scripts
  can no longer read chat messages (`TextChatMessage.Text`, `Player.Chatted`).
