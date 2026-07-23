#=========================================================
# SystemInfo.psm1
#=========================================================

function Get-SystemInfo {

    $OS = Get-CimInstance Win32_OperatingSystem
    $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1

    $Computer = Get-CimInstance Win32_ComputerSystem

    $Disk = Get-CimInstance Win32_LogicalDisk |
            Where-Object DriveType -eq 3 |
            Where-Object DeviceID -eq "C:"

    $BIOS = Get-CimInstance Win32_BIOS

	$Boot = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)

	$RAM = [math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)

	$Free = [math]::Round($Disk.FreeSpace / 1GB, 2)

    $Size = [math]::Round($Disk.Size / 1GB,2)

    $Used = [math]::Round($Size - $Free,2)

    [PSCustomObject]@{

        ComputerName = $env:COMPUTERNAME

        User = $env:USERNAME

        Windows = $OS.Caption

        Version = $OS.Version

        Build = $OS.BuildNumber

        Architecture = $OS.OSArchitecture

        CPU = $CPU.Name.Trim()

        Cores = $CPU.NumberOfCores

        Threads = $CPU.NumberOfLogicalProcessors

        RAM = $RAM

        DiskTotal = $Size

        DiskFree = $Free

        DiskUsed = $Used

        Manufacturer = $Computer.Manufacturer

        Model = $Computer.Model

        BIOS = $BIOS.SMBIOSBIOSVersion

        Uptime = "{0} dias {1} horas {2} minutos" -f $Boot.Days, $Boot.Hours, $Boot.Minutes

    }

}

Export-ModuleMember -Function *