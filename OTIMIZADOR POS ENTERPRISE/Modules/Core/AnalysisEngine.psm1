function Start-CompleteAnalysis {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Simulation)
    $previousMode = $Global:App.AutomaticMode
    $Global:App.AutomaticMode = $true
    try {
        Start-Diagnostic
        $Global:App.Results.BeforeDiagnostic = $Global:App.Results.Diagnostic
        Start-Inventory
        $plan = @(
            foreach ($category in @('Cleaning','Optimization','Repair')) {
                foreach ($item in @(Get-MaintenanceDefinitions $category | Where-Object Enabled)) {
                    [PSCustomObject]@{ Category = $category; Key = $item.Key; Name = $item.Name }
                }
            }
        )
        Write-Host 'Maintenance plan (enabled operations only):' -ForegroundColor Cyan
        for ($i = 0; $i -lt $plan.Count; $i++) { Write-Host ("{0}. {1}: {2}" -f ($i + 1), $plan[$i].Category, $plan[$i].Name) }
        if ($Simulation -or $WhatIfPreference) {
            foreach ($category in @('Cleaning','Optimization','Repair')) { Invoke-MaintenanceCategory $category -WhatIf }
        } elseif ($plan.Count) {
            foreach ($category in @('Cleaning','Optimization','Repair')) {
                $keys = @($plan | Where-Object Category -eq $category | Select-Object -ExpandProperty Key -Unique)
                if ($keys.Count) { Invoke-MaintenanceCategory $category -Only $keys -Confirm:$false }
                if (@($Global:App.Results[$category].Details | Where-Object Status -eq Failed).Count -and -not $Global:App.ProtectionReady) { break }
            }
            Start-Diagnostic
        }
        Start-Report
    } finally { $Global:App.AutomaticMode = $previousMode }
}
Export-ModuleMember -Function Start-CompleteAnalysis
