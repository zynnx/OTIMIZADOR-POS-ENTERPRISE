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
        $selected = @()
        if ($Simulation -or $WhatIfPreference) {
            foreach ($category in @('Cleaning','Optimization','Repair')) { Invoke-MaintenanceCategory $category -WhatIf }
        } elseif ($plan.Count) {
            $answer = Read-Host 'Select operation numbers separated by commas, ALL, or Enter for diagnostic only'
            if ($answer -eq 'ALL') { $selected = $plan }
            elseif (-not [string]::IsNullOrWhiteSpace($answer)) {
                foreach ($token in $answer.Split(',')) {
                    $number = 0
                    if (-not [int]::TryParse($token.Trim(), [ref]$number) -or $number -lt 1 -or $number -gt $plan.Count) { throw "Invalid selection: $token" }
                    $selected += $plan[$number - 1]
                }
            }
            foreach ($category in @('Cleaning','Optimization','Repair')) {
                $keys = @($selected | Where-Object Category -eq $category | Select-Object -ExpandProperty Key -Unique)
                if ($keys.Count) { Invoke-MaintenanceCategory $category -Only $keys }
                if (@($Global:App.Results[$category].Details | Where-Object Status -eq Failed).Count -and -not $Global:App.ProtectionReady) { break }
            }
            if ($selected.Count) { Start-Diagnostic }
        }
        Start-Report
    } finally { $Global:App.AutomaticMode = $previousMode }
    Pause-App
}
Export-ModuleMember -Function Start-CompleteAnalysis
