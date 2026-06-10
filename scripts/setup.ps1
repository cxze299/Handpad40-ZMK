[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipPrerequisites,
    [switch]$SkipSdk
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workRoot = Join-Path $repoRoot "zmk-work"
$zmkRoot = Join-Path $workRoot "zmk"
$venvRoot = Join-Path $workRoot ".venv"
$venvPython = Join-Path $venvRoot "Scripts\python.exe"
$venvWest = Join-Path $venvRoot "Scripts\west.exe"
$sdkParent = Join-Path $repoRoot "zephyr-sdk"
$sdkRoot = Join-Path $sdkParent "zephyr-sdk-0.16.3"
$downloads = Join-Path $repoRoot ".downloads"

$zmkRevision = "v0.3.0"
$sdkVersion = "0.16.3"
$sdkArchive = Join-Path $downloads "zephyr-sdk-$sdkVersion`_windows-x86_64.7z"
$sdkUrl = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$sdkVersion/zephyr-sdk-$sdkVersion`_windows-x86_64.7z"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Find-Python {
    $candidates = @(
        @{ Command = "py"; Args = @("-3.11") },
        @{ Command = "python"; Args = @() },
        @{ Command = "python3"; Args = @() },
        @{ Command = (Join-Path $env:LocalAppData "Programs\Python\Python311\python.exe"); Args = @() },
        @{ Command = (Join-Path $env:ProgramFiles "Python311\python.exe"); Args = @() }
    )

    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate.Command -ErrorAction SilentlyContinue
        $commandPath = $null

        if ($command) {
            $commandPath = $command.Source
        } elseif (Test-Path -LiteralPath $candidate.Command) {
            $commandPath = $candidate.Command
        }

        if (-not $commandPath) {
            continue
        }

        & $commandPath @($candidate.Args) -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)"
        if ($LASTEXITCODE -eq 0) {
            return @{
                Command = $commandPath
                Args = $candidate.Args
            }
        }
    }

    return $null
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$DisplayName
    )

    Write-Host "Installing $DisplayName..."
    & winget install --id $Id --exact --silent `
        --accept-package-agreements --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install $DisplayName with winget."
    }
}

function Find-7Zip {
    $command = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $knownPaths = @()
    if ($env:ProgramFiles) {
        $knownPaths += Join-Path $env:ProgramFiles "7-Zip\7z.exe"
    }
    if (${env:ProgramFiles(x86)}) {
        $knownPaths += Join-Path ${env:ProgramFiles(x86)} "7-Zip\7z.exe"
    }

    foreach ($path in $knownPaths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return $path
        }
    }

    return $null
}

Write-Host "Handpad20 ZMK environment setup"
Write-Host "Repository: $repoRoot"

if (-not $SkipPrerequisites) {
    Write-Step "Checking Windows prerequisites"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is required for automatic prerequisite installation. Install Microsoft App Installer or rerun with -SkipPrerequisites after installing Git and Python manually."
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Install-WingetPackage -Id "Git.Git" -DisplayName "Git"
        $env:Path += ";$env:ProgramFiles\Git\cmd"
    }

    $sevenZip = Find-7Zip
    if (-not $sevenZip) {
        Install-WingetPackage -Id "7zip.7zip" -DisplayName "7-Zip"
        $sevenZip = Find-7Zip
    }

    $pythonCommand = Find-Python
    if (-not $pythonCommand) {
        Install-WingetPackage -Id "Python.Python.3.11" -DisplayName "Python 3.11"
        $pythonCommand = Find-Python
    }
} else {
    $pythonCommand = Find-Python
    $sevenZip = Find-7Zip
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git was not found."
}

if (-not $pythonCommand) {
    throw "Python 3.10 or newer was not found."
}

New-Item -ItemType Directory -Force -Path $workRoot, $downloads | Out-Null

Write-Step "Preparing Python virtual environment"

if ($Force -and (Test-Path -LiteralPath $venvRoot)) {
    Remove-Item -LiteralPath $venvRoot -Recurse -Force
}

if (-not (Test-Path -LiteralPath $venvPython)) {
    & $pythonCommand.Command @($pythonCommand.Args) -m venv $venvRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create Python virtual environment."
    }
}

& $venvPython -m pip install --disable-pip-version-check --upgrade `
    "pip<25" `
    "setuptools==80.9.0" `
    "wheel" `
    "west==1.5.0" `
    "cmake<4" `
    "ninja"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to install base Python build packages."
}

Write-Step "Cloning ZMK $zmkRevision"

if ($Force -and (Test-Path -LiteralPath $zmkRoot)) {
    $resolvedZmk = [System.IO.Path]::GetFullPath($zmkRoot)
    $resolvedWork = [System.IO.Path]::GetFullPath($workRoot)
    if (-not $resolvedZmk.StartsWith($resolvedWork, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a ZMK directory outside the workspace."
    }
    Remove-Item -LiteralPath $resolvedZmk -Recurse -Force
}

if (-not (Test-Path -LiteralPath (Join-Path $zmkRoot ".git"))) {
    & git clone --branch $zmkRevision --depth 1 `
        https://github.com/zmkfirmware/zmk.git $zmkRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone ZMK."
    }
}

$gitSafeConfig = Join-Path $repoRoot "git-safe-config"
& git config --file $gitSafeConfig --replace-all safe.directory ($zmkRoot.Replace("\", "/"))
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the local Git safe-directory configuration."
}

Write-Step "Initializing west workspace"
Push-Location $workRoot
try {
    if (-not (Test-Path -LiteralPath (Join-Path $workRoot ".west"))) {
        & $venvWest init -l "$zmkRoot\app"
        if ($LASTEXITCODE -ne 0) {
            throw "west init failed."
        }
    }

    & $venvWest update
    if ($LASTEXITCODE -ne 0) {
        throw "west update failed."
    }

    & $venvWest zephyr-export
    if ($LASTEXITCODE -ne 0) {
        throw "west zephyr-export failed."
    }

    $zephyrRequirements = Join-Path $workRoot "zephyr\scripts\requirements.txt"
    if (-not (Test-Path -LiteralPath $zephyrRequirements)) {
        throw "Zephyr requirements were not found at $zephyrRequirements."
    }

    & $venvPython -m pip install --disable-pip-version-check `
        -r $zephyrRequirements
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Zephyr Python packages."
    }

    # ZMK v0.3.0 nanopb still imports pkg_resources.
    & $venvPython -m pip install --disable-pip-version-check --upgrade `
        "setuptools==80.9.0" `
        "cmake<4" `
        "ninja"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install the nanopb-compatible setuptools version."
    }
} finally {
    Pop-Location
}

if (-not $SkipSdk) {
    Write-Step "Installing Zephyr SDK $sdkVersion"
    New-Item -ItemType Directory -Force -Path $sdkParent | Out-Null

    if ($Force -and (Test-Path -LiteralPath $sdkRoot)) {
        $resolvedSdk = [System.IO.Path]::GetFullPath($sdkRoot)
        $resolvedSdkParent = [System.IO.Path]::GetFullPath($sdkParent)
        if (-not $resolvedSdk.StartsWith($resolvedSdkParent, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove an SDK directory outside the repository."
        }
        Remove-Item -LiteralPath $resolvedSdk -Recurse -Force
    }

    if (-not (Test-Path -LiteralPath $sdkRoot)) {
        if (-not (Test-Path -LiteralPath $sdkArchive)) {
            Write-Host "Downloading $sdkUrl"
            Invoke-WebRequest -Uri $sdkUrl -OutFile $sdkArchive
        }

        if (-not $sevenZip) {
            throw "7-Zip was not found. Install 7-Zip or extract $sdkArchive manually into $sdkParent."
        }

        & $sevenZip x $sdkArchive "-o$sdkParent" -y
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract the Zephyr SDK archive. Extract $sdkArchive into $sdkParent, then rerun with -SkipSdk."
        }
    }
}

if (-not (Test-Path -LiteralPath $sdkRoot)) {
    throw "Zephyr SDK was not found at $sdkRoot."
}

Write-Step "Environment ready"
Write-Host "ZMK:        $zmkRoot"
Write-Host "Python:     $venvPython"
Write-Host "Zephyr SDK: $sdkRoot"
Write-Host ""
Write-Host "Build Studio UF2 with:"
Write-Host "  .\scripts\build.ps1 -Target Studio"
