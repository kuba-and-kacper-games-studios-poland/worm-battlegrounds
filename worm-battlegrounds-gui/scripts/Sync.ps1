<#
	Created By: 	Nari

	Keeps UmeGui's mirror of the framework libraries in step with the game it is paired with.

	  ./scripts/Sync.ps1 Libs        Mirrors the game's framework libraries into src/engine/Libs/Mirror
	  -Check                         Reports drift without writing
	  -Framework <path>              The game's framework folder (default: the sibling named after this one with
	                                 "-gui" turned into "-game", else without it: epic-mining-gui reads
	                                 ../epic-mining-game, ume-gui reads ../ume)

	The game owns the libraries; this repo owns src/engine.
	Mirrored code is byte-identical except the one line that loads the framework pointer,
	which is pointed at UmeGui's Runtime shim instead. Every @class / @alias the mirror declares
	is renamed to UmeGui_<name> inside annotations so it never collides with the framework's own.
#>
param(
	[Parameter(Mandatory = $true)][ValidateSet("Libs")][string]$Mode,
	[switch]$Check,
	[string]$Framework
)

$ErrorActionPreference = "Stop"

$repo = Resolve-Path (Join-Path $PSScriptRoot "..")

# The paired framework folder next to this one: <base>-game in a game made from new-project, else <base>
if (-not $Framework) {
	$repoName = Split-Path $repo -Leaf
	if ($repoName -notmatch "-gui$") { throw "Can't tell the game folder from '$repoName': pass -Framework <path>" }
	$parent = Split-Path $repo -Parent
	$base = $repoName -replace "-gui$", ""
	$Framework = Join-Path $parent "$base-game"
	if (-not (Test-Path $Framework)) { $Framework = Join-Path $parent $base }
}
if (-not (Test-Path $Framework)) { throw "Missing game folder: $Framework (pass -Framework <path>)" }

$framework = Resolve-Path $Framework
$mirror = Join-Path $repo "src\engine\Libs\Mirror"

$pointerLine = 'local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)'
$runtimeLine = 'local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))'
$typePrefix = "UmeGui_"

# Source (relative to the game's src) -> destination (relative to Libs/Mirror)
$libsMap = [ordered]@{
	"libs\External\BigNum"                                  = "BigNum"
	"libs\External\GoodSignal"                              = "GoodSignal"
	"libs\Internal\Create"                                  = "Create"
	"libs\Internal\Color"                                   = "Color"
	"libs\Internal\UIEmitter"                               = "UIEmitter"
	"modules\Utils\Utils\Settings.lua"                      = "Utils\Settings.lua"
	"modules\Utils\Utils\_meta"                             = "Utils\_meta"
	"modules\Utils\Utils\Data"                              = "Utils\Data"
	"modules\Utils\Utils\Components\Button"                 = "Utils\Components\Button"
	"modules\Utils\Utils\Components\Visual"                 = "Utils\Components\Visual"
	"modules\Utils\Utils\Components\Scaler\UIGrid.lua"      = "Utils\Components\Scaler\UIGrid.lua"
	"modules\Utils\Utils\Scripts\UIStrokeScaler.lua"        = "Utils\Scripts\UIStrokeScaler.lua"
	"modules\Utils\Utils\Scripts\UIStrokeScaler_Billboard.lua" = "Utils\Scripts\UIStrokeScaler_Billboard.lua"
	"modules\Utils\Utils\Scripts\ImageSliceScaler.lua"      = "Utils\Scripts\ImageSliceScaler.lua"
	"modules\Utils\Utils\Scripts\GuiVisibility.lua"         = "Utils\Scripts\GuiVisibility.lua"
	"modules\Utils\Utils\Scripts\ButtonPress.lua"           = "Utils\Scripts\ButtonPress.lua"
	"global_data\Sound"                                     = "Sound"
}

#%%%%%%%%%%%%%%%%%%%% Expand Files

# Returns (source, destination) pairs for a file or every .lua file under a folder.
function Expand-Files([string]$source, [string]$destination) {
	$pairs = @()
	if (Test-Path $source -PathType Leaf) {
		$pairs += , @($source, $destination)
	}
	else {
		foreach ($file in Get-ChildItem $source -Recurse -File -Filter *.lua) {
			$relative = $file.FullName.Substring($source.Length).TrimStart("\")
			$pairs += , @($file.FullName, (Join-Path $destination $relative))
		}
	}
	return , $pairs
}

#%%%%%%%%%%%%%%%%%%%% Sync Tree

# Writes every expected file, removes files the mirror no longer lists, and returns the drift count.
function Sync-Tree([hashtable]$expected, [string]$root) {
	$drift = 0

	foreach ($destination in $expected.Keys) {
		$content = $expected[$destination]
		$current = if (Test-Path $destination) { [IO.File]::ReadAllText($destination) } else { $null }
		if ($current -ceq $content) { continue }

		$drift++
		Write-Host "$(if ($Check) { 'drift' } else { 'write' })  $($destination.Substring($root.Length + 1))"
		if (-not $Check) {
			New-Item -ItemType Directory -Force (Split-Path $destination) | Out-Null
			[IO.File]::WriteAllText($destination, $content)
		}
	}

	if (Test-Path $root) {
		foreach ($file in Get-ChildItem $root -Recurse -File) {
			if ($expected.ContainsKey($file.FullName)) { continue }

			$drift++
			Write-Host "$(if ($Check) { 'extra' } else { 'remove' }) $($file.FullName.Substring($root.Length + 1))"
			if (-not $Check) { Remove-Item $file.FullName }
		}
		if (-not $Check) {
			Get-ChildItem $root -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending |
				Where-Object { -not (Get-ChildItem $_.FullName -Force) } | Remove-Item
		}
	}

	return $drift
}

#%%%%%%%%%%%%%%%%%%%% Prefix Types

# Renames every @class / @alias declared across the files to $typePrefix<name>, touching only `--- @tag ...` annotation text.
function Add-TypePrefix([hashtable]$files) {
	$names = @{}
	foreach ($content in $files.Values) {
		foreach ($match in [regex]::Matches($content, '---[ \t]*@(?:class|alias)[ \t]+(\w+)')) {
			$names[$match.Groups[1].Value] = $true
		}
	}
	if ($names.Count -eq 0) { return }

	$namePattern = [regex]('(?<![\w.])(' + (($names.Keys | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?!\w)')
	$annotation = [regex]'---[ \t]*@[^\r\n]*'

	foreach ($destination in @($files.Keys)) {
		$files[$destination] = $annotation.Replace($files[$destination], {
			param($line)
			$namePattern.Replace($line.Value, "$typePrefix`$1")
		})
	}
}

#%%%%%%%%%%%%%%%%%%%% Modes

$expected = @{}

foreach ($entry in $libsMap.GetEnumerator()) {
	$source = Join-Path $framework "src\$($entry.Key)"
	if (-not (Test-Path $source)) { throw "Missing framework source: $source" }

	foreach ($pair in (Expand-Files $source (Join-Path $mirror $entry.Value))) {
		$content = [IO.File]::ReadAllText($pair[0])
		if ($entry.Value.StartsWith("Utils")) {
			$content = $content.Replace($pointerLine, $runtimeLine)
		}
		$expected[$pair[1]] = $content
	}
}
Add-TypePrefix $expected

$drift = Sync-Tree $expected $mirror

if ($drift -eq 0) {
	Write-Host "$Mode is in sync with $framework."
}
elseif ($Check) {
	Write-Host "$Mode has $drift drifted file(s) against $framework."
	exit 1
}
else {
	Write-Host "$Mode synced from $framework ($drift file(s))."
}
