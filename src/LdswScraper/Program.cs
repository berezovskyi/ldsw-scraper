using System.CommandLine;
using LdswScraper;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

var parallelOption = new Option<int>("--parallelism")
{
    Description = "The number of concurrent host fetchers.",
    DefaultValueFactory = _ => 32
};
parallelOption.Aliases.Add("-p");

var timeoutOption = new Option<double>("--timeout")
{
    Description = "The delay between requests to the same host in seconds.",
    DefaultValueFactory = _ => 0.5
};
timeoutOption.Aliases.Add("-t");

var inputFileOption = new Option<string>("--input-file")
{
    Description = "The path to the input TOML file.",
    DefaultValueFactory = _ => "data/tasks.toml"
};
inputFileOption.Aliases.Add("-i");

var rootCommand = new RootCommand("LDSW Scraper");
rootCommand.Options.Add(parallelOption);
rootCommand.Options.Add(timeoutOption);
rootCommand.Options.Add(inputFileOption);

rootCommand.SetAction((ParseResult parseResult) =>
{
    var parallelism = parseResult.GetValue(parallelOption);
    var timeout = parseResult.GetValue(timeoutOption);
    var inputFile = parseResult.GetValue(inputFileOption);

    if (string.IsNullOrWhiteSpace(inputFile))
    {
        throw new ArgumentException("Input file path cannot be empty.");
    }

    var config = new ScraperConfig(parallelism, timeout);

    var services = new ServiceCollection();
    services.AddHttpClient();
    services.AddLogging(builder =>
    {
        builder.AddConsole();
        builder.SetMinimumLevel(LogLevel.Information);
    });

    var serviceProvider = services.BuildServiceProvider();
    var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
    var httpClientFactory = serviceProvider.GetRequiredService<IHttpClientFactory>();

    logger.LogInformation("Starting scraper with P={Parallelism}, T={Timeout}s, Input={InputFile}", parallelism, timeout, inputFile);

    var tasks = Tasks.GetAll(inputFile).ToList();
    var tasksByHost = tasks.GroupBy(t =>
    {
        try { return new Uri(t.Uri).Host; }
        catch { return "unknown"; }
    });

    var options = new ParallelOptions { MaxDegreeOfParallelism = config.Parallelism };

    // Blocking call to async method
    RunScraperAsync(tasksByHost, httpClientFactory, config, serviceProvider.GetRequiredService<ILoggerFactory>(), options).GetAwaiter().GetResult();

    return Task.CompletedTask;
});

await rootCommand.Parse(args).InvokeAsync();

static async Task RunScraperAsync(IEnumerable<IGrouping<string, ScrapeTask>> tasksByHost, IHttpClientFactory httpClientFactory, ScraperConfig config, ILoggerFactory loggerFactory, ParallelOptions options)
{
    await Parallel.ForEachAsync(tasksByHost, options, async (group, ct) =>
    {
        var hostname = group.Key;
        var hostTasks = group.ToList();
        var client = httpClientFactory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(30);

        var logger = loggerFactory.CreateLogger<HostScraper>();
        var scraper = new HostScraper(client, config, hostname, hostTasks, logger);
        await scraper.RunAsync();
    });
}
