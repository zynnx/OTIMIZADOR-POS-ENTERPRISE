#=========================================================
# Services.psm1
# Services Diagnostic
#=========================================================

function Get-ServicesDiagnostic {

    return [PSCustomObject]@{

        Name = "Services"

        DiagnosticFunction = "Invoke-ServicesDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-ServicesDiagnostic {

    #
    # Critical Windows services
    #

    $Services = @(

        "Spooler",
        "wuauserv",
        "BITS",
        "EventLog"

    )

    $Stopped = @()

    foreach($Name in $Services){

        try{

            $Service = Get-Service $Name -ErrorAction Stop

            if($Service.Status -ne "Running"){

                $Stopped += $Name

            }

        }
        catch{

            $Stopped += "$Name (Not found)"

        }

    }

    if($Stopped.Count -eq 0){

        return [PSCustomObject]@{

            Name = "Services"

            Status = "OK"

            Score = 100

            Details = "All critical services are active."

            Recommendation = ""

        }

    }

    return [PSCustomObject]@{

        Name = "Services"

        Status = "WARNING"

        Score = 70

        Details = "Stopped: $($Stopped -join ', ')"

        Recommendation = "Please start the missing services or review service health."

    }

}

Export-ModuleMember -Function *



