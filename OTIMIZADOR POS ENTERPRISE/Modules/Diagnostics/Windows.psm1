#=========================================================
# Windows.psm1
# Windows Diagnostic
#=========================================================

function Get-WindowsDiagnostic {

    return [PSCustomObject]@{
        Name               = "Windows"
        DiagnosticFunction = "Invoke-WindowsDiagnostic"
    }

}

#---------------------------------------------------------

function Invoke-WindowsDiagnostic {

    try {

        $OS = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop

        if (-not $OS) {
            throw "Unable to retrieve Windows operating system information."
        }

        #-------------------------------------------------
        # Basic Windows information
        #-------------------------------------------------

        $Caption = $OS.Caption
        $Build = $OS.BuildNumber
        $Version = $OS.Version

        #-------------------------------------------------
        # Get uptime safely
        #-------------------------------------------------

        $Boot = $null
        try {
            if ($OS.LastBootUpTime -is [DateTime]) {
                $Boot = $OS.LastBootUpTime
            }
            else {
                $Boot = [Management.ManagementDateTimeConverter]::ToDateTime(
                    [string]$OS.LastBootUpTime
                )
            }
        }
        catch {
            $Boot = $null
        }

        #-------------------------------------------------
        # Calculate uptime
        #-------------------------------------------------

        if ($Boot) {

            $Uptime = (Get-Date) - $Boot

            $Days = [math]::Floor($Uptime.TotalDays)

            $Hours = $Uptime.Hours

            $Minutes = $Uptime.Minutes

            $UptimeText = "{0} days, {1} hours, {2} minutes" -f `
                $Days,
            $Hours,
            $Minutes

        }
        else {
            $Days = -1
            $UptimeText = "Unable to determine uptime."
        }

        #-------------------------------------------------
        # Classification
        #-------------------------------------------------

        if ($Days -eq -1) {
            $Status = "WARNING"
            $Score = 80
            $Recommendation = "Windows uptime could not be determined."
        }
        elseif ($Days -lt 15) {
            $Status = "OK"
            $Score = 100
            $Recommendation = ""
        }
        elseif ($Days -lt 30) {
            $Status = "WARNING"
            $Score = 85
            $Recommendation = "It is recommended to restart the POS."
        }
        elseif ($Days -lt 60) {
            $Status = "WARNING"
            $Score = 70
            $Recommendation = "The POS has been running for an extended period. Restart when convenient."
        }
        else {
            $Status = "CRITICAL"
            $Score = 40
            $Recommendation = "The POS has been running for a very long period. Restart as soon as possible."
        }

        #-------------------------------------------------
        # Details
        #-------------------------------------------------

        $Details = "{0} | Build {1} | Version {2} | Uptime: {3}" -f `
            $Caption,
        $Build,
        $Version,
        $UptimeText

        return [PSCustomObject]@{
            Name           = "Windows"
            Status         = $Status
            Score          = $Score
            Details        = $Details
            Recommendation = $Recommendation
        }
    }
    catch {
        return [PSCustomObject]@{
            Name           = "Windows"
            Status         = "ERROR"
            Score          = 0
            Details        = $_.Exception.Message
            Recommendation = "Check Windows operating system health."
        }
    }
}
Export-ModuleMember -Function *
