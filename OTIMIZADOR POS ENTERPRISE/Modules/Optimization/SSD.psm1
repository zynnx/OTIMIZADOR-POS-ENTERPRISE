function Get-SSDStatus {
    [PSCustomObject]@{ Name = 'SSD'; Status = 'Available'; OptimizeFunction = 'Invoke-SSDOptimization' }
}
function Invoke-SSDOptimization {
    $letter = $env:SystemDrive.TrimEnd(':')
    $partition = Get-Partition -DriveLetter $letter -ErrorAction Stop
    $disk = $partition | Get-Disk -ErrorAction Stop
    $physical = @(Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq [string]$disk.Number -and $_.MediaType -eq 'SSD' })
    if (-not $physical.Count) { return New-OperationResult SSD Skipped -Reason 'System volume could not be confirmed as SSD' }
    Optimize-Volume -DriveLetter $letter -ReTrim -ErrorAction Stop | Out-Null
    New-OperationResult SSD Success -Reason 'ReTrim completed; TRIM configuration unchanged'
}
Export-ModuleMember -Function Get-SSDStatus, Invoke-SSDOptimization
