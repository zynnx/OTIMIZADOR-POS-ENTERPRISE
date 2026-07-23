#=========================================================
# Services.psm1
# Otimização de Serviços
#=========================================================

function Get-ServicesStatus {

    return [PSCustomObject]@{

        Name = "Serviços"

        Status = "Pronto"

        OptimizeFunction = "Invoke-ServicesOptimization"

    }

}

#---------------------------------------------------------

function Set-ServiceStartupSafe {

    param(

        [string]$Name,

        [string]$StartupType

    )

    try {

        $Service = Get-Service $Name -ErrorAction Stop

        Set-Service `
            -Name $Name `
            -StartupType $StartupType `
            -ErrorAction Stop

        Write-Log "$Name -> $StartupType" "OK"

    }
    catch {

        Write-Log "$Name não encontrado." "WARNING"

    }

}

#---------------------------------------------------------

function Invoke-ServicesOptimization {

    Write-Log "A otimizar serviços..." "INFO"

    #
    # Serviços seguros para POS/empresa
    #
    # Apenas ajustamos serviços sem impacto crítico em suporte remoto,
    # VPN ou gestão de rede. Evitamos qualquer alteração em serviços
    # de administração remota ou rede empresarial.

    Set-ServiceStartupSafe "WerSvc" "Manual"

    Set-ServiceStartupSafe "WSearch" "Manual"

    Set-ServiceStartupSafe "SysMain" "Manual"

    Write-Log "Serviços otimizados." "OK"

}

Export-ModuleMember -Function *