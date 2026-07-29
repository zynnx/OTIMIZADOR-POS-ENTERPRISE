#=========================================================
# Utils.psm1
# Utility functions
#=========================================================

function Convert-Bytes {

    param(
        [Int64]$Bytes
    )

    if ($Bytes -ge 1TB) {
        return "{0:N2} TB" -f ($Bytes / 1TB)
    }

    elseif ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }

    elseif ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }

    elseif ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }

    else {
        return "$Bytes Bytes"
    }

}

#---------------------------------------------------------

function Show-Header {

    param(
        [string]$Title
    )

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host (" {0}" -f $Title) -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

}

#---------------------------------------------------------

function Pause-App {

    Write-Host ""
    Read-Host "Prima ENTER para continuar"

}

#---------------------------------------------------------

function Write-Success {

    param([string]$Message)

    Write-Host "[ OK ] $Message" -ForegroundColor Green

}

#---------------------------------------------------------

function Write-WarningMessage {

    param([string]$Message)

    Write-Host "[ WARNING ] $Message" -ForegroundColor Yellow

}

#---------------------------------------------------------

function Write-ErrorMessage {

    param([string]$Message)

    Write-Host "[ ERROR ] $Message" -ForegroundColor Red

}

#---------------------------------------------------------

function Start-Stopwatch {

    return [System.Diagnostics.Stopwatch]::StartNew()

}

#---------------------------------------------------------

function Stop-Stopwatch {

    param(
        $Watch
    )

    $Watch.Stop()

    return $Watch.Elapsed

}

#---------------------------------------------------------

function Format-Time {

    param(
        [TimeSpan]$Elapsed
    )

    return "{0:00}:{1:00}:{2:00}" -f `
        $Elapsed.Hours,
        $Elapsed.Minutes,
        $Elapsed.Seconds

}

#---------------------------------------------------------

function Show-ProgressSimple {

    param(

        [string]$Activity,

        [int]$Current,

        [int]$Total

    )

    if ($Total -eq 0) {
        return
    }

    $Percent = [math]::Round(($Current / $Total) * 100)

    Write-Progress `
        -Activity $Activity `
        -Status "$Percent %" `
        -PercentComplete $Percent

}

#---------------------------------------------------------

function Draw-Line {

    param(
        [char]$Character = "=",
        [int]$Length = 60
    )

    Write-Host ($Character.ToString() * $Length) -ForegroundColor DarkCyan

}

#---------------------------------------------------------

function Get-ModuleItems {

    param(
        [Parameter(Mandatory = $true)]
        [string]$SubFolder,

        [Parameter(Mandatory = $true)]
        [string]$FunctionPattern,

        [string]$BasePath = "$Global:AppRoot\Modules"
    )

    $Items = @()
    $ModulesPath = Join-Path $BasePath $SubFolder

    if (-not (Test-Path $ModulesPath)) {
        Write-Warning "Pasta de módulos não encontrada: $ModulesPath"
        return $Items
    }

    # Nomes dos módulos (sem extensão) presentes nessa subpasta
    $ModuleNamesInFolder = Get-ChildItem -Path $ModulesPath -Filter "*.psm1" -File |
        Select-Object -ExpandProperty BaseName

    $MatchedFunctions = Get-Command -CommandType Function -Name $FunctionPattern -Module $ModuleNamesInFolder -ErrorAction SilentlyContinue

    foreach ($func in $MatchedFunctions) {
        $Items += & $func.Name
    }

    return $Items
}

#---------------------------------------------------------

function New-ModuleResult {

    param(
        [string]$Module,
        [int]$Success = 0,
        [int]$Errors = 0,
        [object[]]$Details = @(),
        [timespan]$Elapsed
    )

    [PSCustomObject]@{
        Module    = $Module
        Date      = Get-Date
        Success   = $Success
        Errors    = $Errors
        Duration  = $Elapsed
        Details   = $Details
    }
}

Export-ModuleMember -Function *
