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

        $CPU = Get-CimInstance Win32_Processor

        $Load = [int]$CPU.LoadPercentage

        $Name = $CPU.Name.Trim()

        $Cores = $CPU.NumberOfCores

        $Threads = $CPU.NumberOfLogicalProcessors

        $Speed = [math]::Round($CPU.MaxClockSpeed / 1000,2)

        #
        # Classification
        #

        if($Load -lt 60){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Load -lt 80){

            $Status = "WARNING"
            $Score = 90
            $Recommendation = "Check running applications."

        }
        elseif($Load -lt 95){

            $Status = "ELEVADA"
            $Score = 70
            $Recommendation = "Analyze high usage processes."

        }
        else{

            $Status = "CRITICAL"
            $Score = 30
            $Recommendation = "Check for possible system lock or overload."

        }

        return [PSCustomObject]@{

            Name = "CPU"

            Status = $Status

            Score = $Score

            Details = "$Name | $Cores Cores | $Threads Threads | $Speed GHz | $Load%"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "CPU"

            Status = "ERROR"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Check processor."

        }

    }

}

Export-ModuleMember -Function *






