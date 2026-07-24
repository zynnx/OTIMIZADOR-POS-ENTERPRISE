#=========================================================
# ReportEngine.psm1
# Motor do Relatório HTML
#=========================================================

function Start-Report {

    Show-Header "RELATÓRIO DO SISTEMA"

    Write-Log "A gerar relatório HTML..." "INFO"

    $Watch = Start-Stopwatch

    #
    # Criar conteúdo HTML
    #

    $Html = @()

    $Html += Get-HTMLHeader

    $Html += Get-SystemSection

    $Html += Get-CleaningSection

    $Html += Get-OptimizationSection

    $Html += Get-RepairSection

    $Html += Get-DiagnosticSection

    $Html += Get-HTMLFooter

    #
    # Guardar
    #

    $File = Save-HTMLReport $Html

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Success "Relatório criado."

    Write-Host ("Ficheiro : {0}" -f $File)

    Write-Host ("Tempo    : {0}" -f (Format-Time $Elapsed))

    Write-Host ""

    #
    # Abrir automaticamente
    #

    if(Test-Path $File){

        Start-Process $File

    }

    Write-Log "Relatório HTML criado." "OK"

    Pause-App

}

Export-ModuleMember -Function *