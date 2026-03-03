@echo off
:: ──────────────────────────────────────────────────────────────────
::  Sequential Sentence Classification — Capstone Project
::  Windows venv setup  |  Python 3.12+ compatible
::  Usage: Double-click OR run from Command Prompt
:: ──────────────────────────────────────────────────────────────────

setlocal

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%venv"

echo.
echo ================================================
echo   Capstone Project -- venv Setup  (Windows)
echo   Location: %VENV_DIR%
echo ================================================
echo.

:: Check Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found on PATH.
    echo        Install from https://python.org
    echo        Tick "Add Python to PATH" during setup.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo   Found: %%v

:: Create venv - inherit system site-packages so numpy/pandas/sklearn ready immediately
echo.
echo Creating virtual environment...
python -m venv --system-site-packages "%VENV_DIR%"
if errorlevel 1 (
    echo ERROR: venv creation failed.
    pause
    exit /b 1
)
echo   venv created: %VENV_DIR%

:: Check packages via helper script (avoids CMD inline Python parsing issues)
echo.
"%VENV_DIR%\Scripts\python.exe" "%SCRIPT_DIR%check_packages.py"

:: Register Jupyter kernel if ipykernel present
echo Checking for Jupyter kernel registration...
"%VENV_DIR%\Scripts\python.exe" -c "import ipykernel" >nul 2>&1
if errorlevel 1 (
    echo   ipykernel not found.
    echo   Run: pip install ipykernel ^&^& python -m ipykernel install --user --name=capstone_venv
) else (
    "%VENV_DIR%\Scripts\python.exe" -m ipykernel install --user --name=capstone_venv --display-name "Python (capstone_venv)"
    echo   Kernel registered: Python (capstone_venv)
)

echo.
echo ================================================
echo   DONE! Next steps:
echo.
echo   1. Activate:
echo      %VENV_DIR%\Scripts\activate.bat
echo.
echo   2. Install deep learning packages (Models 2-4):
echo      pip install tensorflow==2.19.0 tf-keras tensorflow-hub
echo      pip install transformers==4.47.0
echo      pip install torch==2.6.0
echo.
echo   3. Launch notebook:
echo      pip install jupyter ipykernel
echo      python -m ipykernel install --user --name=capstone_venv
echo      jupyter notebook Sequential_Sentence_Classification.ipynb
echo ================================================
echo.
pause
