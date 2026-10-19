$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $root 'parse-check.ps1')
function Assert-True($Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    Write-Host "PASS: $Message"
}
$workspace = Split-Path $root -Parent
$testRoot = Join-Path $workspace ('.validation\Tests_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
$originalTemp = $env:TEMP
$originalRoot = $Global:AppRoot
try {
    Load-Config
    Assert-True (-not (Get-Config Config).CreateRestorePoint -and -not (Get-Config Config).RequireRestorePoint) 'Restore points are disabled by default'
    Assert-True (-not (Get-Config Config).RunSFC) 'RunSFC defaults to false'
    Assert-True (-not (Get-Config Optimization).Services) 'Conservative profile leaves services unchanged'
    $valid = $Global:App.Config
    '{"RunSFC":"false"}' | Set-Content -LiteralPath (Join-Path $testRoot 'Config.json') -Encoding UTF8
    $rejected = $false
    try { Load-Config -ConfigFolder $testRoot } catch { $rejected = $true }
    Assert-True $rejected 'String booleans are rejected'
    Assert-True ([object]::ReferenceEquals($valid, $Global:App.Config)) 'Invalid configuration does not replace validated settings'
    '{"RunSFC":false,"Typo":true}' | Set-Content -LiteralPath (Join-Path $testRoot 'Config.json') -Encoding UTF8
    $rejected = $false
    try { Load-Config -ConfigFolder $testRoot } catch { $rejected = $true }
    Assert-True $rejected 'Unknown configuration options are rejected'
    '{}' | Set-Content -LiteralPath (Join-Path $testRoot 'Config.json') -Encoding UTF8
    '{"MaxReports":0}' | Set-Content -LiteralPath (Join-Path $testRoot 'Report.json') -Encoding UTF8
    $rejected = $false
    try { Load-Config -ConfigFolder $testRoot } catch { $rejected = $true }
    Assert-True $rejected 'Invalid report retention is rejected'
    Load-Config

    & (Get-Module MaintenanceEngine) {
        function Write-Log { param($Message,$Level) }
        function Pause-App { }
        function Initialize-MaintenanceProtection { $Global:App.ProtectionReady = $true; $Global:TestProtection++ }
        function Invoke-TempCleanup { $Global:TestExecutions++; New-OperationResult 'TEMP' Partial -Changed 1 -Errors @('Locked file') }
        $Global:App.Config.Cleaning.CleanWindowsTemp = $false
        $Global:TestExecutions = 0
        $Global:TestProtection = 0
        Invoke-MaintenanceCategory Cleaning -WhatIf
        Assert-True ($Global:TestExecutions -eq 0 -and $Global:TestProtection -eq 0) 'Simulation invokes neither protection nor cleanup'
        Assert-True ($Global:App.Results.Cleaning.Planned -eq 1 -and $Global:App.Results.Cleaning.Success -eq 0) 'Simulation is never counted as success'
        Invoke-MaintenanceCategory Cleaning
        Assert-True ($Global:TestExecutions -eq 1) 'Only enabled cleanup operations run'
        Assert-True ($Global:App.Results.Cleaning.Errors -eq 1 -and $Global:App.Results.Cleaning.Success -eq 0) 'Partial cleanup is counted as an error, not success'
        function Initialize-MaintenanceProtection { throw 'Restore point unavailable' }
        $Global:App.ProtectionReady = $false
        Invoke-MaintenanceCategory Cleaning
        Assert-True ($Global:TestExecutions -eq 1) 'Failed protection prevents cleanup'
        Assert-True ($Global:App.Results.Cleaning.Errors -eq 1) 'Protection failure is reported'
    }
    Load-Config
    & (Get-Module Windows | Where-Object Path -like '*\Repair\Windows.psm1') {
        function Start-Process { throw 'Native repair must not run' }
        $Global:App.Config.Config.RunDISM = $false
        $Global:App.Config.Config.RunSFC = $false
        $results = @(Invoke-WindowsRepair)
        Assert-True (@($results | Where-Object Status -ne Skipped).Count -eq 0) 'DISM and SFC flags prevent native command execution'
        function Start-Process { param($FilePath,$ArgumentList,[switch]$Wait,[switch]$PassThru,[switch]$NoNewWindow); $Global:NativeRepairs++; [PSCustomObject]@{ ExitCode = 3010 } }
        $Global:NativeRepairs = 0
        $Global:App.Config.Config.RunDISM = $true
        $results = @(Invoke-WindowsRepair)
        Assert-True ($Global:NativeRepairs -eq 1 -and $results[0].Status -eq 'Success' -and $results[0].Reason -match 'Restart') 'DISM runs once and records restart-required completion'
    }
    Load-Config
    $Global:App.Results = @{}
    $Global:App.ProtectionReady = $true
    & (Get-Module AnalysisEngine) {
        function Pause-App { }
        function Start-Diagnostic { $Global:Flow += 'diagnostic'; $Global:App.Results.Diagnostic = [PSCustomObject]@{ Score = $Global:Flow.Count } }
        function Start-Inventory { $Global:Flow += 'inventory' }
        function Start-Report { $Global:Flow += 'report' }
        function Get-MaintenanceDefinitions {
            param($Category)
            [PSCustomObject]@{ Name = 'Test operation'; Key = $Category; Enabled = $true }
        }
        function Read-Host { throw 'Complete analysis must not prompt' }
        function Invoke-MaintenanceCategory {
            [CmdletBinding(SupportsShouldProcess)]
            param($Category,$Only)
            if ($WhatIfPreference) { $Global:Flow += 'planned' }
            else { $Global:Flow += 'maintenance' }
        }
        $Global:Flow = @()
        Start-CompleteAnalysis
        Assert-True (($Global:Flow -join ',') -eq 'diagnostic,inventory,maintenance,maintenance,maintenance,diagnostic,report') 'Complete analysis runs every enabled category without prompting'
        Assert-True ($Global:App.Results.BeforeDiagnostic.Score -lt $Global:App.Results.Diagnostic.Score) 'Before diagnostic remains available for comparison'
        $Global:Flow = @()
        Start-CompleteAnalysis -Simulation
        Assert-True ('maintenance' -notin $Global:Flow -and 'planned' -in $Global:Flow) 'Complete simulation never applies its plan'
        function Get-MaintenanceDefinitions { param($Category) }
        $Global:Flow = @()
        Start-CompleteAnalysis
        Assert-True (($Global:Flow -join ',') -eq 'diagnostic,inventory,report') 'No enabled operations generates a diagnostic-only report'
    }
    & (Get-Module Rollback) {
        function Import-Clixml {
            [PSCustomObject]@{
                Version = 1; Computer = $env:COMPUTERNAME
                UserSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                Registry = @([PSCustomObject]@{ Path = 'HKCU:\Control Panel\Desktop'; Name = 'MenuShowDelay'; Exists = $true; Kind = 'String'; Value = '400' })
                Services = @(); PowerPlan = '381b4222-f694-41f0-9685-ff5bb260df2e'
            }
        }
        function New-ItemProperty { throw 'Registry must not change in simulation' }
        function Set-Service { throw 'Services must not change in simulation' }
        Restore-MaintenanceSnapshot -Path 'mock.clixml' -WhatIf
        Assert-True $true 'Settings restore supports simulation without changing registry or services'
        function Import-Clixml {
            [PSCustomObject]@{ Version=1; Computer=$env:COMPUTERNAME; UserSid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value; Registry=@([PSCustomObject]@{Path='HKLM:\Unexpected';Name='Invalid'}); Services=@(); PowerPlan='381b4222-f694-41f0-9685-ff5bb260df2e' }
        }
        $rejected = $false
        try { Restore-MaintenanceSnapshot -Path 'mock.clixml' -WhatIf } catch { $rejected = $true }
        Assert-True $rejected 'Settings restore rejects unexpected registry targets before applying changes'
    }
    & (Get-Module SafeCleanup) {
        function Get-Service {
            param($Name)
            $service = [PSCustomObject]@{ Name = $Name; Status = $(if ($Name -eq 'running') { 'Running' } else { 'Stopped' }) }
            $service | Add-Member ScriptMethod WaitForStatus { param($Status,$Timeout) }
            return $service
        }
        function Stop-Service { param($Name,[switch]$Force); $Global:Stopped += $Name }
        function Start-Service { param($Name); $Global:Started += $Name }
        $Global:Stopped = @(); $Global:Started = @()
        $results = @(Invoke-WithStoppedServices @('running','stopped') { throw 'Cleanup failed' })
        Assert-True ($Global:Started.Count -eq 1 -and $Global:Started[0] -eq 'running') 'Services return to their original running state after failure'
        Assert-True ($results[-1].Status -eq 'Failed') 'Service action failure propagates as a failed result'
    }
    $data = Join-Path $testRoot 'Cleanup'
    $payload = Join-Path $data 'Payload'
    New-Item -ItemType Directory -Path $payload -Force | Out-Null
    'keep' | Set-Content -LiteralPath (Join-Path $payload 'app.txt')
    'delete' | Set-Content -LiteralPath (Join-Path $data 'old.tmp')
    $nested = Join-Path $data 'OldFolder\Nested'
    New-Item -ItemType Directory -Path $nested -Force | Out-Null
    'delete nested' | Set-Content -LiteralPath (Join-Path $nested 'old.tmp')
    $locked = Join-Path $data 'locked.tmp'
    'locked' | Set-Content -LiteralPath $locked
    $env:TEMP = $data
    $Global:AppRoot = $payload
    $handle = [IO.File]::Open($locked, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
    try { $result = Remove-CleanupContent -Path $data } finally { $handle.Dispose() }
    Assert-True ($result.Status -eq 'Partial' -and $result.Errors.Count -eq 1) 'Locked files produce partial cleanup'
    Assert-True (Test-Path -LiteralPath (Join-Path $payload 'app.txt')) 'Cleanup protects the running application payload'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $data 'old.tmp'))) 'Approved cleanup removes eligible files'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $data 'OldFolder'))) 'Approved cleanup handles nested directories'
    $rejected = $false
    try { Remove-CleanupContent -Path $testRoot } catch { $rejected = $true }
    Assert-True $rejected 'Cleanup rejects paths outside its allowlist'
    $Global:AppRoot = $originalRoot
    $env:TEMP = $originalTemp
    $Global:App.Root = $testRoot
    $Global:App.Config.Report.KeepHistory = $false
    $first = Save-HTMLReport @('<html>first</html>')
    Start-Sleep -Milliseconds 30
    $second = Save-HTMLReport @('<html>second</html>')
    Assert-True ((Test-Path -LiteralPath $second) -and -not (Test-Path -LiteralPath $first)) 'Report retention keeps the latest report when history is disabled'
    $Global:App.Results.Cleaning = [PSCustomObject]@{ Success=0; Errors=0; Planned=1; Skipped=0; SpaceRecovered=0; Details=@((New-OperationResult '<script>' Planned -Reason '<unsafe>')) }
    $html = Get-CleaningSection
    Assert-True ($html -match 'SIMULATION' -and $html -match '&lt;script&gt;' -and $html -notmatch '<unsafe>') 'Report identifies simulation and escapes operation text'
    Write-Host 'All regression checks passed; no operating-system maintenance was executed.'
} finally {
    $env:TEMP = $originalTemp
    $Global:AppRoot = $originalRoot
    $Global:App.Root = $originalRoot
    # Delete only this test run, after verifying its resolved absolute location.
    $resolved = [IO.Path]::GetFullPath($testRoot)
    $allowed = [IO.Path]::GetFullPath((Join-Path $workspace '.validation')) + '\'
    if ($resolved.StartsWith($allowed, [StringComparison]::OrdinalIgnoreCase)) { Remove-Item -LiteralPath $resolved -Recurse -Force -ErrorAction Stop }
}
