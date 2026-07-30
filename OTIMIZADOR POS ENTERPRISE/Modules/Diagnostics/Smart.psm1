#=========================================================
# Smart.psm1
# SMART Disk Diagnostic
#=========================================================

function Get-SmartDiagnostic {

    return [PSCustomObject]@{
        Name = "SMART"
        DiagnosticFunction = "Invoke-SmartDiagnostic"
    }
}

#---------------------------------------------------------

function Invoke-SMARTDiagnostic {

    try {
        $Disks = @(
            Get-CimInstance Win32_DiskDrive -ErrorAction Stop
        )

        if ($Disks.Count -eq 0) {
            return [PSCustomObject]@{
                Name = "SMART"
                Status = "NOT AVAILABLE"
                Score = 80
                Details = "No physical disks were detected."
                Recommendation = ""
            }
        }

        $Problems = @()
        $Checked = 0
        $Healthy = 0

        foreach ($Disk in $Disks) {

            $Status = $Disk.Status

            if ([string]::IsNullOrWhiteSpace($Status)) {
                continue
            }

            $Checked++

            if ($Status -eq "OK") {
                $Healthy++
            }
            else {
                $Problems += "$($Disk.Model): $Status"
            }
        }

        #-------------------------------------------------
        # No SMART information available
        #-------------------------------------------------

        if ($Checked -eq 0) {

            return [PSCustomObject]@{
                Name = "SMART"
                Status = "NOT AVAILABLE"
                Score = 80
                Details = "SMART health information is not available from Windows."
                Recommendation = "Check disk health using the manufacturer diagnostic tool."
            }
        }

        #-------------------------------------------------
        # Disk problems detected
        #-------------------------------------------------

        if ($Problems.Count -gt 0) {
            $Details = "Potential disk problems detected: $($Problems -join '; ')"
            return [PSCustomObject]@{
                Name = "SMART"
                Status = "CRITICAL"
                Score = 20
                Details = $Details
                Recommendation = "Back up important data and check the affected disk immediately."
            }
        }

        #-------------------------------------------------
        # All disks healthy
        #-------------------------------------------------

        return [PSCustomObject]@{
            Name = "SMART"
            Status = "OK"
            Score = 100
            Details = "SMART disk status is healthy. $Healthy physical disk(s) checked."
            Recommendation = ""
        }
    }

    catch {
        return [PSCustomObject]@{
            Name = "SMART"
            Status = "ERROR"
            Score = 0
            Details = $_.Exception.Message
            Recommendation = "Unable to verify disk health."
        }
    }
}

Export-ModuleMember -Function *