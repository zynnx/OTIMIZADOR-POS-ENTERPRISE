#=========================================================
# ThumbnailCache.psm1
# Limpeza da Cache de Miniaturas e Ícones
#=========================================================

function Get-ThumbnailCacheAnalysis {

    $Path = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Explorer"

    $Size = 0
    $Files = 0

    if (Test-Folder $Path) {

        try {

            $Items = Get-ChildItem `
                -Path $Path `
                -Force `
                -File `
                -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -like "thumbcache*.db" -or
                $_.Name -like "iconcache*.db"
            }

            if ($Items) {

                $Size = ($Items | Measure-Object Length -Sum).Sum

                if ($null -eq $Size) {
                    $Size = 0
                }

                $Files = $Items.Count

            }

        }
        catch {
        }

    }

    return [PSCustomObject]@{

        Name            = "Cache de Miniaturas"

        Path            = $Path

        Size            = [Int64]$Size

        SizeText        = Convert-Bytes $Size

        Files           = $Files

        CleanupFunction = "Invoke-ThumbnailCacheCleanup"

    }

}

#---------------------------------------------------------

function Invoke-ThumbnailCacheCleanup {

    $Path = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Explorer"

    if (!(Test-Folder $Path)) {

        Write-Log "Cache de Miniaturas não encontrada." "WARNING"

        return

    }

    Write-Log "A limpar Cache de Miniaturas..." "INFO"

    $Removed = 0
    $Errors = 0

    try {

        Get-ChildItem `
            -Path $Path `
            -Force `
            -File `
            -ErrorAction SilentlyContinue |

        Where-Object {

            $_.Name -like "thumbcache*.db" -or
            $_.Name -like "iconcache*.db"

        } |

        ForEach-Object {

            try {

                Remove-Item `
                    $_.FullName `
                    -Force `
                    -ErrorAction Stop

                $Removed++

            }
            catch {

                $Errors++

            }

        }

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    Write-Log "Miniaturas removidas: $Removed" "INFO"

    if ($Errors -gt 0) {

        Write-Log "Ficheiros ignorados: $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *