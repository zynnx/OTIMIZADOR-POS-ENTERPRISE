#=========================================================
# Dashboard.psm1
#=========================================================

function Show-Dashboard {

    $Info = Get-SystemInfo

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                 OTIMIZADOR POS ENTERPRISE" -ForegroundColor White
    Write-Host ("                        Versão {0}" -f $Global:App.Version) -ForegroundColor Gray
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Computador : {0}" -f $Info.ComputerName)
    Write-Host ("Windows    : {0}" -f $Info.Windows)
    Write-Host ("Build      : {0}" -f $Info.Build)
    Write-Host ("CPU        : {0}" -f $Info.CPU)
    Write-Host ("RAM        : {0} GB" -f $Info.RAM)
    Write-Host ("Disco C:   : {0} / {1} GB livres" -f $Info.DiskFree, $Info.DiskTotal)
    Write-Host ("Uptime     : {0}" -f $Info.Uptime)

    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan

    $Percent = [math]::Round(($Info.DiskFree / $Info.DiskTotal) * 100)

    if ($Percent -gt 20) {
        $DiskState = "Saudável"
        $Color = "Green"
    }
    else {
        $DiskState = "Pouco espaço"
        $Color = "Yellow"
    }

    Write-Host "Estado do Sistema"
    Write-Host ""

    Write-Host ("Disco.............. {0}" -f $DiskState) -ForegroundColor $Color
    Write-Host ("Espaço Livre....... {0} %" -f $Percent)
    Write-Host ("Windows Defender... Verificar")
    Write-Host ("Firewall........... Verificar")

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

}

Export-ModuleMember -Function Show-Dashboard