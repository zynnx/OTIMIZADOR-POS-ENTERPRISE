# ==========================================================
# OTIMIZADOR POS ENTERPRISE
# Author: Seabra
# ==========================================================

#-------------------------
# Global configuration
#-------------------------

$ErrorActionPreference = "Stop"

$Global:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$Global:App = @{

    Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
    Version = "3.0.0"
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
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

#-------------------------
# Ensure the execution policy allows this script
# (self-relaunch once with -ExecutionPolicy Bypass)
#-------------------------

$CurrentPolicy = Get-ExecutionPolicy -Scope Process

if (
    $CurrentPolicy -eq 'Restricted' -or
    $CurrentPolicy -eq 'AllSigned' -or
    $CurrentPolicy -eq 'Undefined'
) {

    $ScriptPath = $MyInvocation.MyCommand.Path

    if ($ScriptPath -and -not $env:OPOS_POLICY_RELAXED) {

        $env:OPOS_POLICY_RELAXED = "1"

        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = (Get-Process -Id $PID).Path
        $ProcessInfo.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $ScriptPath
        $ProcessInfo.UseShellExecute = $true

        if (-not $IsAdmin) {
            $ProcessInfo.Verb = "runas"
        }

        try {

            $Child = [System.Diagnostics.Process]::Start($ProcessInfo)

            if ($Child) {
                $Child.WaitForExit()
                exit $Child.ExitCode
            }

        }
        catch {
            # Fall through to the error message below
        }

    }

    Write-Host ""
    Write-Host "The current PowerShell execution policy blocks this application." -ForegroundColor Red
    Write-Host "Run it with: powershell -NoProfile -ExecutionPolicy Bypass -File `"$MyInvocation.MyCommand.Path`"" -ForegroundColor Yellow
    Write-Host ""

    Pause
    exit 1

}

#-------------------------
# Check for administrator (with self-elevation)
#-------------------------

if (-not $IsAdmin) {

    $ScriptPath = $MyInvocation.MyCommand.Path

    if ($ScriptPath -and -not $env:OPOS_ELEVATED_RETRY) {

        $env:OPOS_ELEVATED_RETRY = "1"

        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = (Get-Process -Id $PID).Path
        $ProcessInfo.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $ScriptPath
        $ProcessInfo.UseShellExecute = $true
        $ProcessInfo.Verb = "runas"

        try {

            $Child = [System.Diagnostics.Process]::Start($ProcessInfo)

            if ($Child) {
                $Child.WaitForExit()
                exit $Child.ExitCode
            }

        }
        catch {
            # Fall through to the error message below
        }

    }

    Write-Host ""
    Write-Host "This program must be run as administrator." -ForegroundColor Red
    Write-Host "Elevation was required but could not be completed." -ForegroundColor Red
    Write-Host ""

    Pause
    exit 1

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
    "CreateRestorePoint":false,
    "RequireRestorePoint":false,
    "RunDISM":true,
    "RunSFC":false
}
'@ | Set-Content $ConfigFile -Encoding UTF8
}

$Global:Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

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

#
# Load the extra configuration files (Config folder)
#

try {

    Load-Config

}
catch {

    throw "Invalid configuration. Startup stopped: $($_.Exception.Message)"

}

#-------------------------
# Start the program
#-------------------------

Start-Log

Write-Log "Application started" "OK"

Start-MainMenu
