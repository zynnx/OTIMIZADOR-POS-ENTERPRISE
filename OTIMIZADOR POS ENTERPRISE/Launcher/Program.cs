using System.Diagnostics;
using System.IO.Compression;
using System.Reflection;
using System.Security.Principal;

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------
static bool IsElevated()
{
    try
    {
        var identity = WindowsIdentity.GetCurrent();
        var principal = new WindowsPrincipal(identity);
        return principal.IsInRole(WindowsBuiltInRole.Administrator);
    }
    catch
    {
        return false;
    }
}

static void Pause(string? message = null)
{
    if (!string.IsNullOrEmpty(message))
    {
        Console.WriteLine(message);
    }

    Console.Write("\nPress Enter to close this window... ");
    try
    {
        Console.ReadLine();
    }
    catch
    {
        // stdin may not be available; ignore
    }
}

// ---------------------------------------------------------------------------
// 1) Ensure Administrator privileges (single console window).
//    If we are not elevated, relaunch this same exe elevated and close this
//    (non-elevated) instance, so only one window stays open and any error the
//    app prints remains visible.
// ---------------------------------------------------------------------------
if (!IsElevated())
{
    string exePath = Environment.ProcessPath
        ?? Path.Combine(AppContext.BaseDirectory, "Otimizador_POS.exe");
    bool started = false;

    try
    {
        var psi = new ProcessStartInfo
        {
            FileName = exePath,
            UseShellExecute = true,
            Verb = "runas"
        };

        started = Process.Start(psi) is not null;
    }
    catch (Exception ex)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine("This program requires Administrator privileges.");
        Console.WriteLine($"Could not elevate: {ex.Message}");
        Console.ResetColor();
    }

    if (!started)
    {
        Pause();
        Environment.Exit(1);
    }

    // The elevated instance runs in its own window and keeps it open.
    Environment.Exit(0);
}

var appRoot = Path.Combine(Path.GetTempPath(), "OTIMIZADOR_POS_ENTERPRISE", Guid.NewGuid().ToString("N"));
Directory.CreateDirectory(appRoot);

var assembly = Assembly.GetExecutingAssembly();
var resourceStream = assembly.GetManifestResourceStream("payload.zip");

if (resourceStream == null)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("Embedded package not found in executable.");
    Console.ResetColor();
    Pause();
    Environment.Exit(1);
}

using (resourceStream)
{
    using var archive = new ZipArchive(resourceStream, ZipArchiveMode.Read, leaveOpen: false);
    archive.ExtractToDirectory(appRoot);
}

var scriptPath = Path.Combine(appRoot, "Otimizador_POS.ps1");

if (!File.Exists(scriptPath))
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"Main script not found in embedded package: {scriptPath}");
    Console.ResetColor();
    Pause();
    Environment.Exit(1);
}

var startInfo = new ProcessStartInfo
{
    FileName = "powershell.exe",
    Arguments = $"-NoProfile -ExecutionPolicy Bypass -File \"{scriptPath}\"",
    WorkingDirectory = appRoot,
    UseShellExecute = false
};

int exitCode = 0;

try
{
    using var process = Process.Start(startInfo);
    process?.WaitForExit();
    exitCode = process?.ExitCode ?? 0;
}
catch (Exception ex)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("Failed to start the application:");
    Console.WriteLine(ex.Message);
    Console.ResetColor();
    exitCode = 1;
}

//
// Persist session data (logs and reports) in a permanent location,
// then remove the temporary folder.
//
string? sessionFolder = null;

try
{
    string sessionRoot = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "OtimizadorPOS",
        "Sessions");

    Directory.CreateDirectory(sessionRoot);

    sessionFolder = Path.Combine(sessionRoot, DateTime.Now.ToString("yyyyMMdd_HHmmss"));
    Directory.CreateDirectory(sessionFolder);

    bool hasContent = false;

    foreach (string sub in new[] { "Reports", "Logs" })
    {
        string src = Path.Combine(appRoot, sub);

        if (!Directory.Exists(src))
        {
            continue;
        }

        string dst = Path.Combine(sessionFolder, sub);
        Directory.CreateDirectory(dst);

        foreach (string file in Directory.GetFiles(src))
        {
            File.Copy(file, Path.Combine(dst, Path.GetFileName(file)), true);
            hasContent = true;
        }
    }

    if (!hasContent)
    {
        sessionFolder = null;
    }
}
catch
{
    // Best effort: keep going and just remove the temp folder
    sessionFolder = null;
}

try
{
    Directory.Delete(appRoot, recursive: true);
}
catch
{
    // ignore: some file may still be in use
}

if (sessionFolder != null)
{
    Console.ForegroundColor = ConsoleColor.Green;
    Console.WriteLine($"Session data (logs and reports) saved to: {sessionFolder}");
    Console.ResetColor();
}

// ---------------------------------------------------------------------------
// Keep the window open so the result / any error remains visible.
// ---------------------------------------------------------------------------
Console.WriteLine();
if (exitCode == 0)
{
    Console.WriteLine("Application finished successfully.");
}
else
{
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine($"Application exited with code {exitCode}. See the messages above for details.");
    Console.ResetColor();
}

Pause();
Environment.Exit(exitCode);
