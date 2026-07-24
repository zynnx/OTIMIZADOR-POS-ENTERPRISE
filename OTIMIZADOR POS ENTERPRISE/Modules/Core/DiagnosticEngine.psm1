#=========================================================
# DiagnosticEngine.psm1
# Diagnostic Engine
#=========================================================

function Get-DiagnosticItems {
    return Get-ModuleItems -SubFolder "Diagnostics" -FunctionPattern "Get-*Diagnostic"
}

#---------------------------------------------------------

function Start-Diagnostic {

    Show-Header "SYSTEM DIAGNOSTIC"

    Write-Log "Starting diagnostic." "INFO"

    $Watch = Start-Stopwatch

    $Items = Get-DiagnosticItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "No diagnostic module found."

        Pause-App

        return

    }

    $Results = @()

    $Current = 0

    foreach ($Item in $Items) {

        $Current++

        Show-ProgressSimple `
            -Activity "Diagnostics" `
            -Current $Current `
            -Total $Items.Count

        try {

            if (-not $Item.DiagnosticFunction) {
                throw "Item '$($Item.Name)' não tem DiagnosticFunction definida."
            }

            $Function = Get-Command $Item.DiagnosticFunction -CommandType Function -ErrorAction Stop

            $Results += & $Function

        }
        catch {

            $Results += [PSCustomObject]@{

                Name           = $Item.Name
                Status         = "ERROR"
                Score          = 0
                Details        = $_.Exception.Message
                Recommendation = ""

            }

        }
    }

    

    Write-Progress -Activity "Diagnostics" -Completed

    #
    # Calculate score
    #

    $Score = 0

    foreach ($Result in $Results) {

        $Score += $Result.Score

    }

    $FinalScore = [math]::Round($Score / $Results.Count)

    #
    # Mostrar resultados
    #

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "RESULTS"
    Write-Host "============================================================"
    Write-Host ""

    foreach ($Result in $Results) {

        Write-Host ("{0,-25} {1}" -f $Result.Name, $Result.Status)

        if ($Result.Details) {

            Write-Host ("   {0}" -f $Result.Details) -ForegroundColor DarkGray

        }

    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Host ("Score : {0}/100" -f $FinalScore)

    switch ($FinalScore) {

        { $_ -ge 95 } {

            $State = "EXCELLENT"

        }

        { $_ -ge 80 } {

            $State = "GOOD"

        }

        { $_ -ge 60 } {

            $State = "WARNING"

        }

        default {

            $State = "CRITICAL"

        }

    }

    Write-Host ("Status     : {0}" -f $State)

    #
    # Recommendations
    #

    $Recommendations = $Results |
    Where-Object {
        $_.Recommendation -ne ""
    }

    if ($Recommendations.Count -gt 0) {

        Write-Host ""
        Write-Host "Recommendations:" -ForegroundColor Yellow
        Write-Host ""

        foreach ($Item in $Recommendations) {

            Write-Host ("- {0}" -f $Item.Recommendation)

        }

    }

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host ("Time : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Diagnostic completed." "OK"

    $Global:App.Results.Diagnostic = [PSCustomObject]@{
        Date    = Get-Date
        Score   = $FinalScore
        Results = $Results
    }

    Pause-App
}

Export-ModuleMember -Function *
