$ErrorActionPreference = "Stop"
Copy-Item "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20_col2row.overlay" "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20.overlay" -Force
Write-Host "Using col2row matrix overlay."
