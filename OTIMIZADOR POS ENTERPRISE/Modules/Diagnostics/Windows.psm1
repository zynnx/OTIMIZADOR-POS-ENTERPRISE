#=========================================================
# Windows.psm1
# Windows Diagnostic
#=========================================================

function Get-WindowsDiagnostic {

    return [PSCustomObject]@{

        Name = "Windows"

        DiagnosticFunction = "Invoke-WindowsDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-WindowsDiagnostic {

    try {

        $OS = Get-CimInstance Win32_OperatingSystem

        $Boot = [Management.ManagementDateTimeConverter]::ToDateTime($OS.LastBootUpTime)

        $Days = [math]::Floor(((Get-Date) - $Boot).TotalDays)

        $Caption = $OS.Caption

        $Build = $OS.BuildNumber

        $Version = $OS.Version

        #
        # Classification
        #

        if($Days -lt 15){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Days -lt 30){

            $Status = "WARNING"
            $Score = 85
            $Recommendation = "It is recommended to restart the computer."

        }
        else{

            $Status = "CRITICAL"
            $Score = 60
            $Recommendation = "The computer has been on for many days. Restart."

        }

        return [PSCustomObject]@{

            Name = "Windows"

            Status = $Status

            Score = $Score

            Details = "$Caption | Build $Build | Version $Version | Uptime: $Days days"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "Windows"

            Status = "ERROR"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Check operating system."

        }

    }

}

Export-ModuleMember -Function *







