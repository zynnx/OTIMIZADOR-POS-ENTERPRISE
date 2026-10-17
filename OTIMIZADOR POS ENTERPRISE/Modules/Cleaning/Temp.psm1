#=========================================================
# Temp.psm1
# User TEMP folder cleanup
#=========================================================

function Get-TempAnalysis {

    $Path = $env:TEMP

    if (!(Test-Folder $Path)) {

        return [PSCustomObject]@{
            Name            = "User TEMP"
            Path            = $Path
            Size            = 0
            SizeText        = "0 Bytes"
            Files           = 0
            CleanupFunction = "Invoke-TempCleanup"
        }

    }

    $Size  = Get-FolderSize $Path
    $Files = Get-FilesCount $Path

    return [PSCustomObject]@{

        Name            = "User TEMP"

        Path            = $Path

        Size            = $Size

        SizeText        = Convert-Bytes $Size

        Files           = $Files

        CleanupFunction = "Invoke-TempCleanup"

    }

}

#---------------------------------------------------------

function Invoke-TempCleanup {
    return Remove-CleanupContent -Path $env:TEMP
}
Export-ModuleMember -Function Get-TempAnalysis, Invoke-TempCleanup
