#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
CURLOPT="-L"
mkdir -p data/o/oslc/
curl "https://open-services.net/ns/core" --header "Accept: text/turtle" $CURLOPT > data/o/oslc/core-vocab.ttl
curl "https://open-services.net/ns/core" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT > data/o/oslc/core-vocab.rdf
curl "https://open-services.net/ns/core" --header "Accept: application/n-triples" $CURLOPT > data/o/oslc/core-vocab.nt

curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: text/turtle" $CURLOPT > data/o/oslc/core-shapes.ttl
curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT > data/o/oslc/core-shapes.rdf
curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: application/n-triples" $CURLOPT > data/o/oslc/core-shapes.nt
