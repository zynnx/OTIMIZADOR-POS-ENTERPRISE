#=========================================================
# Firewall.psm1
# Diagnóstico do Firewall
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

            $Status = "ATENÇÃO"
            $Score = 80
            $Details = "Perfis desativados: $Names"
            $Recommendation = "Verificar a configuração da Firewall."

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
            Status = "ERRO"
            Score = 50
            Details = "Não foi possível verificar a Firewall."
            Recommendation = "Verificar o serviço da Firewall."

        }

    }

}

Export-ModuleMember -Function *