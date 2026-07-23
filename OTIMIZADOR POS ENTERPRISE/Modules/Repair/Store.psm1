#=========================================================
# Store.psm1
# Reparação da Microsoft Store
#=========================================================

function Get-StoreRepairStatus {

    return [PSCustomObject]@{

        Name = "Microsoft Store"

        Status = "Pronto"

        RepairFunction = "Invoke-StoreRepair"

    }

}

#---------------------------------------------------------

function Invoke-StoreRepair {

    Write-Log "A reparar Microsoft Store..." "INFO"

    try {

        #
        # Limpar cache da Store
        #

        Start-Process `
            -FilePath "wsreset.exe" `
            -Wait `
            -NoNewWindow

        Write-Log "Cache da Microsoft Store limpa." "OK"

    }
    catch {

        throw "Não foi possível executar o WSReset."

    }

    try {

        #
        # Re-registar a Microsoft Store
        #

        Get-AppxPackage -AllUsers Microsoft.WindowsStore |
        ForEach-Object {

            Add-AppxPackage `
                -DisableDevelopmentMode `
                -Register "$($_.InstallLocation)\AppXManifest.xml"

        }

        Write-Log "Microsoft Store registada novamente." "OK"

    }
    catch {

        Write-Log "Não foi possível re-registar a Microsoft Store." "WARNING"

    }

    Write-Log "Reparação da Microsoft Store concluída." "OK"

}

Export-ModuleMember -Function *