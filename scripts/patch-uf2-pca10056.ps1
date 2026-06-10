$ErrorActionPreference = "Stop"

$inputUf2 = "D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_uf2\zephyr\zmk.uf2"
$outputUf2 = "D:\ZMK_Firmware_cxze\zmk-work\zmk\build\handpad40_uf2\zephyr\zmk-pca10056.uf2"
$familyId = [Convert]::ToUInt32("239A0029", 16)
$uf2Magic0 = [Convert]::ToUInt32("0A324655", 16)
$uf2Magic1 = [Convert]::ToUInt32("9E5D5157", 16)

if (-not (Test-Path -LiteralPath $inputUf2)) {
    throw "Input UF2 not found: $inputUf2"
}

$bytes = [System.IO.File]::ReadAllBytes($inputUf2)
if (($bytes.Length % 512) -ne 0) {
    throw "Invalid UF2 size: $($bytes.Length)"
}

for ($offset = 0; $offset -lt $bytes.Length; $offset += 512) {
    $magic0 = [System.BitConverter]::ToUInt32($bytes, $offset + 0)
    $magic1 = [System.BitConverter]::ToUInt32($bytes, $offset + 4)
    if ($magic0 -ne $uf2Magic0 -or $magic1 -ne $uf2Magic1) {
        throw "Invalid UF2 block at offset $offset"
    }

    $familyBytes = [System.BitConverter]::GetBytes($familyId)
    [System.Array]::Copy($familyBytes, 0, $bytes, $offset + 28, 4)
}

[System.IO.File]::WriteAllBytes($outputUf2, $bytes)

Write-Host "Patched UF2 family id to 0x239A0029:"
Write-Host $outputUf2
