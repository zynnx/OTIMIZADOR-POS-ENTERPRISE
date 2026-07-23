#=========================================================
# ComponentStore.psm1
# Limpeza do Component Store (WinSxS)
#=========================================================

function Get-ComponentStoreStatus {

    return [PSCustomObject]@{

        Name = "Component Store"

        Status = "Pronto"

        RepairFunction = "Invoke-ComponentStoreRepair"

    }

}

#---------------------------------------------------------

function Invoke-ComponentStoreRepair {

    Write-Log "A limpar o Component Store..." "INFO"

    Write-Host ""
    Write-Host "A otimizar a imagem do Windows..." -ForegroundColor Yellow
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

        Write-Log "Component Store limpo com sucesso." "OK"

    }
    else{

        throw "DISM terminou com o código $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *