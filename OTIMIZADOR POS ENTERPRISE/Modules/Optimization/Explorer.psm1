#=========================================================
# Explorer.psm1
# Windows Explorer Optimization
#=========================================================

function Get-ExplorerStatus {

    $Status = "Not optimized"

    try {

        $Advanced = Get-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -ErrorAction SilentlyContinue

        if (
            $Advanced.LaunchTo -eq 1 -and
            $Advanced.HideFileExt -eq 0
        ){
            $Status = "Optimized"
        }

    }
    catch{
        $Status = "Unknown"
    }

    return [PSCustomObject]@{

        Name = "Explorer"

        Status = $Status

        OptimizeFunction = "Invoke-ExplorerOptimization"

    }

}

#---------------------------------------------------------

function Invoke-ExplorerOptimization {

    Write-Log "Optimizing Explorer..." "INFO"

    $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    #
    # Create key if it does not exist
    #

    New-Item `
        -Path $Path `
        -Force | Out-Null

    #
    # Open in This PC
    #

    Set-ItemProperty `
        -Path $Path `
        -Name LaunchTo `
        -Value 1 `
        -Type DWord

    #
    # Show file extensions
    #

    Set-ItemProperty `
        -Path $Path `
        -Name HideFileExt `
        -Value 0 `
        -Type DWord

    #
    # Do not show recent files
    #

    Set-ItemProperty `
        -Path $Path `
        -Name ShowRecent `
        -Value 0 `
        -Type DWord `
        -ErrorAction SilentlyContinue

    #
    # Do not show frequent folders
    #

    Set-ItemProperty `
        -Path $Path `
        -Name ShowFrequent `
        -Value 0 `
        -Type DWord `
        -ErrorAction SilentlyContinue

    #
    # Restart Explorer
    #

    try{

        Stop-Process `
            -Name explorer `
            -Force `
            -ErrorAction SilentlyContinue

    }
    catch{}

    Start-Process explorer.exe

    Write-Log "Explorer optimized." "OK"

}

Export-ModuleMember -Function *










