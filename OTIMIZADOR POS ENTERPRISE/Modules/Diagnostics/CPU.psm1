#=========================================================
# CPU.psm1
# CPU Diagnostic
#=========================================================

function Get-CPUDiagnostic {

    return [PSCustomObject]@{
        Name = "CPU"
        DiagnosticFunction = "Invoke-CPUDiagnostic"
    }
}

#---------------------------------------------------------

function Invoke-CPUDiagnostic {

    try {
        #-------------------------------------------------
        # CPU information
        #-------------------------------------------------

        $CPU = Get-CimInstance Win32_Processor -ErrorAction Stop

        if (-not $CPU) {
            throw "Unable to retrieve CPU information."
        }

        $Name = ($CPU | Select-Object -First 1).Name
        $Cores = ($CPU | Measure-Object -Property NumberOfCores -Sum).Sum
        $Threads = ($CPU | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

        $MaxClock = [math]::Round(
            (($CPU | Measure-Object -Property MaxClockSpeed -Average).Average) / 1000,
            2
        )

        #-------------------------------------------------
        # CPU usage sampling
        #-------------------------------------------------

        $Samples = @()

        for ($i = 0; $i -lt 3; $i++) {

            $Sample = Get-CimInstance Win32_Processor |
                Measure-Object -Property LoadPercentage -Average

            if ($null -ne $Sample.Average) {
                $Samples += [double]$Sample.Average
            }

            if ($i -lt 2) {
                Start-Sleep -Seconds 1
            }
        }

        if ($Samples.Count -gt 0) {
            $Usage = [math]::Round(
                ($Samples | Measure-Object -Average).Average
            )
        }
        else {
            $Usage = 0
        }

        #-------------------------------------------------
        # Classification
        #-------------------------------------------------

        if ($Usage -lt 60) {
            $Status = "OK"
            $Score = 100
            $Recommendation = ""
        }
        elseif ($Usage -lt 80) {
            $Status = "WARNING"
            $Score = 85
            $Recommendation = "Monitor CPU usage and check applications if high usage persists."
        }
        elseif ($Usage -lt 95) {
            $Status = "WARNING"
            $Score = 70
            $Recommendation = "Check applications and processes consuming CPU resources."
        }
        else {
            $Status = "CRITICAL"
            $Score = 30
            $Recommendation = "Investigate processes causing sustained high CPU usage."
        }

        #-------------------------------------------------
        # Details
        #-------------------------------------------------

        $Details = "{0} | {1} Cores | {2} Threads | {3} GHz | Average usage: {4}%" -f `
            $Name,
            $Cores,
            $Threads,
            $MaxClock,
            $Usage

        return [PSCustomObject]@{
            Name = "CPU"
            Status = $Status
            Score = $Score
            Details = $Details
            Recommendation = $Recommendation
        }
    }
    catch {
        return [PSCustomObject]@{
            Name = "CPU"
            Status = "ERROR"
            Score = 0
            Details = $_.Exception.Message
            Recommendation = "Unable to determine CPU health."
        }
    }
}

Export-ModuleMember -Function *
