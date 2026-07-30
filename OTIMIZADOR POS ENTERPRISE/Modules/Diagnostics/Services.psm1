#=========================================================
# Services.psm1
# Services Diagnostic
#=========================================================

function Get-ServicesDiagnostic {

    return [PSCustomObject]@{
        Name               = "Services"
        DiagnosticFunction = "Invoke-ServicesDiagnostic"
    }

}

#---------------------------------------------------------

function Invoke-ServicesDiagnostic {

    #-----------------------------------------------------
    # Essential Windows services
    #-----------------------------------------------------

    $CriticalServices = @(
        "EventLog",
        "Spooler"
    )

    #-----------------------------------------------------
    # Important but non-critical services
    #-----------------------------------------------------

    $ImportantServices = @(
        "wuauserv",
        "BITS"
    )

    $CriticalStopped = @()
    $ImportantStopped = @()
    $NotFound = @()

    #-----------------------------------------------------
    # Check critical services
    #-----------------------------------------------------

    foreach ($Name in $CriticalServices) {

        try {
            $Service = Get-Service $Name -ErrorAction Stop
            if ($Service.Status -ne "Running") {
                $CriticalStopped += $Name
            }
        }
        catch {
            $NotFound += $Name
        }
    }

    #-----------------------------------------------------
    # Check important services
    #-----------------------------------------------------

    foreach ($Name in $ImportantServices) {

        try {
            $Service = Get-Service $Name -ErrorAction Stop
            if ($Service.Status -ne "Running") {
                $ImportantStopped += $Name
            }
        }
        catch {
            $NotFound += $Name
        }
    }

    #-----------------------------------------------------
    # Critical service failure
    #-----------------------------------------------------

    if ($CriticalStopped.Count -gt 0) {
        $Status = "CRITICAL"
        $Score = 40
        $Details = "Critical services stopped: $($CriticalStopped -join ', ')"
        $Recommendation = "Start the stopped critical services and verify Windows service health."
    }

    #-----------------------------------------------------
    # Important services stopped
    #-----------------------------------------------------

    elseif ($ImportantStopped.Count -gt 0) {
        $Status = "WARNING"
        $Score = 80
        $Details = "Important services stopped: $($ImportantStopped -join ', ')"
        $Recommendation = "Review Windows Update services if updates or maintenance are required."
    }

    #-----------------------------------------------------
    # Services not found
    #-----------------------------------------------------

    elseif ($NotFound.Count -gt 0) {
        $Status = "WARNING"
        $Score = 80
        $Details = "Services not found: $($NotFound -join ', ')"
        $Recommendation = "Verify the Windows service configuration."
    }

    #-----------------------------------------------------
    # Everything OK
    #-----------------------------------------------------

    else {
        $Status = "OK"
        $Score = 100
        $Details = "All required Windows services are running."
        $Recommendation = ""
    }

    return [PSCustomObject]@{
        Name           = "Services"
        Status         = $Status
        Score          = $Score
        Details        = $Details
        Recommendation = $Recommendation
    }
}
Export-ModuleMember -Function *
