#=========================================================
# DiagnosticSection.psm1
#=========================================================

function Get-DiagnosticSection {

    if(-not $Global:App.Results.Diagnostic){

        return "<h2>Diagnóstico</h2><p>Not executed.</p><br>"

    }

    $R = $Global:App.Results.Diagnostic

    $Html = @"

<h2>Diagnostic</h2>

<table>

<tr>

<th>Component</th>

<th>Status</th>

<th>Details</th>

</tr>

"@

    foreach($Item in $R.Results){

        $Html += @"

<tr>

<td>$($Item.Name)</td>

<td>$($Item.Status)</td>

<td>$($Item.Details)</td>

</tr>

"@

    }

    $Html += @"

</table>

<br>

<h3>Final Score: $($R.Score)/100</h3>

"@

    return $Html

}

Export-ModuleMember -Function *