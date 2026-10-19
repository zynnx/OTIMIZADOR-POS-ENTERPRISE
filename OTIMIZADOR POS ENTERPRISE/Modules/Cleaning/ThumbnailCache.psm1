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
    return Remove-CleanupContent -Path (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer') -Patterns @('thumbcache*.db','iconcache*.db')
}
Export-ModuleMember -Function Get-ThumbnailCacheAnalysis, Invoke-ThumbnailCacheCleanup
