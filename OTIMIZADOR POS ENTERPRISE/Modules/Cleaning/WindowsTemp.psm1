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

    $Path = Join-Path $env:windir "Temp"

    if (!(Test-Folder $Path)) {

        Write-Log "Windows TEMP folder does not exist." "WARNING"
        return

    }

    Write-Log "Cleaning Windows TEMP..." "INFO"

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

                # Files in use or protected
                $Errors++

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