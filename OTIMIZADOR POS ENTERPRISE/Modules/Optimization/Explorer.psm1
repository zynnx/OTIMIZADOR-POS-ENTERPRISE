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

    if (-not (Test-Path $Path)) {
        try {
            New-Item `
                -Path $Path `
                -Force | Out-Null
        }
        catch {
            throw ("Could not create registry path {0}: {1}" -f $Path, $_.Exception.Message)
        }
    }

    $Properties = @{
        LaunchTo     = 1
        HideFileExt  = 0
        ShowRecent   = 0
        ShowFrequent = 0
    }

    foreach ($Name in $Properties.Keys) {
        try {
            New-ItemProperty `
                -Path $Path `
                -Name $Name `
                -Value $Properties[$Name] `
                -PropertyType DWord `
                -Force | Out-Null
        }
        catch {
            throw "Could not set registry property '$Name': $($_.Exception.Message)"
        }
    }

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










