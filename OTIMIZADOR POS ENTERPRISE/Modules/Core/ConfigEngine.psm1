#=========================================================
# ConfigEngine.psm1
#=========================================================

$Global:App.Config = @{}

function Load-Config {

    param(
        [string]$ConfigFolder = "$Global:AppRoot\Config"
    )

    if (-not (Test-Path $ConfigFolder)) {

        Write-Warning "Config folder not found."
        return

    }

    Get-ChildItem $ConfigFolder -Filter *.json | ForEach-Object {

        $Name = $_.BaseName

        try {

            $Global:App.Config[$Name] = Get-Content $_.FullName -Raw |
                                        ConvertFrom-Json

        }
        catch {

            Write-Warning "Failed loading $($_.Name)"

        }

    }

}

function Get-Config {

    param(

        [Parameter(Mandatory)]
        [string]$Section

    )

    return $Global:App.Config[$Section]

}

Export-ModuleMember -Function *