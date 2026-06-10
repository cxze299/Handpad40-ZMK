[CmdletBinding()]
param(
    [ValidateSet("Studio", "UF2", "SWD", "All")]
    [string]$Target = "Studio",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $repoRoot "scripts\setup.ps1") -Force:$Force
& (Join-Path $repoRoot "scripts\build.ps1") -Target $Target
