using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using VDS.RDF;
using Microsoft.Extensions.Logging;

namespace LdswScraper;

public class HostScraper
{
    private readonly HttpClient _httpClient;
    private readonly ScraperConfig _config;
    private readonly string _hostname;
    private readonly List<ScrapeTask> _tasks;
    private readonly ILogger<HostScraper> _logger;

    public HostScraper(HttpClient httpClient, ScraperConfig config, string hostname, List<ScrapeTask> tasks, ILogger<HostScraper> logger)
    {
        _httpClient = httpClient;
        _config = config;
        _hostname = hostname;
        _tasks = tasks;
        _logger = logger;
    }

    public async Task RunAsync()
    {
        foreach (var task in _tasks)
        {
            await ProcessTaskAsync(task);
            await Task.Delay(TimeSpan.FromSeconds(_config.DelaySeconds));
        }
    }

    private async Task ProcessTaskAsync(ScrapeTask task)
    {
        // _logger.LogInformation("Processing {Uri} ({Type})", task.Uri, task.Type);
        // We defer logging to inside the method to support buffering for conneg

        switch (task.Type)
        {
            case TaskType.Conneg:
                await ProcessConnegAsync(task);
                break;
            case TaskType.Exact:
                await ProcessExactAsync(task);
                break;
            case TaskType.Shex:
                await ProcessShexAsync(task);
                break;
        }
    }

