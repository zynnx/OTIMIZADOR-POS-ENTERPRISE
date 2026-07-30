# ==========================================================
# OTIMIZADOR POS ENTERPRISE
# Author: Seabra
# ==========================================================

#-------------------------
# Global configuration
#-------------------------

$ErrorActionPreference = "Stop"

$Script:Version = "3.0.7"

$Global:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$Global:App = @{

    Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
    Version = "3.0.7"
    Config  = $null
    LogFile = $null
    Results = @{}

}

[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#-------------------------
# Check for administrator
#-------------------------

$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host ""
    Write-Host "This program must be run as administrator." -ForegroundColor Red
    Write-Host ""

    Pause
    exit
}

#-------------------------
# Create folders
#-------------------------

$Folders = @(
    "Modules",
    "Logs",
    "Reports",
    "Config"
)

foreach ($Folder in $Folders) {
    $Path = Join-Path $Global:AppRoot $Folder

    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

#-------------------------
# Load configuration
#-------------------------

$ConfigFile = Join-Path $Global:AppRoot "Config\Config.json"

if (!(Test-Path $ConfigFile)) {
    @'
{
    "Version":"3.0",
    "CreateRestorePoint":true,
    "RunDISM":true,
    "RunSFC":false,
    "CleanBrowsers":true
}
'@ | Set-Content $ConfigFile -Encoding UTF8
}

$Global:Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

#Load-Config

#-------------------------
# Load modules
#-------------------------

$PriorityModules = @(
    "Modules\Core\Utils.psm1",
    "Modules\Core\Logging.psm1",
    "Modules\Core\FileSystem.psm1",
    "Modules\Reports\HTML.psm1",
    "Modules\Reports\SaveReport.psm1",
    "Modules\Reports\SystemSection.psm1",
    "Modules\Reports\CleaningSection.psm1",
    "Modules\Reports\OptimizationSection.psm1",
    "Modules\Reports\RepairSection.psm1",
    "Modules\Reports\DiagnosticSection.psm1"
)

foreach ($Module in $PriorityModules) {

    $Path = Join-Path $Global:AppRoot $Module

    if (Test-Path $Path) {

        Import-Module $Path -Force

    }
    else {

        Write-Warning "Module not found: $Path"

    }

}

# Load remaining modules
$LoadedPriorityPaths = $PriorityModules |
    ForEach-Object {
        Join-Path $Global:AppRoot $_
    }

$Modules = Get-ChildItem "$Global:AppRoot\Modules" -Filter *.psm1 -Recurse |
    Where-Object {
        $_.FullName -notin $LoadedPriorityPaths
    }

foreach ($Module in $Modules) {

    Import-Module $Module.FullName -Force

}

#-------------------------
# Start the program
#-------------------------

Start-Log

Write-Log "Application started" "OK"

Start-MainMenu
