#=========================================================
# OptimizationEngine.psm1
# Motor de Otimização do Windows
#=========================================================

function Get-OptimizationItems {

    $Items = @()

    if (Get-Command Get-VisualEffectsStatus -ErrorAction SilentlyContinue) {
        $Items += Get-VisualEffectsStatus
    }

    if (Get-Command Get-PowerPlanStatus -ErrorAction SilentlyContinue) {
        $Items += Get-PowerPlanStatus
    }

    if (Get-Command Get-ExplorerStatus -ErrorAction SilentlyContinue) {
        $Items += Get-ExplorerStatus
    }

    if (Get-Command Get-StartupStatus -ErrorAction SilentlyContinue) {
        $Items += Get-StartupStatus
    }

    if (Get-Command Get-SSDStatus -ErrorAction SilentlyContinue) {
        $Items += Get-SSDStatus
    }

    if (Get-Command Get-ServicesStatus -ErrorAction SilentlyContinue) {
        $Items += Get-ServicesStatus
    }

    return $Items

}

#---------------------------------------------------------

function Start-Optimization {

    Show-Header "OTIMIZAÇÃO DO WINDOWS"

    Write-Log "Início da Otimização do Windows."

    $Watch = Start-Stopwatch

    $Items = Get-OptimizationItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "Nenhum módulo de otimização encontrado."

        Pause-App

        return

    }

    Write-Host "Estado atual do sistema" -ForegroundColor Cyan
    Write-Host ""

    foreach($Item in $Items){

        Write-Host ("{0,-30} {1}" -f $Item.Name,$Item.Status)

    }

    Write-Host ""
    Write-Host "A iniciar otimização..." -ForegroundColor Cyan
    Write-Host ""

    $OK = 0
    $Erro = 0
    $Current = 0

    foreach($Item in $Items){

        $Current++

        Show-ProgressSimple `
            -Activity "Otimização do Windows" `
            -Current $Current `
            -Total $Items.Count

        try{

            & $Item.OptimizeFunction

            Write-Success ("{0} concluído." -f $Item.Name)

            Write-Log "$($Item.Name) otimizado." "OK"

            $OK++

        }
        catch{

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress `
        -Activity "Otimização do Windows" `
        -Completed

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Módulos executados : {0}" -f $Items.Count)
    Write-Host ("Com sucesso        : {0}" -f $OK)
    Write-Host ("Erros              : {0}" -f $Erro)
    Write-Host ("Tempo              : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Otimização concluída." "OK"

    Pause-App

}

Export-ModuleMember -Function *