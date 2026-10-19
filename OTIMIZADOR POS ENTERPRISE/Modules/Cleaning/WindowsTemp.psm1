#=========================================================
# WindowsTemp.psm1
# C:\Windows\Temp cleanup
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
    return Remove-CleanupContent -Path (Join-Path $env:windir 'Temp')
}
Export-ModuleMember -Function Get-WindowsTempAnalysis, Invoke-WindowsTempCleanup
