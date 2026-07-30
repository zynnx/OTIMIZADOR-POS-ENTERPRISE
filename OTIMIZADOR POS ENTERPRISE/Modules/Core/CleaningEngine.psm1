#=========================================================
# CleaningEngine.psm1
# Smart Cleaning Engine
#=========================================================

#=========================================================
# Discover cleaning modules
#=========================================================

function Get-CleaningItems {
    return Get-ModuleItems -SubFolder "Cleaning" -FunctionPattern "Get-*Analysis"
} 

function Start-Cleaning {

    Show-Header "SMART CLEANING"

    Write-Log "Starting Smart Cleaning."

    $Watch = Start-Stopwatch

    $Items = Get-CleaningItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "No cleaning modules found."
        Pause-App
        return

    }

    $TotalBefore = 0

    Write-Host "Analyzing..." -ForegroundColor Cyan
    Write-Host ""

    foreach ($Item in $Items) {

        $TotalBefore += $Item.Size

        Write-Host ("{0,-25} {1,10} files {2,12}" -f `
                $Item.Name,
            $Item.Files,
            $Item.SizeText)

    }

    Write-Host ""
    Write-Host ("Total found : {0}" -f (Convert-Bytes $TotalBefore)) -ForegroundColor Yellow
    Write-Host ""

    $OK = 0
    $Erro = 0

    $Current = 0

    foreach ($Item in $Items) {

        $Current++

        Show-ProgressSimple `
            -Activity "Smart Cleaning" `
            -Current $Current `
            -Total $Items.Count

        try {

            & $Item.CleanupFunction

            Write-Success $Item.Name

            Write-Log "$($Item.Name) cleaned." "OK"

            $OK++

        }
        catch {

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress -Activity "Smart Cleaning" -Completed

    #
    # NEW ANALYSIS
    #

    Write-Host ""
    Write-Host "Checking recovered space..." -ForegroundColor Cyan
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
    Write-Host ("Items analyzed : {0}" -f $Items.Count)
    Write-Host ("Cleanups OK      : {0}" -f $OK)
    Write-Host ("Errors            : {0}" -f $Erro)
    Write-Host ("Space recovered: {0}" -f (Convert-Bytes $RecoveredTotal))
    Write-Host ("Tempo            : {0}" -f (Format-Time $Elapsed))
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log ("Space recovered: {0}" -f (Convert-Bytes $RecoveredTotal)) "OK"

    $Global:App.Results.Cleaning = [PSCustomObject]@{
        Date           = Get-Date
        Items          = $Items.Count
        Success        = $OK
        Errors         = $Erro
        SpaceRecovered = $RecoveredTotal
        Elapsed        = $Elapsed
    }
        
    Pause-App
}

Export-ModuleMember -Function *
