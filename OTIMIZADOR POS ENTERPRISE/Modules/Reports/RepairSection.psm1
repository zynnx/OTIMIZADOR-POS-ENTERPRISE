#=========================================================
# RepairSection.psm1
# Windows Repair report section
#=========================================================

function Get-RepairSection {

    if (-not $Global:App.Results.Repair) {

        return "<h2>Windows Repair</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Repair

    $Status = "ok"
    $StatusText = "COMPLETED"

    if ($R.Errors -gt 0) {

        $Status = "warn"
        $StatusText = "WARNING"

    }

    if ($R.Success -eq 0 -and $R.Errors -gt 0) {

        $Status = "error"
        $StatusText = "ERROR"

    }

    $Html = @"

<h2>Windows Repair</h2>

<div class="dashboard">

    <div class="card ok">

        <div class="card-title">
            Repairs Successful
        </div>

        <div class="card-value">
            $($R.Success)
        </div>

    </div>

    <div class="card $Status">

        <div class="card-title">
            Errors
        </div>

        <div class="card-value">
            $($R.Errors)
        </div>

    </div>

    <div class="card ok">

        <div class="card-title">
            Execution Time
        </div>

        <div class="card-value">
            N/A
    </div>

</div>

</div>

</div>

<div class="system-status $Status">

    <div class="card-title">
        Repair Status
    </div>

    <div class="status-value">
        $StatusText
    </div>

</div>

<h3>Repair Details</h3>

<table>

<tr>
    <th>Repair</th>
    <th>Status</th>
</tr>

"@

    foreach ($Item in $R.Details) {

        $RowClass = "ok"

        if ($Item.Status -eq "ERROR") {

            $RowClass = "error"

        }

        $Html += @"

<tr>

    <td>$($Item.Name)</td>

    <td class="$RowClass">
        $($Item.Status)
    </td>

</tr>

"@

    }

    $Html += @"

</table>

<br>

"@

    return $Html

}

Export-ModuleMember -Function *