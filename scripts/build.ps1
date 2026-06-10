[CmdletBinding()]
param(
    [ValidateSet("Studio", "UF2", "SWD", "All")]
    [string]$Target = "Studio",
    [switch]$NoPristine
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workRoot = Join-Path $repoRoot "zmk-work"
$zmkRoot = Join-Path $workRoot "zmk"
$venvRoot = Join-Path $workRoot ".venv"
$python = Join-Path $venvRoot "Scripts\python.exe"
$sitePackages = Join-Path $venvRoot "Lib\site-packages"
$sdkRoot = Join-Path $repoRoot "zephyr-sdk\zephyr-sdk-0.16.3"
$outputRoot = Join-Path $repoRoot "firmware"
$pristine = if ($NoPristine) { "auto" } else { "always" }

function Assert-Path {
    param(
        [string]$Path,
        [string]$Message
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw $Message
    }
}

function Invoke-ZmkBuild {
    param(
        [string]$Name,
        [string]$Board,
        [bool]$Studio,
        [string]$Extension
    )

    $buildDir = Join-Path $zmkRoot "build\$Name"
    $arguments = @(
        "-m", "west", "build",
        "-p", $pristine,
        "-d", $buildDir,
        "-b", $Board
    )

    if ($Studio) {
        $arguments += @("-S", "studio-rpc-usb-uart")
    }

    $arguments += @(
        (Join-Path $zmkRoot "app"),
        "--",
        "-DSHIELD=handpad20",
        "-DZMK_CONFIG=$($repoRoot.Replace('\', '/'))/config",
        "-DZMK_EXTRA_MODULES=$($repoRoot.Replace('\', '/'))"
    )

    if ($Studio) {
        $arguments += @(
            "-DCONFIG_ZMK_STUDIO=y",
            "-DCONFIG_ZMK_STUDIO_LOCKING=n",
            "-DCONFIG_ZMK_SETTINGS_SAVE_DEBOUNCE=1000",
            "-DCONFIG_ZMK_SETTINGS_RESET_ON_START=n"
        )
    }

    Write-Host ""
    Write-Host "==> Building $Name" -ForegroundColor Cyan
    & $python @arguments | ForEach-Object { Write-Host $_ }
    $buildExitCode = $LASTEXITCODE
    if ($buildExitCode -ne 0) {
        throw "$Name build failed."
    }

    $source = Join-Path $buildDir "zephyr\zmk.$Extension"
    Assert-Path $source "$Name completed without producing $source."

    New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
    $destination = Join-Path $outputRoot "handpad20_$Name.$Extension"
    Copy-Item -LiteralPath $source -Destination $destination -Force

    Write-Host "Output: $destination" -ForegroundColor Green
    return $destination
}

Assert-Path $python "Build environment is missing. Run .\scripts\setup.ps1 first."
Assert-Path $zmkRoot "ZMK source is missing. Run .\scripts\setup.ps1 first."
Assert-Path $sdkRoot "Zephyr SDK is missing. Run .\scripts\setup.ps1 first."

$env:PYTHONPATH = $sitePackages
$env:GIT_CONFIG_GLOBAL = Join-Path $repoRoot "git-safe-config"
$env:Path = "$sitePackages\cmake\data\bin;$venvRoot\Scripts;$env:Path"
$env:ZEPHYR_CMAKE = Join-Path $sitePackages "cmake\data\bin\cmake.exe"
$env:ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"
$env:ZEPHYR_SDK_INSTALL_DIR = $sdkRoot.Replace("\", "/")

# Keep active ZMK filenames synchronized with the canonical Studio sources.
Copy-Item `
    -LiteralPath (Join-Path $repoRoot "boards\shields\handpad20\handpad20_studio.overlay") `
    -Destination (Join-Path $repoRoot "boards\shields\handpad20\handpad20.overlay") `
    -Force

Copy-Item `
    -LiteralPath (Join-Path $repoRoot "config\handpad20_studio.keymap") `
    -Destination (Join-Path $repoRoot "config\handpad20.keymap") `
    -Force

$outputs = @()

switch ($Target) {
    "Studio" {
        $outputs += Invoke-ZmkBuild `
            -Name "studio_uf2" `
            -Board "e73_handpad40_uf2" `
            -Studio $true `
            -Extension "uf2"
    }
    "UF2" {
        $outputs += Invoke-ZmkBuild `
            -Name "uf2" `
            -Board "e73_handpad40_uf2" `
            -Studio $true `
            -Extension "uf2"
    }
    "SWD" {
        $outputs += Invoke-ZmkBuild `
            -Name "swd" `
            -Board "nrf52840dk_nrf52840" `
            -Studio $true `
            -Extension "hex"
    }
    "All" {
        $outputs += Invoke-ZmkBuild `
            -Name "studio_uf2" `
            -Board "e73_handpad40_uf2" `
            -Studio $true `
            -Extension "uf2"
        $outputs += Invoke-ZmkBuild `
            -Name "swd" `
            -Board "nrf52840dk_nrf52840" `
            -Studio $true `
            -Extension "hex"
    }
}

Write-Host ""
Write-Host "Build complete:" -ForegroundColor Green
$outputs | ForEach-Object { Write-Host "  $_" }
