#=========================================================
# ThumbnailCache.psm1
# Thumbnail and icon cache cleanup
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

        Write-Log "Thumbnail cache not found." "WARNING"

        return

    }

    Write-Log "Cleaning thumbnail cache..." "INFO"

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

        Write-Log "Files ignored: $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *