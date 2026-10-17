function Get-MaintenanceStatus {
    param($Result)
    if (-not $Result) { return 'NOT EXECUTED' }
    if ($Result.Errors -gt 0) {
        if ($Result.Success -gt 0) { return 'PARTIAL' }
        return 'FAILED'
    }
    if ($Result.Planned -gt 0) { return 'SIMULATION' }
    if ($Result.Success -eq 0) { return 'SKIPPED' }
    return 'COMPLETED'
}
function Get-MaintenanceReportSection {
    param([string]$Category)
    $result = $Global:App.Results[$Category]
    $state = Get-MaintenanceStatus $result
    $html = "<h2>$Category</h2><p>Status: $state</p>"
    if (-not $result) { return $html }
    $html += "<p>Successful: $($result.Success) | Failed/partial: $($result.Errors) | Skipped: $($result.Skipped) | Planned: $($result.Planned)</p>"
    if ($Category -eq 'Cleaning') { $html += "<p>Confirmed removed size: $(Convert-Bytes $result.SpaceRecovered)</p>" }
    $html += '<table><tr><th>Operation</th><th>Status</th><th>Changed items</th><th>Details</th></tr>'
    foreach ($item in $result.Details) {
        $name = [Net.WebUtility]::HtmlEncode([string]$item.Name)
        $details = [Net.WebUtility]::HtmlEncode((@($item.Reason) + @($item.Errors)) -join '; ')
        $class = switch ($item.Status) { 'Success' { 'ok' }; 'Failed' { 'error' }; default { 'warn' } }
        $html += "<tr><td>$name</td><td class='$class'>$($item.Status)</td><td>$($item.Changed)</td><td>$details</td></tr>"
    }
    return $html + '</table><br>'
}
Export-ModuleMember -Function Get-MaintenanceStatus, Get-MaintenanceReportSection
