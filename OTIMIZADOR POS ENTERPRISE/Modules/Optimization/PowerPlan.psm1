#=========================================================
# PowerPlan.psm1
# Power Plan
#=========================================================

function Get-PowerPlanStatus {

    $HighPerfGuid = "8c5e7fda-e8f1-4140-ba8b-d5943ac5b513"
    $Status = "Unknown"

    try {

        $Output = powercfg /L
        $Current = @($Output | Where-Object { $_ -match "\*" })

        if ($Current -and $Current[0]) {

            if (
                $Current[0] -match [regex]::Escape($HighPerfGuid) -or
                $Current[0] -match "(?i)High performance|Alto desempenho|Elevado desempenho"
            ) {

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

    $HighPerfGuid = "8c5e7fda-e8f1-4140-ba8b-d5943ac5b513"
    $BalancedGuid = "381b4222-66ff-4d2a-bd2b-b62fb208479a"

    #
    # 1) Try to enable the built-in High Performance scheme (GUID).
    #    On Windows 10/11 this scheme exists even when it is hidden in the list.
    #

    $Activated = $false

    try {

        powercfg /s $HighPerfGuid 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $Activated = $true
        }

    }
    catch {
        # continue to the next attempt
    }

    if ($Activated) {

        Write-Log "High Performance plan activated." "OK"
        return

    }

    #
    # 2) If it does not exist, duplicate the Balanced scheme and
    #    activate the newly created scheme (the last GUID in the list).
    #

    Write-Log "High Performance plan not found. Creating a new scheme..." "INFO"

    try {

        powercfg -duplicatescheme $BalancedGuid | Out-Null

    }
    catch {

        throw "Could not create a new power scheme: $($_.Exception.Message)"

    }

    $Guids = @()

    foreach ($Line in (powercfg /L)) {

        if ($Line -match "([a-fA-F0-9-]{36})") {
            $Guids += $Matches[1]
        }

    }

    if ($Guids.Count -eq 0) {

        throw "Could not determine the GUID of the power schemes."

    }

    $NewGuid = $Guids[$Guids.Count - 1]

    try {

        powercfg /s $NewGuid 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            throw "powercfg returned exit code $LASTEXITCODE."
        }

    }
    catch {

        throw "Could not activate the new power scheme: $($_.Exception.Message)"

    }

    Write-Log "New power scheme activated: $NewGuid" "OK"

}

Export-ModuleMember -Function *







