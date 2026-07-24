#=========================================================
# Services.psm1
# Diagnóstico de Serviços
#=========================================================

function Get-ServicesDiagnostic {

    return [PSCustomObject]@{

        Name = "Serviços"

        DiagnosticFunction = "Invoke-ServicesDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-ServicesDiagnostic {

    #
    # Serviços críticos do Windows
    #

    $Services = @(

        "Spooler",
        "wuauserv",
        "BITS",
        "EventLog"

    )

    $Stopped = @()

    foreach($Name in $Services){

        try{

            $Service = Get-Service $Name -ErrorAction Stop

            if($Service.Status -ne "Running"){

                $Stopped += $Name

            }

        }
        catch{

            $Stopped += "$Name (Não encontrado)"

        }

    }

    if($Stopped.Count -eq 0){

        return [PSCustomObject]@{

            Name = "Serviços"

            Status = "OK"

            Score = 100

            Details = "Todos os serviços críticos estão ativos."

            Recommendation = ""

        }

    }

    return [PSCustomObject]@{

        Name = "Serviços"

        Status = "ATENÇÃO"

        Score = 70

        Details = "Parados: $($Stopped -join ', ')"

        Recommendation = "Verificar os serviços do Windows."

    }

}

Export-ModuleMember -Function *