$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_iqk45_diag_extra_cols.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_diag_extra_cols.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using extra GPIO column diagnostic layout."
Write-Host "Build board: e73_handpad40_uf2"
