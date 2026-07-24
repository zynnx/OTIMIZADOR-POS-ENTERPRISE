#=========================================================
# CleaningSection.psm1
#=========================================================

function Get-CleaningSection {

    if(-not $Global:App.Results.Cleaning){

        return "<h2>Limpeza</h2><p>Não executada.</p><br>"

    }

    $R = $Global:App.Results.Cleaning

@"

<h2>Limpeza Inteligente</h2>

<table>

<tr><th>Campo</th><th>Valor</th></tr>

<tr><td>Data</td><td>$($R.Date)</td></tr>

<tr><td>Itens Limpos</td><td>$($R.Items)</td></tr>

<tr><td>Sucesso</td><td>$($R.Success)</td></tr>

<tr><td>Erros</td><td>$($R.Errors)</td></tr>

<tr><td>Espaço Recuperado</td><td>$(Convert-Bytes $R.SpaceRecovered)</td></tr>

</table>

<br>

"@

}

Export-ModuleMember -Function *