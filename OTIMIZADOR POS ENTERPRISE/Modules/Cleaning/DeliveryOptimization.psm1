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

        Write-Log "Delivery Optimization cache not found." "WARNING"
        return

    }

    Write-Log "Cleaning Delivery Optimization cache..." "INFO"

    #
    # Attempt to stop the DoSvc service
    #

    try {

        $Service = Get-Service DoSvc -ErrorAction Stop

        if ($Service.Status -eq "Running") {

            Stop-Service DoSvc -Force -ErrorAction Stop

            $Service.WaitForStatus("Stopped","00:00:15")

        }

    }
    catch {

        Write-Log "Could not stop service DoSvc." "WARNING"

    }

    #
    # Cleanup
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
    # Restart the service
    #

    try {

        $Service = Get-Service DoSvc -ErrorAction Stop

        if ($Service.Status -ne "Running") {

            Start-Service DoSvc

        }

    }
    catch {

        Write-Log "Could not start service DoSvc." "WARNING"

    }

    Write-Log "Items removed: $Removed" "INFO"

    if ($Errors -gt 0) {

        Write-Log "Items ignored: $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *