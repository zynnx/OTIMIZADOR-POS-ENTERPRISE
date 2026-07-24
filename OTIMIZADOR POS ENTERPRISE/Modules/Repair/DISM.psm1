#=========================================================
# DISM.psm1
# Windows image repair
#=========================================================

function Get-DISMStatus {

    return [PSCustomObject]@{

        Name = "DISM RestoreHealth"

        Status = "Ready"

        RepairFunction = "Invoke-DISMRepair"

    }

}

#---------------------------------------------------------

function Invoke-DISMRepair {

    Write-Log "Executing DISM..." "INFO"

    Write-Host ""
    Write-Host "This operation may take several minutes..." -ForegroundColor Yellow
    Write-Host ""

    $Arguments = @(
        "/Online"
        "/Cleanup-Image"
        "/RestoreHealth"
        "/NoRestart"
    )

    $Process = Start-Process `
        -FilePath "DISM.exe" `
        -ArgumentList $Arguments `
        -Wait `
        -PassThru `
        -NoNewWindow

    if($Process.ExitCode -eq 0){

        Write-Log "DISM completed successfully." "OK"

    }
    else{

        throw "DISM finished with exit code $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *




