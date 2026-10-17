# OTIMIZADOR POS ENTERPRISE

Windows 10/11 x64 maintenance console for POS environments, written in PowerShell 5.1 with a portable .NET 8 launcher.

The application provides diagnostics, hardware/software inventory, selected cleaning and repair actions, HTML reports and session logs.

## Run

Open PowerShell as Administrator:

```powershell
cd "OTIMIZADOR POS ENTERPRISE"
powershell -NoProfile -ExecutionPolicy Bypass -File .\Otimizador_POS.ps1
```

The standalone executable also requests Administrator privileges. Diagnostics, inventory and simulation create logs/reports but do not apply maintenance operations.

## Menu and workflow

| Option | Behavior |
| --- | --- |
| 1 — Complete Analysis | Diagnose first, capture inventory, display enabled operations, accept a selection, execute it, diagnose again and generate a report. |
| 2 — Smart Cleaning | Execute enabled cleaning operations. |
| 3 — Windows Optimization | Execute enabled optimization operations. |
| 4 — Windows Repair | Execute enabled repair operations. |
| 5 — Diagnostic | Read system health and recommendations. |
| 6 — Report | Generate an HTML report from this session's results. |
| 7 — Inventory | Collect hardware/software inventory. |
| 8 — Simulate maintenance | Diagnose and display planned operations without invoking cleanup, optimization, repair, restore points or settings backups. |
| 9 — Restore settings | Restore a selected `Settings_*.clixml` backup for the same computer and Windows user. |
| 0 — Exit | Write the execution summary and close. |

In Complete Analysis, enter operation numbers separated by commas, `ALL`, or press Enter for diagnostics only. Schedule actual maintenance outside trading hours.

Operations are reported as `Success`, `Failed`, `Partial`, `Skipped` or `Planned`. Failed or partial operations are not counted as successful. Reports include individual errors and the before/latest diagnostic scores.

## Configuration

Files in `OTIMIZADOR POS ENTERPRISE/Config` are validated before startup. Missing supported settings receive defaults; unknown settings, malformed JSON, string booleans such as `"false"`, and invalid ranges stop startup with an error. Configuration is published only after all sections validate.

| File | Supported options |
| --- | --- |
| `Config.json` | `CreateRestorePoint`, `RequireRestorePoint`, `RunDISM`, `RunSFC` |
| `Cleaning.json` | `CleanTemp`, `CleanWindowsTemp`, `CleanRecycleBin`, `CleanThumbnailCache`, `CleanWindowsUpdate`, `CleanDeliveryOptimization` |
| `Optimization.json` | `PowerPlan`, `VisualEffects`, `Services`, `SSD`, `Explorer` |
| `Repair.json` | `Windows`, `WindowsUpdate`, `CheckDisk`, `ComponentStore`, `Store` |
| `Diagnostic.json` | `MinimumScore` (0–100), `ShowRecommendations` |
| `Inventory.json` | `ShowPrinters`, `ShowMonitors`, `ShowDisks`, `ShowSoftware` |
| `Report.json` | `OpenAutomatically`, `KeepHistory`, `MaxReports` (1–10000) |
| `Settings.json` | `Company`, `Version`, `Language`, `ReportsFolder`, `LogsFolder` |
| `SoftwareDetection.json` | `Software`: names used to identify POS and support software |

`Company`, `Version` and `Language` are metadata; they do not translate the interface or override the application's own version. Output folders must be simple names containing letters, digits, `_` or `-`.

The default conservative configuration enables user/Windows temporary-file cleanup, system-volume SSD ReTrim, and Windows repair with DISM. SFC is disabled. Services, power-plan changes, visual effects, Explorer, Recycle Bin, update caches and other repairs require enabling their corresponding flags. SSD maintenance skips volumes whose underlying disk cannot be confirmed as SSD and does not change TRIM settings. Explorer changes take effect after signing out; the app does not terminate Explorer.

The old `CleanBrowsers`, `CleanPrefetch`, `ClearDNS`, `ResetWinsock`, `FlushStore` and `OptimizeNTFS` options were not connected to their advertised actions and have been removed. Replace old configuration files with the supported schema before upgrading. DISM image repair runs once through the Windows repair sequence; Component Store cleanup is a separate optional operation.

## Protection and recovery

Before the first real maintenance operation in a session, the app requests a restore point and saves previous registry values, service startup settings and the active power plan in `Backups/Settings_*.clixml`. With the defaults, failure to create the required restore point prevents maintenance. Setting `CreateRestorePoint` to false explicitly disables that protection; `RequireRestorePoint` controls whether a creation failure stops execution.

Option 9 restores the captured Explorer/visual registry values, startup types for `WerSvc`, `WSearch` and `SysMain`, and the original power plan. It does not recover deleted files or undo DISM, Store, Windows Update repair or ReTrim. Windows System Restore is separate from this settings backup. Sign out or restart after restoring visual settings.

Cache operations restore services that were originally running, including after cleanup failure; services originally stopped remain stopped. File cleanup accepts only known maintenance directories, rejects reparse points and protects the running application payload. Locked/inaccessible items produce failed or partial results.

## Reports and logs

Direct script runs save output under the configured folders next to the script. Reports have unique names. `KeepHistory: false` keeps the newest report; otherwise `MaxReports` limits retained reports.

The executable extracts its embedded payload into a unique temporary folder. On exit, it copies and verifies reports, logs and settings backups using SHA-256, then removes the temporary payload only after successful preservation. Saved sessions are under:

```text
%LOCALAPPDATA%\OtimizadorPOS\Sessions\<timestamp>_<unique-id>\
```

If copying or verification fails, the original temporary folder is preserved and its location is shown. Session retention across separate executable runs is manual; `MaxReports` applies within each run's report folder. Configuration changes for the executable must be made before rebuilding its embedded payload.

## Validate and build

These checks require no Administrator privileges and do not perform operating-system maintenance:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\OTIMIZADOR POS ENTERPRISE\Tests\Test-Project.ps1"
dotnet run --project "OTIMIZADOR POS ENTERPRISE/Tests/Launcher.Tests/Launcher.Tests.csproj" --configuration Release
```

The PowerShell checks validate syntax, imports, configuration, operation selection, simulation, failure propagation, service recovery, report retention and cleanup behavior in isolated test directories. The C# checks cover custom output folders, nested backups, unique sessions and copy failures.

Build a portable executable with the .NET 8 SDK:

```powershell
cd "OTIMIZADOR POS ENTERPRISE"
.\Build-StandaloneExe.ps1
```

Output: `Launcher/publish/Otimizador_POS.exe`. `-FrameworkDependent` builds a smaller executable requiring the .NET 8 runtime on the target machine. Close a running app before building; the builder will not terminate an active session. GitHub Actions runs checks and builds a downloadable executable artifact for pushes and pull requests.

Build outputs, runtime logs, backups and generated reports are ignored by Git. Existing local artifacts remain available; distribute executables through release assets rather than committing them.

Author: **Seabra** · Application version **3.0.0**
