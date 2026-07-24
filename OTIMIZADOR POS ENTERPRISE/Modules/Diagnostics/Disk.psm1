#=========================================================
# Disk.psm1
# Diagnóstico do Disco
#=========================================================

function Get-DiskDiagnostic {

    return [PSCustomObject]@{

        Name = "Disco"

        DiagnosticFunction = "Invoke-DiskDiagnostic"

    }

}

#---------------------------------------------------------

function Invoke-DiskDiagnostic {

    try {

        $Drive = Get-CimInstance Win32_LogicalDisk `
                    -Filter "DeviceID='C:'"

        $FreeGB = [math]::Round($Drive.FreeSpace / 1GB,2)

        $TotalGB = [math]::Round($Drive.Size / 1GB,2)

        $Percent = [math]::Round(($Drive.FreeSpace / $Drive.Size) * 100)

        #
        # Classificação
        #

        if($Percent -ge 20){

            $Status = "OK"

            $Score = 100

            $Recommendation = ""

        }
        elseif($Percent -ge 15){

            $Status = "ATENÇÃO"

            $Score = 90

            $Recommendation = "Executar Limpeza Inteligente"

        }
        elseif($Percent -ge 10){

            $Status = "ATENÇÃO"

            $Score = 70

            $Recommendation = "Executar Limpeza Inteligente"

        }
        elseif($Percent -ge 5){

            $Status = "CRÍTICO"

            $Score = 40

            $Recommendation = "Libertar espaço urgentemente"

        }
        else{

            $Status = "CRÍTICO"

            $Score = 10

            $Recommendation = "Disco quase cheio"

        }

        return [PSCustomObject]@{

            Name = "Disco"

            Status = $Status

            Score = $Score

            Details = "$FreeGB GB livres de $TotalGB GB ($Percent%)"

            Recommendation = $Recommendation

        }

    }
    catch{

        return [PSCustomObject]@{

            Name = "Disco"

            Status = "ERRO"

            Score = 0

            Details = $_.Exception.Message

            Recommendation = "Verificar disco"

        }

    }

}

Export-ModuleMember -Function *