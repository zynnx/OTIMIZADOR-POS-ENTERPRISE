# OTIMIZADOR POS ENTERPRISE

![Version](https://img.shields.io/badge/version-3.0.0-0078D6)
![Language](https://img.shields.io/badge/language-PowerShell-539EFE)
![OS](https://img.shields.io/badge/OS-Windows%2010%2F11-blue)
![Launcher](https://img.shields.io/badge/launcher-.NET%208-512BD4)

**OTIMIZADOR POS ENTERPRISE** is a PowerShell console application designed for the maintenance, optimization, repair, and diagnostics of Windows systems (focused on POS — *Point of Sale* environments).

Through an interactive menu, it lets you run a complete system analysis, smart cleaning, optimization, Windows repair, detailed diagnostics, hardware/software inventory, and professional HTML report generation.

## ✨ Features

The main menu offers the following options:

| Option | Description |
| :----: | :-------- |
| **1 — Complete Analysis** | Runs the full sequence: clean → optimize → repair → diagnose, and generates the final report. |
| **2 — Smart Cleaning** | Smart cleanup of temporary files, thumbnail cache, Recycle Bin, `WinSxS` (Delivery Optimization), Windows temp files, and old updates. |
| **3 — Windows Optimization** | Performance tweaks: power plan, visual effects, services, SSD, Explorer, DNS, Winsock, and NTFS optimization. |
| **4 — Windows Repair** | System repair: SFC, DISM, disk check (`chkdsk`), Component Store, Microsoft Store repair, and Windows Update. |
| **5 — Diagnostic** | System diagnostics: CPU, RAM, disk (including S.M.A.R.T.), Defender, firewall, services, and Windows health — with scoring and recommendations. |
| **6 — Report** | Generates/opens the HTML report with the results of all sessions. |
| **7 — Inventory** | Equipment inventory: computer, hardware, disks, monitors, network, printers, and installed software. |
| **0 — Exit** | Exits the application (with an execution summary written to the log). |

### Highlights

- 🔐 **Automatic elevation to Administrator** — the app requests elevation automatically when needed.
- ⚙️ **JSON-based configuration** — every behavior is controlled by editable configuration files.
- 📄 **HTML reports** — professional reports with sections for system, cleaning, optimization, repair, and diagnostics.
- 📝 **Full logging** — every event is recorded in `Logs\`.
- 💾 **Restore point** — optional Windows restore point creation before making changes.
- 📦 **Standalone executable** — a .NET 8 launcher that embeds the whole application into a single `Otimizador_POS.exe`.

## 📋 Requirements

- **Windows 10 / Windows 11** (x64)
- **PowerShell 5.1 or later** (included with Windows)
- **Administrator privileges** (the app requests elevation automatically)
- *(Optional, only for building the executable)* **.NET SDK 8.0**

## 🚀 How to run

### Option A — Directly via PowerShell

Open PowerShell (ideally as Administrator) and run:

```powershell
cd "OTIMIZADOR POS ENTERPRISE"
.\Otimizador_POS.ps1
```

> If the PowerShell execution policy blocks startup, the app will try to relaunch itself automatically with `-ExecutionPolicy Bypass`. Alternatively, you can run:
>
> ```powershell
> powershell -NoProfile -ExecutionPolicy Bypass -File ".\Otimizador_POS.ps1"
> ```

## ⚙️ Configuration

Configuration lives in the `Config\` folder:

| File | Description |
| :--- | :--- |
| `Config.json` | General settings: `CreateRestorePoint`, `RunDISM`, `RunSFC`, `CleanBrowsers`. |
| `Cleaning.json` | Cleaning items: `CleanTemp`, `CleanWindowsTemp`, `CleanPrefetch`, `CleanRecycleBin`. |
| `Optimization.json` | Optimizations: `ClearDNS`, `ResetWinsock`, `FlushStore`, `OptimizeNTFS`. |
| `Diagnostic.json` | Diagnostics: `MinimumScore` (score threshold), `ShowRecommendations`. |
| `Inventory.json` | Inventory sections: `ShowPrinters`, `ShowMonitors`, `ShowDisks`, `ShowSoftware`. |
| `Report.json` | Reports: `OpenAutomatically`, `KeepHistory`, `MaxReports`. |
| `Settings.json` | Application settings: `Company`, `Version`, `Language`, `ReportsFolder`, `LogsFolder`. |

If `Config\Config.json` does not exist, the app creates it automatically with default values.

## 📁 Project structure

```
OTIMIZADOR POS ENTERPRISE/
├── Otimizador_POS.ps1            # Entry point (elevation, config, menu startup)
├── Build-StandaloneExe.ps1       # Standalone executable builder (.NET 8)
├── Config/                       # JSON configuration files
├── Logs/                         # Runtime logs
├── Reports/                      # Generated HTML reports
├── Launcher/                     # C# launcher (.NET 8) for the standalone .exe
│   └── publish/                  # Build output (Otimizador_POS.exe)
└── Modules/
    ├── Core/                     # Main engines, menu, dashboard, logging, utilities
    ├── Cleaning/                 # Cleaning: Temp, WindowsTemp, RecycleBin, ThumbnailCache, WinSxS…
    ├── Optimization/             # PowerPlan, VisualEffects, Services, SSD, Explorer
    ├── Repair/                   # DISM, SFC/Windows, CheckDisk, ComponentStore, Store, WindowsUpdate
    ├── Diagnostics/              # CPU, RAM, Disk, S.M.A.R.T., Defender, Firewall, Services, Windows
    ├── Reports/                  # HTML report generation (sections and summary)
    └── Assets/                   # Inventory: Computer, Hardware, Disks, Monitors, Network, Printers, Software
```

## 📊 Reports and logs

- **HTML reports** — saved as `Reports\Report_AAAAMMDD_HHMMSS.html`, with dedicated sections for system, cleaning, optimization, repair, and diagnostics, plus an executive summary. History is capped by `MaxReports` (`Config\Report.json`).
- **Logs** — every event (OK, WARNING, ERROR) is recorded in `Logs\`, ending with an *Execution Summary* for each session.

## 🔨 Building the standalone executable

The C# launcher (.NET 8) embeds the application (script + `Config` + `Modules`) into a `payload.zip` package and produces a **single portable executable** (self-contained by default — no .NET runtime needed on the target machine):

```powershell
cd "OTIMIZADOR POS ENTERPRISE"
.\Build-StandaloneExe.ps1
```

The executable is generated at `Launcher\publish\Otimizador_POS.exe`.

- **Default (self-contained):** ~64 MB, runs on any clean Windows 10/11 x64 PC.
- **`-FrameworkDependent`:** ~0.2 MB, but the target PC must have the .NET 8 runtime installed.
  ```powershell
  .\Build-StandaloneExe.ps1 -FrameworkDependent
  ```

> **Note:** *building* requires the **.NET SDK 8.0** to be installed (the *runtime* is only required for `-FrameworkDependent` builds).

## ⚠️ Disclaimer

This tool makes changes to the operating system (services, registry, file cleanup, DISM/SFC repairs, among others). **Use at your own risk** and keep restore-point creation enabled (`Config\CreateRestorePoint`).

## 📄 Author

**Seabra** — OTIMIZADOR POS ENTERPRISE v3.0.0

