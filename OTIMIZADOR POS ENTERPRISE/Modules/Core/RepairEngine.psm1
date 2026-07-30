#=========================================================
# RepairEngine.psm1
# Windows Repair Engine
#=========================================================

#---------------------------------------------------------

function Get-RepairItems {
    return Get-ModuleItems -SubFolder "Repair" -FunctionPattern "Get-*Status"
}

#---------------------------------------------------------

function Start-Repair {

    Show-Header "WINDOWS REPAIR"

    Write-Log "Starting Windows Repair."

    $Watch = Start-Stopwatch

    $Global:App.Results.Repair = [PSCustomObject]@{
        Date    = Get-Date
        Success = 0
        Errors  = 0
    }

    $Items = Get-RepairItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "No repair modules found."

        Pause-App

        return

    }

    Write-Host "Available modules:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Item in $Items) {

        Write-Host ("{0,-35} {1}" -f $Item.Name, $Item.Status)

    }

    Write-Host ""
    Write-Host "Starting repair..." -ForegroundColor Cyan
    Write-Host ""

    $OK = 0
    $Erro = 0
    $Resultados = @()

    $Current = 0

    foreach ($Item in $Items) {

        $Current++

        Show-ProgressSimple `
            -Activity "Windows Repair" `
            -Current $Current `
            -Total $Items.Count

        $ModuleWatch = Start-Stopwatch

        try {

            if (-not $Item.RepairFunction) {
                throw "RepairFunction is not defined for $($Item.Name)."
            }

            if (-not (Get-Command -Name $Item.RepairFunction -ErrorAction SilentlyContinue)) {
                throw "Repair function '$($Item.RepairFunction)' was not found."
            }

            & $Item.RepairFunction

            $ModuleElapsed = Stop-Stopwatch $ModuleWatch

            Write-Host ("   Time: {0}" -f (Format-Time $ModuleElapsed)) -ForegroundColor DarkGray

            $Resultados += [PSCustomObject]@{

                Name    = $Item.Name
                Status  = "OK"
                Elapsed = $ModuleElapsed

            }

            Write-Success "$($Item.Name) completed."

            Write-Log "$($Item.Name) executed." "OK"

            $OK++

        }
        catch {

            $ModuleElapsed = Stop-Stopwatch $ModuleWatch

            $Resultados += [PSCustomObject]@{

                Name    = $Item.Name
                Status  = "ERROR"
                Elapsed = $ModuleElapsed

            }

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress `
        -Activity "Windows Repair" `
        -Completed

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    REPAIR SUMMARY"
    Write-Host "============================================================"
    Write-Host ""

    foreach ($Resultado in $Resultados) {

        Write-Host ("{0,-35} {1}" -f $Resultado.Name, $Resultado.Status)

    }

    Write-Host ""
    Write-Host ("Repairs OK : {0}" -f $OK)
    Write-Host ("Errors         : {0}" -f $Erro)
    Write-Host ("Time         : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    $Global:App.Results.Repair = New-ModuleResult `
        -Module "Repair" `
        -Success $OK `
        -Errors $Erro `
        -Details $Resultados `
        -Elapsed $Elapsed

    Write-Log "Repair completed." "OK"

    Pause-App

}

Export-ModuleMember -Function *

