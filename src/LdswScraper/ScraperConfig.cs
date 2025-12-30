namespace LdswScraper;

public record ScraperConfig(int Parallelism = 32, double DelaySeconds = 0.5);
