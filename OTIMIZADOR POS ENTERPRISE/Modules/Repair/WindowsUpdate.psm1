function Get-WindowsUpdateRepairStatus {
    [PSCustomObject]@{ Name = 'Windows Update'; Status = 'Available'; RepairFunction = 'Invoke-WindowsUpdateRepair' }
}
function Invoke-WindowsUpdateRepair {
    Invoke-WithStoppedServices -Names @('wuauserv','BITS','cryptSvc') -Action {
        foreach ($path in @(
            (Join-Path $env:windir 'SoftwareDistribution\Download'),
            (Join-Path $env:windir 'SoftwareDistribution\DataStore'),
            (Join-Path $env:windir 'System32\catroot2')
        )) { Remove-CleanupContent -Path $path }
    }
}
Export-ModuleMember -Function Get-WindowsUpdateRepairStatus, Invoke-WindowsUpdateRepair
