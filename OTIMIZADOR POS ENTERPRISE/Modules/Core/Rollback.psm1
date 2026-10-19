function Get-OptimizationRegistryTargets {
    @(
        @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', @('LaunchTo','HideFileExt','ShowRecent','ShowFrequent')),
        @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects', @('VisualFXSetting')),
        @('HKCU:\Control Panel\Desktop', @('UserPreferencesMask','MenuShowDelay')),
        @('HKCU:\Control Panel\Desktop\WindowMetrics', @('MinAnimate'))
    ) | ForEach-Object {
        $path = $_[0]
        foreach ($name in $_[1]) { [PSCustomObject]@{ Path = $path; Name = $name } }
    }
}
function Save-MaintenanceSnapshot {
    $folder = Join-Path $Global:AppRoot 'Backups'
    New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    $registry = @(
        foreach ($target in Get-OptimizationRegistryTargets) {
            $key = Get-Item -LiteralPath $target.Path -ErrorAction SilentlyContinue
            $exists = $key -and $target.Name -in $key.GetValueNames()
            [PSCustomObject]@{
                Path = $target.Path; Name = $target.Name; Exists = [bool]$exists
                Kind = if ($exists) { $key.GetValueKind($target.Name).ToString() } else { $null }
                Value = if ($exists) { $key.GetValue($target.Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) } else { $null }
            }
        }
    )
    $services = @(foreach ($name in @('WerSvc','WSearch','SysMain')) {
        $key = Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$name" -ErrorAction SilentlyContinue
        if ($key) { [PSCustomObject]@{ Name = $name; Start = $key.Start; DelayedAutoStart = $key.DelayedAutoStart } }
    })
    $power = (& powercfg.exe /getactivescheme 2>&1) -join ' '
    if ($LASTEXITCODE -ne 0 -or $power -notmatch '[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}') { throw 'Could not capture the active power plan.' }
    $snapshot = [PSCustomObject]@{ Version = 1; Computer = $env:COMPUTERNAME; UserSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value; Date = Get-Date; Registry = $registry; Services = $services; PowerPlan = $Matches[0] }
    $file = Join-Path $folder ("Settings_{0}_{1}.clixml" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [guid]::NewGuid().ToString('N'))
    $snapshot | Export-Clixml -LiteralPath $file -Depth 8 -ErrorAction Stop
    $Global:App.SnapshotFile = $file
    Write-Log "Settings backup saved to $file" INFO
}
function Restore-MaintenanceSnapshot {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$Path)
    $snapshot = Import-Clixml -LiteralPath $Path -ErrorAction Stop
    if ($snapshot.Version -ne 1 -or $snapshot.Computer -ne $env:COMPUTERNAME -or $snapshot.UserSid -ne [Security.Principal.WindowsIdentity]::GetCurrent().User.Value) { throw 'Backup belongs to a different computer/user or has an unsupported version.' }
    $allowed = @(Get-OptimizationRegistryTargets | ForEach-Object { "$($_.Path)|$($_.Name)" })
    foreach ($value in $snapshot.Registry) {
        if ("$($value.Path)|$($value.Name)" -notin $allowed) { throw 'Backup contains an unexpected registry target.' }
    }
    foreach ($service in $snapshot.Services) {
        if ($service.Name -notin @('WerSvc','WSearch','SysMain') -or $service.Start -notin @(2,3,4)) { throw 'Backup contains an unexpected service setting.' }
    }
    if ($snapshot.PowerPlan -notmatch '^[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$') { throw 'Invalid power plan in backup.' }
    if (-not $PSCmdlet.ShouldProcess($Path, 'Restore registry settings, service startup types and power plan')) { return }
    foreach ($value in $snapshot.Registry) {
        if ($value.Exists) {
            if (-not (Test-Path -LiteralPath $value.Path)) { New-Item -Path $value.Path -ErrorAction Stop | Out-Null }
            New-ItemProperty -LiteralPath $value.Path -Name $value.Name -Value $value.Value -PropertyType $value.Kind -Force -ErrorAction Stop | Out-Null
        } elseif (Get-ItemProperty -LiteralPath $value.Path -Name $value.Name -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -LiteralPath $value.Path -Name $value.Name -ErrorAction Stop
        }
    }
    foreach ($service in $snapshot.Services) {
        $startup = switch ($service.Start) { 2 { 'Automatic' }; 3 { 'Manual' }; 4 { 'Disabled' } }
        Set-Service -Name $service.Name -StartupType $startup -ErrorAction Stop
        $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
        if ($null -ne $service.DelayedAutoStart) { Set-ItemProperty -LiteralPath $servicePath -Name DelayedAutoStart -Value $service.DelayedAutoStart -ErrorAction Stop }
        elseif (Get-ItemProperty -LiteralPath $servicePath -Name DelayedAutoStart -ErrorAction SilentlyContinue) { Remove-ItemProperty -LiteralPath $servicePath -Name DelayedAutoStart -ErrorAction Stop }
    }
    & powercfg.exe /setactive $snapshot.PowerPlan | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Could not restore power plan.' }
    $Global:App.ProtectionReady = $false
    Write-Log 'Settings restored. Sign out or restart to apply visual settings.' OK
}
Export-ModuleMember -Function Save-MaintenanceSnapshot, Restore-MaintenanceSnapshot
