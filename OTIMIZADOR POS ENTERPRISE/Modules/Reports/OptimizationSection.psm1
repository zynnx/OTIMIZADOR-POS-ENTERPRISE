#=========================================================
# OptimizationSection.psm1
#=========================================================

function Get-OptimizationSection {

    if(-not $Global:App.Results.Optimization){

        return "<h2>Optimization</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Optimization

@"

<h2>Windows Optimization</h2>

<table>

<tr><th>Campo</th><th>Valor</th></tr>

<tr><td>Date</td><td>$($R.Date)</td></tr>

<tr><td>Sucessos</td><td>$($R.Success)</td></tr>

<tr><td>Errors</td><td>$($R.Errors)</td></tr>

</table>

<br>

"@

}

Export-ModuleMember -Function *
