#=========================================================
# Disk.psm1
# Disk Diagnostic
#=========================================================

function Get-DiskDiagnostic {

    return [PSCustomObject]@{
        Name = "Disk"
        DiagnosticFunction = "Invoke-DiskDiagnostic"
    }

}

#---------------------------------------------------------

function Invoke-DiskDiagnostic {

    try {
        $Drive = Get-CimInstance Win32_LogicalDisk `
            -Filter "DeviceID='C:'" `
            -ErrorAction Stop

        if (-not $Drive -or $Drive.Size -le 0) {
            throw "Unable to retrieve valid disk information."
        }

        $FreeGB = [math]::Round(
            $Drive.FreeSpace / 1GB,
            2
        )

        $TotalGB = [math]::Round(
            $Drive.Size / 1GB,
            2
        )

        $UsedGB = [math]::Round(
            ($Drive.Size - $Drive.FreeSpace) / 1GB,
            2
        )

        $Percent = [math]::Round(
            ($Drive.FreeSpace / $Drive.Size) * 100
        )

        #-------------------------------------------------
        # Classification
        #-------------------------------------------------

        if ($Percent -ge 20) {
            $Status = "OK"
            $Score = 100
            $Recommendation = ""
        }
        elseif ($Percent -ge 15) {
            $Status = "WARNING"
            $Score = 90
            $Recommendation = "Monitor disk space and consider running Smart Cleaning."
        }
        elseif ($Percent -ge 10) {
            $Status = "WARNING"
            $Score = 70
            $Recommendation = "Run Smart Cleaning to free disk space."
        }
        elseif ($Percent -ge 5) {
            $Status = "CRITICAL"
            $Score = 40
            $Recommendation = "Free up disk space urgently."
        }
        else {

            $Status = "CRITICAL"
            $Score = 10
            $Recommendation = "Disk space is critically low. Free up space immediately."

        }

        #-------------------------------------------------
        # Details
        #-------------------------------------------------

        $Details = "{0} GB free of {1} GB ({2}%). Used: {3} GB." -f `
            $FreeGB,
            $TotalGB,
            $Percent,
            $UsedGB

        return [PSCustomObject]@{
            Name = "Disk"
            Status = $Status
            Score = $Score
            Details = $Details
            Recommendation = $Recommendation
        }
    }

    catch {

        return [PSCustomObject]@{
            Name = "Disk"
            Status = "ERROR"
            Score = 0
            Details = $_.Exception.Message
            Recommendation = "Unable to determine disk health and available space."
        }
    }
}
Export-ModuleMember -Function *
