Write-Host "=== PCSX2 Backup Installer ===" -ForegroundColor Cyan

function Test-PythonCommand {
    param($cmd)
    try {
        & $cmd --version 2>$null | Out-Null
        return $?
    }
    catch {
        return $false
    }
}

$pythonCommands = @("python3.14", "python3.12", "python3.11", "python3.10", "python3.9", "python3.8", "python", "py", "python3")
$pythonCmd = $null

foreach ($cmd in $pythonCommands) {
    if (Test-PythonCommand $cmd) {
        $pythonCmd = $cmd
        break
    }
}

if (-not $pythonCmd) {
    Write-Host "✗ Python 3 not found! Please install Python 3.6 or higher" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$pythonVersion = & $pythonCmd --version
Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green

Write-Host "Creating virtual environment..."
& $pythonCmd -m venv venv

"venv\Scripts\Activate.ps1"

Write-Host "Installing deps..."
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "✓ Dependencies have been successfully installed" -ForegroundColor Green

$configFile = "pcsx2_backup_config.json"

if (-not (Test-Path $configFile)) {
    Write-Host "Configuration file not found" -ForegroundColor Yellow
    Write-Host "Starting initial setup..."
    
    python setup.py
    
    if (-not (Test-Path $configFile)) {
        Write-Host "✗ Setup was not completed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "✓ Configuration successfully created" -ForegroundColor Green
} else {
    Write-Host "✓ Configuration file found" -ForegroundColor Green
}

Write-Host "Creating Windows service..."

$currentDir = Get-Location

$batchContent = @"
@echo off
cd /d "$currentDir"
call venv\Scripts\activate.bat
python main.py
"@

$batchContent | Out-File -FilePath "pcsx2_backup_service.bat" -Encoding ASCII

$psServiceContent = @"
Set-Location "$currentDir"
& "venv\Scripts\Activate.ps1"
python main.py
"@

$psServiceContent | Out-File -FilePath "pcsx2_backup_service.ps1" -Encoding UTF8

try {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$currentDir\pcsx2_backup_service.ps1`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName "PCSX2 Backup Service" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
    
    Write-Host "✓ Service successfully installed as scheduled task" -ForegroundColor Green
    Write-Host "The service will start automatically on system boot" -ForegroundColor Cyan
}
catch {
    Write-Host "✗ Could not create scheduled task. You may need to run as Administrator" -ForegroundColor Red
}

Write-Host "✓ Installation complete" -ForegroundColor Greem
Read-Host "Press Enter to exit"