#=========================================================
# Explorer.psm1
# Otimização do Explorador do Windows
#=========================================================

function Get-ExplorerStatus {

    $Status = "Não otimizado"

    try {

        $Advanced = Get-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -ErrorAction SilentlyContinue

        if (
            $Advanced.LaunchTo -eq 1 -and
            $Advanced.HideFileExt -eq 0
        ){
            $Status = "Otimizado"
        }

    }
    catch{
        $Status = "Desconhecido"
    }

    return [PSCustomObject]@{

        Name = "Explorador"

        Status = $Status

        OptimizeFunction = "Invoke-ExplorerOptimization"

    }

}

#---------------------------------------------------------

function Invoke-ExplorerOptimization {

    Write-Log "A otimizar o Explorador..." "INFO"

    $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    #
    # Criar chave caso não exista
    #

    New-Item `
        -Path $Path `
        -Force | Out-Null

    #
    # Abrir em Este PC
    #

    Set-ItemProperty `
        -Path $Path `
        -Name LaunchTo `
        -Value 1 `
        -Type DWord

    #
    # Mostrar extensões dos ficheiros
    #

    Set-ItemProperty `
        -Path $Path `
        -Name HideFileExt `
        -Value 0 `
        -Type DWord

    #
    # Não mostrar ficheiros recentes
    #

    Set-ItemProperty `
        -Path $Path `
        -Name ShowRecent `
        -Value 0 `
        -Type DWord `
        -ErrorAction SilentlyContinue

    #
    # Não mostrar pastas frequentes
    #

    Set-ItemProperty `
        -Path $Path `
        -Name ShowFrequent `
        -Value 0 `
        -Type DWord `
        -ErrorAction SilentlyContinue

    #
    # Reiniciar o Explorer
    #

    try{

        Stop-Process `
            -Name explorer `
            -Force `
            -ErrorAction SilentlyContinue

    }
    catch{}

    Start-Process explorer.exe

    Write-Log "Explorador otimizado." "OK"

}

Export-ModuleMember -Function *