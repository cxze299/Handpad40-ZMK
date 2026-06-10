$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_iqk45_cols5_14.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_layout40.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using iqk45 reference scan: full COL1..COL16, mapped to main COL5..COL14."
Write-Host "Build with your normal ZMK build command or: D:\ZMK_Firmware_cxze\scripts\build-swd.ps1"
