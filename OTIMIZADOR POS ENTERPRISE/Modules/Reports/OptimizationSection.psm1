#=========================================================
# OptimizationSection.psm1
#=========================================================

function Get-OptimizationSection {

    if(-not $Global:App.Results.Optimization){

        return "<h2>Otimização</h2><p>Não executada.</p><br>"

    }

    $R = $Global:App.Results.Optimization

@"

<h2>Otimização do Windows</h2>

<table>

<tr><th>Campo</th><th>Valor</th></tr>

<tr><td>Data</td><td>$($R.Date)</td></tr>

<tr><td>Sucessos</td><td>$($R.Success)</td></tr>

<tr><td>Erros</td><td>$($R.Errors)</td></tr>

</table>

<br>

"@

}

Export-ModuleMember -Function *