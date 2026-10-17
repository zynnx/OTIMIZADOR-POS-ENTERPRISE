using System.Security.Cryptography;
using System.Text.Json;
using System.Text.RegularExpressions;

internal static class SessionStorage
{
    // Throws on any copy/verification error. The caller must preserve appRoot on failure.
    internal static string? Save(string appRoot, string sessionRoot)
    {
        var folders = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "Reports", "Logs", "Backups" };
        string settingsPath = Path.Combine(appRoot, "Config", "Settings.json");
        if (File.Exists(settingsPath))
        {
            using var settings = JsonDocument.Parse(File.ReadAllText(settingsPath));
            foreach (string key in new[] { "ReportsFolder", "LogsFolder" })
            {
                if (!settings.RootElement.TryGetProperty(key, out var value)) continue;
                string? folder = value.GetString();
                if (string.IsNullOrWhiteSpace(folder) || !Regex.IsMatch(folder, @"\A[a-zA-Z0-9_-]+\z"))
                    throw new InvalidDataException($"Invalid output folder: {key}");
                folders.Add(folder);
            }
        }
        string sessionFolder = Path.Combine(sessionRoot, DateTime.Now.ToString("yyyyMMdd_HHmmss") + "_" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(sessionFolder);
        bool hasContent = false;
        foreach (string sub in folders)
        {
            string source = Path.Combine(appRoot, sub);
            if (!Directory.Exists(source)) continue;
            foreach (string file in EnumerateFiles(source))
            {
                string destination = Path.Combine(sessionFolder, sub, Path.GetRelativePath(source, file));
                Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
                File.Copy(file, destination, false);
                using var original = File.OpenRead(file);
                using var copy = File.OpenRead(destination);
                if (!SHA256.HashData(original).AsSpan().SequenceEqual(SHA256.HashData(copy)))
                    throw new IOException($"Session copy could not be verified: {file}");
                hasContent = true;
            }
        }
        // Only a fully verified session permits the caller to remove the original payload.
        if (!hasContent) Directory.Delete(sessionFolder);
        return hasContent ? sessionFolder : null;
    }

    private static IEnumerable<string> EnumerateFiles(string directory)
    {
        if ((File.GetAttributes(directory) & FileAttributes.ReparsePoint) != 0)
            throw new IOException($"Session directory is a reparse point: {directory}");
        foreach (string entry in Directory.EnumerateFileSystemEntries(directory))
        {
            var attributes = File.GetAttributes(entry);
            if ((attributes & FileAttributes.ReparsePoint) != 0)
                throw new IOException($"Session entry is a reparse point: {entry}");
            if ((attributes & FileAttributes.Directory) != 0)
            {
                foreach (string file in EnumerateFiles(entry)) yield return file;
            }
            else yield return entry;
        }
    }
}
