$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$files = @(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object { $_.Extension -in @('.ps1','.psm1') -and $_.FullName -notmatch '\\(bin|obj|publish)\\' })
foreach ($file in $files) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "$($file.FullName): $($errors.Message -join '; ')" }
}
$Global:AppRoot = $root
$Global:App = @{ Root = $root; Config = @{}; Results = @{}; AutomaticMode = $true }
# Match the entry point's priority imports, then the remaining modules.
$priority = @('Core\Utils','Core\Logging','Core\FileSystem','Reports\HTML','Reports\SaveReport','Reports\SystemSection','Reports\CleaningSection','Reports\OptimizationSection','Reports\RepairSection','Reports\DiagnosticSection')
$priorityPaths = @($priority | ForEach-Object { Join-Path $root "Modules\$_.psm1" })
foreach ($path in $priorityPaths) { Import-Module $path -Force -ErrorAction Stop -DisableNameChecking }
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $root 'Modules') -Recurse -Filter '*.psm1') {
    if ($file.FullName -notin $priorityPaths) { Import-Module $file.FullName -Force -ErrorAction Stop -DisableNameChecking }
}
Load-Config
foreach ($category in @('Cleaning','Optimization','Repair')) {
    foreach ($item in Get-MaintenanceDefinitions $category) { Get-Command $item.Function -CommandType Function -ErrorAction Stop | Out-Null }
}
foreach ($name in @('Get-WindowsDiagnostic','Get-WindowsStatus','Get-ServicesDiagnostic','Get-ServicesStatus','Get-WindowsUpdateAnalysis','Invoke-WindowsUpdateRepair','Get-CPUDiagnostic','Get-RecycleBinAnalysis','Save-MaintenanceSnapshot','Restore-MaintenanceSnapshot')) {
    Get-Command $name -CommandType Function -ErrorAction Stop | Out-Null
}
Write-Host "PASS: parsed $($files.Count) scripts, imported all modules and validated configuration and operation functions."
