function Get-MaintenanceDefinitions {
    param([ValidateSet('Cleaning', 'Optimization', 'Repair')][string]$Category)
    $definitions = @{
        Cleaning = @(
            @('CleanTemp', 'User TEMP', 'Invoke-TempCleanup'),
            @('CleanWindowsTemp', 'Windows TEMP', 'Invoke-WindowsTempCleanup'),
            @('CleanRecycleBin', 'Recycle Bin', 'Invoke-RecycleBinCleanup'),
            @('CleanThumbnailCache', 'Thumbnail cache', 'Invoke-ThumbnailCacheCleanup'),
            @('CleanWindowsUpdate', 'Windows Update cache', 'Invoke-WindowsUpdateCleanup'),
            @('CleanDeliveryOptimization', 'Delivery Optimization', 'Invoke-DeliveryOptimizationCleanup')
        )
        Optimization = @(
            @('PowerPlan', 'Power Plan', 'Invoke-PowerPlanOptimization'),
            @('VisualEffects', 'Visual Effects', 'Invoke-VisualEffectsOptimization'),
            @('Services', 'Services', 'Invoke-ServicesOptimization'),
            @('SSD', 'SSD', 'Invoke-SSDOptimization'),
            @('Explorer', 'Explorer', 'Invoke-ExplorerOptimization')
        )
        Repair = @(
            @('Windows', 'Windows System Repair', 'Invoke-WindowsRepair'),
            @('WindowsUpdate', 'Windows Update', 'Invoke-WindowsUpdateRepair'),
            @('CheckDisk', 'Disk check', 'Invoke-CheckDiskRepair'),
            @('ComponentStore', 'Component Store', 'Invoke-ComponentStoreRepair'),
            @('Store', 'Microsoft Store', 'Invoke-StoreRepair')
        )
    }
    $config = Get-Config $Category
    foreach ($definition in $definitions[$Category]) {
        [PSCustomObject]@{ Key = $definition[0]; Name = $definition[1]; Function = $definition[2]; Enabled = $config.($definition[0]) }
    }
}
function New-OperationResult {
    param([string]$Name, [ValidateSet('Success','Failed','Partial','Skipped','Planned')][string]$Status,
        [int]$Changed = 0, [string[]]$Errors = @(), [string]$Reason = '')
    [PSCustomObject]@{ Name = $Name; Status = $Status; Changed = $Changed; Errors = @($Errors); Reason = $Reason }
}
function Initialize-MaintenanceProtection {
    if ($Global:App.ProtectionReady) { return }
    $config = Get-Config Config
    if ($config.CreateRestorePoint) {
        $created = New-RestorePointSafe
        if (-not $created -and $config.RequireRestorePoint) { throw 'Maintenance stopped: the required restore point could not be created.' }
    }
    Save-MaintenanceSnapshot
    $Global:App.ProtectionReady = $true
}
function Invoke-MaintenanceCategory {
    [CmdletBinding(SupportsShouldProcess)]
    param([ValidateSet('Cleaning', 'Optimization', 'Repair')][string]$Category, [string[]]$Only)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $details = @()
    foreach ($item in @(Get-MaintenanceDefinitions $Category)) {
        if (-not $item.Enabled -or ($Only -and $item.Key -notin $Only)) {
            $details += New-OperationResult $item.Name Skipped -Reason 'Disabled or not selected'
            continue
        }
        if (-not $PSCmdlet.ShouldProcess($item.Name, $Category)) {
            $details += New-OperationResult $item.Name Planned -Reason 'Simulation or declined'
            continue
        }
        try {
            Initialize-MaintenanceProtection
            $command = Get-Command $item.Function -CommandType Function -ErrorAction Stop
            $output = @(& $command)
            $result = @($output | Where-Object { $_ -and $_.PSObject.Properties['Status'] -and $_.Status -in @('Success','Failed','Partial','Skipped') })
            if ($result.Count) { $details += $result }
            else { $details += New-OperationResult $item.Name Success }
        }
        catch {
            $details += New-OperationResult $item.Name Failed -Errors @($_.Exception.Message)
            Write-Log "$($item.Name): $($_.Exception.Message)" ERROR
            if (-not $Global:App.ProtectionReady) { break }
        }
    }
    $watch.Stop()
    $result = [PSCustomObject]@{
        Date = Get-Date; Module = $Category; Items = $details.Count
        Success = @($details | Where-Object Status -eq Success).Count
        Errors = @($details | Where-Object { $_.Status -in @('Failed','Partial') }).Count
        Skipped = @($details | Where-Object Status -eq Skipped).Count
        Planned = @($details | Where-Object Status -eq Planned).Count
        Details = $details; Elapsed = $watch.Elapsed; Duration = Format-Time $watch.Elapsed
        SpaceRecovered = [long](($details | Measure-Object -Property BytesRemoved -Sum -ErrorAction SilentlyContinue).Sum)
    }
    $Global:App.Results[$Category] = $result
    $details | Format-Table Name, Status, Changed, Reason -AutoSize | Out-Host
    foreach ($detail in $details) {
        $level = if ($detail.Status -in @('Failed','Partial')) { 'WARNING' } elseif ($detail.Status -eq 'Success') { 'OK' } else { 'INFO' }
        Write-Log "$Category / $($detail.Name): $($detail.Status) $($detail.Errors -join '; ')" $level
    }
    Pause-App
}
Export-ModuleMember -Function *
