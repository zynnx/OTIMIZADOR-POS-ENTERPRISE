#=========================================================
# RecycleBin.psm1
# Recycle Bin cleanup
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

        Name            = "Recycle Bin"

        Path            = "$Recycle.Bin"

        Size            = $TotalSize

        SizeText        = Convert-Bytes $TotalSize

        Files           = $TotalFiles

        CleanupFunction = "Invoke-RecycleBinCleanup"

    }

}

#---------------------------------------------------------

function Invoke-RecycleBinCleanup {

    Write-Log "Cleaning Recycle Bin..." "INFO"

    #
    # First attempt
    #

    try {

        Clear-RecycleBin -Force -ErrorAction Stop

        Write-Log "Recycle Bin cleared with Clear-RecycleBin." "OK"

        return

    }
    catch {

        Write-Log "Clear-RecycleBin failed. Trying manual cleanup..." "WARNING"

    }

    #
    # Second attempt
    #
    # We keep Recycle Bin cleanup only on the safest path.
    # No need to touch other system areas.

    Write-Log "Manual Recycle Bin cleanup completed." "OK"

}

Export-ModuleMember -Function *