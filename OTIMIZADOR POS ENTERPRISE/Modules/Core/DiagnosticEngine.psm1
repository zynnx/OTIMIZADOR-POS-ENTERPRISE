#=========================================================
# DiagnosticEngine.psm1
# Motor de Diagnóstico
#=========================================================

function Get-DiagnosticItems {

    $Items = @()

    if (Get-Command Get-DiskDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-DiskDiagnostic
    }

    if (Get-Command Get-SmartDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-SmartDiagnostic
    }

    if (Get-Command Get-RAMDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-RAMDiagnostic
    }

    if (Get-Command Get-CPUDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-CPUDiagnostic
    }

    if (Get-Command Get-WindowsDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-WindowsDiagnostic
    }

    if (Get-Command Get-DefenderDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-DefenderDiagnostic
    }

    if (Get-Command Get-FirewallDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-FirewallDiagnostic
    }

    if (Get-Command Get-ServicesDiagnostic -ErrorAction SilentlyContinue) {
        $Items += Get-ServicesDiagnostic
    }

    return $Items
}

#---------------------------------------------------------

function Start-Diagnostic {

    Show-Header "DIAGNOSTICO DO SISTEMA"

    Write-Log "Inicio do diagnostico." "INFO"

    $Watch = Start-Stopwatch

    $Items = Get-DiagnosticItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "Nenhum modulo de diagnostico encontrado."

        Pause-App

        return

    }

    $Results = @()

    $Current = 0

    foreach ($Item in $Items) {

        $Current++

        Show-ProgressSimple `
            -Activity "Diagnóstico" `
            -Current $Current `
            -Total $Items.Count

        try {

            $Results += & $Item.DiagnosticFunction

        }
        catch {

            $Results += [PSCustomObject]@{

                Name = $Item.Name
                Status = "ERRO"
                Score = 0
                Details = $_.Exception.Message
                Recommendation = ""

            }

        }

    }

    Write-Progress -Activity "Diagnóstico" -Completed

    #
    # Calcular pontuação
    #

    $Score = 0

    foreach($Result in $Results){

        $Score += $Result.Score

    }

    $FinalScore = [math]::Round($Score / $Results.Count)

    #
    # Mostrar resultados
    #

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "RESULTADOS"
    Write-Host "============================================================"
    Write-Host ""

    foreach($Result in $Results){

        Write-Host ("{0,-25} {1}" -f $Result.Name,$Result.Status)

        if($Result.Details){

            Write-Host ("   {0}" -f $Result.Details) -ForegroundColor DarkGray

        }

    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Host ("Pontuacao : {0}/100" -f $FinalScore)

    switch ($FinalScore) {

        {$_ -ge 95} {

            $State = "EXCELENTE"

        }

        {$_ -ge 80} {

            $State = "BOM"

        }

        {$_ -ge 60} {

            $State = "ATENÇÃO"

        }

        default {

            $State = "CRÍTICO"

        }

    }

    Write-Host ("Estado     : {0}" -f $State)

    #
    # Recomendações
    #

    $Recommendations = $Results |
        Where-Object {
            $_.Recommendation -ne ""
        }

    if($Recommendations.Count -gt 0){

        Write-Host ""
        Write-Host "Recomendacoes:" -ForegroundColor Yellow
        Write-Host ""

        foreach($Item in $Recommendations){

            Write-Host ("- {0}" -f $Item.Recommendation)

        }

    }

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host ("Tempo : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Diagnostico concluido." "OK"

    Pause-App

}

$Global:App.Results.Diagnostic = [PSCustomObject]@{
    Date = Get-Date
    Score = $FinalScore
    Results = $Results
}

Export-ModuleMember -Function *