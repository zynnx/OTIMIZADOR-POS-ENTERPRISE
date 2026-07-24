#=========================================================
# Defender.psm1
# Diagnóstico do Microsoft Defender
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
            $Details = "Proteção em tempo real ativa."

        }
        else {

            $Status = "CRÍTICO"
            $Score = 20
            $Recommendation = "Ativar o Microsoft Defender."
            $Details = "Proteção em tempo real desativada."

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
            Status = "NÃO DISPONÍVEL"
            Score = 80
            Details = "Microsoft Defender não está instalado ou foi substituído por outro antivírus."
            Recommendation = ""

        }

    }

}

Export-ModuleMember -Function *