function Get-ConfigDefaults {
    return @{
        Config = @{ CreateRestorePoint = $false; RequireRestorePoint = $false; RunDISM = $true; RunSFC = $false }
        Cleaning = @{ CleanTemp = $true; CleanWindowsTemp = $true; CleanRecycleBin = $false; CleanThumbnailCache = $false; CleanWindowsUpdate = $false; CleanDeliveryOptimization = $false }
        Optimization = @{ PowerPlan = $false; VisualEffects = $false; Services = $false; SSD = $true; Explorer = $false }
        Repair = @{ Windows = $true; WindowsUpdate = $false; CheckDisk = $false; ComponentStore = $false; Store = $false }
        Diagnostic = @{ MinimumScore = 80; ShowRecommendations = $true }
        Inventory = @{ ShowPrinters = $true; ShowMonitors = $true; ShowDisks = $true; ShowSoftware = $true }
        Report = @{ OpenAutomatically = $true; KeepHistory = $true; MaxReports = 50 }
        Settings = @{ Company = 'OTIMIZADOR POS ENTERPRISE'; Version = '3.0'; Language = 'en-US'; ReportsFolder = 'Reports'; LogsFolder = 'Logs' }
    }
}
function Load-Config {
    param([string]$ConfigFolder = "$Global:AppRoot\Config")
    $defaults = Get-ConfigDefaults
    $loaded = @{}
    foreach ($section in $defaults.Keys) {
        $values = @{}
        foreach ($key in $defaults[$section].Keys) { $values[$key] = $defaults[$section][$key] }
        $file = Join-Path $ConfigFolder "$section.json"
        if (Test-Path -LiteralPath $file) {
            $json = Get-Content -LiteralPath $file -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
            if ($null -eq $json -or $json -is [array] -or $json -is [string] -or $json -is [ValueType]) { throw "Invalid configuration object: $file" }
            foreach ($property in $json.PSObject.Properties) {
                $key = $property.Name
                if (-not $values.ContainsKey($key)) { throw "Unknown option: $section.$key" }
                $value = $property.Value
                $expected = $defaults[$section][$key]
                if ($expected -is [bool] -and $value -isnot [bool]) { throw "$section.$key must be a JSON boolean." }
                if ($expected -is [int] -and ($value -isnot [int] -and $value -isnot [long])) { throw "$section.$key must be an integer." }
                if ($expected -is [string] -and ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value))) { throw "$section.$key must be a non-empty string." }
                $values[$key] = $value
            }
        }
        $loaded[$section] = [PSCustomObject]$values
    }
    if ($loaded.Report.MaxReports -lt 1 -or $loaded.Report.MaxReports -gt 10000) { throw 'Report.MaxReports must be between 1 and 10000.' }
    if ($loaded.Diagnostic.MinimumScore -lt 0 -or $loaded.Diagnostic.MinimumScore -gt 100) { throw 'Diagnostic.MinimumScore must be between 0 and 100.' }
    foreach ($key in @('ReportsFolder', 'LogsFolder')) {
        if ($loaded.Settings.$key -notmatch '^[a-zA-Z0-9_-]+$') { throw "Settings.$key must be a simple folder name." }
    }
    $softwareFile = Join-Path $ConfigFolder 'SoftwareDetection.json'
    if (Test-Path -LiteralPath $softwareFile) {
        $software = Get-Content -LiteralPath $softwareFile -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $software.Software -or @($software.Software | Where-Object { $_ -isnot [string] }).Count) { throw 'SoftwareDetection.Software must contain strings.' }
        $loaded.SoftwareDetection = $software
    }
    $Global:App.Config = $loaded
    $Global:Config = $loaded.Config
}
function Get-Config {
    param([Parameter(Mandatory)][string]$Section)
    if (-not $Global:App.Config.ContainsKey($Section)) { throw "Configuration section not loaded: $Section" }
    return $Global:App.Config[$Section]
}
Export-ModuleMember -Function Get-ConfigDefaults, Load-Config, Get-Config
