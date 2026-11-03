<#
	Created By: 	Nari

	Sets up a new game in this repo, made from the new-project template. Copies ume into <name>-game and ume-gui into
	<name>-gui without their git history, names both projects after the game, moves the place to <name>.rbxl, adds the
	game's theme, swaps in each folder's agent files for games (its .game/ folder), mirrors the game's libraries into
	the gui folder, and replaces this template's files with the game's.

	  ./setup.ps1                      Names the game after this folder (epic-mining, "Epic Mining")
	  -Name <name>                     The game's folder name: lowercase words joined by "-"
	  -Title "<Title>"                 The game's display name (default: the name in Title Case)
	  -UmeRef <tag>                    The ume version to copy (default: its newest v* tag; "main" works too)
	  -UmeGuiRef <tag>                 The ume-gui version to copy (default: its newest v* tag)
	  -Author <nickname>               The Created By name on files setup writes (default: the ume-vscode nickname
	                                   setting, else the git identity)

	It works in a temporary folder and changes this repo only once everything is ready. It runs once: it stops when
	template/ is gone.
#>
param(
	[string]$Name,
	[string]$Title,
	[string]$UmeRef,
	[string]$UmeGuiRef,
	[string]$Author
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$template = Join-Path $root "template"
$umeUrl = "https://github.com/ume-roblox/ume"
$umeGuiUrl = "https://github.com/ume-roblox/ume-gui"

#%%%%%%%%%%%%%%%%%%%% Helpers

# Returns a repo's newest v* tag on GitHub.
function Get-NewestTag([string]$url) {
	$tags = @(git ls-remote --tags --refs $url "v*" | ForEach-Object { ($_ -split "refs/tags/")[1] })
	if ($LASTEXITCODE -ne 0) { throw "Can't read the tags of $url (check your git access to it)" }
	$tag = $tags | Where-Object { $_ -match '^v\d+(\.\d+){1,3}$' } | Sort-Object { [version]$_.Substring(1) } -Descending | Select-Object -First 1
	if (-not $tag) { throw "$url has no v* tag: pass a ref" }
	return $tag
}

# Returns the author nickname: the ume-vscode setting, else the git identity (luau/authorship.md).
function Get-Nickname {
	foreach ($editor in @("Cursor", "Code")) {
		$settings = Join-Path $env:APPDATA "$editor\User\settings.json"
		if (-not (Test-Path $settings)) { continue }
		$match = Select-String -Path $settings -Pattern '"ume-vscode\.general\.username"\s*:\s*"([^"]*)"' | Select-Object -First 1
		if ($match -and $match.Matches[0].Groups[1].Value -notin @("", "-")) { return $match.Matches[0].Groups[1].Value }
	}
	$identity = "$(git config user.name) $(git config user.email)"
	if ($identity -match "nari|nyaridev") { return "Nari" }
	$userName = git config user.name
	if ($userName) { return $userName }
	throw "Can't tell who you are: pass -Author <nickname>"
}

# Reads a text file, changes it and writes it back as UTF-8 without a BOM, keeping its line endings.
function Edit-Text([string]$path, [scriptblock]$change) {
	$text = [IO.File]::ReadAllText($path)
	[IO.File]::WriteAllText($path, (& $change $text), [Text.UTF8Encoding]::new($false))
}

# Sets the "name" of a folder's default.project.json.
function Set-ProjectName([string]$folder, [string]$projectName) {
	Edit-Text (Join-Path $folder "default.project.json") {
		param($text)
		([regex]'"name":\s*"[^"]*"').Replace($text, "`"name`": `"$projectName`"", 1)
	}
}

# Swaps in the agent files a game gets (the folder's .game/: AGENTS.md, CLAUDE.md, .claude/rules/family/ and the
# code folder's starter game rules) for the ones for working on ume or ume-gui itself.
function Use-GameFiles([string]$folder) {
	$gameFiles = Join-Path $folder ".game"
	if (-not (Test-Path $gameFiles)) { throw "$folder has no .game/ folder: this setup needs ume 2.0.0 and ume-gui 4.1.0 or newer" }
	Remove-Item (Join-Path $folder "AGENTS.md"), (Join-Path $folder "CLAUDE.md"), (Join-Path $folder ".claude/rules/family") -Recurse -Force
	foreach ($file in Get-ChildItem $gameFiles -File -Recurse -Force) {
		$target = Join-Path $folder $file.FullName.Substring($gameFiles.Length + 1)
		New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
		Copy-Item $file.FullName $target -Force
	}
	Remove-Item $gameFiles -Recurse -Force
}

#%%%%%%%%%%%%%%%%%%%% Checks

if (-not (Test-Path $template)) { throw "Setup already ran: template/ is gone." }

# Never turn the template itself into a game
$origin = git -C $root remote get-url origin 2>$null
if ($origin -match "ume-roblox/new-project(\.git)?$") { throw "This is the new-project template itself: make a repo from it, then run setup there." }

if (-not $Name) { $Name = (Split-Path $root -Leaf).ToLower() }
if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { throw "The name must be lowercase words joined by '-' (got '$Name'): pass -Name" }
if (-not $Title) { $Title = ($Name -split "-" | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }) -join " " }
$themeName = $Title -replace "[^A-Za-z0-9]", ""
if ($themeName -notmatch "^[A-Za-z]") { throw "Can't make a theme name from '$Title': pass a -Title that starts with a letter" }
if (-not $Author) { $Author = Get-Nickname }

$gameFolder = "$Name-game"
$guiFolder = "$Name-gui"
$place = "$Name.rbxl"
foreach ($path in @($gameFolder, $guiFolder, $place)) {
	if (Test-Path (Join-Path $root $path)) { throw "$path already exists in this repo" }
}

# Each ref defaults to its repo's newest tag. A passed tag older than that is warned about, since it usually came from
# a stale doc rather than the user
$newestUme = Get-NewestTag $umeUrl
$newestUmeGui = Get-NewestTag $umeGuiUrl
if (-not $UmeRef) { $UmeRef = $newestUme }
if (-not $UmeGuiRef) { $UmeGuiRef = $newestUmeGui }
foreach ($ref in @(@("ume", "-UmeRef", $UmeRef, $newestUme), @("ume-gui", "-UmeGuiRef", $UmeGuiRef, $newestUmeGui))) {
	if ($ref[2] -match '^v\d+(\.\d+){1,3}$' -and [version]$ref[2].Substring(1) -lt [version]$ref[3].Substring(1)) {
		Write-Warning "$($ref[1]) $($ref[2]) is older than $($ref[0])'s newest tag $($ref[3]). Run without $($ref[1]) to get the newest."
	}
}

Write-Host "Setting up $Title ($Name) from ume $UmeRef and ume-gui $UmeGuiRef"

#%%%%%%%%%%%%%%%%%%%% Copy

$temp = Join-Path ([IO.Path]::GetTempPath()) "new-project-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
New-Item -ItemType Directory -Force $temp | Out-Null
try {
	$gameDir = Join-Path $temp $gameFolder
	$guiDir = Join-Path $temp $guiFolder
	foreach ($copy in @(@($umeUrl, $UmeRef, $gameDir), @($umeGuiUrl, $UmeGuiRef, $guiDir))) {
		git -c advice.detachedHead=false clone --quiet --depth 1 --branch $copy[1] $copy[0] $copy[2]
		if ($LASTEXITCODE -ne 0) { throw "Can't clone $($copy[0]) at $($copy[1])" }
		Remove-Item (Join-Path $copy[2] ".git") -Recurse -Force
	}

	#%%%%%%%%%%%%%%%%%%%% Game Folder

	Set-ProjectName $gameDir $gameFolder
	Use-GameFiles $gameDir
	$umePlace = Join-Path $gameDir "ume.rbxl"
	if (Test-Path $umePlace) { Move-Item $umePlace (Join-Path $temp $place) }

	#%%%%%%%%%%%%%%%%%%%% Gui Folder

	Set-ProjectName $guiDir $guiFolder
	Use-GameFiles $guiDir

	# The game's theme, extending System
	$themeDir = Join-Path $guiDir "src\themes\$themeName"
	New-Item -ItemType Directory -Force $themeDir | Out-Null
	$theme = "--[[`n`tCreated By: `t$Author`n]]`n`n--- @type UmeGui_ThemeDefinition`nlocal _theme = {`n`n`t--[[ General ]]`n`n`tExtends = `"System`",`n`n`t--[[ Tokens ]]`n`n`tTokens = {},`n}`n`nreturn _theme`n"
	[IO.File]::WriteAllText((Join-Path $themeDir "init.lua"), $theme, [Text.UTF8Encoding]::new($false))

	# The front pages and their art describe ume and ume-gui, not this game
	foreach ($dir in @($gameDir, $guiDir)) {
		Remove-Item (Join-Path $dir "README.md") -Force -ErrorAction SilentlyContinue
		Remove-Item (Join-Path $dir "docs\assets") -Recurse -Force -ErrorAction SilentlyContinue
	}

	# Mirror the game's libraries into the gui folder, so previews use the game's components and sounds
	try {
		& (Join-Path $guiDir "scripts\Sync.ps1") Libs -Framework $gameDir | Out-Null
	}
	catch {
		throw "ume $UmeRef and ume-gui $UmeGuiRef don't fit together ($($_.Exception.Message)). Tag a newer ume and run setup again, or pass -UmeRef main for its unreleased changes. Nothing was changed."
	}

	#%%%%%%%%%%%%%%%%%%%% Root Files

	$values = @{ "Name" = $Name; "Title" = $Title; "Theme" = $themeName; "UmeRef" = $UmeRef; "UmeGuiRef" = $UmeGuiRef }
	$rootFiles = @{}
	foreach ($file in Get-ChildItem $template -File -Force) {
		$text = [IO.File]::ReadAllText($file.FullName)
		foreach ($key in $values.Keys) { $text = $text.Replace("{{$key}}", $values[$key]) }
		$rootFiles[$file.Name] = $text
	}

	#%%%%%%%%%%%%%%%%%%%% Applying

	# Everything is ready: change the repo
	Move-Item $gameDir (Join-Path $root $gameFolder)
	Move-Item $guiDir (Join-Path $root $guiFolder)
	if (Test-Path (Join-Path $temp $place)) { Move-Item (Join-Path $temp $place) (Join-Path $root $place) }
	foreach ($fileName in $rootFiles.Keys) {
		[IO.File]::WriteAllText((Join-Path $root $fileName), $rootFiles[$fileName], [Text.UTF8Encoding]::new($false))
	}
	Remove-Item $template -Recurse -Force
	Remove-Item $PSCommandPath -Force
}
finally {
	Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
}

#%%%%%%%%%%%%%%%%%%%% Next Steps

Write-Host ""
Write-Host "$Title is set up:"
Write-Host "  $gameFolder/   the game's code (ume $UmeRef)"
Write-Host "  $guiFolder/    the game's guis (ume-gui $UmeGuiRef), with the $themeName theme"
Write-Host "  $place     the place"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Commit."
Write-Host "  2. In UmeSync, make a category '$Title' and add $gameFolder and $guiFolder to it."
Write-Host "  3. Open $place and connect both projects in the Sync tool."
