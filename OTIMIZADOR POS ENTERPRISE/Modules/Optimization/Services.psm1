#=========================================================
# Services.psm1
# Services Optimization
#=========================================================

function Get-ServicesStatus {

    return [PSCustomObject]@{

        Name = "Services"

        Status = "Ready"

        OptimizeFunction = "Invoke-ServicesOptimization"

    }

}

#---------------------------------------------------------

function Set-ServiceStartupSafe {

    param(

        [string]$Name,

        [string]$StartupType

    )

    try {

        $Service = Get-Service $Name -ErrorAction Stop

        Set-Service `
            -Name $Name `
            -StartupType $StartupType `
            -ErrorAction Stop

        Write-Log "$Name -> $StartupType" "OK"

    }
    catch {

        Write-Log "$Name not found." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-ServicesOptimization {

    Write-Log "Optimizing services..." "INFO"

    #
    # Safe services for POS/business
    #
    # We only adjust services without critical impact on remote support,
    # VPN or network management. We avoid any changes to services
    # of remote administration or enterprise network.

    Set-ServiceStartupSafe "WerSvc" "Manual"

    Set-ServiceStartupSafe "WSearch" "Manual"

    Set-ServiceStartupSafe "SysMain" "Manual"

    Write-Log "Services optimized." "OK"

}

Export-ModuleMember -Function *







