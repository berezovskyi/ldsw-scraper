# Contributing to ldsw-scraper

Thank you for contributing to **ldsw-scraper**! This project tracks and archives Linked Data/semweb TBox definitions.

## Project Structure

- **[src/LdswScraper/](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/src/LdswScraper/)**: Main scraper console application.
- **[src/LdswScraper.Tests/](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/src/LdswScraper.Tests/)**: Unit tests.
- **[data/](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/data/)**: Directory containing scraped RDF vocabularies, partitioned alphabetically by their relative path.
- **[data/tasks.toml](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/data/tasks.toml)**: Scraping task definitions config file.

## Running the Scraper

To build and run the scraper:
```bash
dotnet build
dotnet run --project src/LdswScraper -- --input-file data/tasks.toml
```

To run tests:
```bash
dotnet test
```

---

## Adding Offline or Inaccessible Vocabularies

When a vocabulary is no longer accessible on the internet but you have a local copy of its RDF definition, you can manually import it into the archive. Follow the steps below:

### 1. Define the Task
Add the task to **[data/tasks.toml](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/data/tasks.toml)**. Specify `type = "conneg"` to generate all conneg formats:
```toml
[[tasks]]
type = "conneg"
uri = "http://purl.org/NET/scovo#"
path = "scovo/scovo"
```

### 2. Determine Output Directory
The scraper organizes files alphabetically under `data/` using the first character of the task's path.
- For `path = "scovo/scovo"`, the output directory is **[data/s/scovo/](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/data/s/scovo/)**.
- Files will be generated as `scovo.ttl`, `scovo.rdf`, `scovo.nt`, `scovo.jsonld`, `scovo.nq`, `scovo.trig`, and `scovo.n3`.

### 3. Parse and Transcode the Local File
To ensure consistency and compatibility with the crawler's parsing logic, the local source file must be transcoded into all 7 supported serializations using the project's native **[RdfHandler](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/src/LdswScraper/RdfHandler.cs)**.

You can write a temporary unit test or utility method to automate this transcoding. Below is an example code snippet that parses a local `.n3` file and generates the other serializations:

```csharp
string sourceFilePath = "/path/to/your/vocabulary.n3";
string targetDir = "data/s/scovo"; // adjust accordingly
System.IO.Directory.CreateDirectory(targetDir);

byte[] originalBytes = System.IO.File.ReadAllBytes(sourceFilePath);
string content = System.Text.Encoding.UTF8.GetString(originalBytes);

// Parse the original file (e.g. text/n3)
if (RdfHandler.TryParse(content, "text/n3", out IGraph? graph, out string? error))
{
    var formats = new[]
    {
        ("text/turtle", ".ttl"),
        ("application/rdf+xml", ".rdf"),
        ("application/n-triples", ".nt"),
        ("application/ld+json", ".jsonld"),
        ("application/n-quads", ".nq"),
        ("application/trig", ".trig"),
        ("text/n3", ".n3")
    };

    foreach (var (accept, ext) in formats)
    {
        string outPath = System.IO.Path.Combine(targetDir, "scovo" + ext);
        if (ext == ".n3")
        {
            // Write original file bytes directly to preserve formatting/encoding
            System.IO.File.WriteAllBytes(outPath, originalBytes);
        }
        else
        {
            // Transcode other formats using RdfHandler
            string generated = RdfHandler.Generate(graph, accept);
            System.IO.File.WriteAllText(outPath, generated);
        }
    }
}
```

### 4. Verify & Commit
Once the files are created under **[data/](file:///Users/ezandbe/code/a/oslc/ldsw-scraper/data/)**, run `git status` to ensure they are listed in the correct paths:
```bash
git status
```
When the automated scraper is run, it will attempt to fetch the URI, fail, and output `Failed` for all formats, but it will **not** modify or delete the manually imported files.
