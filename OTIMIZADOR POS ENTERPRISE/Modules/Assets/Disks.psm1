#=========================================================
# Disks.psm1
#=========================================================

function Get-DiskInventory {

    $Disks = Get-CimInstance Win32_DiskDrive

    foreach ($Disk in $Disks) {

        [PSCustomObject]@{
        Name = "Disk"

        Data = [PSCustomObject]@{

            Model    = $Disk.Model

            Serial   = $Disk.SerialNumber

            SizeGB   = [math]::Round($Disk.Size / 1GB)

            Interface = $Disk.InterfaceType

        }

    }
    }
}

Export-ModuleMember -Function *