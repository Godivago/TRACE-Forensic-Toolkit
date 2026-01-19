# TRACE Forensic Toolkit - Windows Installer
# This script sets up a Python virtual environment and installs dependencies

param(
    [switch]$SkipVenv = $false
)

# Colors for output
$ErrorColor = "`e[31m"
$SuccessColor = "`e[32m"
$InfoColor = "`e[36m"
$WarningColor = "`e[33m"
$Reset = "`e[0m"

Write-Host "${InfoColor}╔════════════════════════════════════════════════╗${Reset}"
Write-Host "${InfoColor}║    TRACE Forensic Toolkit - Windows Setup      ║${Reset}"
Write-Host "${InfoColor}╚════════════════════════════════════════════════╝${Reset}`n"

# Get the script directory
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) {
    $ScriptDir = Get-Location
}

Write-Host "${InfoColor}Project root:${Reset} $ScriptDir`n"

# Check Python availability
Write-Host "${InfoColor}Checking Python installation...${Reset}"
$PythonCmd = $null
$PythonVersion = $null

try {
    $PythonCmd = (Get-Command python.exe -ErrorAction Stop).Path
    $PythonVersion = & $PythonCmd --version 2>&1
    Write-Host "${SuccessColor}✓ Found Python: $PythonVersion${Reset}`n"
}
catch {
    Write-Host "${ErrorColor}✗ Python not found in PATH${Reset}"
    Write-Host "${WarningColor}Please install Python 3.8+ from python.org or Microsoft Store${Reset}"
    exit 1
}

# Create virtual environment if needed
$VenvPath = Join-Path $ScriptDir "venv"
if (-not $SkipVenv) {
    if (Test-Path $VenvPath) {
        Write-Host "${WarningColor}Virtual environment already exists at $VenvPath${Reset}"
        $Response = Read-Host "Recreate it? (y/n)"
        if ($Response -eq 'y') {
            Write-Host "${InfoColor}Removing old venv...${Reset}"
            Remove-Item -Recurse -Force $VenvPath
        }
    }
    
    if (-not (Test-Path $VenvPath)) {
        Write-Host "${InfoColor}Creating Python virtual environment...${Reset}"
        & $PythonCmd -m venv $VenvPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "${ErrorColor}✗ Failed to create venv${Reset}"
            exit 1
        }
        Write-Host "${SuccessColor}✓ Virtual environment created${Reset}`n"
    }
}

# Activate venv
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"
if (Test-Path $ActivateScript) {
    Write-Host "${InfoColor}Activating virtual environment...${Reset}"
    & $ActivateScript
    Write-Host "${SuccessColor}✓ Virtual environment activated${Reset}`n"
} else {
    Write-Host "${ErrorColor}✗ Activation script not found${Reset}"
    exit 1
}

# Upgrade pip, setuptools, wheel
Write-Host "${InfoColor}Upgrading pip, setuptools, wheel...${Reset}"
python.exe -m pip install --upgrade pip setuptools wheel 2>&1 | Select-String -Pattern "Successfully|Collecting" -OutVariable PipOutput | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "${SuccessColor}✓ Packages upgraded${Reset}`n"
} else {
    Write-Host "${ErrorColor}✗ Failed to upgrade packages${Reset}"
    exit 1
}

# Install requirements
$RequirementsFile = Join-Path $ScriptDir "requirements.txt"
if (Test-Path $RequirementsFile) {
    Write-Host "${InfoColor}Installing Python dependencies from requirements.txt...${Reset}"
    Write-Host "${WarningColor}This may take several minutes...${Reset}`n"
    python.exe -m pip install --no-cache-dir -r $RequirementsFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n${SuccessColor}✓ Dependencies installed successfully${Reset}`n"
    } else {
        Write-Host "${ErrorColor}✗ Failed to install dependencies${Reset}"
        exit 1
    }
} else {
    Write-Host "${ErrorColor}✗ requirements.txt not found at $RequirementsFile${Reset}"
    exit 1
}

# Confirmation message
Write-Host "${SuccessColor}╔════════════════════════════════════════════════╗${Reset}"
Write-Host "${SuccessColor}║      Installation Complete!                   ║${Reset}"
Write-Host "${SuccessColor}╚════════════════════════════════════════════════╝${Reset}`n"
Write-Host "To start the TRACE Forensic Toolkit:"
Write-Host "  ${WarningColor}python main.py${Reset}`n"
Write-Host "To deactivate the virtual environment later:"
Write-Host "  ${WarningColor}deactivate${Reset}"
