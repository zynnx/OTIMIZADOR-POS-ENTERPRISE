function Get-StoreRepairStatus {
    [PSCustomObject]@{ Name = 'Microsoft Store'; Status = 'Available'; RepairFunction = 'Invoke-StoreRepair' }
}
function Invoke-StoreRepair {
    $process = Start-Process -FilePath "$env:SystemRoot\System32\wsreset.exe" -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) { throw "WSReset exited with code $($process.ExitCode)." }
    $packages = @(Get-AppxPackage -AllUsers Microsoft.WindowsStore -ErrorAction Stop)
    if (-not $packages.Count) { return New-OperationResult 'Microsoft Store' Skipped -Reason 'Store is not installed' }
    foreach ($package in $packages) {
        Add-AppxPackage -DisableDevelopmentMode -Register (Join-Path $package.InstallLocation 'AppXManifest.xml') -ErrorAction Stop
    }
    New-OperationResult 'Microsoft Store' Success -Changed $packages.Count
}
Export-ModuleMember -Function Get-StoreRepairStatus, Invoke-StoreRepair
