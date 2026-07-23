#=========================================================
# CheckDisk.psm1
# Verificação do Disco
#=========================================================

function Get-CheckDiskStatus {

    return [PSCustomObject]@{

        Name = "CHKDSK"

        Status = "Pronto"

        RepairFunction = "Invoke-CheckDiskRepair"

    }

}

#---------------------------------------------------------

function Invoke-CheckDiskRepair {

    Write-Log "A executar CHKDSK..." "INFO"

    Write-Host ""
    Write-Host "A verificar o disco C:..." -ForegroundColor Yellow
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

        Write-Log "CHKDSK concluído com sucesso." "OK"

    }
    else{

        throw "CHKDSK terminou com o código $($Process.ExitCode)."

    }

}

Export-ModuleMember -Function *