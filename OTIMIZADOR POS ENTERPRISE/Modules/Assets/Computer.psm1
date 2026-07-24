#=========================================================
# Computer.psm1
# Inventário do Equipamento
#=========================================================

function Get-ComputerInventory {

    $CS = Get-CimInstance Win32_ComputerSystem
    $BIOS = Get-CimInstance Win32_BIOS
    $Manufacturer = $CS.Manufacturer
    $Model = $CS.Model
    $Serial = $BIOS.SerialNumber
    $Version = $BIOS.SMBIOSBIOSVersion

    try {
        $Date = Get-Date $BIOS.ReleaseDate -Format "yyyy-MM-dd"
    }
    catch {
        $Date = ""
    }

    [PSCustomObject]@{
        Name = "Computer"

        Data = [PSCustomObject]@{
            Manufacturer = $Manufacturer
            Model        = $Model
            SerialNumber = $Serial
            BIOSVersion  = $Version
            BIOSDate     = $Date

        }
    }
}

Export-ModuleMember -Function *