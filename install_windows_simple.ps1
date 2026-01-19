param([switch]$SkipVenv = $false)

Write-Host "TRACE Forensic Toolkit - Windows Setup`n"

$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Host "Project root: $ScriptDir`n"

# Check Python
Write-Host "Checking Python installation..."
$PythonCmd = (Get-Command python.exe -ErrorAction SilentlyContinue).Path
if (-not $PythonCmd) {
    Write-Host "ERROR: Python not found. Please install Python 3.8+"
    exit 1
}
$PythonVersion = &$PythonCmd --version 2>&1
Write-Host "Found Python: $PythonVersion`n"

# Create venv
$VenvPath = Join-Path $ScriptDir "venv"
if ((Test-Path $VenvPath) -and -not $SkipVenv) {
    Write-Host "Virtual environment exists. Removing..."
    Remove-Item -Recurse -Force $VenvPath
}

if (-not (Test-Path $VenvPath)) {
    Write-Host "Creating Python virtual environment..."
    &$PythonCmd -m venv $VenvPath
    Write-Host "Virtual environment created`n"
}

# Activate venv
Write-Host "Activating virtual environment..."
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"
&$ActivateScript

# Upgrade pip
Write-Host "Upgrading pip, setuptools, wheel..."
python.exe -m pip install --upgrade pip setuptools wheel | Out-Null

# Install requirements
$RequirementsFile = Join-Path $ScriptDir "requirements.txt"
if (Test-Path $RequirementsFile) {
    Write-Host "Installing dependencies (this may take a few minutes)...`n"
    python.exe -m pip install --no-cache-dir -r $RequirementsFile
    Write-Host "`nInstallation complete!`n"
    Write-Host "To start TRACE, run: python main.py"
    Write-Host "To exit the venv later, run: deactivate"
}
else {
    Write-Host "ERROR: requirements.txt not found"
    exit 1
}
