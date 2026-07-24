#=========================================================
# Software.psm1
#=========================================================

function Get-SoftwareInventory {

    $Programs = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Name = "Software"

        Data = [PSCustomObject]@{

            InstalledPrograms = $Programs.Count
        }
    }

}

Export-ModuleMember -Function *