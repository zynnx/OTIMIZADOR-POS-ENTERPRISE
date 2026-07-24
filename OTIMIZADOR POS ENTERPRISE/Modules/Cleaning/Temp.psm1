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

    $Path = $env:TEMP

    if (!(Test-Folder $Path)) {

        Write-Log "TEMP folder does not exist." "WARNING"
        return

    }

    Write-Log "Cleaning user TEMP..." "INFO"

    $Removed = 0
    $Errors  = 0

    try {

        Get-ChildItem `
            -Path $Path `
            -Force `
            -ErrorAction SilentlyContinue |

        ForEach-Object {

            try {

                Remove-Item `
                    $_.FullName `
                    -Force `
                    -Recurse `
                    -ErrorAction Stop

                $Removed++

            }
            catch {

        # Ignore files in use
            }

        }

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    Write-Log "Items removed: $Removed" "INFO"

    if ($Errors -gt 0) {

        Write-Log "Items ignored (in use): $Errors" "WARNING"

    }

}

Export-ModuleMember -Function *
