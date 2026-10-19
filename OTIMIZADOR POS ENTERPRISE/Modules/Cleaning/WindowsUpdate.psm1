#=========================================================
# WindowsUpdate.psm1
# Windows Update cache cleanup
#=========================================================

function Get-WindowsUpdateAnalysis {

    $Path = Join-Path $env:windir "SoftwareDistribution\Download"

    if (!(Test-Folder $Path)) {

        return [PSCustomObject]@{
            Name            = "Windows Update"
            Path            = $Path
            Size            = 0
            SizeText        = "0 Bytes"
            Files           = 0
            CleanupFunction = "Invoke-WindowsUpdateCleanup"
        }

    }

    $Size  = Get-FolderSize $Path
    $Files = Get-FilesCount $Path

    return [PSCustomObject]@{

        Name            = "Windows Update"

        Path            = $Path

        Size            = $Size

        SizeText        = Convert-Bytes $Size

        Files           = $Files

        CleanupFunction = "Invoke-WindowsUpdateCleanup"

    }

}

#---------------------------------------------------------

function Invoke-WindowsUpdateCleanup {
    Invoke-WithStoppedServices -Names @('wuauserv','bits') -Action { Remove-CleanupContent -Path (Join-Path $env:windir 'SoftwareDistribution\Download') }
}
Export-ModuleMember -Function Get-WindowsUpdateAnalysis, Invoke-WindowsUpdateCleanup
