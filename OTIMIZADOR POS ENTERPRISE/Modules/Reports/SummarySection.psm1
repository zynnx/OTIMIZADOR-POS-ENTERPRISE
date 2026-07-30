#=========================================================

# SummarySection.psm1

# Enterprise System Summary

#=========================================================

function Get-SummarySection {
    
    $Diagnostic = $Global:App.Results.Diagnostic
    $Cleaning = $Global:App.Results.Cleaning
    $Optimization = $Global:App.Results.Optimization
    $Repair = $Global:App.Results.Repair

    #-----------------------------------------------------
    # Diagnostic score
    #-----------------------------------------------------

    $DiagnosticScore = 0

    if ($Diagnostic -and $Diagnostic.Details) {

        $Results = @($Diagnostic.Details)

        if ($Results.Count -gt 0) {

            $Scores = @(
                $Results |
                Where-Object {
                    $null -ne $_.Score
                }
            )

            if ($Scores.Count -gt 0) {
                $DiagnosticScore = [math]::Round(
                    ($Scores | Measure-Object -Property Score -Average).Average
                )
            }
        }
    }

    #-----------------------------------------------------
    # Overall status
    #-----------------------------------------------------

    if (-not $Diagnostic) {
        $OverallStatus = "NOT EXECUTED"
        $StatusClass = "warn"
    }
    elseif ($DiagnosticScore -ge 95) {
        $OverallStatus = "EXCELLENT"
        $StatusClass = "ok"
    }
    elseif ($DiagnosticScore -ge 80) {
        $OverallStatus = "GOOD"
        $StatusClass = "ok"
    }
    elseif ($DiagnosticScore -ge 60) {
        $OverallStatus = "WARNING"
        $StatusClass = "warn"
    }
    else {
        $OverallStatus = "CRITICAL"
        $StatusClass = "error"
    }

    #-----------------------------------------------------
    # Cleaning
    #-----------------------------------------------------

    if ($Cleaning) {
        $CleaningStatus = "EXECUTED"
    }
    else {
        $CleaningStatus = "NOT EXECUTED"
    }

    #-----------------------------------------------------
    # Optimization
    #-----------------------------------------------------

    if ($Optimization) {
        $OptimizationStatus = "EXECUTED"
    }
    else {
        $OptimizationStatus = "NOT EXECUTED"
    }

    #-----------------------------------------------------
    # Repair
    #-----------------------------------------------------

    if ($Repair) {
        $RepairStatus = "EXECUTED"
    }
    else {
        $RepairStatus = "NOT EXECUTED"
    }

    #-----------------------------------------------------

# HTML

#-----------------------------------------------------

$CleaningClass = if ($Cleaning) { "ok" } else { "info" }

$OptimizationClass = if ($Optimization) { "ok" } else { "info" }

$RepairClass = if ($Repair) { "ok" } else { "info" }

return @"

<h2>System Overview</h2>

<div class="system-status $StatusClass">

<div>
    <strong>Overall System Status</strong>
</div>

<div class="status-value">
    $OverallStatus
</div>

<div>
    Diagnostic Score:
    <strong>$DiagnosticScore / 100</strong>
</div>

</div>

<div class="dashboard-grid">

<div class="dashboard-card $StatusClass">

    <div class="dashboard-card-title">
        System Diagnostic
    </div>

    <div class="dashboard-card-value">
        $DiagnosticScore / 100
    </div>

    <div>
        $OverallStatus
    </div>

</div>


<div class="dashboard-card $CleaningClass">

    <div class="dashboard-card-title">
        Smart Cleaning
    </div>

    <div class="dashboard-card-value">
        $CleaningStatus
    </div>

</div>


<div class="dashboard-card $OptimizationClass">

    <div class="dashboard-card-title">
        Windows Optimization
    </div>

    <div class="dashboard-card-value">
        $OptimizationStatus
    </div>

</div>


<div class="dashboard-card $RepairClass">

    <div class="dashboard-card-title">
        Windows Repair
    </div>

    <div class="dashboard-card-value">
        $RepairStatus
    </div>

</div>

</div>

<table>

<tr>
    <th>Module</th>
    <th>Status</th>
</tr>

<tr>
    <td>System Diagnostic</td>
    <td class="$StatusClass">
        $OverallStatus
    </td>
</tr>

<tr>
    <td>Smart Cleaning</td>
    <td>$CleaningStatus</td>
</tr>

<tr>
    <td>Windows Optimization</td>
    <td>$OptimizationStatus</td>
</tr>

<tr>
    <td>Windows Repair</td>
    <td>$RepairStatus</td>
</tr>

</table>

<br>

"@
}

Export-ModuleMember -Function *
