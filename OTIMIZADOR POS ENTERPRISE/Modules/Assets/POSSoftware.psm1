#=========================================================
# POSSoftware.psm1
#=========================================================

function Get-POSSoftwareInventory {

    $Programs = Get-ItemProperty `
        HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
        HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue

    $Software = @()

    $SearchList = @(

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