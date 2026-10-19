function Get-ServicesStatus {
    [PSCustomObject]@{ Name = 'Services'; Status = 'Available'; OptimizeFunction = 'Invoke-ServicesOptimization' }
}
function Invoke-ServicesOptimization {
    foreach ($name in @('WerSvc','WSearch','SysMain')) {
        try {
            $service = Get-Service -Name $name -ErrorAction Stop
            Set-Service -Name $name -StartupType Manual -ErrorAction Stop
            New-OperationResult $name Success -Changed 1
        } catch { New-OperationResult $name Failed -Errors @($_.Exception.Message) }
    }
}
Export-ModuleMember -Function Get-ServicesStatus, Invoke-ServicesOptimization
