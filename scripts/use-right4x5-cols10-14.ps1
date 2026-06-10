$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_iqk45_right4x5_cols10_14.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_right4x5.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using right-side 4x5 layout, mapped to COL10..COL14."
Write-Host "Build board: e73_handpad40_uf2"
