$ErrorActionPreference = "Stop"
Copy-Item "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20_cols5_14.overlay" "D:\ZMK_Firmware_cxze\boards\shields\handpad20\handpad20.overlay" -Force
Write-Host "Using 48-key compatible scan range COL5..COL16, mapped to leftmost COL5..COL14."
