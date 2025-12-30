using System.Collections.Concurrent;
using System.CommandLine;
using System.CommandLine.Invocation;
using LdswScraper;
using Microsoft.Extensions.DependencyInjection;

var parallelOption = new Option<int>(
    new[] { "--parallelism", "-p" },
    () => 32,
    "The number of concurrent host fetchers.");

var timeoutOption = new Option<double>(
    new[] { "--timeout", "-t" },
    () => 0.5,
    "The delay between requests to the same host in seconds.");

var rootCommand = new RootCommand("LDSW Scraper")
{
    parallelOption,
    timeoutOption
};

rootCommand.SetHandler(async (int parallelism, double timeout) =>
{
    var config = new ScraperConfig(parallelism, timeout);
    Console.WriteLine($"Starting scraper with P={parallelism}, T={timeout}s");

    var services = new ServiceCollection();
    services.AddHttpClient();
    var serviceProvider = services.BuildServiceProvider();
    var httpClientFactory = serviceProvider.GetRequiredService<IHttpClientFactory>();

    var tasks = Tasks.GetAll().ToList();
    var tasksByHost = tasks.GroupBy(t =>
    {
        try { return new Uri(t.Uri).Host; }
        catch { return "unknown"; }
    });

    var options = new ParallelOptions { MaxDegreeOfParallelism = config.Parallelism };

    await Parallel.ForEachAsync(tasksByHost, options, async (group, ct) =>
    {
        var hostname = group.Key;
        var hostTasks = group.ToList();
        var client = httpClientFactory.CreateClient();
        // Configure client timeout
        client.Timeout = TimeSpan.FromSeconds(30); // Global request timeout

        var scraper = new HostScraper(client, config, hostname, hostTasks);
        await scraper.RunAsync();
    });

}, parallelOption, timeoutOption);

return await rootCommand.InvokeAsync(args);
