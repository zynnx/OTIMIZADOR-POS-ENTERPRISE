#=========================================================
# Store.psm1
# Microsoft Store repair
#=========================================================

function Get-StoreRepairStatus {

    return [PSCustomObject]@{

        Name = "Microsoft Store"

        Status = "Ready"

        RepairFunction = "Invoke-StoreRepair"

    }

}

#---------------------------------------------------------

function Invoke-StoreRepair {

    Write-Log "Repairing Microsoft Store..." "INFO"

    try {

        #
        # Clear the Microsoft Store cache
        #

        Start-Process `
            -FilePath "wsreset.exe" `
            -Wait `
            -NoNewWindow

        Write-Log "Microsoft Store cache cleared." "OK"

    }
    catch {

        throw "Could not execute WSReset."

    }

    try {

        #
        # Re-register the Microsoft Store
        #

        Get-AppxPackage -AllUsers Microsoft.WindowsStore |
        ForEach-Object {

            Add-AppxPackage `
                -DisableDevelopmentMode `
                -Register "$($_.InstallLocation)\AppXManifest.xml"

        }

        Write-Log "Microsoft Store re-registered." "OK"

    }
    catch {

        Write-Log "Could not re-register Microsoft Store." "WARNING"

    }

    Write-Log "Microsoft Store repair completed." "OK"

}

Export-ModuleMember -Function *


