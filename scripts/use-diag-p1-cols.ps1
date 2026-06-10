$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_diag_p1_cols.overlay" "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force
Copy-Item "$repoRoot\config\handpad20_diag_p1_cols.keymap" "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Using P1-only column diagnostic layout."
Write-Host "Columns: P1.00, P1.04, P1.06"
Write-Host "Expected output: F1..F12"
Write-Host "Build board: e73_handpad40_uf2"
