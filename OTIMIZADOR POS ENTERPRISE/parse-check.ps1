$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# Import order mimics Otimizador_POS.ps1: alphabetical Assets, Cleaning, Core, Diagnostics, Optimization, Repair, Reports
$paths = Get-ChildItem $root -Recurse -Filter *.psm1 |
    Where-Object { $_.FullName -notmatch '\\(bin|obj|publish)\\' } |
    Sort-Object FullName

foreach ($p in $paths) {
    Import-Module $p.FullName -Force -ErrorAction SilentlyContinue
}

$checks = @(
    'Get-WindowsDiagnostic',
    'Get-WindowsStatus',
    'Get-ServicesDiagnostic',
    'Get-ServicesStatus',
    'Get-WindowsUpdateAnalysis',
    'Invoke-WindowsUpdateRepair',
    'Get-CPUDiagnostic',
    'Get-RecycleBinAnalysis'
)

foreach ($c in $checks) {
    $cmd = Get-Command $c -CommandType Function -ErrorAction SilentlyContinue
    if ($cmd) {
        $mod = $cmd.Module
        $where = if ($mod) { $mod.Path } else { '<GLOBAL>' }
        Write-Output ("{0} => {1}" -f $c, $where)
    }
    else {
        Write-Output ("{0} => LOST" -f $c)
    }
}

Write-Output 'IMPORT ORDER TEST DONE'