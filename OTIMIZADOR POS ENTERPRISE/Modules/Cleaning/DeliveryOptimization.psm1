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
    Invoke-WithStoppedServices -Names @('DoSvc') -Action { Remove-CleanupContent -Path (Join-Path $env:ProgramData 'Microsoft\Windows\DeliveryOptimization\Cache') }
}
Export-ModuleMember -Function Get-DeliveryOptimizationAnalysis, Invoke-DeliveryOptimizationCleanup
