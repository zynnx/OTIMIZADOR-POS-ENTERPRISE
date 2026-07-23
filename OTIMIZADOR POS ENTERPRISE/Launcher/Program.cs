using System.Diagnostics;
using System.IO.Compression;
using System.Reflection;

var appRoot = Path.Combine(Path.GetTempPath(), "OTIMIZADOR_POS_ENTERPRISE", Guid.NewGuid().ToString("N"));
Directory.CreateDirectory(appRoot);

var assembly = Assembly.GetExecutingAssembly();
var resourceStream = assembly.GetManifestResourceStream("payload.zip");

if (resourceStream == null)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("Pacote embutido não encontrado no executável.");
    Console.ResetColor();
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
    Console.WriteLine($"Script principal não encontrado no pacote embutido: {scriptPath}");
    Console.ResetColor();
    Environment.Exit(1);
}

var startInfo = new ProcessStartInfo
{
    FileName = "powershell.exe",
    Arguments = $"-NoProfile -ExecutionPolicy Bypass -File \"{scriptPath}\"",
    WorkingDirectory = appRoot,
    UseShellExecute = false
};

try
{
    using var process = Process.Start(startInfo);
    process?.WaitForExit();
    Environment.Exit(process?.ExitCode ?? 0);
}
catch (Exception ex)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("Falha ao iniciar a aplicação:");
    Console.WriteLine(ex.Message);
    Console.ResetColor();
    Environment.Exit(1);
}
