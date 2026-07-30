#=========================================================
# Defender.psm1
# Microsoft Defender Diagnostic
#=========================================================

function Get-DefenderDiagnostic {

    return [PSCustomObject]@{

        Name               = "Defender"

        DiagnosticFunction = "Invoke-DefenderDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-DefenderDiagnostic {

    try {

        $Defender = Get-MpComputerStatus -ErrorAction Stop

        $RealTime = $Defender.RealTimeProtectionEnabled
        $Antivirus = $Defender.AntivirusEnabled
        $Antispyware = $Defender.AntispywareEnabled

        #-------------------------------------------------
        # Everything OK
        #-------------------------------------------------

        if ($RealTime -and $Antivirus -and $Antispyware) {
            $Status = "OK"
            $Score = 100
            $Details = "Microsoft Defender is active and real-time protection is enabled."
            $Recommendation = ""
        }

        #-------------------------------------------------
        # Real-time protection disabled
        #-------------------------------------------------

        elseif (-not $RealTime) {
            $Status = "CRITICAL"
            $Score = 20
            $Details = "Real-time protection is disabled."
            $Recommendation = "Enable Microsoft Defender real-time protection."
        }

        #-------------------------------------------------
        # Antivirus disabled
        #-------------------------------------------------

        elseif (-not $Antivirus) {
            $Status = "CRITICAL"
            $Score = 20
            $Details = "Microsoft Defender antivirus protection is disabled."
            $Recommendation = "Enable Microsoft Defender antivirus protection."
        }

        #-------------------------------------------------
        # Antispyware disabled
        #-------------------------------------------------

        elseif (-not $Antispyware) {
            $Status = "WARNING"
            $Score = 60
            $Details = "Microsoft Defender antispyware protection is disabled."
            $Recommendation = "Enable Microsoft Defender antispyware protection."
        }

        #-------------------------------------------------
        # Return result
        #-------------------------------------------------

        return [PSCustomObject]@{
            Name           = "Defender"
            Status         = $Status
            Score          = $Score
            Details        = $Details
            Recommendation = $Recommendation
        }
    }
    catch {
        return [PSCustomObject]@{
            Name           = "Defender"
            Status         = "NOT AVAILABLE"
            Score          = 80
            Details        = "Microsoft Defender is not available or has been replaced by another antivirus."
            Recommendation = ""
        }
    }
}

Export-ModuleMember -Function *