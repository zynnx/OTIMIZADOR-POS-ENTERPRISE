#=========================================================
# InventoryEngine.psm1
# Motor do Inventário
#=========================================================
function Get-AssetItems {
    return Get-ModuleItems -SubFolder "Assets" -FunctionPattern "Get-*Inventory"
} 
function Start-Inventory {

    if ($Global:App.Results.Inventory) {

        return $Global:App.Results.Inventory
        Pause-App
        return

    }

    Show-Header "MACHINE INVENTORY"

    $Watch = Start-Stopwatch

    $Items = Get-AssetItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "No asset modules found."
        Pause-App
        return

    }

    $Inventory = @{}

    foreach ($Item in $Items) {

        $Item | Format-List *

    }

    foreach ($Item in $Items) {

        $Inventory[$Item.Name] = $Item.Data

    }

    $Global:App.Results.Inventory = $Inventory

    #
    # Mostrar resumo
    #

    Write-Host ""
    Write-Host "Inventory Summary"
    Write-Host "================="
    Write-Host ""

    Write-Host ("Manufacturer : {0}" -f $Inventory.Computer.Manufacturer)
    Write-Host ("Model        : {0}" -f $Inventory.Computer.Model)
    Write-Host ("Windows    : {0}" -f $Inventory.Windows.Caption)
    Write-Host ("CPU        : {0}" -f $Inventory.Hardware.CPU)
    Write-Host ("RAM        : {0} GB" -f $Inventory.Hardware.RAM)
    Write-Host ("IP         : {0}" -f $Inventory.Network.IP)

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host ("Time : {0}" -f (Format-Time $Elapsed))
    Write-Log "Inventory completed." "OK"

    if ($Inventory.POSSoftware -and $Inventory.POSSoftware.Count -gt 0) {

        foreach ($App in $Inventory.POSSoftware) {

            Write-Host ("  • {0} ({1})" -f $App.Name, $App.Version)

        }
    }
    else {

        Write-Host " No critical software found."

    }
    $Global:App.Results.Inventory = New-ModuleResult `
    -Module "Inventory" `
    -Success 1 `
    -Errors 0 `
    -Details $Inventory `
    -Elapsed $Elapsed
    
    Pause-App
}


Export-ModuleMember -Function *