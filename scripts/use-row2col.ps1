$ErrorActionPreference = "Stop"
Copy-Item "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20_row2col.overlay" "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20.overlay" -Force
Write-Host "Using row2col matrix overlay."
