param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$LauncherDir = Join-Path $Root "Launcher"
$PublishDir = Join-Path $LauncherDir "publish"
$PayloadPath = Join-Path $LauncherDir "payload.zip"

Get-Process -Name "Otimizador_POS" -ErrorAction SilentlyContinue | Stop-Process -Force

if (Test-Path $PublishDir) {
    Remove-Item $PublishDir -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $PayloadPath) {
    Remove-Item $PayloadPath -Force -ErrorAction SilentlyContinue
}

Compress-Archive -Path (Join-Path $Root "Otimizador_POS.ps1"), (Join-Path $Root "Config"), (Join-Path $Root "Modules") -DestinationPath $PayloadPath -Force

Set-Location $LauncherDir
& dotnet publish -c $Configuration -o .\publish

if ($LASTEXITCODE -ne 0) {
    throw "Falha ao publicar o executável."
}

Write-Host ""
Write-Host "Executável gerado em: $PublishDir\Otimizador_POS.exe" -ForegroundColor Green
