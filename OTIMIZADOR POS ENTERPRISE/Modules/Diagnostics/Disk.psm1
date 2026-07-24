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
                    -Filter "DeviceID='C:'"

        $FreeGB = [math]::Round($Drive.FreeSpace / 1GB,2)

        $TotalGB = [math]::Round($Drive.Size / 1GB,2)

        $Percent = [math]::Round(($Drive.FreeSpace / $Drive.Size) * 100)

        #
        # Classification
        #

        if($Percent -ge 20){

            $Status = "OK"

            $Score = 100

            $Recommendation = ""

        }
        elseif($Percent -ge 15){

            $Status = "WARNING"

            $Score = 90

            $Recommendation = "Run Smart Cleaning"

        }
        elseif($Percent -ge 10){

            $Status = "WARNING"

            $Score = 70

            $Recommendation = "Run Smart Cleaning"

        }
        elseif($Percent -ge 5){

            $Status = "CRITICAL"

            $Score = 40

            $Recommendation = "Free up space urgently"

        }
        else{

            $Status = "CRITICAL"

            $Score = 10

            $Recommendation = "Disk almost full"

        }

        return [PSCustomObject]@{

            Name = "Disk"

            Status = $Status

            Score = $Score

            Details = "$FreeGB GB free of $TotalGB GB ($Percent%)"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "Disk"

            Status = "ERROR"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Check disk"

        }

    }

}

Export-ModuleMember -Function *






