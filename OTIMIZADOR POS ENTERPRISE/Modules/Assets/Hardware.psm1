#=========================================================
# Hardware.psm1
#=========================================================

function Get-HardwareInventory {

    $CPU = Get-CimInstance Win32_Processor

    $RAM = Get-CimInstance Win32_ComputerSystem

    $Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

    [PSCustomObject]@{
        Name = "Hardware"

        Data = [PSCustomObject]@{

            CPU      = $CPU.Name.Trim()

            RAM      = [math]::Round($RAM.TotalPhysicalMemory / 1GB)

            DiskSize = [math]::Round($Disk.Size / 1GB)

            DiskFree = [math]::Round($Disk.FreeSpace / 1GB)

        }
    }
}

Export-ModuleMember -Function *