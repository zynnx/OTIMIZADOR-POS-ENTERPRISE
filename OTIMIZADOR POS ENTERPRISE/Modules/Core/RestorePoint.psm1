#=========================================================
# RestorePoint.psm1
# Ponto de restauração
#=========================================================

function New-RestorePointSafe {

    param(
        [string]$Description = "Otimizador POS Enterprise"
    )

    try {

        Checkpoint-Computer `
            -Description $Description `
            -RestorePointType "APPLICATION_INSTALL" `
            -ErrorAction Stop | Out-Null

        Write-Log "Restore point created: $Description" "OK"

        return $true

    }
    catch {

        Write-Log "Could not create restore point: $($_.Exception.Message)" "WARNING"

        return $false

    }

}

Export-ModuleMember -Function *