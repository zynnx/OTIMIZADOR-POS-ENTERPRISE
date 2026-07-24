#=========================================================
# RepairSection.psm1
#=========================================================

function Get-RepairSection {

    if(-not $Global:App.Results.Repair){

        return "<h2>Repair</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Repair

@"

<h2>Windows Repair</h2>

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
