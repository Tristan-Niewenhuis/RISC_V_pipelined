$ErrorActionPreference = "Stop"

# ============================================================
# Configuration
# ============================================================

# Private repository, relative to this script.
$PrivateRepo = "."

# Public GitHub repository.
$PublicRepo = "https://github.com/Tristan-Niewenhuis/RISC_V_pipelined.git"

# Branch to publish.
$PublicBranch = "master"

# Directory to remove from the public repository.
$ProprietaryDir = "RISC_V.srcs/sources_1/proprietary"

# ============================================================
# Locate private repository
# ============================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PrivateRepoPath = Join-Path $ScriptDir $PrivateRepo

Write-Host ""
Write-Host "========================================"
Write-Host " Publishing private repository"
Write-Host "========================================"
Write-Host ""

Write-Host "Private repository:"
Write-Host "  $PrivateRepoPath"
Write-Host ""

Write-Host "Public repository:"
Write-Host "  $PublicRepo"
Write-Host ""

if (-not (Test-Path (Join-Path $PrivateRepoPath ".git"))) {
    Write-Error "Could not find a Git repository at $PrivateRepoPath"
    exit 1
}

# ============================================================
# Check for uncommitted changes
# ============================================================

Push-Location $PrivateRepoPath

try {
    $Status = git status --porcelain

    if ($Status) {
        Write-Host "ERROR: The private repository has uncommitted changes:"
        Write-Host ""
        Write-Host $Status
        Write-Host ""
        Write-Host "Commit or stash your changes before publishing."
        exit 1
    }

    # Make sure git-filter-repo exists.
    $FilterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue

    if (-not $FilterRepo) {
        Write-Host "ERROR: git-filter-repo is not installed."
        Write-Host ""
        Write-Host "Install it with:"
        Write-Host ""
        Write-Host "    py -m pip install git-filter-repo"
        Write-Host ""
        exit 1
    }

    # ========================================================
    # Create temporary directory
    # ========================================================

    $TempDir = Join-Path $env:TEMP ("public-repo-" + [guid]::NewGuid().ToString())

    Write-Host "Creating temporary repository..."
    Write-Host "  $TempDir"
    Write-Host ""

    git clone --mirror $PrivateRepoPath "$TempDir.git"

    # ========================================================
    # Remove proprietary files from ALL history
    # ========================================================

    Push-Location "$TempDir.git"

    try {
        Write-Host "Removing proprietary files from Git history:"
        Write-Host "  $ProprietaryDir"
        Write-Host ""

        git filter-repo `
            --path "$ProprietaryDir/" `
            --invert-paths `
            --force

        # ====================================================
        # Safety check
        # ====================================================

        Write-Host "Checking that proprietary files are absent..."

        $Objects = git rev-list --objects --all

        $FoundProprietary = $Objects |
            Select-String -SimpleMatch "$ProprietaryDir/"

        if ($FoundProprietary) {
            Write-Error "PROPRIETARY FILES ARE STILL PRESENT. Aborting push."
            exit 1
        }

        Write-Host "Verified: proprietary files are absent."
        Write-Host ""

        # ====================================================
        # Push all branches and tags
        # ====================================================

        Write-Host "Pushing all branches and tags..."
        Write-Host ""

        git push --force --mirror $PublicRepo

        Write-Host ""
        Write-Host "========================================"
        Write-Host " Public repository updated successfully"
        Write-Host "========================================"
        Write-Host ""

        Write-Host "Private:"
        Write-Host "  $PrivateRepoPath"
        Write-Host ""

        Write-Host "Public:"
        Write-Host "  $PublicRepo"
        Write-Host ""

        Write-Host "Excluded:"
        Write-Host "  $ProprietaryDir"
        Write-Host ""

    }
    finally {
        Pop-Location
    }

}
finally {
    Pop-Location

    # Clean up temporary repository.
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir
    }
    if ($TempDir -and (Test-Path "$TempDir.git")) {
        Remove-Item -Recurse -Force "$TempDir.git"
    }
}
