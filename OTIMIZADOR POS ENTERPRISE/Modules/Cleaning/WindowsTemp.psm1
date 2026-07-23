#=========================================================
# WindowsTemp.psm1
# Limpeza da pasta C:\Windows\Temp
#=========================================================

function Get-WindowsTempAnalysis {

    $Path = Join-Path $env:windir "Temp"

    if (!(Test-Folder $Path)) {

        return [PSCustomObject]@{
            Name            = "Windows TEMP"
            Path            = $Path
            Size            = 0
            SizeText        = "0 Bytes"
            Files           = 0
            CleanupFunction = "Invoke-WindowsTempCleanup"
        }

    }

    $Size  = Get-FolderSize $Path
    $Files = Get-FilesCount $Path

    return [PSCustomObject]@{

        Name            = "Windows TEMP"

        Path            = $Path

        Size            = $Size

        SizeText        = Convert-Bytes $Size

        Files           = $Files

        CleanupFunction = "Invoke-WindowsTempCleanup"

    }

}

#---------------------------------------------------------

function Invoke-WindowsTempCleanup {

    $Path = Join-Path $env:windir "Temp"

    if (!(Test-Folder $Path)) {

        Write-Log "A pasta Windows TEMP não existe." "WARNING"
        return

    }

    Write-Log "A limpar Windows TEMP..." "INFO"

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

                # Ficheiros em utilização ou protegidos
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