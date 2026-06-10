[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,

    [ValidateSet("public", "private")]
    [string]$Visibility = "public",

    [string]$Description = "ZMK firmware for the Handpad20 E73/nRF52840 4x10 keyboard"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is not installed. Run .\scripts\setup.ps1 first."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is not installed. Install it with: winget install --id GitHub.cli"
}

& gh auth status
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run: gh auth login"
}

Push-Location $repoRoot
try {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot ".git"))) {
        & git init
        if ($LASTEXITCODE -ne 0) {
            throw "git init failed."
        }
    }

    & git add --all
    if ($LASTEXITCODE -ne 0) {
        throw "git add failed."
    }

    & git diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        & git commit -m "Add reproducible ZMK setup and build workflow"
        if ($LASTEXITCODE -ne 0) {
            throw "git commit failed. Configure git user.name and user.email first."
        }
    } else {
        Write-Host "No uncommitted changes to publish."
    }

    $origin = & git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and $origin) {
        Write-Host "Using existing remote: $origin"
        & git push -u origin HEAD
        if ($LASTEXITCODE -ne 0) {
            throw "git push failed."
        }
    } else {
        & gh repo create $Repository `
            "--$Visibility" `
            --description $Description `
            --source $repoRoot `
            --remote origin `
            --push

        if ($LASTEXITCODE -ne 0) {
            throw "GitHub repository creation or push failed."
        }
    }

    Write-Host ""
    $url = & gh repo view --json url --jq ".url"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Published: $url" -ForegroundColor Green
    }
} finally {
    Pop-Location
}
