#=========================================================
# OptimizationSection.psm1
# Windows Optimization report section
#=========================================================

function Get-OptimizationSection {

    if (-not $Global:App.Results.Optimization) {

        return "<h2>Windows Optimization</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Optimization

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

<h2>Windows Optimization</h2>

<div class="dashboard">

    <div class="card ok">

        <div class="card-title">
            Successful Actions
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
            $(Format-Time $R.Elapsed)
        </div>

    </div>

</div>


<div class="system-status $Status">

    <div class="card-title">
        Optimization Status
    </div>

    <div class="status-value">
        $StatusText
    </div>

</div>

"@

}

Export-ModuleMember -Function *