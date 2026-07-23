#=========================================================
# RepairEngine.psm1
# Motor de Reparação Windows
#=========================================================

#---------------------------------------------------------

function Get-RepairItems {

    $Items = @()

    #
    # Ordem fixa dos módulos
    #

    if (Get-Command Get-ComponentStoreStatus -ErrorAction SilentlyContinue) {
        $Items += Get-ComponentStoreStatus
    }

    if (Get-Command Get-DISMStatus -ErrorAction SilentlyContinue) {
        $Items += Get-DISMStatus
    }

    if (Get-Command Get-SFCStatus -ErrorAction SilentlyContinue) {
        $Items += Get-SFCStatus
    }

    if (Get-Command Get-CheckDiskStatus -ErrorAction SilentlyContinue) {
        $Items += Get-CheckDiskStatus
    }

    if (Get-Command Get-WindowsUpdateRepairStatus -ErrorAction SilentlyContinue) {
        $Items += Get-WindowsUpdateRepairStatus
    }

    if (Get-Command Get-StoreRepairStatus -ErrorAction SilentlyContinue) {
        $Items += Get-StoreRepairStatus
    }

    return $Items

}

#---------------------------------------------------------

function Start-Repair {

    Show-Header "REPARAÇÃO DO WINDOWS"

    Write-Log "Início da Reparação do Windows."

    $Watch = Start-Stopwatch

    $Items = Get-RepairItems

    if ($Items.Count -eq 0){

        Write-WarningMessage "Nenhum módulo de reparação encontrado."

        Pause-App

        return

    }

    Write-Host "Módulos disponíveis:" -ForegroundColor Cyan
    Write-Host ""

    foreach($Item in $Items){

        Write-Host ("{0,-35} {1}" -f $Item.Name,$Item.Status)

    }

    Write-Host ""
    Write-Host "A iniciar reparação..." -ForegroundColor Cyan
    Write-Host ""

    $OK = 0
    $Erro = 0
    $Resultados = @()

    $Current = 0

    foreach($Item in $Items){

        $Current++

        Show-ProgressSimple `
            -Activity "Reparação do Windows" `
            -Current $Current `
            -Total $Items.Count

        try{

            & $Item.RepairFunction

            $Resultados += [PSCustomObject]@{

                Nome = $Item.Name
                Estado = "OK"

            }

            Write-Success "$($Item.Name) concluído."

            Write-Log "$($Item.Name) executado." "OK"

            $OK++

        }
        catch{

            $Resultados += [PSCustomObject]@{

                Nome = $Item.Name
                Estado = "ERRO"

            }

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress `
        -Activity "Reparação do Windows" `
        -Completed

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    RESUMO DA REPARAÇÃO"
    Write-Host "============================================================"
    Write-Host ""

    foreach($Resultado in $Resultados){

        Write-Host ("{0,-35} {1}" -f $Resultado.Nome,$Resultado.Estado)

    }

    Write-Host ""
    Write-Host ("Reparações OK : {0}" -f $OK)
    Write-Host ("Erros         : {0}" -f $Erro)
    Write-Host ("Tempo         : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Reparação concluída." "OK"

    Pause-App

}

Export-ModuleMember -Function *