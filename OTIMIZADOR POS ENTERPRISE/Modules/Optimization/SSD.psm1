#=========================================================
# SSD.psm1
# SSD Optimization
#=========================================================

function Get-SSDStatus {

    $Status = "Not supported"

    try {

        $Media = Get-PhysicalDisk -ErrorAction Stop | Where-Object {
            $_.MediaType -eq "SSD"
        }

        if ($Media) {

            $Trim = (fsutil behavior query DisableDeleteNotify)

            if ($Trim -match "DisableDeleteNotify = 0") {

                $Status = "Optimized"

            }
            else {

                $Status = "TRIM disabled"

            }

        }

    }
    catch {

        $Status = "Unknown"

    }

    return [PSCustomObject]@{

        Name = "SSD"

        Status = $Status

        OptimizeFunction = "Invoke-SSDOptimization"

    }

}

#---------------------------------------------------------

function Invoke-SSDOptimization {

    Write-Log "Checking SSD..." "INFO"

    try {

        $SSD = Get-PhysicalDisk -ErrorAction Stop | Where-Object {
            $_.MediaType -eq "SSD"
        }

        if (-not $SSD) {

            Write-Log "No SSD detected." "INFO"
            return

        }

    }
    catch {

        Write-Log "Could not determine disk type." "WARNING"
        return

    }

    #
    # Ativar TRIM
    #

    fsutil behavior set DisableDeleteNotify 0 | Out-Null

    Write-Log "TRIM ativado." "OK"

    #
    # Executar ReTrim
    #

    try {

        Optimize-Volume `
            -DriveLetter C `
            -ReTrim `
            -ErrorAction Stop

        Write-Log "ReTrim executado." "OK"

    }
    catch {

        Write-Log "Could not execute ReTrim." "WARNING"

    }

}

Export-ModuleMember -Function *




