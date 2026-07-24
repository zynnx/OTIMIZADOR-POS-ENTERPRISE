#=========================================================
# Defender.psm1
# Microsoft Defender Diagnostic
#=========================================================

function Get-DefenderDiagnostic {

    return [PSCustomObject]@{

        Name = "Defender"

        DiagnosticFunction = "Invoke-DefenderDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-DefenderDiagnostic {

    try {

        $Defender = Get-MpComputerStatus -ErrorAction Stop

        if ($Defender.RealTimeProtectionEnabled) {

            $Status = "OK"
            $Score = 100
            $Recommendation = ""
            $Details = "Real-time protection is enabled."

        }
        else {

            $Status = "CRITICAL"
            $Score = 20
            $Recommendation = "Enable Microsoft Defender."
            $Details = "Real-time protection is disabled."

        }

        return [PSCustomObject]@{

            Name = "Defender"
            Status = $Status
            Score = $Score
            Details = $Details
            Recommendation = $Recommendation

        }

    }
    catch {

        return [PSCustomObject]@{

            Name = "Defender"
            Status = "NOT AVAILABLE"
            Score = 80
            Details = "Microsoft Defender is not installed or has been replaced by another antivirus."
            Recommendation = ""

        }

    }

}

Export-ModuleMember -Function *