using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using VDS.RDF;

namespace LdswScraper;

public class HostScraper
{
    private readonly HttpClient _httpClient;
    private readonly ScraperConfig _config;
    private readonly string _hostname;
    private readonly List<ScrapeTask> _tasks;

    public HostScraper(HttpClient httpClient, ScraperConfig config, string hostname, List<ScrapeTask> tasks)
    {
        _httpClient = httpClient;
        _config = config;
        _hostname = hostname;
        _tasks = tasks;
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
        Console.WriteLine($"Processing {task.Uri} ({task.Type})");

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

        foreach (var (accept, ext, name) in formats)
        {
            var content = await FetchAsync(task.Uri, accept);
            if (content != null)
            {
                if (RdfHandler.TryParse(content, accept, out var graph, out _))
                {
                    SaveFile(task.Path, ext, content);
                    validGraph ??= graph; // Keep the first valid graph
                    Console.WriteLine($"  {name}: OK");
                }
                else
                {
                    Console.WriteLine($"  {name}: Invalid Format");
                }
            }
            else
            {
                Console.WriteLine($"  {name}: Failed");
            }
            await Task.Delay(TimeSpan.FromSeconds(_config.DelaySeconds));
        }

        // Transcoding
        if (validGraph != null)
        {
            foreach (var (accept, ext, name) in formats)
            {
                if (!FileExists(task.Path, ext))
                {
                    try
                    {
                        var content = RdfHandler.Generate(validGraph, accept);
                        SaveFile(task.Path, ext, content);
                        Console.WriteLine($"  {name}: Generated");
                    }
                    catch (Exception)
                    {
                        // Ignore if generation fails (e.g. not supported)
                    }
                }
            }
        }
    }

    private async Task ProcessExactAsync(ScrapeTask task)
    {
        if (string.IsNullOrEmpty(task.AcceptHeader)) return;

        var content = await FetchAsync(task.Uri, task.AcceptHeader);
        if (content != null)
        {
            // For Exact, we might not have a clean extension mapping, but the task.Path includes extension usually?
            // In the bash script, 'path' often has extension.
            // But wait, curl_get_exact calls curl_safe with empty extension.
            // So we write directly to task.Path.

            // We should still validate if possible.
            // Try to guess format from extension or Content-Type?
            // The task has AcceptHeader which tells us the format.

            if (RdfHandler.TryParse(content, task.AcceptHeader, out _, out _))
            {
                 SaveFileDirect(task.Path, content);
                 Console.WriteLine($"  Exact ({task.AcceptHeader}): OK");
            }
            else
            {
                 Console.WriteLine($"  Exact ({task.AcceptHeader}): Invalid Format");
            }
        }
        else
        {
             Console.WriteLine($"  Exact ({task.AcceptHeader}): Failed");
        }
    }

    private async Task ProcessShexAsync(ScrapeTask task)
    {
        var content = await FetchAsync(task.Uri, "text/shex");
        if (content != null)
        {
             // dotNetRDF might not support Shex parsing easily.
             // We'll just save it for now as per bash script behavior, maybe checking for HTML.
             if (!IsHtml(content))
             {
                 SaveFile(task.Path, ".shex", content);
                 Console.WriteLine("  ShEx: OK");
             }
             else
             {
                 Console.WriteLine("  ShEx: HTML detected (Ignored)");
             }
        }
        else
        {
             Console.WriteLine("  ShEx: Failed");
        }
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
        return trimmed.StartsWith("<!DOCTYPE html", StringComparison.OrdinalIgnoreCase) ||
               trimmed.StartsWith("<html", StringComparison.OrdinalIgnoreCase);
    }

    private void SaveFile(string taskPath, string ext, string content)
    {
        var fullPath = GetOutputPath(taskPath);
        // If taskPath has extension and ext is empty, it's exact.
        // But here we construct path.
        // Bash logic: outpath="data/${firstchar,,}/${path}"
        // curl_safe uses "${outpath}${ext}"

        var filePath = $"{fullPath}{ext}";
        Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);
        File.WriteAllText(filePath, content);
    }

    private void SaveFileDirect(string taskPath, string content)
    {
        var filePath = GetOutputPath(taskPath);
        Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);
        File.WriteAllText(filePath, content);
    }

    private bool FileExists(string taskPath, string ext)
    {
        var filePath = $"{GetOutputPath(taskPath)}{ext}";
        return File.Exists(filePath);
    }

    private string GetOutputPath(string taskPath)
    {
        if (string.IsNullOrEmpty(taskPath)) return "data/unknown";
        var firstChar = char.ToLowerInvariant(taskPath[0]);
        return Path.Combine("data", firstChar.ToString(), taskPath);
    }
}
