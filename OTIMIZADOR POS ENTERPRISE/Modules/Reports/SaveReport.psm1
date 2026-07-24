#=========================================================
# SaveReport.psm1
#=========================================================

function Save-HTMLReport {

    param(

        [string[]]$Html

    )

    $Folder = Join-Path $Global:App.Root "Reports"

    if(!(Test-Path $Folder)){

        New-Item -ItemType Directory $Folder | Out-Null

    }

    $File = Join-Path $Folder ("Report_{0}.html" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

    $Html | Out-File $File -Encoding UTF8

    return $File

}

Export-ModuleMember -Function *