#=========================================================
# Smart.psm1
# Diagnóstico SMART do Disco
#=========================================================

function Get-SmartDiagnostic {

    return [PSCustomObject]@{

        Name = "SMART"

        DiagnosticFunction = "Invoke-SmartDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-SmartDiagnostic {

    try {

        $Status = Get-CimInstance `
            -Namespace root\wmi `
            -ClassName MSStorageDriver_FailurePredictStatus `
            -ErrorAction Stop

        if($Status){

            $PredictFailure = $Status | Where-Object {$_.PredictFailure -eq $true}

            if($PredictFailure){

                return [PSCustomObject]@{

                    Name = "SMART"

                    Status = "CRÍTICO"

                    Score = 20

                    Details = "O disco indica possível falha."

                    Recommendation = "Substituir o disco o mais rapidamente possível."

                }

            }
            else{

                return [PSCustomObject]@{

                    Name = "SMART"

                    Status = "OK"

                    Score = 100

                    Details = "Nenhuma falha prevista pelo SMART."

                    Recommendation = ""

                }

            }

        }

        return [PSCustomObject]@{

            Name = "SMART"

            Status = "DESCONHECIDO"

            Score = 80

            Details = "Não foi possível obter informações SMART."

            Recommendation = ""

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "SMART"

            Status = "NÃO SUPORTADO"

            Score = 80

            Details = "O hardware ou controlador não disponibiliza SMART."

            Recommendation = ""

        }

    }

}

Export-ModuleMember -Function *