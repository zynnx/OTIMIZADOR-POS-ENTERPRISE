function Show-Header {

    Clear-Host

    $Width = 70

    Write-Host ("=" * $Width) -ForegroundColor Cyan

    Write-Host ""

    Write-Host "        OTIMIZADOR POS ENTERPRISE" -ForegroundColor Yellow

    Write-Host "               Versao 3.0" -ForegroundColor Gray

    Write-Host ""

    Write-Host ("=" * $Width) -ForegroundColor Cyan

}

function Show-SystemInfo {

    $Info = Get-SystemInfo

	Write-Host ""
	Write-Host (" Computador : {0}" -f $Info.ComputerName)
	Write-Host (" Windows    : {0}" -f $Info.Windows)
	Write-Host (" Build      : {0}" -f $Info.Build)
	Write-Host (" CPU        : {0}" -f $Info.CPU)
	Write-Host (" RAM        : {0} GB" -f $Info.RAM)
	Write-Host (" Disco C:   : {0}/{1} GB livres" -f $Info.DiskFree,$Info.DiskTotal)
	Write-Host (" Uptime     : {0}" -f $Info.Uptime)
}

function Show-Menu {

    Write-Host ("=" * 70) -ForegroundColor DarkGray

    Write-Host ""
    Write-Host " 1  Analise Completa" -ForegroundColor Green
    Write-Host " 2  Limpeza Inteligente" -ForegroundColor Green
    Write-Host " 3  Otimizacao Windows" -ForegroundColor Green
    Write-Host " 4  Reparacao Windows" -ForegroundColor Green
    Write-Host " 5  Relatorios" -ForegroundColor Green
    Write-Host " 6  Configuracao" -ForegroundColor Green
    Write-Host " 7  Historico" -ForegroundColor Green
    Write-Host ""
    Write-Host " 0  Sair" -ForegroundColor Red
    Write-Host ""

    Write-Host ("=" * 70) -ForegroundColor DarkGray

}

function Start-MainMenu {

    do {

        Show-Header

	Show-Dashboard

	Show-Menu

        $Option = Read-Host "Escolha uma opcao"

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

                Start-Reports

            }

            "6" {

                Start-Configuration

            }

            "7" {

                Start-History

            }

            "0" {
                
                break
                Stop-Log
                
            }

            default {

                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red
                Start-Sleep 1

            }

        }

    } until ($Option -eq "0")

}

Export-ModuleMember -Function *