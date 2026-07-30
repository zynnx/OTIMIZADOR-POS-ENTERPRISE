#=========================================================
# Firewall.psm1
# Firewall Diagnostic
#=========================================================

function Get-FirewallDiagnostic {

    return [PSCustomObject]@{

        Name               = "Firewall"

        DiagnosticFunction = "Invoke-FirewallDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-FirewallDiagnostic {

    try {

        $Profiles = @(Get-NetFirewallProfile -ErrorAction Stop)

        if ($Profiles.Count -eq 0) {
            return [PSCustomObject]@{
                Name           = "Firewall"
                Status         = "ERROR"
                Score          = 50
                Details        = "No firewall profiles were found."
                Recommendation = "Check the Windows Firewall configuration."

            }

        }
        $Enabled = @(
            $Profiles | Where-Object {
                $_.Enabled -eq $true
            }
        )

        $Disabled = @(
            $Profiles | Where-Object {
                $_.Enabled -eq $false
            }
        )

        $Total = $Profiles.Count
        $EnabledCount = $Enabled.Count
        $DisabledCount = $Disabled.Count

        #-------------------------------------------------
        # All profiles enabled
        #-------------------------------------------------

        if ($DisabledCount -eq 0) {
            $Status = "OK"
            $Score = 100
            $Details = "Windows Firewall is enabled on all profiles ($EnabledCount/$Total)."
            $Recommendation = ""
        }

        #-------------------------------------------------
        # Some profiles disabled
        #-------------------------------------------------

        elseif ($EnabledCount -gt 0) {
            $Names = ($Disabled.Name -join ", ")
            $Status = "WARNING"
            $Score = 70
            $Details = "Firewall enabled on $EnabledCount/$Total profiles. Disabled: $Names."
            $Recommendation = "Review the disabled firewall profiles."
        }

        #-------------------------------------------------
        # All profiles disabled
        #-------------------------------------------------

        else {
            $Names = ($Disabled.Name -join ", ")
            $Status = "CRITICAL"
            $Score = 20
            $Details = "Windows Firewall is disabled on all profiles: $Names."
            $Recommendation = "Enable Windows Firewall on all active network profiles."
        }

        return [PSCustomObject]@{
            Name           = "Firewall"
            Status         = $Status
            Score          = $Score
            Details        = $Details
            Recommendation = $Recommendation
        }
    }
    catch {
        return [PSCustomObject]@{
            Name           = "Firewall"
            Status         = "ERROR"
            Score          = 50
            Details        = "Unable to verify Windows Firewall status."
            Recommendation = "Check the Windows Firewall service and configuration."
        }
    }
}

Export-ModuleMember -Function *