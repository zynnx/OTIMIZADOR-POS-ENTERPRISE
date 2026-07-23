#=========================================================
# CleaningEngine.psm1
# Motor da Limpeza Inteligente
#=========================================================

#=========================================================
# Descobrir módulos de limpeza
#=========================================================

function Get-CleaningItems {

    $Items = @()

    if (Get-Command Get-TempAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-TempAnalysis
    }

    if (Get-Command Get-WindowsTempAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-WindowsTempAnalysis
    }

    if (Get-Command Get-RecycleBinAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-RecycleBinAnalysis
    }

    if (Get-Command Get-WindowsUpdateAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-WindowsUpdateAnalysis
    }

    if (Get-Command Get-DeliveryOptimizationAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-DeliveryOptimizationAnalysis
    }

    if (Get-Command Get-ThumbnailCacheAnalysis -ErrorAction SilentlyContinue) {
        $Items += Get-ThumbnailCacheAnalysis
    }

    return $Items

}

function Start-Cleaning {

    Show-Header "LIMPEZA INTELIGENTE"

    Write-Log "Início da Limpeza Inteligente."

    $Watch = Start-Stopwatch

    $Items = Get-CleaningItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "Nenhum módulo de limpeza encontrado."
        Pause-App
        return

    }

    $TotalBefore = 0

    Write-Host "A analisar..." -ForegroundColor Cyan
    Write-Host ""

    foreach ($Item in $Items) {

        $TotalBefore += $Item.Size

        Write-Host ("{0,-25} {1,10} ficheiros {2,12}" -f `
            $Item.Name,
            $Item.Files,
            $Item.SizeText)

    }

    Write-Host ""
    Write-Host ("Total encontrado : {0}" -f (Convert-Bytes $TotalBefore)) -ForegroundColor Yellow
    Write-Host ""

    $Ok = 0
    $Erro = 0

    $Current = 0

    foreach ($Item in $Items) {

        $Current++

        Show-ProgressSimple `
            -Activity "Limpeza Inteligente" `
            -Current $Current `
            -Total $Items.Count

        try {

            & $Item.CleanupFunction

            Write-Success $Item.Name

            Write-Log "$($Item.Name) limpo." "OK"

            $Ok++

        }
        catch {

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress -Activity "Limpeza Inteligente" -Completed

    #
    # NOVA ANÁLISE
    #

    Write-Host ""
    Write-Host "A verificar espaço recuperado..." -ForegroundColor Cyan
    Write-Host ""

    $AfterItems = Get-CleaningItems

    $TotalAfter = 0

    for ($i = 0; $i -lt $Items.Count; $i++) {

        $Before = $Items[$i].Size
        $After = $AfterItems[$i].Size

        $Recovered = $Before - $After

        if ($Recovered -lt 0) {
            $Recovered = 0
        }

        $TotalAfter += $After

        Write-Host ("{0,-25} {1,12} -> {2,-12} Recuperado: {3}" -f `
            $Items[$i].Name,
            (Convert-Bytes $Before),
            (Convert-Bytes $After),
            (Convert-Bytes $Recovered))

    }

    $RecoveredTotal = $TotalBefore - $TotalAfter

    if ($RecoveredTotal -lt 0) {
        $RecoveredTotal = 0
    }

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Itens analisados : {0}" -f $Items.Count)
    Write-Host ("Limpezas OK      : {0}" -f $Ok)
    Write-Host ("Erros            : {0}" -f $Erro)
    Write-Host ("Espaço recuperado: {0}" -f (Convert-Bytes $RecoveredTotal))
    Write-Host ("Tempo            : {0}" -f (Format-Time $Elapsed))
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log ("Espaço recuperado: {0}" -f (Convert-Bytes $RecoveredTotal)) "OK"

    Pause-App

}

Export-ModuleMember -Function *