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

        $OS = Get-CimInstance Win32_OperatingSystem

        $TotalGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB,2)

        $FreeGB = [math]::Round($OS.FreePhysicalMemory / 1MB,2)

        $UsedGB = [math]::Round($TotalGB - $FreeGB,2)

        $Percent = [math]::Round(($UsedGB / $TotalGB) * 100)

        #
        # Classification
        #

        if($Percent -lt 70){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Percent -lt 80){

            $Status = "WARNING"
            $Score = 90
            $Recommendation = "Check open applications."

        }
        elseif($Percent -lt 90){

            $Status = "ELEVADA"
            $Score = 70
            $Recommendation = "Close unnecessary applications."

        }
        else{

            $Status = "CRITICAL"
            $Score = 30
            $Recommendation = "Restart the POS or increase RAM."

        }

        return [PSCustomObject]@{

            Name = "RAM"

            Status = $Status

            Score = $Score

            Details = "$UsedGB GB used of $TotalGB GB ($Percent%)"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "RAM"

            Status = "ERROR"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Check memory."

        }

    }

}

Export-ModuleMember -Function *







