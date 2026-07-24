#=========================================================
# CPU.psm1
# Diagnóstico do Processador
#=========================================================

function Get-CPUDiagnostic {

    return [PSCustomObject]@{

        Name = "CPU"

        DiagnosticFunction = "Invoke-CPUDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-CPUDiagnostic {

    try {

        $CPU = Get-CimInstance Win32_Processor

        $Load = [int]$CPU.LoadPercentage

        $Name = $CPU.Name.Trim()

        $Cores = $CPU.NumberOfCores

        $Threads = $CPU.NumberOfLogicalProcessors

        $Speed = [math]::Round($CPU.MaxClockSpeed / 1000,2)

        #
        # Classificação
        #

        if($Load -lt 60){

            $Status = "OK"
            $Score = 100
            $Recommendation = ""

        }
        elseif($Load -lt 80){

            $Status = "ATENÇÃO"
            $Score = 90
            $Recommendation = "Verificar aplicações em execução."

        }
        elseif($Load -lt 95){

            $Status = "ELEVADA"
            $Score = 70
            $Recommendation = "Analisar processos com utilização elevada."

        }
        else{

            $Status = "CRÍTICO"
            $Score = 30
            $Recommendation = "Verificar possível bloqueio ou sobrecarga do sistema."

        }

        return [PSCustomObject]@{

            Name = "CPU"

            Status = $Status

            Score = $Score

            Details = "$Name | $Cores Cores | $Threads Threads | $Speed GHz | $Load%"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "CPU"

            Status = "ERRO"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Verificar processador."

        }

    }

}

Export-ModuleMember -Function *