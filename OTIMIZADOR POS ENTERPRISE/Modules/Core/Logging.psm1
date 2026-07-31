#=========================================================
# Logging.psm1
# Sistema de Logs
#=========================================================

function Start-Log {

    $LogFolder = "C:\Logs\MeusLogs"

    if (!(Test-Path $LogFolder)) {

        New-Item `
            -ItemType Directory `
            -Path $LogFolder `
            -Force | Out-Null

    }

    $FileName = "POS_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss")

    $Global:App.LogFile = Join-Path $LogFolder $FileName

    New-Item `
        -ItemType File `
        -Path $Global:App.LogFile `
        -Force | Out-Null

    Write-Log "============================================================"
    Write-Log "OTIMIZADOR POS ENTERPRISE"
    Write-Log "============================================================"
    Write-Log "Version     : $($Global:App.Version)"
    Write-Log "Computer    : $env:COMPUTERNAME"
    Write-Log "User        : $env:USERNAME"
    Write-Log "PowerShell  : $($PSVersionTable.PSVersion)"
    Write-Log "Windows     : $([Environment]::OSVersion.Version)"
    Write-Log "Start       : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
    Write-Log "Log file    : $Global:App.LogFile"
    Write-Log "============================================================"

}

#---------------------------------------------------------

function Write-Log {

    param(

        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","OK","WARNING","ERROR")]
        [string]$Level="INFO"

    )

    $Time = Get-Date -Format "HH:mm:ss"

    $Line = "[{0}] [{1}] {2}" -f $Time,$Level,$Message

    switch($Level){

        "INFO" {

            Write-Host $Line -ForegroundColor Gray

        }

        "OK" {

            Write-Host $Line -ForegroundColor Green

        }

        "WARNING" {

            Write-Host $Line -ForegroundColor Yellow

        }

        "ERROR" {

            Write-Host $Line -ForegroundColor Red

        }

    }

    if($Global:App.LogFile){

        Add-Content `
            -Path $Global:App.LogFile `
            -Value $Line `
            -Encoding UTF8

    }

}

#---------------------------------------------------------

function Write-Section {

    param(
        [string]$Title
    )

    Write-Log ""
    Write-Log "--------------------------------------------------"
    Write-Log $Title
    Write-Log "--------------------------------------------------"

}

#---------------------------------------------------------

function Stop-Log {

    Write-Log ""
    Write-Log "Execution finished."

}

#---------------------------------------------------------

Export-ModuleMember -Function *
