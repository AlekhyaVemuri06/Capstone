# ──────────────────────────────────────────────────────────────────
#  Sequential Sentence Classification — Capstone Project
#  PowerShell venv setup  |  Python 3.12+ compatible
#  Usage: powershell -ExecutionPolicy Bypass -File setup_venv.ps1
# ──────────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir   = Join-Path $ScriptDir "venv"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Capstone Project -- venv Setup (Windows)" -ForegroundColor Cyan
Write-Host "  Location: $VenvDir" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check Python
try {
    $pyVer = & python --version 2>&1
    Write-Host "  Found: $pyVer" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python not found. Install from https://python.org" -ForegroundColor Red
    Read-Host "Press Enter to exit"; exit 1
}

# Create venv
Write-Host ""
Write-Host "Creating virtual environment..." -ForegroundColor Yellow
python -m venv --system-site-packages $VenvDir
Write-Host "  venv created: $VenvDir" -ForegroundColor Green

# Check packages via helper script
Write-Host ""
& "$VenvDir\Scripts\python.exe" "$ScriptDir\check_packages.py"

# Register Jupyter kernel
Write-Host "Checking for Jupyter kernel registration..." -ForegroundColor Yellow
$kernelCheck = & "$VenvDir\Scripts\python.exe" -c "import ipykernel" 2>&1
if ($LASTEXITCODE -eq 0) {
    & "$VenvDir\Scripts\python.exe" -m ipykernel install --user `
        --name=capstone_venv --display-name "Python (capstone_venv)"
    Write-Host "  Kernel registered: Python (capstone_venv)" -ForegroundColor Green
} else {
    Write-Host "  ipykernel not found - skipping." -ForegroundColor DarkGray
    Write-Host "  Run: pip install ipykernel && python -m ipykernel install --user --name=capstone_venv" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  DONE! Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Activate:" -ForegroundColor White
Write-Host "     $VenvDir\Scripts\Activate.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Install deep learning packages (Models 2-4):" -ForegroundColor White
Write-Host "     pip install tensorflow==2.19.0 tf-keras tensorflow-hub" -ForegroundColor Yellow
Write-Host "     pip install transformers==4.47.0" -ForegroundColor Yellow
Write-Host "     pip install torch==2.6.0" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. Launch notebook:" -ForegroundColor White
Write-Host "     pip install jupyter ipykernel" -ForegroundColor Yellow
Write-Host "     python -m ipykernel install --user --name=capstone_venv" -ForegroundColor Yellow
Write-Host "     jupyter notebook Sequential_Sentence_Classification.ipynb" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
