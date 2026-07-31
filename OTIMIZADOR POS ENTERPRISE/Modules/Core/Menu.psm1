function Show-Header {

    Clear-Host
    $Width = 70
    Write-Host ("=" * $Width) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "        OTIMIZADOR POS ENTERPRISE" -ForegroundColor Yellow
    Write-Host "               Version 3.0" -ForegroundColor Gray
    Write-Host ""
    Write-Host ("=" * $Width) -ForegroundColor Cyan
}

function Show-SystemInfo {

    $Info = Get-SystemInfo

    Write-Host ""
    Write-Host (" Computer : {0}" -f $Info.ComputerName)
    Write-Host (" Windows  : {0}" -f $Info.Windows)
    Write-Host (" Build    : {0}" -f $Info.Build)
    Write-Host (" CPU      : {0}" -f $Info.CPU)
    Write-Host (" RAM      : {0} GB" -f $Info.RAM)
    Write-Host (" Disk C:  : {0}/{1} GB free" -f $Info.DiskFree, $Info.DiskTotal)
    Write-Host (" Uptime   : {0}" -f $Info.Uptime)
}

function Show-Menu {

    Write-Host ("=" * 70) -ForegroundColor DarkGray

    Write-Host ""
    Write-Host " 1  Complete Analysis" -ForegroundColor Green
    Write-Host " 2  Smart Cleaning" -ForegroundColor Green
    Write-Host " 3  Windows Optimization" -ForegroundColor Green
    Write-Host " 4  Windows Repair" -ForegroundColor Green
    Write-Host " 5  Diagnostic" -ForegroundColor Green
    Write-Host " 6  Report" -ForegroundColor Green
    Write-Host " 7  Inventory" -ForegroundColor Green
    Write-Host ""
    Write-Host " 0  Exit" -ForegroundColor Red
    Write-Host ""

    Write-Host ("=" * 70) -ForegroundColor DarkGray
}
function Write-ExecutionSummary {

    Write-Log ""
    Write-Log "============================================================"
    Write-Log "EXECUTION SUMMARY"
    Write-Log "============================================================"

    $Modules = @(
        "Cleaning",
        "Optimization",
        "Repair",
        "Diagnostic"
    )

    foreach ($Module in $Modules) {

        $Result = $Global:App.Results[$Module]

        if ($null -eq $Result) {
            Write-Log ("{0,-15}: NOT EXECUTED" -f $Module) "WARNING"
            continue
        }

        if ($Result.Errors -gt 0) {
            Write-Log `
            ("{0,-15}: OK ({1} errors)" -f $Module, $Result.Errors) `
                "WARNING"
        }
        else {
            Write-Log `
            ("{0,-15}: OK" -f $Module) `
                "OK"
        }
    }
    Write-Log "============================================================"
}
function Start-MainMenu {

    do {
        Show-Header
        Show-Dashboard
        Show-Menu

        $Option = Read-Host "Choose an option"

        switch ($Option) {

            "1" {
                Start-CompleteAnalysis
            }
            "2" {
                Start-Cleaning
            }
            "3" {
                Start-Optimization
            }
            "4" {
                Start-Repair
            }
            "5" {
                Start-Diagnostic
            }
            "6" {
                Start-Report
            }
            "7" {
                Start-Inventory
            }
            "0" {
                Stop-Log   
                break
            }
            default {
                Write-Host ""
                Write-Host "Invalid option." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    } until ($Option -eq "0")
    Write-ExecutionSummary
    Stop-Log
}
Export-ModuleMember -Function *