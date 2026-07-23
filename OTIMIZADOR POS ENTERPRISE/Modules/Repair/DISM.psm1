#=========================================================
# DISM.psm1
# Reparação da imagem do Windows
#=========================================================

function Get-DISMStatus {

    return [PSCustomObject]@{

        Name = "DISM RestoreHealth"

        Status = "Pronto"

        RepairFunction = "Invoke-DISMRepair"

    }

}

#---------------------------------------------------------

function Invoke-DISMRepair {

    Write-Log "A executar DISM..." "INFO"

    Write-Host ""
    Write-Host "Esta operação pode demorar vários minutos..." -ForegroundColor Yellow
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

        Write-Log "DISM concluído com sucesso." "OK"

    }
    else{

        throw "DISM terminou com o código $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *