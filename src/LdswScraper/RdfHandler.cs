using System;
using System.IO;
using System.Linq;
using VDS.RDF;
using VDS.RDF.Parsing;
using VDS.RDF.Writing;

namespace LdswScraper;

public class RdfHandler
{
    public static bool TryParse(string content, string format, out IGraph? graph, out string? error)
    {
        graph = new Graph();
        try
        {
            var parser = GetReader(format);
            // Some parsers are IStoreReader (like JsonLdParser, NQuadsParser, TriGParser)
            // others are IRdfReader (TurtleParser, RdfXmlParser, NTriplesParser, Notation3Parser)

            if (parser is IRdfReader rdfReader)
            {
                rdfReader.Load(graph, new System.IO.StringReader(content));
            }
            else if (parser is IStoreReader storeReader)
            {
                // Store readers read into a TripleStore
                var store = new TripleStore();
                storeReader.Load(store, new System.IO.StringReader(content));

                // If the store has graphs, merge them or pick the default one
                if (store.Graphs.Any())
                {
                    // Merge all graphs into one for simplicity, or just pick the default one?
                    // conneg tasks usually fetch a single resource (graph)
                    // NQuads/TriG can have multiple graphs.
                    // We'll merge them into the output graph.
                    foreach (var g in store.Graphs)
                    {
                        graph.Merge(g);
                    }
                }
            }
            else
            {
                throw new InvalidOperationException("Unknown parser type");
            }

            error = null;
            return true;
        }
        catch (Exception ex)
        {
            graph = null;
            error = ex.Message;
            return false;
        }
    }

    public static string Generate(IGraph graph, string format)
    {
        var writer = GetWriter(format);
        using var sw = new System.IO.StringWriter();

        if (writer is IRdfWriter rdfWriter)
        {
            rdfWriter.Save(graph, sw);
        }
        else if (writer is IStoreWriter storeWriter)
        {
            var store = new TripleStore();
            store.Add(graph);
            storeWriter.Save(store, sw);
        }
         else
        {
            throw new InvalidOperationException("Unknown writer type");
        }

        return sw.ToString();
    }

    private static object GetReader(string format)
    {
        return format.ToLowerInvariant() switch
        {
            "turtle" or "text/turtle" or ".ttl" => new TurtleParser(),
            "rdfxml" or "rdf/xml" or "application/rdf+xml" or ".rdf" or ".xml" => new RdfXmlParser(),
            "ntriples" or "n-triples" or "application/n-triples" or ".nt" => new NTriplesParser(),
            "jsonld" or "json-ld" or "application/ld+json" or ".jsonld" => new JsonLdParser(),
            "nquads" or "n-quads" or "application/n-quads" or ".nq" => new NQuadsParser(),
            "trig" or "application/trig" or ".trig" => new TriGParser(),
            "n3" or "text/n3" or ".n3" => new Notation3Parser(),
            _ => throw new NotSupportedException($"Format '{format}' is not supported.")
        };
    }

    private static object GetWriter(string format)
    {
        return format.ToLowerInvariant() switch
        {
            "turtle" or "text/turtle" or ".ttl" => new CompressingTurtleWriter(),
            "rdfxml" or "rdf/xml" or "application/rdf+xml" or ".rdf" or ".xml" => new RdfXmlWriter(),
            "ntriples" or "n-triples" or "application/n-triples" or ".nt" => new NTriplesWriter(),
            "jsonld" or "json-ld" or "application/ld+json" or ".jsonld" => new JsonLdWriter(),
            "nquads" or "n-quads" or "application/n-quads" or ".nq" => new NQuadsWriter(),
            "trig" or "application/trig" or ".trig" => new TriGWriter(),
            "n3" or "text/n3" or ".n3" => new Notation3Writer(),
            _ => throw new NotSupportedException($"Format '{format}' is not supported.")
        };
    }

    public static string GetExtension(string mimeType)
    {
         return mimeType.ToLowerInvariant() switch
        {
            "text/turtle" => ".ttl",
            "application/rdf+xml" or "application/xml" => ".rdf",
            "application/n-triples" => ".nt",
            "application/ld+json" => ".jsonld",
            "application/n-quads" => ".nq",
            "application/trig" => ".trig",
            "text/n3" => ".n3",
            "text/shex" => ".shex",
            _ => ".dat"
        };
    }
}
