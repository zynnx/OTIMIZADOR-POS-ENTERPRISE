#=========================================================
# Windows.psm1
# Diagnóstico do Windows
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
        # Classificação
        #

        if($Days -lt 15){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Days -lt 30){

            $Status = "ATENÇÃO"
            $Score = 85
            $Recommendation = "Recomenda-se reiniciar o computador."

        }
        else{

            $Status = "CRÍTICO"
            $Score = 60
            $Recommendation = "O computador está ligado há muitos dias. Reiniciar."

        }

        return [PSCustomObject]@{

            Name = "Windows"

            Status = $Status

            Score = $Score

            Details = "$Caption | Build $Build | Versão $Version | Uptime: $Days dias"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "Windows"

            Status = "ERRO"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Verificar sistema operativo."

        }

    }

}

Export-ModuleMember -Function *
