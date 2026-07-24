#=========================================================
# RAM.psm1
# Diagnóstico da Memória RAM
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
        # Classificação
        #

        if($Percent -lt 70){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Percent -lt 80){

            $Status = "ATENÇÃO"
            $Score = 90
            $Recommendation = "Verificar aplicações abertas."

        }
        elseif($Percent -lt 90){

            $Status = "ELEVADA"
            $Score = 70
            $Recommendation = "Fechar aplicações desnecessárias."

        }
        else{

            $Status = "CRÍTICO"
            $Score = 30
            $Recommendation = "Reiniciar o POS ou aumentar a memória RAM."

        }

        return [PSCustomObject]@{

            Name = "RAM"

            Status = $Status

            Score = $Score

            Details = "$UsedGB GB utilizados de $TotalGB GB ($Percent%)"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "RAM"

            Status = "ERRO"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Verificar memória."

        }

    }

}

Export-ModuleMember -Function *