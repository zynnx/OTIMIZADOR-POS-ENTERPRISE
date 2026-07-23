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

    Write-Log "============================================="
    Write-Log "Otimizador POS $($Global:App.Version)"
    Write-Log "Computador : $env:COMPUTERNAME"
    Write-Log "Utilizador : $env:USERNAME"
    Write-Log "============================================="

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
    Write-Log "Fim da execução."

}

#---------------------------------------------------------

Export-ModuleMember -Function *