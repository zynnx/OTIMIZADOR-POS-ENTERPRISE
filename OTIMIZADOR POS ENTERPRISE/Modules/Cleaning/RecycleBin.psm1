#=========================================================
# RecycleBin.psm1
# Limpeza da Reciclagem
#=========================================================

function Get-RecycleBinAnalysis {

    $TotalSize = 0
    $TotalFiles = 0

    try {

        Get-PSDrive -PSProvider FileSystem | ForEach-Object {

            $Recycle = Join-Path $_.Root '$Recycle.Bin'

            if (Test-Path $Recycle) {

                $TotalSize += Get-FolderSize $Recycle
                $TotalFiles += Get-FilesCount $Recycle

            }

        }

    }
    catch {
    }

    return [PSCustomObject]@{

        Name            = "Reciclagem"

        Path            = "$Recycle.Bin"

        Size            = $TotalSize

        SizeText        = Convert-Bytes $TotalSize

        Files           = $TotalFiles

        CleanupFunction = "Invoke-RecycleBinCleanup"

    }

}

#---------------------------------------------------------

function Invoke-RecycleBinCleanup {

    Write-Log "A limpar Reciclagem..." "INFO"

    #
    # Primeira tentativa
    #

    try {

        Clear-RecycleBin -Force -ErrorAction Stop

        Write-Log "Reciclagem limpa com Clear-RecycleBin." "OK"

        return

    }
    catch {

        Write-Log "Clear-RecycleBin falhou. A tentar limpeza manual..." "WARNING"

    }

    #
    # Segunda tentativa
    #

    foreach ($Drive in Get-PSDrive -PSProvider FileSystem) {

        $Recycle = Join-Path $Drive.Root '$Recycle.Bin'

        if (!(Test-Path $Recycle)) {
            continue
        }

        try {

            Get-ChildItem `
                -Path $Recycle `
                -Force `
                -ErrorAction SilentlyContinue |

            ForEach-Object {

                try {

                    Remove-Item `
                        $_.FullName `
                        -Recurse `
                        -Force `
                        -ErrorAction Stop

                }
                catch {
                }

            }

        }
        catch {
        }

    }

    Write-Log "Limpeza manual da Reciclagem concluída." "OK"

}

Export-ModuleMember -Function *