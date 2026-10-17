using System.Text;

string testRoot = Path.Combine(Environment.CurrentDirectory, ".validation", "Sessions_" + Guid.NewGuid().ToString("N"));
Directory.CreateDirectory(testRoot);
void Assert(bool condition, string message)
{
    if (!condition) throw new Exception(message);
    Console.WriteLine("PASS: " + message);
}
try
{
    string app = Path.Combine(testRoot, "app");
    string sessions = Path.Combine(testRoot, "sessions");
    Directory.CreateDirectory(Path.Combine(app, "Config"));
    File.WriteAllText(Path.Combine(app, "Config", "Settings.json"), "{\"ReportsFolder\":\"CustomReports\",\"LogsFolder\":\"CustomLogs\"}", Encoding.UTF8);
    Directory.CreateDirectory(Path.Combine(app, "CustomReports"));
    Directory.CreateDirectory(Path.Combine(app, "CustomLogs"));
    Directory.CreateDirectory(Path.Combine(app, "Backups", "nested"));
    File.WriteAllText(Path.Combine(app, "CustomReports", "report.html"), "report");
    File.WriteAllText(Path.Combine(app, "CustomLogs", "log.txt"), "log");
    File.WriteAllText(Path.Combine(app, "Backups", "nested", "settings.clixml"), "backup");
    string? saved = SessionStorage.Save(app, sessions);
    Assert(saved != null && File.ReadAllText(Path.Combine(saved, "CustomReports", "report.html")) == "report", "Custom report folder is copied and verified");
    Assert(File.Exists(Path.Combine(saved!, "Backups", "nested", "settings.clixml")), "Nested settings backups are preserved");
    string? second = SessionStorage.Save(app, sessions);
    Assert(saved != second, "Sessions in the same second use unique destinations");
    using (var locked = new FileStream(Path.Combine(app, "CustomLogs", "log.txt"), FileMode.Open, FileAccess.Read, FileShare.None))
    {
        bool failed = false;
        try { SessionStorage.Save(app, sessions); } catch (IOException) { failed = true; }
        Assert(failed && Directory.Exists(app) && File.Exists(Path.Combine(app, "CustomReports", "report.html")), "Copy failure preserves all original session files");
    }
    File.WriteAllText(Path.Combine(app, "Config", "Settings.json"), "{\"ReportsFolder\":\"../escape\"}");
    bool rejected = false;
    try { SessionStorage.Save(app, sessions); } catch (InvalidDataException) { rejected = true; }
    Assert(rejected && Directory.Exists(app), "Invalid folder configuration preserves original session");
}
finally
{
    // testRoot is a newly generated absolute child of this workspace's .validation directory.
    Directory.Delete(testRoot, recursive: true);
}
