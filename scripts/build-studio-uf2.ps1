$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "build.ps1") -Target Studio
