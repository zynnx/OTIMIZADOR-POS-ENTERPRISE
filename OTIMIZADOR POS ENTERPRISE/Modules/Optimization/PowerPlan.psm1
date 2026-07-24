#=========================================================
# PowerPlan.psm1
# Power Plan
#=========================================================

function Get-PowerPlanStatus {

    $Status = "Unknown"

    try {

        $Output = powercfg /L

        $Current = ($Output | Where-Object { $_ -match "\*" })

        if ($Current) {

            if ($Current -match "High performance|Alto desempenho") {

                $Status = "Optimized"

            }
            else {

                $Status = "Not optimized"

            }

        }

    }
    catch {

        $Status = "ERROR"

    }

    return [PSCustomObject]@{

        Name = "Power Plan"

        Status = $Status

        OptimizeFunction = "Invoke-PowerPlanOptimization"

    }

}

#---------------------------------------------------------

function Invoke-PowerPlanOptimization {

    Write-Log "Checking power plans..." "INFO"

    $Plans = powercfg /L

    #
    # Search for High Performance
    #

    $High = $Plans | Where-Object {

        $_ -match "High performance|Alto desempenho"

    }

    if (-not $High) {

        Write-Log "High Performance plan not found." "WARNING"

        Write-Log "Creating High Performance plan..." "INFO"

        powercfg -duplicatescheme SCHEME_MIN | Out-Null

        $Plans = powercfg /L

        $High = $Plans | Where-Object {

            $_ -match "High performance|Alto desempenho"

        }

    }

    if ($High) {

        if ($High -match "([a-fA-F0-9\-]{36})") {

            $Guid = $Matches[1]

            powercfg /S $Guid

            Write-Log "High Performance plan activated." "OK"

        }

    }
    else {

        Write-Log "Could not activate the plan." "ERROR"

    }

}

Export-ModuleMember -Function *







