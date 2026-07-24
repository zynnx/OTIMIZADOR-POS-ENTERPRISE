#=========================================================
# Dashboard.psm1
#=========================================================

function Show-Dashboard {

    $Info = Get-SystemInfo

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                 OTIMIZADOR POS ENTERPRISE" -ForegroundColor White
    Write-Host ("                        Version {0}" -f $Global:App.Version) -ForegroundColor Gray
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Computer : {0}" -f $Info.ComputerName)
    Write-Host ("Windows  : {0}" -f $Info.Windows)
    Write-Host ("Build    : {0}" -f $Info.Build)
    Write-Host ("CPU      : {0}" -f $Info.CPU)
    Write-Host ("RAM      : {0} GB" -f $Info.RAM)
    Write-Host ("Disk C:  : {0} / {1} GB free" -f $Info.DiskFree, $Info.DiskTotal)
    Write-Host ("Uptime   : {0}" -f $Info.Uptime)

    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan

    $Percent = [math]::Round(($Info.DiskFree / $Info.DiskTotal) * 100)

    if ($Percent -gt 20) {
        $DiskState = "Healthy"
        $Color = "Green"
    }
    else {
        $DiskState = "Low space"
        $Color = "Yellow"
    }

    Write-Host "System Status"
    Write-Host ""

    Write-Host ("Disk.............. {0}" -f $DiskState) -ForegroundColor $Color
    Write-Host ("Free Space....... {0} %" -f $Percent)
    Write-Host ("Windows Defender... Check")
    Write-Host ("Firewall........... Check")

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

}

Export-ModuleMember -Function Show-Dashboard
