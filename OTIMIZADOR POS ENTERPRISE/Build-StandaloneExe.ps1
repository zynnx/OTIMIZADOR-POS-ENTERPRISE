param(
    [string]$Configuration = "Release",

    # By default the exe is self-contained (portable - no .NET runtime needed).
    # Pass -FrameworkDependent for a tiny exe (~0.2 MB) that requires the .NET 8 runtime.
    [switch]$FrameworkDependent
)

$ErrorActionPreference = "Stop"

$Root        = Split-Path -Parent $MyInvocation.MyCommand.Path
$LauncherDir = Join-Path $Root "Launcher"
$CsProj      = Join-Path $LauncherDir "Launcher.csproj"
$PublishDir  = Join-Path $LauncherDir "publish"
$ObjDir      = Join-Path $LauncherDir "obj"
$PayloadPath = Join-Path $LauncherDir "payload.zip"
$ExePath     = Join-Path $PublishDir "Otimizador_POS.exe"

function Test-PathExists([string]$p, [string]$what) {
    if (-not (Test-Path $p)) {
        Write-Host "ERROR: $what not found at: $p" -ForegroundColor Red
        throw "Missing required input: $what"
    }
}

Write-Host "=== OTIMIZADOR POS ENTERPRISE - Standalone EXE Builder ===" -ForegroundColor Cyan
Write-Host "Configuration : $Configuration"
Write-Host "Mode          : $(if ($FrameworkDependent) { 'Framework-dependent (needs .NET 8 runtime)' } else { 'Self-contained (portable)' })"
Write-Host ""

#---- 1) Prerequisites -------------------------------------------------------
$DotNet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $DotNet) {
    Write-Host "ERROR: the 'dotnet' CLI was not found in PATH." -ForegroundColor Red
    Write-Host "Install the .NET 8 SDK (https://dotnet.microsoft.com/download) and try again." -ForegroundColor Yellow
    throw "dotnet SDK not found."
}

Test-PathExists (Join-Path $Root "Otimizador_POS.ps1") "entry script (Otimizador_POS.ps1)"
Test-PathExists (Join-Path $Root "Config")  "Config folder"
Test-PathExists (Join-Path $Root "Modules") "Modules folder"
Test-PathExists $CsProj "Launcher project (Launcher.csproj)"

#---- 2) Stop any running instance (avoids file locks) ----------------------
Get-Process -Name "Otimizador_POS" -ErrorAction SilentlyContinue | Stop-Process -Force

#---- 3) Clean previous build artifacts -------------------------------------
foreach ($p in @($PublishDir, $PayloadPath, $ObjDir)) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
}

#---- 4) Build the embedded payload -----------------------------------------
$payload = @(
    (Join-Path $Root "Otimizador_POS.ps1"),
    (Join-Path $Root "Config"),
    (Join-Path $Root "Modules")
)

Compress-Archive -Path $payload -DestinationPath $PayloadPath -Force

$payloadSize = [math]::Round((Get-Item $PayloadPath).Length / 1MB, 2)
Write-Host "Payload built: $PayloadPath ($payloadSize MB)" -ForegroundColor Green

#---- 5) Publish the executable ---------------------------------------------
$publishArgs = @("publish", $CsProj, "--configuration", $Configuration, "--output", $PublishDir, "--nologo")
if ($FrameworkDependent) { $publishArgs += "--self-contained=false" }

Write-Host "Running: dotnet $($publishArgs -join ' ')" -ForegroundColor DarkGray
& dotnet @publishArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: 'dotnet publish' failed with exit code $LASTEXITCODE." -ForegroundColor Red
    throw "Failed to publish the executable."
}

#---- 6) Verify the result ---------------------------------------------------
if (-not (Test-Path $ExePath)) {
    Write-Host "ERROR: expected executable was not produced: $ExePath" -ForegroundColor Red
    throw "Build finished but Otimizador_POS.exe was not found."
}

$exeSize = [math]::Round((Get-Item $ExePath).Length / 1MB, 2)
Write-Host ""
Write-Host "SUCCESS: executable generated at $ExePath ($exeSize MB)" -ForegroundColor Green
if ($FrameworkDependent) {
    Write-Host "NOTE: framework-dependent build - the target PC must have the .NET 8 runtime installed." -ForegroundColor Yellow
    Write-Host "      Omit '-FrameworkDependent' for a fully portable single-file exe." -ForegroundColor Yellow
} else {
    Write-Host "Self-contained build - portable, no .NET runtime needed on the target PC." -ForegroundColor Green
}



