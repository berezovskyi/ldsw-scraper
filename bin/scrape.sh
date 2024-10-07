#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
CURLOPT="-L --fail"

function curl_try_all() {
   uri="$1"
   path="$2"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   curl "$uri" --header "Accept: text/turtle" $CURLOPT > "${outpath}.ttl" || rm "${outpath}.ttl"
   curl "$uri" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT "${outpath}.rdf" || rm "${outpath}.rdf"
   curl "$uri" --header "Accept: application/n-triples" $CURLOPT >"${outpath}.nt" || "${outpath}.nt"
   curl "$uri" --header "Accept: application/n-quads" $CURLOPT >"${outpath}.nq" || "${outpath}.nq"
   curl "$uri" --header "Accept: application/trig" $CURLOPT >"${outpath}.trig" || "${outpath}.trig"
}

mkdir -p data/o/oslc/
curl_try_all "https://open-services.net/ns/core" "oslc/core-vocab"
# curl "https://open-services.net/ns/core" --header "Accept: text/turtle" $CURLOPT >data/o/oslc/core-vocab.ttl
# curl "https://open-services.net/ns/core" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT >data/o/oslc/core-vocab.rdf
# curl "https://open-services.net/ns/core" --header "Accept: application/n-triples" $CURLOPT >data/o/oslc/core-vocab.nt
# curl "https://open-services.net/ns/core" --header "Accept: application/n-quads" $CURLOPT >data/o/oslc/core-vocab.nq

curl_try_all "https://open-services.net/ns/core/shapes/3.0" "oslc/core-shapes"
# curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: text/turtle" $CURLOPT >data/o/oslc/core-shapes.ttl
# curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT >data/o/oslc/core-shapes.rdf
# curl "https://open-services.net/ns/core/shapes/3.0" --header "Accept: application/n-triples" $CURLOPT >data/o/oslc/core-shapes.nt
