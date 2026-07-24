#=========================================================
# Windows.psm1
#=========================================================

function Get-WindowsInventory {

    $OS = Get-CimInstance Win32_OperatingSystem
    [PSCustomObject]@{
        Name = "Windows"

        Data = [PSCustomObject]@{

            Caption      = $OS.Caption
            Version      = $OS.Version
            Build        = $OS.BuildNumber
            Architecture = $OS.OSArchitecture

        }

    }
}    

Export-ModuleMember -Function *