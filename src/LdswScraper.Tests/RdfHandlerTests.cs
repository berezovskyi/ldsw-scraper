using Xunit;
using LdswScraper;
using VDS.RDF;
using System.Linq;

namespace LdswScraper.Tests;

public class RdfHandlerTests
{
    [Fact]
    public void TryParse_ValidTurtle_ReturnsTrue()
    {
        string turtle = "@prefix ex: <http://example.org/> . ex:subject ex:predicate ex:object .";
        bool result = RdfHandler.TryParse(turtle, "text/turtle", out IGraph? graph, out string? error);

        Assert.True(result);
        Assert.NotNull(graph);
        Assert.Null(error);
        Assert.False(graph!.IsEmpty);
        Assert.Equal(1, graph.Triples.Count);
    }

    [Fact]
    public void TryParse_InvalidTurtle_ReturnsFalse()
    {
        string garbage = "This is not turtle";
        bool result = RdfHandler.TryParse(garbage, "text/turtle", out IGraph? graph, out string? error);

        Assert.False(result);
        Assert.Null(graph);
        Assert.NotNull(error);
    }

    [Fact]
    public void TryParse_MismatchedFormat_ReturnsFalse()
    {
        // XML content but asking for Turtle
        string xml = "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'><rdf:Description rdf:about='s'><p>o</p></rdf:Description></rdf:RDF>";
        bool result = RdfHandler.TryParse(xml, "text/turtle", out IGraph? graph, out string? error);

        // Turtle parser might fail or parse it as garbage, but likely fail.
        Assert.False(result);
    }

    [Fact]
    public void TryParse_JsonLd_ReturnsTrue()
    {
        string jsonld = "{ \"@id\": \"http://example.org/s\", \"http://example.org/p\": { \"@id\": \"http://example.org/o\" } }";
        bool result = RdfHandler.TryParse(jsonld, "application/ld+json", out IGraph? graph, out string? error);

        Assert.True(result);
        Assert.NotNull(graph);
        Assert.Equal(1, graph!.Triples.Count);
    }

    [Fact]
    public void Generate_CanTranscode()
    {
        string turtle = "@prefix ex: <http://example.org/> . ex:s ex:p ex:o .";
        RdfHandler.TryParse(turtle, "text/turtle", out IGraph? graph, out _);

        Assert.NotNull(graph);

        string nt = RdfHandler.Generate(graph!, "application/n-triples");
        Assert.Contains("<http://example.org/s> <http://example.org/p> <http://example.org/o> .", nt);
    }
}
