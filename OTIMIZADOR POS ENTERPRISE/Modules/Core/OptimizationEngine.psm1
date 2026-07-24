#=========================================================
# OptimizationEngine.psm1
# Windows Optimization Engine
#=========================================================

function Get-OptimizationItems {
    return Get-ModuleItems -SubFolder "Optimization" -FunctionPattern "Get-*Status"
}

<# function Get-OptimizationItems {

    param(
        [string]$ModulesPath = "$PSScriptRoot\..\Optimization"
    )

    $Items = @()
    $ImportedModuleNames = @()

    Get-ChildItem -Path $ModulesPath -Filter "*.psm1" -File | ForEach-Object {
        $Module = Import-Module $_.FullName -Force -PassThru
        $ImportedModuleNames += $Module.Name
    }

    $StatusFunctions = Get-Command -CommandType Function -Name "Get-*Status" -Module $ImportedModuleNames -ErrorAction SilentlyContinue

    foreach ($func in $StatusFunctions) {
        $Items += & $func.Name
    }

    return $Items
} #>

<# function Get-OptimizationItems {

    $Items = @()

    if (Get-Command Get-VisualEffectsStatus -ErrorAction SilentlyContinue) {
        $Items += Get-VisualEffectsStatus
    }

    if (Get-Command Get-PowerPlanStatus -ErrorAction SilentlyContinue) {
        $Items += Get-PowerPlanStatus
    }

    if (Get-Command Get-ExplorerStatus -ErrorAction SilentlyContinue) {
        $Items += Get-ExplorerStatus
    }

    if (Get-Command Get-StartupStatus -ErrorAction SilentlyContinue) {
        $Items += Get-StartupStatus
    }

    if (Get-Command Get-SSDStatus -ErrorAction SilentlyContinue) {
        $Items += Get-SSDStatus
    }

    if (Get-Command Get-ServicesStatus -ErrorAction SilentlyContinue) {
        $Items += Get-ServicesStatus
    }

    return $Items

} #>

#---------------------------------------------------------

function Start-Optimization {

    Show-Header "WINDOWS OPTIMIZATION"

    Write-Log "Starting Windows Optimization."

    $Watch = Start-Stopwatch

    $Items = Get-OptimizationItems

    if ($Items.Count -eq 0) {

        Write-WarningMessage "No optimization modules found."

        Pause-App

        return

    }

    Write-Host "Current system status" -ForegroundColor Cyan
    Write-Host ""

    foreach($Item in $Items){

        Write-Host ("{0,-30} {1}" -f $Item.Name,$Item.Status)

    }

    Write-Host ""
    Write-Host "Starting optimization..." -ForegroundColor Cyan
    Write-Host ""

    $OK = 0
    $Erro = 0
    $Current = 0

    foreach($Item in $Items){

        $Current++

        Show-ProgressSimple `
            -Activity "Windows Optimization" `
            -Current $Current `
            -Total $Items.Count

        try{

            if (-not $Item.OptimizeFunction) {
                throw "OptimizeFunction is not defined for $($Item.Name)."
            }

            if (-not (Get-Command -Name $Item.OptimizeFunction -ErrorAction SilentlyContinue)) {
                throw "Optimize function '$($Item.OptimizeFunction)' was not found."
            }

            & $Item.OptimizeFunction

            Write-Success ("{0} completed." -f $Item.Name)

            Write-Log "$($Item.Name) optimized." "OK"

            $OK++

        }
        catch{

            Write-ErrorMessage $Item.Name

            Write-Log $_.Exception.Message "ERROR"

            $Erro++

        }

    }

    Write-Progress `
        -Activity "Windows Optimization" `
        -Completed

    $Elapsed = Stop-Stopwatch $Watch

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host ("Modules executed : {0}" -f $Items.Count)
    Write-Host ("Succeeded        : {0}" -f $OK)
    Write-Host ("Errors              : {0}" -f $Erro)
    Write-Host ("Time               : {0}" -f (Format-Time $Elapsed))

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan

    Write-Log "Optimization completed." "OK"

    Pause-App

}
$Global:App.Results.Optimization = [PSCustomObject]@{
    Date = Get-Date
    Success = $OK
    Errors = $Erro
}

Export-ModuleMember -Function *








