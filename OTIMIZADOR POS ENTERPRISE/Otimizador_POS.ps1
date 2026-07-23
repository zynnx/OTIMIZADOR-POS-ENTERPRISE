# ==========================================================
# OTIMIZADOR POS ENTERPRISE
# Autor: Seabra 
# ==========================================================

#-------------------------
# Configurações Globais
#-------------------------

$ErrorActionPreference = "Stop"

$Script:Version = "3.0.0"

$Global:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$Global:App = @{
    Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
    Version = "3.0.0"
    Config  = $null
    LogFile = $null
}

[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#-------------------------
# Verificar Administrador
#-------------------------

$Identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
    Write-Host ""
    Write-Host "Este programa tem de ser executado como Administrador." -ForegroundColor Red
    Write-Host ""

    Pause
    exit
}

#-------------------------
# Criar Pastas
#-------------------------

$Folders = @(
    "Modules",
    "Logs",
    "Reports",
    "Config"
)

foreach($Folder in $Folders)
{
    $Path = Join-Path $Global:AppRoot $Folder

    if(!(Test-Path $Path))
    {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

#-------------------------
# Carregar Configuração
#-------------------------

$ConfigFile = Join-Path $Global:AppRoot "Config\Config.json"

if(!(Test-Path $ConfigFile))
{
@'
{
    "Version":"3.0",
    "CreateRestorePoint":true,
    "RunDISM":true,
    "RunSFC":false,
    "CleanBrowsers":true
}
'@ | Set-Content $ConfigFile -Encoding UTF8
}

$Global:Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

#-------------------------
# Carregar Módulos
#-------------------------

$Modules = Get-ChildItem "$Global:AppRoot\Modules" -Filter *.psm1 -Recurse

foreach($Module in $Modules)
{
    Import-Module $Module.FullName -Force 
}

#-------------------------
# Arrancar Programa
#-------------------------

Start-Log

Write-Log "Aplicação iniciada" "OK"

Start-MainMenu