#=========================================================
# CheckDisk.psm1
# Disk check
#=========================================================

function Get-CheckDiskStatus {

    return [PSCustomObject]@{

        Name = "CHKDSK"

        Status = "Ready"

        RepairFunction = "Invoke-CheckDiskRepair"

    }

}

#---------------------------------------------------------

function Invoke-CheckDiskRepair {

    Write-Log "Executing CHKDSK..." "INFO"

    Write-Host ""
    Write-Host "Checking disk C:..." -ForegroundColor Yellow
    Write-Host ""

    $Arguments = @(
        "C:"
        "/scan"
    )

    $Output = & chkdsk.exe @($Arguments) 2>&1
    $ExitCode = $LASTEXITCODE

    #
    # /scan is not supported on older Windows. Fall back to /check.
    #

    if ($ExitCode -ne 0 -and ($Output -join " ") -match "(?i)not.*(valid|supported)|n[ãa]o.*(v[áa]lida|suportada)|opcao|op[çc][ãa]o") {

        Write-Log "/scan is not supported on this Windows version. Falling back to /check." "WARNING"

        $Output = & chkdsk.exe C: /check 2>&1
        $ExitCode = $LASTEXITCODE

    }

    $Output | ForEach-Object { Write-Host $_ }

    if ($ExitCode -eq 0) {

        Write-Log "CHKDSK completed successfully." "OK"

    }
    else {

        throw "CHKDSK finished with exit code $ExitCode."

    }

}

Export-ModuleMember -Function *




