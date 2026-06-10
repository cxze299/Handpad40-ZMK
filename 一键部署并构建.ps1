[CmdletBinding()]
param(
    [ValidateSet("Studio", "UF2", "SWD", "All")]
    [string]$Target = "Studio",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $repoRoot "setup-and-build.ps1") -Target $Target -Force:$Force
