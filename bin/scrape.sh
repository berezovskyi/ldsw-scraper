#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
CURLOPT="-L --fail --silent --show-error"

function curl_try_all() {
   uri="$1"
   path="$2"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   echo -e -n "\tTurtle   "
   { curl "$uri" --header "Accept: text/turtle" $CURLOPT >"${outpath}.ttl" && echo "✅" ; } || { rm "${outpath}.ttl" ; }
   echo -e -n "\tRDF/XML   "
   { curl "$uri" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT >"${outpath}.rdf" && echo "✅" ; } || { rm "${outpath}.rdf" ; }
   echo -e -n "\tN-Triples   "
   { curl "$uri" --header "Accept: application/n-triples" $CURLOPT >"${outpath}.nt" && echo "✅" ; } || { rm "${outpath}.nt"  ; }
   echo -e -n "\tN-Quads   "
   { curl "$uri" --header "Accept: application/n-quads" $CURLOPT >"${outpath}.nq" && echo "✅" ; } || { rm "${outpath}.nq" ; }
   echo -e -n "\tTriG   "
   { curl "$uri" --header "Accept: application/trig" $CURLOPT >"${outpath}.trig" && echo "✅" ; } || { rm "${outpath}.trig" ; }
   echo -e -n "\tJSON-LD   "
   { curl "$uri" --header "Accept: application/ld+json" $CURLOPT >"${outpath}.jsonld" && echo "✅" ; } || { rm "${outpath}.jsonld" ; }
}

function curl_try_exact() {
   uri="$1"
   path="$2"
   accept="$3"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   echo -e -n "\t${accept}   "
   { curl "$uri" --header "Accept: ${accept}" $CURLOPT >"${outpath}.ttl" && echo "✅" ; } || { rm "${outpath}.ttl" ; }
}

# TODO: handle /-ending vocab without #
# returns HTML incorrectly
# curl_try_all "http://purl.org/vocab/vann/" "x/vann"
curl_try_exact "https://purl.org/vocab/vann/vann-vocab-20100607.rdf" "x-vann/vann-vocab.rdf" "application/rdf+xml"

curl_try_all "https://open-services.net/ns/config" "oslc/config-vocab"
curl_try_all "https://open-services.net/ns/config/shapes/1.0/" "oslc/config-shapes"

curl_try_all "https://open-services.net/ns/core/trs" "oslc/trs-vocab"
curl_try_all "https://open-services.net/ns/core/trspatch" "oslc/trspatch-vocab"
curl_try_all "https://open-services.net/ns/trs/shapes/3.0/" "oslc/trs-shapes"

curl_try_all "https://open-services.net/ns/core" "oslc/core-vocab"
curl_try_all "https://open-services.net/ns/core/shapes/3.0" "oslc/core-shapes"

curl_try_all "http://www.w3.org/ns/ldp" "w3c/ldp"
curl_try_all "http://purl.org/dc/terms/" "dc/terms"