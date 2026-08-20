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

        Write-Log "Clear-RecycleBin failed: $($_.Exception.Message). Trying manual cleanup..." "WARNING"

    }

    #
    # Manual fallback: remove the S-* user folders of $Recycle.Bin on each drive
    #

    $Cleaned = 0
    $Failed = 0

    $Drives = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue

    foreach ($Drive in $Drives) {

        $Recycle = Join-Path $Drive.Root '$Recycle.Bin'

        if (Test-Path $Recycle) {

            $UserFolders = Get-ChildItem -Path $Recycle -Directory -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "S-*" }

            foreach ($Folder in $UserFolders) {

                try {

                    Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction Stop
                    $Cleaned++

                }
                catch {

                    $Failed++

                }

            }

        }

    }

    Write-Log "Manual cleanup: $Cleaned folder(s) removed, $Failed ignored." "INFO"

    if ($Failed -gt 0) {

        Write-Log "Some Recycle Bin items could not be removed." "WARNING"

    }
    else {

        Write-Log "Manual Recycle Bin cleanup completed." "OK"

    }
}

Export-ModuleMember -Function *