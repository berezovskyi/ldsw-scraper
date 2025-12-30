namespace LdswScraper;

public enum TaskType
{
    Conneg,
    Exact,
    Shex
}

public record ScrapeTask(TaskType Type, string Uri, string Path, string? AcceptHeader = null);
