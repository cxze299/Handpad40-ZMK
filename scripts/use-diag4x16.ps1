$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_iqk45_diag4x16.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_diag4x16.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using 4x16 diagnostic layout, mapped to full COL1..COL16."
Write-Host "Build board: e73_handpad40_uf2"
