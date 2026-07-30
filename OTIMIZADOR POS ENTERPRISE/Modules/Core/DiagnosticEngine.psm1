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

        $ModuleWatch = Start-Stopwatch

        try {

            if (-not $Item.DiagnosticFunction) {
                throw "Item '$($Item.Name)' does not have DiagnosticFunction defined."
            }

            $Function = Get-Command `
                $Item.DiagnosticFunction `
                -CommandType Function `
                -ErrorAction Stop

            $DiagnosticResult = & $Function

            $ModuleElapsed = Stop-Stopwatch $ModuleWatch

            $Results += [PSCustomObject]@{

                Name           = $DiagnosticResult.Name
                Status         = $DiagnosticResult.Status
                Score          = $DiagnosticResult.Score
                Details        = $DiagnosticResult.Details
                Recommendation = $DiagnosticResult.Recommendation
                Elapsed        = $ModuleElapsed

            }

        }
        catch {
            $ModuleElapsed = Stop-Stopwatch $ModuleWatch

            $Results += [PSCustomObject]@{

                Name           = $Item.Name
                Status         = "ERROR"
                Score          = 0
                Details        = $_.Exception.Message
                Recommendation = ""
                Elapsed        = $ModuleElapsed
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

    if ($Results.Count -gt 0) {

        $FinalScore = [math]::Round(
            $Score / $Results.Count
        )

    }
    else {
        $FinalScore = 0
    }

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

    #---------------------------------------------------------
    # Determine diagnostic state
    #---------------------------------------------------------

    $HasCritical = @(
        $Results | Where-Object {
            $_.Status -eq "CRITICAL"
        }
    ).Count -gt 0

    $HasWarning = @(
        $Results | Where-Object {
            $_.Status -eq "WARNING"
        }
    ).Count -gt 0

    $HasErrors = @(
        $Results | Where-Object {
            $_.Status -eq "ERROR"
        }
    ).Count -gt 0


    if ($HasErrors) {
        $State = "ERROR"
    }
    elseif ($HasCritical) {
        $State = "CRITICAL"
    }
    elseif ($HasWarning) {
        $State = "WARNING"
    }
    elseif ($FinalScore -ge 95) {
        $State = "EXCELLENT"
    }
    elseif ($FinalScore -ge 80) {
        $State = "GOOD"
    }
    else {
        $State = "WARNING"
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

    $Success = @(
        $Results | Where-Object {
            $_.Status -eq "OK"
        }
    ).Count

    $Errors = @(
        $Results | Where-Object {
            $_.Status -eq "ERROR"
        }
    ).Count

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host ("Time : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Diagnostic completed." "OK"

    $Global:App.Results.Diagnostic = New-ModuleResult `
        -Module "Diagnostic" `
        -Success $Success `
        -Errors $Errors `
        -Details $Results `
        -Elapsed $Elapsed

    $Global:App.Results.Diagnostic | Add-Member `
        -MemberType NoteProperty `
        -Name Score `
        -Value $FinalScore `
        -Force

    $Global:App.Results.Diagnostic | Add-Member `
        -MemberType NoteProperty `
        -Name State `
        -Value $State `
        -Force

    Pause-App
}

Export-ModuleMember -Function *
