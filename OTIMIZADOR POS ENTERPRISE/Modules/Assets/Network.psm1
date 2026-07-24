#=========================================================
# Network.psm1
#=========================================================

function Get-NetworkInventory {

    $NIC = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {

        $_.IPAddress -notlike "169.*" -and
        $_.IPAddress -ne "127.0.0.1"

    } |
    Select-Object -First 1

    $Adapter = Get-NetAdapter |
    Where-Object Status -eq Up |
    Select-Object -First 1

    [PSCustomObject]@{
        Name = "Network"

        Data = [PSCustomObject]@{

            Computer = $env:COMPUTERNAME

            IP       = $NIC.IPAddress

            MAC      = $Adapter.MacAddress

            Domain   = (Get-CimInstance Win32_ComputerSystem).Domain
        }
    }

}

Export-ModuleMember -Function *