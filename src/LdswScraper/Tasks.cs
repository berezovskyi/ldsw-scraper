using System;
using System.Collections.Generic;
using System.IO;
using Tomlyn;

namespace LdswScraper;

public static class Tasks
{
    private class TaskConfig
    {
        public string Type { get; set; } = "";
        public string Uri { get; set; } = "";
        public string Path { get; set; } = "";
        public string? Accept { get; set; }
    }

    private class RootConfig
    {
        public List<TaskConfig> Tasks { get; set; } = new();
    }

    public static IEnumerable<ScrapeTask> GetAll(string filePath)
    {
        var content = File.ReadAllText(filePath);
        var config = Toml.ToModel<RootConfig>(content);

        foreach (var taskConfig in config.Tasks)
        {
            var type = taskConfig.Type.ToLowerInvariant() switch
            {
                "conneg" => TaskType.Conneg,
                "exact" => TaskType.Exact,
                "shex" => TaskType.Shex,
                _ => throw new FormatException($"Unknown task type: {taskConfig.Type}")
            };

            yield return new ScrapeTask(type, taskConfig.Uri, taskConfig.Path, taskConfig.Accept);
        }
    }
}
