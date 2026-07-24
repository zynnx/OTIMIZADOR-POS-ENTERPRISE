#=========================================================
# ComponentStore.psm1
# Component Store cleanup (WinSxS)
#=========================================================

function Get-ComponentStoreStatus {

    return [PSCustomObject]@{

        Name = "Component Store"

        Status = "Ready"

        RepairFunction = "Invoke-ComponentStoreRepair"

    }

}

#---------------------------------------------------------

function Invoke-ComponentStoreRepair {

    Write-Log "Cleaning the Component Store..." "INFO"

    Write-Host ""
    Write-Host "Optimizing the Windows image..." -ForegroundColor Yellow
    Write-Host ""

    $Arguments = @(
        "/Online"
        "/Cleanup-Image"
        "/StartComponentCleanup"
    )

    $Process = Start-Process `
        -FilePath "DISM.exe" `
        -ArgumentList $Arguments `
        -Wait `
        -PassThru `
        -NoNewWindow

    if($Process.ExitCode -eq 0){

        Write-Log "Component Store cleaned successfully." "OK"

    }
    else{

        throw "DISM finished with exit code $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *

