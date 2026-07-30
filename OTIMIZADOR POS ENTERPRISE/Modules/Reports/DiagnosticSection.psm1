#=========================================================

# DiagnosticSection.psm1

# Diagnostic HTML Report Section

#=========================================================

function Get-DiagnosticSection {

    if (-not $Global:App.Results.Diagnostic) {

        return @"


<h2>System Diagnostic</h2>

<div class="system-status warn">


<div class="status-value">NOT EXECUTED</div>

<div>System diagnostic has not been executed.</div>

</div>

<br>

"@

    }

    $R = $Global:App.Results.Diagnostic

    $Results = @($R.Details)

    #-----------------------------------------------------
    # Calculate score
    #-----------------------------------------------------

    $Score = 0

    if ($Results.Count -gt 0) {

        $ValidScores = @(
            $Results |
            Where-Object {
                $null -ne $_.Score
            }
        )

        if ($ValidScores.Count -gt 0) {

            $Score = [math]::Round(
                ($ValidScores | Measure-Object -Property Score -Average).Average
            )

        }

    }

    #-----------------------------------------------------
    # Determine overall status
    #-----------------------------------------------------

    if ($Score -ge 95) {
        $OverallStatus = "EXCELLENT"
        $StatusClass = "ok"
    }
    elseif ($Score -ge 80) {
        $OverallStatus = "GOOD"
        $StatusClass = "ok"
    }
    elseif ($Score -ge 60) {
        $OverallStatus = "WARNING"
        $StatusClass = "warn"
    }
    else {
        $OverallStatus = "CRITICAL"
        $StatusClass = "error"
    }

    #-----------------------------------------------------
    # Diagnostic summary
    #-----------------------------------------------------

    $Total = $Results.Count
    $OK = @(
        $Results |
        Where-Object {
            $_.Status -eq "OK"
        }
    ).Count

    $Warnings = @(
        $Results |
        Where-Object {
            $_.Status -eq "WARNING"
        }
    ).Count

    $Critical = @(
        $Results |
        Where-Object {
            $_.Status -eq "CRITICAL"
        }
    ).Count

    $Errors = @(
        $Results |
        Where-Object {
            $_.Status -eq "ERROR"
        }
    ).Count

    #-----------------------------------------------------
    # Header
    #-----------------------------------------------------

    $Html = @"


<h2>System Diagnostic</h2>

<div class="system-status $StatusClass">


<div>
    <strong>Overall System Status</strong>
</div>

<div class="status-value">
    $OverallStatus
</div>

<div>
    Diagnostic Score: <strong>$Score / 100</strong>
</div>

</div>

<table>

<tr>
    <th>Total Checks</th>
    <th>OK</th>
    <th>Warnings</th>
    <th>Critical</th>
    <th>Errors</th>
</tr>

<tr>
    <td>$Total</td>
    <td class="ok">$OK</td>
    <td class="warn">$Warnings</td>
    <td class="error">$Critical</td>
    <td class="error">$Errors</td>
</tr>

</table>

<br>

<h3>Diagnostic Details</h3>

<table>

<tr>
    <th>Component</th>
    <th>Status</th>
    <th>Score</th>
    <th>Details</th>
    <th>Recommendation</th>
</tr>

"@

    #-----------------------------------------------------
    # Diagnostic rows
    #-----------------------------------------------------

    foreach ($Item in $Results) {

        $StatusClass = ""
        switch ($Item.Status) {
            "OK" {
                $StatusClass = "ok"
            }
            "WARNING" {
                $StatusClass = "warn"
            }
            "CRITICAL" {
                $StatusClass = "error"
            }
            "ERROR" {
                $StatusClass = "error"
            }
            default {
                $StatusClass = ""
            }
        }
        $Html += @"

<tr>

<td><strong>$($Item.Name)</strong></td>

<td class="$StatusClass">
    $($Item.Status)
</td>

<td>
    $($Item.Score) / 100
</td>

<td>
    $($Item.Details)
</td>

<td>
    $($Item.Recommendation)
</td>

</tr>

"@

    }

    $Html += @"

</table>

<br>

"@

    #-----------------------------------------------------
    # Recommendations
    #-----------------------------------------------------

    $Recommendations = @(
        $Results |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_.Recommendation)
        }
    )

    if ($Recommendations.Count -gt 0) {

        $Html += @"

<h3>Recommendations</h3>

<div class="system-status warn">

"@

        foreach ($Item in $Recommendations) {

            $Html += @"

<div style="margin:8px 0;">
    <strong>$($Item.Name):</strong>
    $($Item.Recommendation)
</div>

"@

        }

        $Html += @"

</div>

"@

    }
    return $Html
}
Export-ModuleMember -Function *
