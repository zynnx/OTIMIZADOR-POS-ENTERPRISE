#=========================================================
# InventoryEngine.psm1
# Motor do Inventário
#=========================================================
function Get-AssetItems {
    return Get-ModuleItems -SubFolder "Assets" -FunctionPattern "Get-*Inventory"
} 
function Start-Inventory {

    if ($Global:App.Results.Inventory) {

        Write-Success "Inventory already completed in this session."
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

    #
    # Group items by name (there may be several disks, monitors, printers, etc.)
    #

    $Inventory = [ordered]@{}

    foreach ($Item in $Items) {

        if ($Inventory.Contains($Item.Name)) {

            $Inventory[$Item.Name] += @($Item.Data)

        }
        else {

            $Inventory[$Item.Name] = @($Item.Data)

        }

    }

    #
    # Mostrar resumo
    #

    Write-Host ""
    Write-Host "Inventory Summary"
    Write-Host "================="
    Write-Host ""

    $Computer = Get-FirstValue $Inventory.Computer
    $Windows = Get-FirstValue $Inventory.Windows
    $Hardware = Get-FirstValue $Inventory.Hardware
    $Network = Get-FirstValue $Inventory.Network
    $Disks = @(
        $Inventory.Disk | Where-Object {
            $null -ne $_
        }
    )

    if ($Computer) {

        Write-Host ("Manufacturer : {0}" -f $Computer.Manufacturer)
        Write-Host ("Model        : {0}" -f $Computer.Model)
        Write-Host ("Serial       : {0}" -f $Computer.SerialNumber)

    }

    if ($Windows) {
        Write-Host ("Windows      : {0}" -f $Windows.Caption)
    }

    if ($Hardware) {
        Write-Host ("CPU          : {0}" -f $Hardware.CPU)
        Write-Host ("RAM          : {0} GB" -f $Hardware.RAM)
    }

    if ($Disks.Count -gt 0) {
        Write-Host ("Disks        : {0} detected" -f $Disks.Count)
    }

    if ($Network) {
        Write-Host ("IP           : {0}" -f $Network.IP)
    }

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host ("Time : {0}" -f (Format-Time $Elapsed))
    Write-Log "Inventory completed." "OK"

    $PosSoftware = @($Inventory."POS Software")

    if ($PosSoftware.Count -gt 0) {

        Write-Host ""
        Write-Host "POS / critical software detected:" -ForegroundColor Yellow
        Write-Host ""

        foreach ($App in $PosSoftware) {

            Write-Host ("  - {0} ({1})" -f $App.Name, $App.Version)

        }
    }
    else {

        Write-Host ""
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


function Get-FirstValue {

    param($Value)

    if ($null -eq $Value) { return $null }

    $Array = @($Value)

    if ($Array.Count -eq 0) { return $null }

    return $Array[0]
}

Export-ModuleMember -Function *