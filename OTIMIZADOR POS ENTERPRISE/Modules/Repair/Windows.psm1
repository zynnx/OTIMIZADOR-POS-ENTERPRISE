function Get-WindowsStatus {
    [PSCustomObject]@{ Name = 'Windows System Repair'; Status = 'Available'; RepairFunction = 'Invoke-WindowsRepair' }
}
function Invoke-WindowsRepair {
    $config = Get-Config Config
    $results = @()
    if ($config.RunDISM) {
        # A single image repair sequence; never discover/run the standalone DISM module as well.
        try {
            $process = Start-Process -FilePath "$env:SystemRoot\System32\DISM.exe" -ArgumentList @('/Online','/Cleanup-Image','/RestoreHealth','/NoRestart') -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -notin @(0,3010)) { throw "DISM exited with code $($process.ExitCode)." }
            $results += New-OperationResult DISM Success -Reason $(if ($process.ExitCode -eq 3010) { 'Restart required' } else { 'Completed' })
        } catch { $results += New-OperationResult DISM Failed -Errors @($_.Exception.Message) }
    } else { $results += New-OperationResult DISM Skipped -Reason 'RunDISM is disabled' }
    if ($config.RunSFC) {
        try {
            $process = Start-Process -FilePath "$env:SystemRoot\System32\sfc.exe" -ArgumentList '/scannow' -Wait -PassThru -NoNewWindow
            if ($process.ExitCode -ne 0) { throw "SFC exited with code $($process.ExitCode). Review CBS.log." }
            $results += New-OperationResult SFC Success -Reason 'Command completed; see CBS.log for integrity findings'
        } catch { $results += New-OperationResult SFC Failed -Errors @($_.Exception.Message) }
    } else { $results += New-OperationResult SFC Skipped -Reason 'RunSFC is disabled' }
    $Global:App.Results.RepairDetails = $results
    $results
}
Export-ModuleMember -Function Get-WindowsStatus, Invoke-WindowsRepair
