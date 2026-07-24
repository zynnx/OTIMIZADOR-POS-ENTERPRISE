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

function Stop-ServiceSafe {

    param([string]$Name)

    try {

        $Service = Get-Service $Name -ErrorAction Stop

        if ($Service.Status -eq 'Running') {

            Stop-Service $Name -Force -ErrorAction Stop

            $Service.WaitForStatus('Stopped','00:00:15')

        }

    }
    catch {

        Write-Log "Could not stop service $Name." "WARNING"

    }

}

#---------------------------------------------------------

function Start-ServiceSafe {

    param([string]$Name)

    try {

        $Service = Get-Service $Name -ErrorAction Stop

        if ($Service.Status -ne 'Running') {

            Start-Service $Name -ErrorAction Stop

        }

    }
    catch {

        Write-Log "Could not start service $Name." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-WindowsUpdateCleanup {

    $Path = Join-Path $env:windir "SoftwareDistribution\Download"

    if (!(Test-Folder $Path)) {

        Write-Log "SoftwareDistribution folder not found." "WARNING"

        return

    }

    Write-Log "Cleaning Windows Update..." "INFO"

    Stop-ServiceSafe "wuauserv"
    Stop-ServiceSafe "bits"

    try {

        Get-ChildItem `
            -Path $Path `
            -Force `
            -ErrorAction SilentlyContinue |

        Remove-Item `
            -Force `
            -Recurse `
            -ErrorAction SilentlyContinue

        Write-Log "Windows Update cache removed." "OK"

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    Start-ServiceSafe "bits"
    Start-ServiceSafe "wuauserv"

}

Export-ModuleMember -Function *