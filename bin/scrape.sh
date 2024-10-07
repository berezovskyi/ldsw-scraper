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

   curl "$uri" --header "Accept: text/turtle" $CURLOPT >"${outpath}.ttl" || rm "${outpath}.ttl"
   curl "$uri" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT >"${outpath}.rdf" || rm "${outpath}.rdf"
   curl "$uri" --header "Accept: application/n-triples" $CURLOPT >"${outpath}.nt" || rm "${outpath}.nt"
   curl "$uri" --header "Accept: application/n-quads" $CURLOPT >"${outpath}.nq" || rm "${outpath}.nq"
   curl "$uri" --header "Accept: application/trig" $CURLOPT >"${outpath}.trig" || rm "${outpath}.trig"
   curl "$uri" --header "Accept: application/ld+json" $CURLOPT >"${outpath}.jsonld" || rm "${outpath}.jsonld"
}

curl_try_all "https://open-services.net/ns/core" "oslc/core-vocab"
curl_try_all "https://open-services.net/ns/core/shapes/3.0" "oslc/core-shapes"

curl_try_all "https://open-services.net/ns/config" "oslc/config-vocab"
curl_try_all "https://open-services.net/ns/config/shapes/1.0/" "oslc/config-shapes"

curl_try_all "https://open-services.net/ns/core/trs" "oslc/trs-vocab"
curl_try_all "https://open-services.net/ns/trs/shapes/3.0/" "oslc/trs-shapes"
