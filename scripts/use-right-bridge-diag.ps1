$ErrorActionPreference = "Stop"

$repoRoot = "D:\ZMK_Firmware_cxze"

Copy-Item "$repoRoot\boards\shields\handpad20\handpad20_right_bridge_diag.overlay" `
    "$repoRoot\boards\shields\handpad20\handpad20.overlay" -Force

Copy-Item "$repoRoot\config\handpad20_right_bridge_diag.keymap" `
    "$repoRoot\config\handpad20.keymap" -Force

Write-Host "Right passive PCB diagnostic enabled."
Write-Host "Scanning controller COL7..COL11 and ROW1..ROW4 only."
