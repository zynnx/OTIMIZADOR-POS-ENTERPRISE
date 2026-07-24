#=========================================================
# Firewall.psm1
# Firewall Diagnostic
#=========================================================

function Get-FirewallDiagnostic {

    return [PSCustomObject]@{

        Name = "Firewall"

        DiagnosticFunction = "Invoke-FirewallDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-FirewallDiagnostic {

    try {

        $Profiles = Get-NetFirewallProfile -ErrorAction Stop

        $Disabled = $Profiles | Where-Object { $_.Enabled -eq $false }

        if ($Disabled.Count -eq 0) {

            $Status = "OK"
            $Score = 100
            $Details = "Firewall ativa em todos os perfis."
            $Recommendation = ""

        }
        else {

            $Names = ($Disabled.Name -join ", ")

            $Status = "WARNING"
            $Score = 80
            $Details = "Disabled profiles: $Names"
            $Recommendation = "Check the firewall configuration."

        }

        return [PSCustomObject]@{

            Name = "Firewall"
            Status = $Status
            Score = $Score
            Details = $Details
            Recommendation = $Recommendation

        }

    }
    catch {

        return [PSCustomObject]@{

            Name = "Firewall"
            Status = "ERROR"
            Score = 50
            Details = "Unable to verify the firewall."
            Recommendation = "Check the firewall service."

        }

    }

}

Export-ModuleMember -Function *