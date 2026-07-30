#=========================================================
# RAM.psm1
# RAM Diagnostic
#=========================================================

function Get-RAMDiagnostic {

    return [PSCustomObject]@{

        Name = "RAM"

        DiagnosticFunction = "Invoke-RAMDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-RAMDiagnostic {

    try {
        $OS = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $TotalGB = [math]::Round(
            $OS.TotalVisibleMemorySize / 1MB,
            2
        )

        $FreeGB = [math]::Round(
            $OS.FreePhysicalMemory / 1MB,
            2
        )

        $UsedGB = [math]::Round(
            $TotalGB - $FreeGB,
            2
        )

        $Percent = [math]::Round(
            ($UsedGB / $TotalGB) * 100
        )

        #-------------------------------------------------
        # Classification
        #-------------------------------------------------

        if ($Percent -lt 70) {
            $Status = "OK"
            $Score = 100
            $Recommendation = ""
        }
        elseif ($Percent -lt 80) {
            $Status = "WARNING"
            $Score = 90
            $Recommendation = "Monitor memory usage and check unnecessary applications."
        }
        elseif ($Percent -lt 90) {
            $Status = "WARNING"
            $Score = 70
            $Recommendation = "Close unnecessary applications and monitor memory usage."
        }
        else {
            $Status = "CRITICAL"
            $Score = 30
            $Recommendation = "Memory usage is critically high. Restart the POS or consider increasing RAM."
        }

        #-------------------------------------------------
        # Details
        #-------------------------------------------------

        $Details = "{0} GB used of {1} GB ({2}%). Free: {3} GB." -f `
            $UsedGB,
            $TotalGB,
            $Percent,
            $FreeGB

        return [PSCustomObject]@{
            Name = "RAM"
            Status = $Status
            Score = $Score
            Details = $Details
            Recommendation = $Recommendation
        }

    }
    catch {
        return [PSCustomObject]@{
            Name = "RAM"
            Status = "ERROR"
            Score = 0
            Details = $_.Exception.Message
            Recommendation = "Unable to determine RAM usage. Check Windows memory information."
        }
    }
}

Export-ModuleMember -Function *
