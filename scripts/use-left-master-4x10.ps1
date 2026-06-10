$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_left_master_4x10.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_layout40.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using 4x10 layout: left master local COL12..COL16 + right passive COL7..COL11."
Write-Host "Build board: e73_handpad40_uf2"
