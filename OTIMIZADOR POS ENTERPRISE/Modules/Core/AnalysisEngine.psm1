#=========================================================
# AnalysisEngine.psm1
# Complete Analysis Engine
#=========================================================

function Start-CompleteAnalysis {

    Show-Header

    Write-Log "Starting complete analysis." "OK"

    Write-Host ""
    Write-Host "Starting complete analysis..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Executing Smart Cleaning..." -ForegroundColor Yellow
    Write-Host ""

    Start-Cleaning

    Write-Host ""
    Write-Host "Executing Windows Optimization..." -ForegroundColor Yellow
    Write-Host ""

    Start-Optimization

    Write-Host ""
    Write-Host "Complete analysis finished." -ForegroundColor Green
    Write-Host ""

    Pause-App

}

Export-ModuleMember -Function *

