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

function Invoke-WindowsUpdateRepair {

    Write-Log "A reparar Windows Update..." "INFO"

    $Services = @(
        "wuauserv",
        "BITS",
        "cryptSvc",
        "msiserver"
    )

    #
    # Parar serviços
    #

    foreach($Service in $Services){

        try{

            Stop-Service `
                -Name $Service `
                -Force `
                -ErrorAction Stop

            Write-Log "$Service parado." "OK"

        }
        catch{

            Write-Log "$Service já estava parado ou não existe." "WARNING"

        }

    }

    #
    # Limpar SoftwareDistribution
    #

    $SD = Join-Path $env:SystemRoot "SoftwareDistribution"

    if(Test-Path $SD){

        try{

            Remove-Item "$SD\*" `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Write-Log "SoftwareDistribution limpa." "OK"

        }
        catch{

            Write-Log "Não foi possível limpar SoftwareDistribution." "WARNING"

        }

    }

    #
    # Limpar Catroot2
    #

    $Catroot = Join-Path $env:SystemRoot "System32\catroot2"

    if(Test-Path $Catroot){

        try{

            Remove-Item "$Catroot\*" `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Write-Log "Catroot2 limpa." "OK"

        }
        catch{

            Write-Log "Não foi possível limpar Catroot2." "WARNING"

        }

    }

    #
    # Reiniciar serviços
    #

    foreach($Service in $Services){

        try{

            Start-Service `
                -Name $Service `
                -ErrorAction Stop

            Write-Log "$Service iniciado." "OK"

        }
        catch{

            Write-Log "$Service não pôde ser iniciado." "WARNING"

        }

    }

    Write-Log "Reparação do Windows Update concluída." "OK"

}

Export-ModuleMember -Function *