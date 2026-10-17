#=========================================================
# ReportEngine.psm1
# HTML Report Engine
#=========================================================

function Start-Report {

    Show-Header "SYSTEM REPORT"

    Write-Log "Generating HTML report..." "INFO"

    $Watch = Start-Stopwatch

    #
    # Create HTML content
    #

    $Html = @()

    $Html += Get-HTMLHeader

    $Html += Get-SystemSection

    $Html += Get-SummarySection
    if ($Global:App.Results.BeforeDiagnostic) {
        $before = $Global:App.Results.BeforeDiagnostic
        $after = $Global:App.Results.Diagnostic
        $Html += "<h2>Diagnostic comparison</h2><p>Before: $($before.Score)/100 | Latest: $($after.Score)/100</p>"
    }

    $Html += Get-CleaningSection

    $Html += Get-OptimizationSection

    $Html += Get-RepairSection

    $Html += Get-DiagnosticSection

    $Html += Get-HTMLFooter

    #
    # Save report
    #

    $File = Save-HTMLReport $Html

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Success "Report created."

    Write-Host ("File    : {0}" -f $File)

    Write-Host ("Time    : {0}" -f (Format-Time $Elapsed))

    Write-Host ""

    #
    # Open automatically (can be disabled in Config\Report.json)
    #

    $OpenAutomatically = $true

    $ReportConfig = $null

    if ($Global:App.Config -and $Global:App.Config.Report) {
        $ReportConfig = $Global:App.Config.Report
    }

    if ($ReportConfig -and $null -ne $ReportConfig.OpenAutomatically) {
        $OpenAutomatically = [bool]$ReportConfig.OpenAutomatically
    }

    if ($OpenAutomatically -and (Test-Path $File)) {

        Start-Process $File

    }

    Write-Log "HTML report created." "OK"

    Pause-App

}

Export-ModuleMember -Function *