    private async Task ProcessConnegAsync(ScrapeTask task)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"Processing {task.Uri} ({task.Type})");

        // Defined formats to try for conneg
        var formats = new[]
        {
            ("text/turtle", ".ttl", "Turtle"),
            ("application/rdf+xml", ".rdf", "RDF/XML"),
            ("application/n-triples", ".nt", "N-Triples"),
            ("application/ld+json", ".jsonld", "JSON-LD"),
            ("application/n-quads", ".nq", "N-Quads"),
            ("application/trig", ".trig", "TriG"),
            ("text/n3", ".n3", "N3")
        };

        IGraph? validGraph = null;
        var successfulFormats = new HashSet<string>();
        bool validGraphIsomorphicToDisk = false;

        foreach (var (accept, ext, name) in formats)
        {
            var content = await FetchAsync(task.Uri, accept);
            if (content != null)
            {
                if (RdfHandler.TryParse(content, accept, out var graph, out _))
                {
                    var finalPath = GetOutputPath(task.Path) + ext;
                    bool isIsomorphic = false;

                    // If file exists, check isomorphism
                    if (File.Exists(finalPath))
                    {
                        try
                        {
                            var existingContent = File.ReadAllText(finalPath);
                            if (RdfHandler.TryParse(existingContent, accept, out var existingGraph, out _))
                            {
                                if (new GraphMatcher().Equals(graph, existingGraph))
                                {
                                    isIsomorphic = true;
                                }
                            }
                        }
                        catch { /* ignore errors */ }
                    }

                    if (isIsomorphic)
                    {
                        sb.AppendLine($"  {name}: Skipped (Isomorphic)");
                        if (validGraph == null)
                        {
                            validGraphIsomorphicToDisk = true;
                        }
                    }
                    else
                    {
                        var tempPath = Path.GetTempFileName();
                        File.WriteAllText(tempPath, content);
                        EnsureDirectory(finalPath);
                        MoveOrReplace(tempPath, finalPath);
                        sb.AppendLine($"  {name}: OK");
                    }

                    validGraph ??= graph; // Keep the first valid graph
                    successfulFormats.Add(ext);
                }
                else
                {
                    sb.AppendLine($"  {name}: Invalid Format");
                }
            }
            else
            {
                sb.AppendLine($"  {name}: Failed");
            }
            await Task.Delay(TimeSpan.FromSeconds(_config.DelaySeconds));
        }

        if (validGraph != null)
        {
            foreach (var (accept, ext, name) in formats)
            {
                if (!successfulFormats.Contains(ext))
                {
                    var finalPath = GetOutputPath(task.Path) + ext;

                    // If the source (validGraph) is isomorphic to its on-disk counterpart,
                    // we skip generating derived formats if they already exist, assuming they are consistent.
                    if (validGraphIsomorphicToDisk && File.Exists(finalPath))
                    {
                         sb.AppendLine($"  {name}: Skipped (Source Isomorphic)");
                         continue;
                    }

                    try
                    {
                        var content = RdfHandler.Generate(validGraph, accept);
                        EnsureDirectory(finalPath);
                        File.WriteAllText(finalPath, content);
                        sb.AppendLine($"  {name}: Generated");
                    }
                    catch (Exception)
                    {
                        // Ignore
                    }
                }
            }
        }

        _logger.LogInformation(sb.ToString().TrimEnd());
    }

    private async Task ProcessExactAsync(ScrapeTask task)
    {
        if (string.IsNullOrEmpty(task.AcceptHeader)) return;

        // Exact is simpler, usually single request. No need for buffering unless we want consistency.
        // But buffering is good practice for parallel output.

        var sb = new StringBuilder();
        sb.AppendLine($"Processing {task.Uri} ({task.Type})");

        var content = await FetchAsync(task.Uri, task.AcceptHeader);
        if (content != null)
        {
            if (RdfHandler.TryParse(content, task.AcceptHeader, out _, out _))
            {
                 var finalPath = GetOutputPath(task.Path); // Exact usually has extension in Path
                 EnsureDirectory(finalPath);

                 // Use temp
                 var tempPath = Path.GetTempFileName();
                 File.WriteAllText(tempPath, content);
                 MoveOrReplace(tempPath, finalPath);

                 sb.AppendLine($"  Exact ({task.AcceptHeader}): OK");
            }
            else
            {
                 sb.AppendLine($"  Exact ({task.AcceptHeader}): Invalid Format");
            }
        }
        else
        {
             sb.AppendLine($"  Exact ({task.AcceptHeader}): Failed");
        }
        _logger.LogInformation(sb.ToString().TrimEnd());
    }

    private async Task ProcessShexAsync(ScrapeTask task)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"Processing {task.Uri} ({task.Type})");

        var content = await FetchAsync(task.Uri, "text/shex");
        if (content != null)
        {
             if (!IsHtml(content))
             {
                 var finalPath = GetOutputPath(task.Path) + ".shex";
                 EnsureDirectory(finalPath);

                 var tempPath = Path.GetTempFileName();
                 File.WriteAllText(tempPath, content);
                 MoveOrReplace(tempPath, finalPath);

                 sb.AppendLine("  ShEx: OK");
             }
             else
             {
                 sb.AppendLine("  ShEx: HTML detected (Ignored)");
             }
        }
        else
        {
             sb.AppendLine("  ShEx: Failed");
        }
        _logger.LogInformation(sb.ToString().TrimEnd());
    }

    private async Task<string?> FetchAsync(string uri, string accept)
    {
        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, uri);
            request.Headers.Add("Accept", accept);
            request.Headers.UserAgent.ParseAdd("LdswScraper/1.0");

            var response = await _httpClient.SendAsync(request);
            if (!response.IsSuccessStatusCode) return null;

            var content = await response.Content.ReadAsStringAsync();
            if (IsHtml(content)) return null;

            return content;
        }
        catch
        {
            return null;
        }
    }

    private bool IsHtml(string content)
    {
        if (string.IsNullOrWhiteSpace(content)) return false;
        var trimmed = content.TrimStart();

        // Robust HTML detection
        if (trimmed.StartsWith("<!DOCTYPE html", StringComparison.OrdinalIgnoreCase)) return true;
        if (trimmed.StartsWith("<html", StringComparison.OrdinalIgnoreCase)) return true;

        // Check for common HTML tags near the start
        // Some servers return XML that is actually XHTML or similar
        // Or sometimes we get a 200 OK with an error page

        // Simple heuristic: look for <head>, <body>, <script>, <meta within the first 1000 chars
        var sample = trimmed.Length > 1000 ? trimmed.Substring(0, 1000) : trimmed;
        if (sample.IndexOf("<head", StringComparison.OrdinalIgnoreCase) >= 0 ||
            sample.IndexOf("<body", StringComparison.OrdinalIgnoreCase) >= 0 ||
            sample.IndexOf("<script", StringComparison.OrdinalIgnoreCase) >= 0 ||
            sample.IndexOf("<title", StringComparison.OrdinalIgnoreCase) >= 0 ||
            sample.IndexOf("<meta http-equiv", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return true;
        }

        return false;
    }

    private void MoveOrReplace(string source, string dest)
    {
        if (File.Exists(dest)) File.Delete(dest);
        File.Move(source, dest);
    }

    private void EnsureDirectory(string path)
    {
        var dir = Path.GetDirectoryName(path);
        if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);
    }

    private string GetOutputPath(string taskPath)
    {
        if (string.IsNullOrEmpty(taskPath)) return "data/unknown";
        var firstChar = char.ToLowerInvariant(taskPath[0]);
        return Path.Combine("data", firstChar.ToString(), taskPath);
    }
}
