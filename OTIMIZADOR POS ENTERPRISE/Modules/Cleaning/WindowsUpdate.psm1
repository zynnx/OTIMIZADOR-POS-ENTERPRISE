#=========================================================
# WindowsUpdate.psm1
# Limpeza da cache do Windows Update
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

        Write-Log "Não foi possível parar o serviço $Name." "WARNING"

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

        Write-Log "Não foi possível iniciar o serviço $Name." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-WindowsUpdateCleanup {

    $Path = Join-Path $env:windir "SoftwareDistribution\Download"

    if (!(Test-Folder $Path)) {

        Write-Log "Pasta SoftwareDistribution não encontrada." "WARNING"

        return

    }

    Write-Log "A limpar Windows Update..." "INFO"

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

        Write-Log "Cache do Windows Update removida." "OK"

    }
    catch {

        Write-Log $_.Exception.Message "ERROR"

    }

    Start-ServiceSafe "bits"
    Start-ServiceSafe "wuauserv"

}

Export-ModuleMember -Function *