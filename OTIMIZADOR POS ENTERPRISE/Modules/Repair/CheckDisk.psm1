#=========================================================
# CheckDisk.psm1
# Disk check
#=========================================================

function Get-CheckDiskStatus {

    return [PSCustomObject]@{

        Name = "CHKDSK"

        Status = "Ready"

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

    $Process = Start-Process `
        -FilePath "chkdsk.exe" `
        -ArgumentList $Arguments `
        -Wait `
        -PassThru `
        -NoNewWindow

    if($Process.ExitCode -eq 0){

        Write-Log "CHKDSK completed successfully." "OK"

    }
    else{

        throw "CHKDSK finished with exit code $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *




