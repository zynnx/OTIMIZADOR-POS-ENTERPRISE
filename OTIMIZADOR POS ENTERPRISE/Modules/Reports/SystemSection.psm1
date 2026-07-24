#=========================================================
# SystemSection.psm1
#=========================================================

function Get-SystemSection {

    $Info = Get-SystemInfo

@"

<h2>Sistema</h2>

<table>

<tr><th>Campo</th><th>Valor</th></tr>

<tr><td>Computer</td><td>$($Info.ComputerName)</td></tr>

<tr><td>Windows</td><td>$($Info.Windows)</td></tr>

<tr><td>Build</td><td>$($Info.Build)</td></tr>

<tr><td>CPU</td><td>$($Info.CPU)</td></tr>

<tr><td>RAM</td><td>$($Info.RAM) GB</td></tr>

<tr><td>Free Disk</td><td>$($Info.DiskFree) GB</td></tr>

<tr><td>Uptime</td><td>$($Info.Uptime)</td></tr>

</table>

<br>

"@

}

Export-ModuleMember -Function *
