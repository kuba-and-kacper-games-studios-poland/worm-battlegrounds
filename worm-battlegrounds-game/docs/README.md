<h1 align="center">Ume - Documentation</h1>

<div align="center">

<table>
<thead>
<tr><th>Document</th><th>Description</th></tr>
</thead>
<tbody>

<tr><td colspan="2" align="center"><strong>Architecture</strong></td></tr>
<tr><td><a href="architecture/project-structure.md"><strong>Project Structure</strong></a></td><td>Repo layout and major folders.</td></tr>
<tr><td><a href="architecture/startup-order.md"><strong>Startup Order</strong></a></td><td>Startup order on server and client.</td></tr>
<tr><td><a href="architecture/start-tasks.md"><strong>Start Tasks</strong></a></td><td>Per-task breakdown of <code>core/game_instance/Start/tasks/</code>.</td></tr>
<tr><td><a href="architecture/module-communication.md"><strong>Module Communication</strong></a></td><td>How modules talk to each other inside the framework.</td></tr>
<tr><td><a href="architecture/networking.md"><strong>Networking</strong></a></td><td>Client &harr; server communication patterns.</td></tr>
<tr><td><a href="architecture/place-loader.md"><strong>Place Loader</strong></a></td><td>How places are resolved and loaded.</td></tr>

<tr><td colspan="2" align="center"><strong>Authoring Guides</strong></td></tr>
<tr><td colspan="2" align="center"><em>Structure</em></td></tr>
<tr><td><a href="guides/module-structure.md"><strong>Module Structure</strong></a></td><td>Entry scripts, sections, <code>Init</code>/<code>Start</code>, registry, conventions.</td></tr>
<tr><td><a href="guides/component-structure.md"><strong>Component Structure</strong></a></td><td><code>*.comp.json</code>, layout, class naming, lifecycle, <code>I.Component</code>.</td></tr>
<tr><td><a href="guides/data-structure.md"><strong>Data Structure</strong></a></td><td><code>Data/</code> rows, typing, loaders vs <code>Settings.lua</code>.</td></tr>
<tr><td><a href="guides/settings-structure.md"><strong>Settings Structure</strong></a></td><td><code>Settings.lua</code>, <code>I.Settings</code>, organization.</td></tr>
<tr><td colspan="2" align="center"><em>Documentation</em></td></tr>
<tr><td><a href="guides/types.md"><strong>Types</strong></a></td><td>Luau vs annotations, <code>@class</code> / <code>@alias</code>, <code>_types.lua</code>.</td></tr>
<tr><td><a href="guides/events.md"><strong>Events</strong></a></td><td>The README's Network section, Receive vs Send; inbound-only remote <code>argTypes</code>.</td></tr>
<tr><td><a href="guides/comments.md"><strong>Comments</strong></a></td><td>Function headers, <code>%</code> sections, flow comments, <code>**SERVER** |</code>.</td></tr>
<tr><td><a href="guides/module-readme.md"><strong>Module README</strong></a></td><td>The <code>_meta/README.md</code> every module and library has: API per side, network, data, settings, components, commands.</td></tr>
<tr><td colspan="2" align="center"><em>Other</em></td></tr>
<tr><td><a href="guides/tag-list-plus.md"><strong>TagListPlus</strong></a></td><td>The TagListPlus registry.</td></tr>
<tr><td><a href="guides/actors.md"><strong>Actors</strong></a></td><td>GameMode <code>Actors</code> client/server scripts.</td></tr>

<tr><td colspan="2" align="center"><strong>Decisions</strong></td></tr>
<tr><td><a href="adr/README.md"><strong>Decision Records</strong></a></td><td>The framework's decisions that are hard to reverse, and why: windows, tags, values, input, the place, AdminPanel, priorities, a game's agent files.</td></tr>
<tr><td><a href="game/lessons.md"><strong>Game Lessons</strong></a></td><td>In a game: the framework and design decisions the game settled, behind the rules in <code>.claude/rules/game/practices.md</code>.</td></tr>

<tr><td colspan="2" align="center"><strong>Reference</strong></td></tr>
<tr><td><a href="reference/core-globals.md"><strong>Core Globals</strong></a></td><td>Variables exposed on the framework instance pointer (<code>I.Camera</code>, <code>I.Dirs</code>, ...).</td></tr>
<tr><td><a href="reference/configs.md"><strong>Configs</strong></a></td><td>Files in <code>core/game_instance/Start/configs/</code>.</td></tr>
<tr><td><a href="reference/global-data.md"><strong>Global Data</strong></a></td><td>Tunables under <code>src/global_data/</code>.</td></tr>

</tbody>
</table>

</div>
