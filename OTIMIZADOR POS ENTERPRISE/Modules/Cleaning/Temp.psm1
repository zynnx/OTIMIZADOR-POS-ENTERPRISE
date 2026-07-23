#=========================================================
# Temp.psm1
# Limpeza da pasta TEMP do utilizador
#=========================================================

function Get-TempAnalysis {

    $Path = $env:TEMP

    if (!(Test-Folder $Path)) {

        return [PSCustomObject]@{
            Name            = "TEMP Utilizador"
            Path            = $Path
            Size            = 0
            SizeText        = "0 Bytes"
            Files           = 0
            CleanupFunction = "Invoke-TempCleanup"
        }

    }

    $Size  = Get-FolderSize $Path
    $Files = Get-FilesCount $Path

    return [PSCustomObject]@{

        Name            = "TEMP Utilizador"

        Path            = $Path

        Size            = $Size

        SizeText        = Convert-Bytes $Size

        Files           = $Files

        CleanupFunction = "Invoke-TempCleanup"

    }

}

#---------------------------------------------------------

function Invoke-TempCleanup {

    $Path = $env:TEMP

    if (!(Test-Folder $Path)) {

        Write-Log "Pasta TEMP não existe." "WARNING"
        return

    }

    Write-Log "A limpar TEMP do utilizador..." "INFO"

    $Removed = 0
    $Errors  = 0

    try {

        Get-ChildItem `
            -Path $Path `
            -Force `
            -ErrorAction SilentlyContinue |

        ForEach-Object {

            try {

                Remove-Item `
                    $_.FullName `
                    -Force `
                    -Recurse `
                    -ErrorAction Stop

                $Removed++

            }
            catch {

                # Ignora ficheiros em utilização
                $Errors++

            }

        }

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    Write-Log "Itens removidos: $Removed" "INFO"

    if ($Errors -gt 0) {

        Write-Log "Itens ignorados (em utilização): $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *