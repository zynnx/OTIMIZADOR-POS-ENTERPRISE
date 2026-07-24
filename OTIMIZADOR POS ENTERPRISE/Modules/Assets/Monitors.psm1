#=========================================================
# Monitors.psm1
#=========================================================

function Get-MonitorInventory {

    $Monitors = Get-CimInstance -Namespace root\wmi `
        -Class WmiMonitorID `
        -ErrorAction SilentlyContinue

    foreach ($Monitor in $Monitors) {

        $Name = ($Monitor.UserFriendlyName |
            Where-Object { $_ -ne 0 } |
            ForEach-Object { [char]$_ }) -join ""

        [PSCustomObject]@{
            Name = "Monitor"

            Data = [PSCustomObject]@{

                Name = $Name

            }
        }
    }

}

Export-ModuleMember -Function *