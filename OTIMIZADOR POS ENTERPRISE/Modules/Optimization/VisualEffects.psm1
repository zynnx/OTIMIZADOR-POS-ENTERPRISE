#=========================================================
# VisualEffects.psm1
# Visual Effects Optimization
#=========================================================

function Get-VisualEffectsStatus {

    $Status = "Unknown"

    try {

        $Value = Get-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            -Name VisualFXSetting `
            -ErrorAction SilentlyContinue

        if ($null -eq $Value) {

            $Status = "Not configured"

        }
        elseif ($Value.VisualFXSetting -eq 2) {

            $Status = "Optimized"

        }
        else {

            $Status = "Not optimized"

        }

    }
    catch {

        $Status = "Unknown"

    }

    return [PSCustomObject]@{

        Name = "Visual Effects"

        Status = $Status

        OptimizeFunction = "Invoke-VisualEffectsOptimization"

    }

}

#---------------------------------------------------------

function Invoke-VisualEffectsOptimization {

    Write-Log "Optimizing visual effects..." "INFO"

    #
    # Adjust for Better Performance
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
    # Remove animations
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name UserPreferencesMask `
        -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

    #
    # Faster menu
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name MenuShowDelay `
        -Value "0"

    #
    # Do not minimize with animation
    #

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
        -Name MinAnimate `
        -Value "0" `
        -ErrorAction SilentlyContinue

    Write-Log "Visual effects optimized." "OK"

}

Export-ModuleMember -Function *











