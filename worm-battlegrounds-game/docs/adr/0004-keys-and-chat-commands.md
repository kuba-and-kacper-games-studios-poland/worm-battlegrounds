# 0004: Number keys belong to the hotbar; admin tools open from keys; chat commands are made on the server

**Status:** Accepted
**Date:** 2026-10-26
**Deciders:** Nari

## Context

Three input problems came up in My Tree Farm on one day:

- **Keys picked twice.** The Lumberjack's dialogue options are picked with 1 to 4, but pressing 1 also equipped the
  item in hotbar slot 1: BackpackPlus reads number keys through `UserInputService` unless the game already used them.
- **A launcher on every screen.** The AdminPanel module drew a draggable gear that Ctrl + [ showed for every player,
  with buttons for the command bar and the dashboard: a whole gui and its driver between a key and a window.
- **Commands leaking into chat.** The `/cmd` chat command, a `TextChatCommand` made on the client, still opened the
  command bar, but with `PlatformIntegratedChat` on its message was also delivered to the chat for everyone. Roblox
  also takes message text away from scripts (`TextChatMessage.Text`, `Player.Chatted`, `OnIncomingMessage`), so a
  `TextChatCommand` is the only way left to act on chat.

## Decision

- **Number keys belong to the hotbar.** A widget that uses keys binds them with ContextActionService at
  `Enum.ContextActionPriority.High`, returns `Sink` while it shows, and unbinds them when it closes.
- **Admin and development tools put nothing on players' screens.** They open from key combinations or commands:
  Ctrl + [ toggles the command bar and Ctrl + ] the dashboard (AdminPanel's `COMMAND_BAR_KEYS`, `DASHBOARD_KEYS`).
- **Chat commands are made on the server.** Their `Triggered` runs there, checks the sender, and tells the sender's
  client what to do. The message never reaches the chat, and clients still see the command for autocomplete.

Rule: `ume/input.md`.

## Options considered

| | A: as above (chosen) | B: as before |
| --- | --- | --- |
| A widget's keys | Sunk while it shows | Also reach the hotbar |
| Admin tools on a player's screen | Nothing | A gear for everyone who pressed the keys |
| `/cmd` in chat | Opens the bar, never shows | Opens the bar and shows to everyone |
