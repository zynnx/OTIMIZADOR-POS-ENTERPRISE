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

    Write-Log "============================================================"
    Write-Log "SMART CLEANING STARTED" "INFO"

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

    #
    # Match results by name: after cleaning, the module list/order
    # could differ from the initial analysis.
    #

    $AfterByName = @{}

    foreach ($AfterItem in $AfterItems) {
        $AfterByName[$AfterItem.Name] = $AfterItem.Size
    }

    $TotalAfter = 0

    foreach ($Item in $Items) {

        $Before = $Item.Size

        $After = 0

        if ($AfterByName.ContainsKey($Item.Name)) {
            $After = $AfterByName[$Item.Name]
        }

        $Recovered = $Before - $After

        if ($Recovered -lt 0) {
            $Recovered = 0
        }

        $TotalAfter += $After

        Write-Host ("{0,-25} {1,12} -> {2,-12} Recuperado: {3}" -f `
                $Item.Name,
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
    Write-Log "SMART CLEANING FINISHED" "OK"
    Write-Log ("Smart Cleaning elapsed time: {0}" -f (Format-Time $Elapsed)) "OK"
    Write-Log "============================================================"
    
    Pause-App
}

Export-ModuleMember -Function *
