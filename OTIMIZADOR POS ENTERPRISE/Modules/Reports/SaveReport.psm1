function Save-HTMLReport {
    param([string[]]$Html)
    $folder = Join-Path $Global:App.Root (Get-Config Settings).ReportsFolder
    New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    $file = Join-Path $folder ("Report_{0}_{1}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [guid]::NewGuid().ToString('N'))
    $Html | Out-File -LiteralPath $file -Encoding UTF8 -ErrorAction Stop
    $config = Get-Config Report
    $keep = if ($config.KeepHistory) { $config.MaxReports } else { 1 }
    Get-ChildItem -LiteralPath $folder -Filter 'Report_*.html' -File |
        Sort-Object LastWriteTime -Descending | Select-Object -Skip $keep |
        Where-Object FullName -ne $file | Remove-Item -Force -ErrorAction Stop
    return $file
}
Export-ModuleMember -Function Save-HTMLReport
