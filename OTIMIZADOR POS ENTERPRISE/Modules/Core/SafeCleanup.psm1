function Remove-CleanupContent {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path, [string[]]$Patterns = @('*'))
    $resolved = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $allowed = @($env:TEMP, (Join-Path $env:windir 'Temp'),
        (Join-Path $env:windir 'SoftwareDistribution\Download'),
        (Join-Path $env:windir 'SoftwareDistribution\DataStore'),
        (Join-Path $env:windir 'System32\catroot2'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\DeliveryOptimization\Cache'))
    $allowed = @($allowed | ForEach-Object { [IO.Path]::GetFullPath($_).TrimEnd('\') })
    if ($resolved -notin $allowed -or $resolved -eq [IO.Path]::GetPathRoot($resolved).TrimEnd('\')) { throw "Cleanup path is not allowed: $resolved" }
    if (-not (Test-Path -LiteralPath $resolved)) { return New-OperationResult $resolved Skipped -Reason 'Folder does not exist' }
    if ((Get-Item -LiteralPath $resolved -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Cleanup root cannot be a reparse point.' }
    $changed = 0
    [long]$bytes = 0
    $failures = @()
    foreach ($entry in @(Get-ChildItem -LiteralPath $resolved -Force -ErrorAction Stop)) {
        if (-not @($Patterns | Where-Object { $entry.Name -like $_ }).Count) { continue }
        $target = [IO.Path]::GetFullPath($entry.FullName)
        if (-not $target.StartsWith($resolved + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Cleanup target escaped the approved folder.' }
        # Never delete the running standalone payload or a directory containing it.
        $appPath = [IO.Path]::GetFullPath($Global:AppRoot).TrimEnd('\')
        if ($appPath -eq $target -or $appPath.StartsWith($target + '\', [StringComparison]::OrdinalIgnoreCase) -or $target.StartsWith($appPath + '\', [StringComparison]::OrdinalIgnoreCase)) { continue }
        try {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse point skipped: $target" }
            $files = @()
            if ($entry.PSIsContainer) {
                # Walk explicitly so junctions are rejected before traversing them.
                $pending = New-Object 'System.Collections.Generic.Stack[string]'
                $pending.Push($target)
                while ($pending.Count) {
                    foreach ($child in @(Get-ChildItem -LiteralPath $pending.Pop() -Force -ErrorAction Stop)) {
                        if ($child.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Folder containing reparse points skipped: $target" }
                        if ($child.PSIsContainer) { $pending.Push($child.FullName) } else { $files += $child }
                    }
                }
            } else { $files = @($entry) }
            $size = ($files | Measure-Object Length -Sum).Sum
            Remove-Item -LiteralPath $target -Force -Recurse -ErrorAction Stop
            $changed++
            $bytes += [long]$size
        } catch { $failures += $_.Exception.Message }
    }
    $status = if ($failures.Count -and $changed) { 'Partial' } elseif ($failures.Count) { 'Failed' } else { 'Success' }
    $result = New-OperationResult $resolved $status -Changed $changed -Errors $failures
    $result | Add-Member NoteProperty BytesRemoved $bytes
    return $result
}
function Invoke-WithStoppedServices {
    param([string[]]$Names, [scriptblock]$Action)
    $running = @()
    $failures = @()
    try {
        foreach ($name in $Names) {
            $service = Get-Service -Name $name -ErrorAction Stop
            if ($service.Status -eq 'Running') {
                $running += $name
                Stop-Service -Name $name -ErrorAction Stop
                $service.WaitForStatus('Stopped', [TimeSpan]::FromSeconds(15))
            } elseif ($service.Status -ne 'Stopped') { throw "Service $name is in transition; try later." }
        }
        & $Action
    } catch { $failures += $_.Exception.Message }
    finally {
        foreach ($name in $running) {
            try { Start-Service -Name $name -ErrorAction Stop }
            catch { $failures += "Could not restore service ${name}: $($_.Exception.Message)" }
        }
    }
    if ($failures.Count) { New-OperationResult 'Service maintenance' Failed -Errors $failures }
}
Export-ModuleMember -Function Remove-CleanupContent, Invoke-WithStoppedServices
