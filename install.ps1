# Installs every skill in .\skills into the user-scope Claude Code skills folder.
# Usage: .\install.ps1 [-Target <dir>]   (default: ~\.claude\skills)
param(
    [string]$Target = (Join-Path $HOME '.claude\skills')
)

$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot 'skills'

if (-not (Test-Path $src)) { throw "skills folder not found: $src" }
New-Item -ItemType Directory -Force -Path $Target | Out-Null

$count = 0
foreach ($dir in Get-ChildItem -Path $src -Directory) {
    if (-not (Test-Path (Join-Path $dir.FullName 'SKILL.md'))) {
        Write-Host "skip $($dir.Name) (no SKILL.md)"
        continue
    }
    $dest = Join-Path $Target $dir.Name
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse -Path $dir.FullName -Destination $dest
    Write-Host "installed $($dir.Name)"
    $count++
}

Write-Host "$count skills installed to $Target - restart Claude Code to load them."
