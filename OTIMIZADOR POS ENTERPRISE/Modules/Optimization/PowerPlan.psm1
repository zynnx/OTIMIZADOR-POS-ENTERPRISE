#=========================================================
# PowerPlan.psm1
# Plano de Energia
#=========================================================

function Get-PowerPlanStatus {

    $Status = "Desconhecido"

    try {

        $Output = powercfg /L

        $Current = ($Output | Where-Object { $_ -match "\*" })

        if ($Current) {

            if ($Current -match "High performance|Alto desempenho") {

                $Status = "Otimizado"

            }
            else {

                $Status = "Não otimizado"

            }

        }

    }
    catch {

        $Status = "Erro"

    }

    return [PSCustomObject]@{

        Name = "Plano de Energia"

        Status = $Status

        OptimizeFunction = "Invoke-PowerPlanOptimization"

    }

}

#---------------------------------------------------------

function Invoke-PowerPlanOptimization {

    Write-Log "A verificar planos de energia..." "INFO"

    $Plans = powercfg /L

    #
    # Procura Alto Desempenho
    #

    $High = $Plans | Where-Object {

        $_ -match "High performance|Alto desempenho"

    }

    if (-not $High) {

        Write-Log "Plano Alto Desempenho não encontrado." "WARNING"

        Write-Log "A criar plano Alto Desempenho..." "INFO"

        powercfg -duplicatescheme SCHEME_MIN | Out-Null

        $Plans = powercfg /L

        $High = $Plans | Where-Object {

            $_ -match "High performance|Alto desempenho"

        }

    }

    if ($High) {

        if ($High -match "([a-fA-F0-9\-]{36})") {

            $Guid = $Matches[1]

            powercfg /S $Guid

            Write-Log "Plano Alto Desempenho ativado." "OK"

        }

    }
    else {

        Write-Log "Não foi possível ativar o plano." "ERROR"

    }

}

Export-ModuleMember -Function *