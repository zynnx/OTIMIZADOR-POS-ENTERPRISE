#=========================================================
# WindowsUpdate.psm1
# Windows Update repair
#=========================================================

function Get-WindowsUpdateRepairStatus {

    return [PSCustomObject]@{

        Name = "Windows Update"

        Status = "Ready"

        RepairFunction = "Invoke-WindowsUpdateRepair"

    }

}

#---------------------------------------------------------

function Stop-ServiceSafe {

    param([string]$Name)

    try {

        $Service = Get-Service -Name $Name -ErrorAction Stop

        if ($Service.Status -ne 'Stopped') {

            Stop-Service -Name $Name -Force -ErrorAction Stop
            $Service.WaitForStatus('Stopped', '00:00:15')

        }

        Write-Log "$Name stopped." "OK"

    }
    catch {

        Write-Log "Service $Name was already stopped or does not exist." "WARNING"

    }

}

#---------------------------------------------------------

function Start-ServiceSafe {

    param([string]$Name)

    try {

        $Service = Get-Service -Name $Name -ErrorAction Stop

        if ($Service.Status -ne 'Running') {

            Start-Service -Name $Name -ErrorAction Stop

        }

        Write-Log "$Name started." "OK"

    }
    catch {

        Write-Log "Service $Name could not be started." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-WindowsUpdateRepair {

    Write-Log "Repairing Windows Update..." "INFO"

    $Services = @(
        "wuauserv",
        "BITS",
        "cryptSvc",
        "msiserver"
    )

    #
    # Stop services with safe control
    #

    foreach($Service in $Services){

        Stop-ServiceSafe -Name $Service

    }

    #
    # Clean only Windows Update cache directories
    #

    $SD = Join-Path $env:SystemRoot "SoftwareDistribution"
    $SDDownload = Join-Path $SD "Download"
    $SDDataStore = Join-Path $SD "DataStore"

    foreach($Path in @($SDDownload, $SDDataStore)){

        if(Test-Path $Path){

            try {

                Get-ChildItem -Path $Path -Force -ErrorAction Stop |
                    Remove-Item -Recurse -Force -ErrorAction Stop

                Write-Log "Cache cleared in $Path." "OK"

            }
            catch {

                Write-Log "Could not clear $Path." "WARNING"

            }

        }

    }

    #
    # Limpar Catroot2
    #

    $Catroot = Join-Path $env:SystemRoot "System32\catroot2"

    if(Test-Path $Catroot){

        try{

            Get-ChildItem -Path $Catroot -Force -ErrorAction Stop |
                Remove-Item -Recurse -Force -ErrorAction Stop

            Write-Log "Catroot2 cleared." "OK"

        }
        catch{

            Write-Log "Could not clear Catroot2." "WARNING"

        }

    }

    #
    # Restart services with safe control
    #

    foreach($Service in $Services){

        Start-ServiceSafe -Name $Service

    }

    Write-Log "Windows Update repair completed." "OK"

}

Export-ModuleMember -Function *





