$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_cols5_16_diagnostic.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_diagnostic48.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using diagnostic 4x12 matrix: ROW1..ROW4 + COL5..COL16."
Write-Host "Build with: D:\ZMK_Firmware_cxze\scripts\build-swd.ps1"
