#=========================================================
# VisualEffects.psm1
# Otimização dos efeitos visuais
#=========================================================

function Get-VisualEffectsStatus {

    $Status = "Desconhecido"

    try {

        $Value = Get-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            -Name VisualFXSetting `
            -ErrorAction SilentlyContinue

        if ($null -eq $Value) {

            $Status = "Não configurado"

        }
        elseif ($Value.VisualFXSetting -eq 2) {

            $Status = "Otimizado"

        }
        else {

            $Status = "Não otimizado"

        }

    }
    catch {

        $Status = "Desconhecido"

    }

    return [PSCustomObject]@{

        Name = "Efeitos Visuais"

        Status = $Status

        OptimizeFunction = "Invoke-VisualEffectsOptimization"

    }

}

#---------------------------------------------------------

function Invoke-VisualEffectsOptimization {

    Write-Log "A otimizar efeitos visuais..." "INFO"

    #
    # Ajustar para Melhor Desempenho
    #

    New-Item `
        -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
        -Force | Out-Null

    Set-ItemProperty `
        -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
        -Name VisualFXSetting `
        -Value 2 `
        -Type DWord

    #
    # Remover animações
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name UserPreferencesMask `
        -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

    #
    # Menu mais rápido
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name MenuShowDelay `
        -Value "0"

    #
    # Não minimizar com animação
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
        -Name MinAnimate `
        -Value "0" `
        -ErrorAction SilentlyContinue

    Write-Log "Efeitos visuais otimizados." "OK"

}

Export-ModuleMember -Function *