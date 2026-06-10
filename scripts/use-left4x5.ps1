$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_iqk45_left4x5_cols12_16.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_left4x5.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using left-side 4x5 layout on the verified COL12..COL16 physical columns."
Write-Host "Build board: e73_handpad40_uf2"
