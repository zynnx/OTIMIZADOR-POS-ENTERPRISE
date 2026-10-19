#=========================================================
# Menu.psm1
#=========================================================

function Show-AppHeader {

    Clear-Host
    $Width = 70
    Write-Host ("=" * $Width) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "        OTIMIZADOR POS ENTERPRISE" -ForegroundColor Yellow
    Write-Host ("               Version {0}" -f $Global:App.Version) -ForegroundColor Gray
    Write-Host ""
    Write-Host ("=" * $Width) -ForegroundColor Cyan
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
    Write-Host " 8  Simulate maintenance (no system changes)" -ForegroundColor Cyan
    Write-Host " 9  Restore settings from backup" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " 0  Exit" -ForegroundColor Red
    Write-Host ""

    Write-Host ("=" * 70) -ForegroundColor DarkGray
}

function Write-ExecutionSummary {
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

        if ($Module -in @('Cleaning','Optimization','Repair')) {
            $state = Get-MaintenanceStatus $Result
            $level = if ($Result.Errors -gt 0) { 'WARNING' } elseif ($state -eq 'COMPLETED') { 'OK' } else { 'INFO' }
            Write-Log ("{0,-15}: {1} (successful: {2}, errors: {3}, skipped: {4}, planned: {5})" -f $Module, $state, $Result.Success, $Result.Errors, $Result.Skipped, $Result.Planned) $level
            continue
        }

        if ($Result.Errors -gt 0) {
            Write-Log `
            ("{0,-15}: FAILED OR PARTIAL ({1} errors)" -f $Module, $Result.Errors) `
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

    try {

        do {

            Show-AppHeader

            try {
                Show-Dashboard
            }
            catch {
                Write-Log "Could not render the dashboard: $($_.Exception.Message)" "WARNING"
            }

            Show-Menu

            $Option = Read-Host "Choose an option"

            # EOF / closed stdin: treat as exit to avoid an infinite loop
            if ($null -eq $Option) {
                $Option = "0"
            }

            switch ($Option) {

                "1" {
                    try {
                        Start-CompleteAnalysis
                    }
                    catch {
                        Write-Log "Complete Analysis failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "2" {
                    try {
                        Start-Cleaning
                    }
                    catch {
                        Write-Log "Smart Cleaning failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "3" {
                    try {
                        Start-Optimization
                    }
                    catch {
                        Write-Log "Windows Optimization failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "4" {
                    try {
                        Start-Repair
                    }
                    catch {
                        Write-Log "Windows Repair failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "5" {
                    try {
                        Start-Diagnostic
                    }
                    catch {
                        Write-Log "Diagnostic failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "6" {
                    try {
                        Start-Report
                    }
                    catch {
                        Write-Log "Report failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "7" {
                    try {
                        Start-Inventory
                    }
                    catch {
                        Write-Log "Inventory failed: $($_.Exception.Message)" "ERROR"
                    }
                }

                "8" {
                    try { Start-CompleteAnalysis -Simulation }
                    catch { Write-Log $_.Exception.Message ERROR }
                }
                "9" {
                    try {
                        $backup = Read-Host 'Path to Settings_*.clixml backup (Enter to cancel)'
                        if (-not [string]::IsNullOrWhiteSpace($backup)) { Restore-MaintenanceSnapshot -Path $backup }
                    } catch { Write-Log $_.Exception.Message ERROR }
                    Pause-App
                }
                "0" {
                    break
                }

                default {
                    Write-Host ""
                    Write-Host "Invalid option." -ForegroundColor Red
                    Start-Sleep 1
                }

            }

        } until ($Option -eq "0")

    }
    catch {

        Write-Log "Unexpected error in the main menu: $($_.Exception.Message)" "ERROR"

    }
    finally {

        try {
            Write-ExecutionSummary
        }
        catch {
            # Never block the log shutdown
        }

        Stop-Log

    }

}
Export-ModuleMember -Function *
