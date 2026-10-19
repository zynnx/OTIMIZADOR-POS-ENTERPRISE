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
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        New-OperationResult 'Recycle Bin' Success -Changed 1
    } catch {
        New-OperationResult 'Recycle Bin' Failed -Errors @($_.Exception.Message)
    }
}
Export-ModuleMember -Function Get-RecycleBinAnalysis, Invoke-RecycleBinCleanup
