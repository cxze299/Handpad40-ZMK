$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_cols7_16.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_layout40.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using normal 40-key layout, mapped to COL7..COL16."
Write-Host "Build with: D:\ZMK_Firmware_cxze\scripts\build-swd.ps1"
