#=========================================================
# AnalysisEngine.psm1
# Motor da Analise Completa
#=========================================================

function Start-CompleteAnalysis {

    Show-Header

    Write-Log "Inicio da Analise Completa." "OK"

    Write-Host ""
    Write-Host "Iniciando Analise Completa..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "A executar Limpeza Inteligente..." -ForegroundColor Yellow
    Write-Host ""

    Start-Cleaning

    Write-Host ""
    Write-Host "A executar Otimizacao Windows..." -ForegroundColor Yellow
    Write-Host ""

    Start-Optimization

    Write-Host ""
    Write-Host "Analise completa concluida." -ForegroundColor Green
    Write-Host ""

    Pause-App

}

Export-ModuleMember -Function *
