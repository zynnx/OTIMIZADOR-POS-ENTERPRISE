#=========================================================
# AnalysisEngine.psm1
# Complete Analysis Engine
#=========================================================

function Start-CompleteAnalysis {

    $Global:App.AutomaticMode = $true
    
    Show-Header "COMPLETE SYSTEM ANALYSIS"

    Write-Log "Starting complete analysis." "INFO"

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "             COMPLETE SYSTEM ANALYSIS" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    #
    # Restore point (enabled by default, can be disabled in Config\Config.json)
    #

    $CreatePoint = $true

    if ($Global:Config -and $null -ne $Global:Config.CreateRestorePoint) {
        $CreatePoint = [bool]$Global:Config.CreateRestorePoint
    }

    if ($CreatePoint) {

        Write-Host "Creating a restore point before the maintenance..." -ForegroundColor Cyan
        Write-Host ""
        New-RestorePointSafe -Description ("Otimizador POS - {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm"))
        Write-Host ""

    }

    try {

    #
    # 1 - SMART CLEANING
    #

    Write-Host "Executing Smart Cleaning..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Cleaning
    }
    catch {
        Write-Log "Smart Cleaning failed: $($_.Exception.Message)" "ERROR"
    }


    #
    # 2 - WINDOWS OPTIMIZATION
    #

    Write-Host ""
    Write-Host "Executing Windows Optimization..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Optimization
    }
    catch {
        Write-Log "Windows Optimization failed: $($_.Exception.Message)" "ERROR"
    }

    #
    # 3 - WINDOWS REPAIR
    #

    Write-Host ""
    Write-Host "Executing Windows Repair..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Repair
    }
    catch {
        Write-Log "Windows Repair failed: $($_.Exception.Message)" "ERROR"
    }

    #
    # 4 - SYSTEM DIAGNOSTIC
    #

    Write-Host ""
    Write-Host "Executing System Diagnostic..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Diagnostic
    }
    catch {
        Write-Log "System Diagnostic failed: $($_.Exception.Message)" "ERROR"
    }

    #
    # 5 - INVENTORY
    #

    Write-Host ""
    Write-Host "Executing System Inventory..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Inventory
    }
    catch {
        Write-Log "System Inventory failed: $($_.Exception.Message)" "ERROR"
    }

    #
    # 6 - REPORT
    #

    Write-Host ""
    Write-Host "Generating System Report..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Start-Report
    }
    catch {
        Write-Log "System Report failed: $($_.Exception.Message)" "ERROR"
    }

    #
    # FINISHED
    #
    }
    finally {

        $Global:App.AutomaticMode = $false

    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "          COMPLETE ANALYSIS FINISHED" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""

    Write-Log "Complete analysis finished." "OK"
    Pause-App
}

Export-ModuleMember -Function *