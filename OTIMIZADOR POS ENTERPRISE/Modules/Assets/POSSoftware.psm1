#=========================================================
# POSSoftware.psm1
#=========================================================

function Get-POSSoftwareInventory {

    $Programs = Get-ItemProperty `
        HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
        HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue

    $Software = @()

    $DefaultSearchList = @(

        "SQL Server",
        "SQL Server Express",
        "OpenVPN",
        "UltraVNC",
        "TightVNC",
        "DWService",
        "Java",
        ".NET",
        "WinREST",
        "ZoneSoft",
        "Primavera",
        "PHC",
        "Sage",
        "XD"

    )

    $SearchList = $DefaultSearchList

    #
    # Config\SoftwareDetection.json (loaded by Load-Config) can override the list
    #

    $DetectionConfig = $null

    if ($Global:App.Config -and $Global:App.Config.SoftwareDetection) {

        $DetectionConfig = $Global:App.Config.SoftwareDetection

    }

    if ($DetectionConfig -and $DetectionConfig.Software) {

        $ConfigList = @($DetectionConfig.Software)

        if ($ConfigList.Count -gt 0) {

            $SearchList = $ConfigList

        }

    }

    foreach ($Search in $SearchList) {

        $Found = $Programs | Where-Object {

            $_.DisplayName -like "*$Search*"

        }

        if ($Found) {

            foreach ($App in $Found) {

                $Software += [PSCustomObject]@{
                    Name = "POS Software"

                    Data = [PSCustomObject]@{

                        Name    = $App.DisplayName

                        Version = $App.DisplayVersion
                    }
                }

            }

        }

    }

    return $Software

}

Export-ModuleMember -Function *