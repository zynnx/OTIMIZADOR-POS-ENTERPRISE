#=========================================================
# CleaningSection.psm1
# Smart Cleaning report section
#=========================================================

function Get-CleaningSection {

    if (-not $Global:App.Results.Cleaning) {

        return "<h2>Smart Cleaning</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Cleaning

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

@"

<h2>Smart Cleaning</h2>

<div class="dashboard">

    <div class="card ok">
        <div class="card-title">Items Analyzed</div>
        <div class="card-value">$($R.Items)</div>
    </div>

    <div class="card ok">
        <div class="card-title">Cleanups Successful</div>
        <div class="card-value">$($R.Success)</div>
    </div>

    <div class="card $Status">
        <div class="card-title">Errors</div>
        <div class="card-value">$($R.Errors)</div>
    </div>

    <div class="card ok">
        <div class="card-title">Space Recovered</div>
        <div class="card-value">$(Convert-Bytes $R.SpaceRecovered)</div>
    </div>

</div>

<div class="system-status $Status">

    <div class="card-title">Cleaning Status</div>

    <div class="status-value">$StatusText</div>

</div>

"@

}

Export-ModuleMember -Function *