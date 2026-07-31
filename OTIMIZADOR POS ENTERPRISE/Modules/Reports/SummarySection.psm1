#=========================================================

# SummarySection.psm1

# Enterprise System Summary

#=========================================================

function Get-SummarySection {
    
    $Diagnostic = $Global:App.Results.Diagnostic
    $Cleaning = $Global:App.Results.Cleaning
    $Optimization = $Global:App.Results.Optimization
    $Repair = $Global:App.Results.Repair
    $SystemInfo = Get-SystemInfo

    #-----------------------------------------------------
    # Diagnostic score
    #-----------------------------------------------------

    $DiagnosticScore = 0
    $DiagnosticTotal = 0
    $DiagnosticOK = 0
    $DiagnosticWarnings = 0
    $DiagnosticCritical = 0
    $DiagnosticErrors = 0

    if ($Diagnostic -and $Diagnostic.Details) {
        $DiagnosticResults = @($Diagnostic.Details)
        $DiagnosticTotal = $DiagnosticResults.Count
        $DiagnosticOK = @(
            $DiagnosticResults |
            Where-Object { $_.Status -eq "OK" }
        ).Count

        $DiagnosticWarnings = @(
            $DiagnosticResults |
            Where-Object { $_.Status -eq "WARNING" }
        ).Count

        $DiagnosticCritical = @(
            $DiagnosticResults |
            Where-Object { $_.Status -eq "CRITICAL" }
        ).Count

        $DiagnosticErrors = @(
            $DiagnosticResults |
            Where-Object { $_.Status -eq "ERROR" }
        ).Count
    }

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

    $CleaningFiles = 0
    $CleaningRecovered = 0

    if ($Cleaning) {
        if ($null -ne $Cleaning.Items) {
            $CleaningFiles = $Cleaning.Items
        }

        if ($null -ne $Cleaning.SpaceRecovered) {
            $CleaningRecovered = $Cleaning.SpaceRecovered
        }
    }

    $OptimizationClass = if ($Optimization) { "ok" } else { "info" }
    $OptimizationSuccess = 0
    $OptimizationErrors = 0

    if ($Optimization) {
        if ($null -ne $Optimization.Success) {
            $OptimizationSuccess = $Optimization.Success
        }

        if ($null -ne $Optimization.Errors) {
            $OptimizationErrors = $Optimization.Errors
        }
    }

    $RepairClass = if ($Repair) { "ok" } else { "info" }
    $RepairSuccess = 0
    $RepairErrors = 0
    $RepairElapsed = $null

    if ($Repair) {
        if ($null -ne $Repair.Success) {
            $RepairSuccess = $Repair.Success
        }

        if ($null -ne $Repair.Errors) {
            $RepairErrors = $Repair.Errors
        }
        if ($null -ne $Repair.Elapsed) {
            $RepairElapsed = Format-Time $Repair.Elapsed
        }

        else {
            $RepairElapsed = "N/A"
        }
    }

    $ScoreBarClass = "score-warning"

    if ($DiagnosticScore -ge 95) {
        $ScoreBarClass = "score-ok"
    }
    elseif ($DiagnosticScore -ge 80) {
        $ScoreBarClass = "score-good"
    }
    elseif ($DiagnosticScore -ge 60) {
        $ScoreBarClass = "score-warning"
    }
    else {
        $ScoreBarClass = "score-critical"
    }
    return @"

<h2>System Overview</h2>

<div class="dashboard-system-info">

    <div>
        <strong>Computer</strong>
        <span>$($SystemInfo.ComputerName)</span>
    </div>

    <div>
        <strong>Windows</strong>
        <span>$($SystemInfo.Windows)</span>
    </div>

    <div>
        <strong>Build</strong>
        <span>$($SystemInfo.Build)</span>
    </div>

    <div>
        <strong>CPU</strong>
        <span>$($SystemInfo.CPU)</span>
    </div>

    <div>
        <strong>RAM</strong>
        <span>$($SystemInfo.RAM) GB</span>
    </div>

    <div>
        <strong>Free Disk</strong>
        <span>$($SystemInfo.DiskFree) GB</span>
    </div>

    <div>
        <strong>Uptime</strong>
        <span>$($SystemInfo.Uptime)</span>
    </div>

</div>

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
            Status:
            <strong>$OverallStatus</strong>
        </div>
        <div class="score-bar">
            <div class="score-bar-fill $ScoreBarClass"
                style="width:${DiagnosticScore}%;">
            </div>
        </div>

        <div class="score-label">
            System Health Score: $DiagnosticScore / 100
        </div>

        <div style="margin-top:10px;">
            Checks:
            <strong>$DiagnosticTotal</strong>
        </div>

        <div>
            <span class="ok">
                OK: $DiagnosticOK
            </span>

            &nbsp; | &nbsp;

            <span class="warn">
                Warnings: $DiagnosticWarnings
            </span>

            &nbsp; | &nbsp;

            <span class="error">
                Critical: $DiagnosticCritical
            </span>

            &nbsp; | &nbsp;

            <span class="error">
                Errors: $DiagnosticErrors
            </span>
    </div>
</div>

<div class="dashboard-card $CleaningClass">
    <div class="dashboard-card-title">
        Smart Cleaning
    </div>

    <div class="dashboard-card-value">
        $CleaningStatus
    </div>

    <div>
        Items: <strong>$CleaningFiles</strong>
    </div>

    <div>
        Recovered:
    <strong>$(Convert-Bytes $CleaningRecovered)</strong>
    </div>
</div>



<div class="dashboard-card $OptimizationClass">
    <div class="dashboard-card-title">
        Windows Optimization
    </div>
    <div class="dashboard-card-value">
        $OptimizationStatus
    </div>
    <div>
        Successful:
        <strong>$OptimizationSuccess</strong>
    </div>
    <div>
        Errors:
        <strong>$OptimizationErrors</strong>
    </div>
</div>

<div class="dashboard-card $RepairClass">
    <div class="dashboard-card-title">
        Windows Repair
    </div>

    <div class="dashboard-card-value">
        $RepairStatus
    </div>

    <div>
        Successful:
        <strong>$RepairSuccess</strong>
    </div>

    <div>
        Errors:
        <strong>$RepairErrors</strong>
    </div>
    <div>
        Time:
        <strong>$RepairElapsed</strong>
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
