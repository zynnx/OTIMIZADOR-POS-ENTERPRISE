#=========================================================
# RepairEngine.psm1
# Windows Repair Engine
#=========================================================

#---------------------------------------------------------

function Get-RepairItems {
    return Get-ModuleItems -SubFolder "Repair" -FunctionPattern "Get-*Status"
}

<# function Get-RepairItems {

    $Items = @()

    #
    # Fixed module order
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

} #>

#---------------------------------------------------------

function Start-Repair {

    Show-Header "WINDOWS REPAIR"

    Write-Log "Starting Windows Repair."

    $Watch = Start-Stopwatch

    $Items = Get-RepairItems

    if ($Items.Count -eq 0){

        Write-WarningMessage "No repair modules found."

        Pause-App

        return

    }

    Write-Host "Available modules:" -ForegroundColor Cyan
    Write-Host ""

    foreach($Item in $Items){

        Write-Host ("{0,-35} {1}" -f $Item.Name,$Item.Status)

    }

    Write-Host ""
    Write-Host "Starting repair..." -ForegroundColor Cyan
    Write-Host ""

    $OK = 0
    $Erro = 0
    $Resultados = @()

    $Current = 0

    foreach($Item in $Items){

        $Current++

        Show-ProgressSimple `
            -Activity "Windows Repair" `
            -Current $Current `
            -Total $Items.Count

        try{

            if (-not $Item.RepairFunction) {
                throw "RepairFunction is not defined for $($Item.Name)."
            }

            if (-not (Get-Command -Name $Item.RepairFunction -ErrorAction SilentlyContinue)) {
                throw "Repair function '$($Item.RepairFunction)' was not found."
            }

            & $Item.RepairFunction

            $Resultados += [PSCustomObject]@{

                Name = $Item.Name
                Status = "OK"

            }

            Write-Success "$($Item.Name) completed."

            Write-Log "$($Item.Name) executed." "OK"

            $OK++

        }
        catch{

            $Resultados += [PSCustomObject]@{

                Name = $Item.Name
                Status = "ERROR"

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

    foreach($Resultado in $Resultados){

        Write-Host ("{0,-35} {1}" -f $Resultado.Nome,$Resultado.Estado)

    }

    Write-Host ""
    Write-Host ("Repairs OK : {0}" -f $OK)
    Write-Host ("Errors         : {0}" -f $Erro)
    Write-Host ("Time         : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Repair completed." "OK"

    Pause-App

}

$Global:App.Results.Repair = [PSCustomObject]@{
    Date = Get-Date
    Success = $OK
    Errors = $Erro
}
Export-ModuleMember -Function *













