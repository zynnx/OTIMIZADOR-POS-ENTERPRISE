#=========================================================
# Windows.psm1
# Windows Repair Module
#=========================================================

function Get-WindowsStatus {

    [PSCustomObject]@{
        Name           = "Windows System Repair"
        Status         = "Available"
        RepairFunction = "Invoke-WindowsRepair"
    }

}


function Invoke-WindowsRepair {

    Write-Host ""
    Write-Host "Starting Windows system repair..." -ForegroundColor Cyan
    Write-Host ""

    $Results = @()

    #-----------------------------------------------------
    # 1. DISM CHECKHEALTH
    #-----------------------------------------------------

    Write-Host "1. DISM CheckHealth" -ForegroundColor Yellow
    Write-Host ""

    $Output = & DISM.exe /Online /Cleanup-Image /CheckHealth 2>&1
    $ExitCode = $LASTEXITCODE

    $OutputText = $Output -join "`n"

    if ($ExitCode -ne 0) {

        $CheckStatus = "ERROR"

    }
    elseif (
        $OutputText -match "No component store corruption detected" -or
        $OutputText -match "Nenhuma corrupção" -or
        $OutputText -match "No corruption"
    ) {

        $CheckStatus = "HEALTHY"

    }
    else {

        $CheckStatus = "CHECKED"

    }

    $Results += [PSCustomObject]@{

        Name     = "DISM CheckHealth"
        Status   = $CheckStatus
        ExitCode = $ExitCode
        Output   = $OutputText

    }

    Write-Host ""
    Write-Host "Result: $CheckStatus"
    Write-Host ""


    #-----------------------------------------------------
    # 2. DISM SCANHEALTH
    #-----------------------------------------------------

    Write-Host "2. DISM ScanHealth" -ForegroundColor Yellow
    Write-Host ""

    $Output = & DISM.exe /Online /Cleanup-Image /ScanHealth 2>&1
    $ExitCode = $LASTEXITCODE

    $OutputText = $Output -join "`n"

    if ($ExitCode -ne 0) {

        $ScanStatus = "ERROR"
        $RepairRequired = $true

    }
    elseif (
        $OutputText -match "No component store corruption detected" -or
        $OutputText -match "Nenhuma corrupção" -or
        $OutputText -match "No corruption"
    ) {

        $ScanStatus = "HEALTHY"
        $RepairRequired = $false

    }
    elseif (
        $OutputText -match "component store is repairable" -or
        $OutputText -match "reparável" -or
        $OutputText -match "repairable"
    ) {

        $ScanStatus = "REPAIR REQUIRED"
        $RepairRequired = $true

    }
    else {

        $ScanStatus = "CHECKED"
        $RepairRequired = $false

    }

    $Results += [PSCustomObject]@{

        Name     = "DISM ScanHealth"
        Status   = $ScanStatus
        ExitCode = $ExitCode
        Output   = $OutputText

    }

    Write-Host ""
    Write-Host "Result: $ScanStatus"
    Write-Host ""


    #-----------------------------------------------------
    # 3. DISM RESTOREHEALTH
    #-----------------------------------------------------

    if ($RepairRequired) {

        Write-Host "3. DISM RestoreHealth" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Corruption detected. Starting repair..." -ForegroundColor Yellow
        Write-Host ""

        $Output = & DISM.exe /Online /Cleanup-Image /RestoreHealth 2>&1
        $ExitCode = $LASTEXITCODE

        $OutputText = $Output -join "`n"

        if ($ExitCode -eq 0) {

            $RestoreStatus = "REPAIRED"

        }
        else {

            $RestoreStatus = "FAILED"

        }

        $Results += [PSCustomObject]@{

            Name     = "DISM RestoreHealth"
            Status   = $RestoreStatus
            ExitCode = $ExitCode
            Output   = $OutputText

        }

        Write-Host ""
        Write-Host "Result: $RestoreStatus"

    }
    else {

        Write-Host "3. DISM RestoreHealth - SKIPPED" -ForegroundColor Green

        $Results += [PSCustomObject]@{

            Name     = "DISM RestoreHealth"
            Status   = "NOT REQUIRED"
            ExitCode = 0
            Output   = "System image repair was not required."

        }

    }


    #-----------------------------------------------------
    # 4. SFC
    #-----------------------------------------------------

    Write-Host ""
    Write-Host "4. System File Checker" -ForegroundColor Yellow
    Write-Host ""

    $Output = & sfc.exe /scannow 2>&1
    $ExitCode = $LASTEXITCODE

    $OutputText = $Output -join "`n"

    if ($ExitCode -eq 0) {

        if (
            $OutputText -match "did not find any integrity violations" -or
            $OutputText -match "não encontrou violações" -or
            $OutputText -match "no integrity violations"
        ) {

            $SFCStatus = "HEALTHY"

        }
        else {

            $SFCStatus = "COMPLETED"

        }

    }
    else {

        $SFCStatus = "FAILED"

    }

    $Results += [PSCustomObject]@{

        Name     = "SFC Scan"
        Status   = $SFCStatus
        ExitCode = $ExitCode
        Output   = $OutputText

    }

    Write-Host ""
    Write-Host "Result: $SFCStatus"


    #-----------------------------------------------------
    # Guardar resultados detalhados
    #-----------------------------------------------------

    $Global:App.Results.RepairDetails = $Results


    #-----------------------------------------------------
    # Resumo
    #-----------------------------------------------------

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "WINDOWS REPAIR DETAILS"
    Write-Host "============================================================"
    Write-Host ""

    foreach ($Result in $Results) {

        switch ($Result.Status) {

            "HEALTHY" {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status) -ForegroundColor Green
            }

            "REPAIRED" {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status) -ForegroundColor Green
            }

            "NOT REQUIRED" {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status) -ForegroundColor Green
            }

            "REPAIR REQUIRED" {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status) -ForegroundColor Yellow
            }

            "FAILED" {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status) -ForegroundColor Red
            }

            default {
                Write-Host ("{0,-30} {1}" -f `
                    $Result.Name,
                    $Result.Status)
            }

        }

    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

}


Export-ModuleMember -Function *