#=========================================================
# SSD.psm1
# Otimização para SSD
#=========================================================

function Get-SSDStatus {

    $Status = "Não suportado"

    try {

        $Media = Get-PhysicalDisk -ErrorAction Stop | Where-Object {
            $_.MediaType -eq "SSD"
        }

        if ($Media) {

            $Trim = (fsutil behavior query DisableDeleteNotify)

            if ($Trim -match "DisableDeleteNotify = 0") {

                $Status = "Otimizado"

            }
            else {

                $Status = "TRIM desativado"

            }

        }

    }
    catch {

        $Status = "Desconhecido"

    }

    return [PSCustomObject]@{

        Name = "SSD"

        Status = $Status

        OptimizeFunction = "Invoke-SSDOptimization"

    }

}

#---------------------------------------------------------

function Invoke-SSDOptimization {

    Write-Log "A verificar SSD..." "INFO"

    try {

        $SSD = Get-PhysicalDisk -ErrorAction Stop | Where-Object {
            $_.MediaType -eq "SSD"
        }

        if (-not $SSD) {

            Write-Log "Não foi detetado nenhum SSD." "INFO"
            return

        }

    }
    catch {

        Write-Log "Não foi possível determinar o tipo de disco." "WARNING"
        return

    }

    #
    # Ativar TRIM
    #

    fsutil behavior set DisableDeleteNotify 0 | Out-Null

    Write-Log "TRIM ativado." "OK"

    #
    # Executar ReTrim
    #

    try {

        Optimize-Volume `
            -DriveLetter C `
            -ReTrim `
            -ErrorAction Stop

        Write-Log "ReTrim executado." "OK"

    }
    catch {

        Write-Log "Não foi possível executar o ReTrim." "WARNING"

    }

}

Export-ModuleMember -Function *