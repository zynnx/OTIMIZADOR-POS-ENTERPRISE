#=========================================================
# CleaningSection.psm1
#=========================================================

function Get-CleaningSection {

    if(-not $Global:App.Results.Cleaning){

        return "<h2>Cleaning</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Cleaning

@"

<h2>Smart Cleaning</h2>

<table>

<tr><th>Campo</th><th>Valor</th></tr>

<tr><td>Date</td><td>$($R.Date)</td></tr>

<tr><td>Items Cleaned</td><td>$($R.Items)</td></tr>

<tr><td>Success</td><td>$($R.Success)</td></tr>

<tr><td>Errors</td><td>$($R.Errors)</td></tr>

<tr><td>Space Recovered</td><td>$(Convert-Bytes $R.SpaceRecovered)</td></tr>

</table>

<br>

"@

}

Export-ModuleMember -Function *
