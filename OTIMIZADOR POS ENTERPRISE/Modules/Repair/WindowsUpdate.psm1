#=========================================================
# WindowsUpdate.psm1
# Reparação do Windows Update
#=========================================================

function Get-WindowsUpdateRepairStatus {

    return [PSCustomObject]@{

        Name = "Windows Update"

        Status = "Pronto"

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

        Write-Log "$Name parado." "OK"

    }
    catch {

        Write-Log "Serviço $Name já estava parado ou não existe." "WARNING"

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

        Write-Log "$Name iniciado." "OK"

    }
    catch {

        Write-Log "Serviço $Name não pôde ser iniciado." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-WindowsUpdateRepair {

    Write-Log "A reparar Windows Update..." "INFO"

    $Services = @(
        "wuauserv",
        "BITS",
        "cryptSvc",
        "msiserver"
    )

    #
    # Parar serviços com controlo seguro
    #

    foreach($Service in $Services){

        Stop-ServiceSafe -Name $Service

    }

    #
    # Limpar apenas os diretórios de cache do Windows Update
    #

    $SD = Join-Path $env:SystemRoot "SoftwareDistribution"
    $SDDownload = Join-Path $SD "Download"
    $SDDataStore = Join-Path $SD "DataStore"

    foreach($Path in @($SDDownload, $SDDataStore)){

        if(Test-Path $Path){

            try {

                Get-ChildItem -Path $Path -Force -ErrorAction Stop |
                    Remove-Item -Recurse -Force -ErrorAction Stop

                Write-Log "Cache limpa em $Path." "OK"

            }
            catch {

                Write-Log "Não foi possível limpar $Path." "WARNING"

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

            Write-Log "Catroot2 limpa." "OK"

        }
        catch{

            Write-Log "Não foi possível limpar Catroot2." "WARNING"

        }

    }

    #
    # Reiniciar serviços com controlo seguro
    #

    foreach($Service in $Services){

        Start-ServiceSafe -Name $Service

    }

    Write-Log "Reparação do Windows Update concluída." "OK"

}

Export-ModuleMember -Function *