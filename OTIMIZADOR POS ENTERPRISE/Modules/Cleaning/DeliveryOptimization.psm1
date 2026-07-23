#=========================================================
# DeliveryOptimization.psm1
# Limpeza da Cache do Delivery Optimization
#=========================================================

function Get-DeliveryOptimizationAnalysis {

    $Path = "C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"

    if (!(Test-Folder $Path)) {

        return [PSCustomObject]@{

            Name            = "Delivery Optimization"
            Path            = $Path
            Size            = 0
            SizeText        = "0 Bytes"
            Files           = 0
            CleanupFunction = "Invoke-DeliveryOptimizationCleanup"

        }

    }

    $Size  = Get-FolderSize $Path
    $Files = Get-FilesCount $Path

    return [PSCustomObject]@{

        Name            = "Delivery Optimization"
        Path            = $Path
        Size            = $Size
        SizeText        = Convert-Bytes $Size
        Files           = $Files
        CleanupFunction = "Invoke-DeliveryOptimizationCleanup"

    }

}

#---------------------------------------------------------

function Invoke-DeliveryOptimizationCleanup {

    $Path = "C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"

    if (!(Test-Folder $Path)) {

        Write-Log "Cache Delivery Optimization não encontrada." "WARNING"
        return

    }

    Write-Log "A limpar Delivery Optimization..." "INFO"

    #
    # Tenta parar o serviço DoSvc
    #

    try {

        $Service = Get-Service DoSvc -ErrorAction Stop

        if ($Service.Status -eq "Running") {

            Stop-Service DoSvc -Force -ErrorAction Stop

            $Service.WaitForStatus("Stopped","00:00:15")

        }

    }
    catch {

        Write-Log "Não foi possível parar o serviço DoSvc." "WARNING"

    }

    #
    # Limpeza
    #

    $Removed = 0
    $Errors = 0

    try {

        Get-ChildItem `
            -Path $Path `
            -Force `
            -ErrorAction SilentlyContinue |

        ForEach-Object {

            try {

                Remove-Item `
                    $_.FullName `
                    -Force `
                    -Recurse `
                    -ErrorAction Stop

                $Removed++

            }
            catch {

                $Errors++

            }

        }

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    #
    # Reinicia o serviço
    #

    try {

        $Service = Get-Service DoSvc -ErrorAction Stop

        if ($Service.Status -ne "Running") {

            Start-Service DoSvc

        }

    }
    catch {

        Write-Log "Não foi possível iniciar o serviço DoSvc." "WARNING"

    }

    Write-Log "Itens removidos: $Removed" "INFO"

    if ($Errors -gt 0) {

        Write-Log "Itens ignorados: $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *