#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
CURLOPT="-L --fail --silent --show-error"

function delete_if_html() {
   file_path="$1"

   mime_type=$(file --mime-type "$file_path" | awk '{print $2}')

   # Check if the MIME type is text/html
   if [ "$mime_type" = "text/html" ] || [ "$mime_type" = "text/xml" ]; then
      # Additional check for common HTML tags in the first 5 lines
      if head -n 5 "$file_path" | grep -q "<html" || head -n 5 "$file_path" | grep -q "<!DOCTYPE html"; then
         # Delete the file
         rm "$file_path"
         echo "File $file_path has been deleted because its MIME type is text/html or text/xml and it contains HTML tags in the first 5 lines."
      else
         echo "File $file_path has a MIME type of text/html or text/xml but does not contain common HTML tags in the first 5 lines. It will not be deleted."
      fi
   fi
}

function curl_try_all() {
   uri="$1"
   path="$2"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   echo -e -n "\tTurtle\t"
   { curl "$uri" --header "Accept: text/turtle" $CURLOPT >"${outpath}.ttl" && echo "✅"; } || { rm "${outpath}.ttl"; }
   delete_if_html "${outpath}.ttl"
   echo -e -n "\tRDF/XML\t"
   { curl "$uri" --header "Accept: application/rdf+xml, application/xml;q=0.1" $CURLOPT >"${outpath}.rdf" && echo "✅"; } || { rm "${outpath}.rdf"; }
   delete_if_html "${outpath}.rdf"
   echo -e -n "\tN-Triples\t"
   { curl "$uri" --header "Accept: application/n-triples" $CURLOPT >"${outpath}.nt" && echo "✅"; } || { rm "${outpath}.nt"; }
   delete_if_html "${outpath}.nt"
   echo -e -n "\tN-Quads\t"
   { curl "$uri" --header "Accept: application/n-quads" $CURLOPT >"${outpath}.nq" && echo "✅"; } || { rm "${outpath}.nq"; }
   delete_if_html "${outpath}.nq"
   echo -e -n "\tTriG\t"
   { curl "$uri" --header "Accept: application/trig" $CURLOPT >"${outpath}.trig" && echo "✅"; } || { rm "${outpath}.trig"; }
   delete_if_html "${outpath}.trig"
   echo -e -n "\tJSON-LD\t"
   { curl "$uri" --header "Accept: application/ld+json" $CURLOPT >"${outpath}.jsonld" && echo "✅"; } || { rm "${outpath}.jsonld"; }
   delete_if_html "${outpath}.jsonld"
}

function curl_try_exact() {
   uri="$1"
   path="$2"
   accept="$3"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   echo -e -n "\t${accept}\t"
   { curl "$uri" --header "Accept: ${accept}" $CURLOPT >"${outpath}" && echo "✅"; } || { rm "${outpath}"; }
   delete_if_html "${outpath}"
}


function curl_try_shex() {
   uri="$1"
   path="$2"
   outpath="data/${path:0:1}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   echo -e -n "\tShEx\t"
   { curl "$uri" --header "Accept: text/shex" $CURLOPT >"${outpath}.shex" && echo "✅"; } || { rm "${outpath}.shex"; }
   delete_if_html "${outpath}.shex"
}

curl_try_all "http://www.w3.org/ns/solid/terms" "solid/solid-terms"
curl_try_all "http://www.w3.org/ns/pim/space" "w3c/pim/space"
curl_try_all "http://www.w3.org/ns/pim/arg" "w3c/pim/arg"

# not an RDF resource
curl_try_shex "http://www.w3.org/2002/12/cal/ical" "w3c/w3c-ical/ical"
# note the typo in application/rdf+xml
# curl_try_all "https://www.w3.org/2002/12/cal/icaltzd" "w3c/w3c-ical/icaltzd.rdf"
curl_try_exact "https://www.w3.org/2002/12/cal/icaltzd" "w3c/w3c-ical/icaltzd.rdf" "applications/rdf+xml"

curl_try_all "http://www.w3.org/ns/auth/acl" "w3c/auth/WAC/acl"
curl_try_all "http://www.w3.org/ns/auth/cert" "w3c/auth/WebID-TLS/cert"
curl_try_all "http://www.w3.org/ns/posix/stat" "w3c/w3c-posix/stat"
# bad conneg
# curl_try_all "http://usefulinc.com/ns/doap" "doap/doap"
curl_try_exact "http://usefulinc.com/ns/doap" "doap/doap.rdf" "application/rdf+xml"
curl_try_all "http://purl.org/dc/elements/1.1/" "dc/elements/dc"
curl_try_all "http://www.w3.org/2007/ont/http" "w3c/w3c-ont/http"
curl_try_all "http://www.w3.org/2007/ont/httph" "w3c/w3c-ont/httph"

# bad conneg
# curl_try_all "http://www.w3.org/2004/02/skos/core" "skos/skos-core"
curl_try_exact "http://www.w3.org/2004/02/skos/core" "skos/skos-core.rdf" "application/rdf+xml"

curl_try_all "http://semweb.mmlab.be/ns/rml" "rml/rml-vocab/rml"
curl_try_all "http://semweb.mmlab.be/ns/rml-target" "rml/rml-target/rmlt"
# TODO: more here http://semweb.mmlab.be/ns/
# curl_try_all "http://semweb.mmlab.be/ns/ql" "rml/ql-vocab/ql"
curl_try_all "http://www.w3.org/ns/r2rml" "rml/r2rml-vocab/r2rml"

curl_try_all "http://open-services.net/ns/sysmlv2" "oslc/oslc-sysmlv2/sysmlv2"
# curl_try_all "http://open-services.net/ns/sysmlv2/shapes/" "oslc/sysmlv2-shapes"
curl_try_all "http://open-services.net/ns/sysmlv2/shapes/20240801" "oslc/oslc-sysmlv2/sysmlv2-shapes"

curl_try_all "https://open-services.net/ns/config" "oslc/oslc-config/config"
curl_try_all "https://open-services.net/ns/config/shapes/1.0/" "oslc/oslc-config/config-shapes"

curl_try_all "https://open-services.net/ns/core/trs" "oslc/oslc-trs/trs"
curl_try_all "https://open-services.net/ns/core/trspatch" "oslc/oslc-trs/trspatch"
curl_try_all "https://open-services.net/ns/trs/shapes/3.0/" "oslc/oslc-trs/trs-shapes"

curl_try_all "https://open-services.net/ns/core" "oslc/oslc-core/core"
curl_try_all "https://open-services.net/ns/core/shapes/3.0" "oslc/oslc-core/core-shapes"

curl_try_all "http://www.w3.org/ns/ldp" "w3c/w3c-ldp"
curl_try_all "http://purl.org/dc/terms/" "dc/terms/dcterms"

# TODO: handle /-ending vocab without #
# returns HTML incorrectly
# curl_try_all "http://purl.org/vocab/vann/" "x/vann"
curl_try_exact "https://purl.org/vocab/vann/vann-vocab-20100607.rdf" "vann/vann-vocab.rdf" "application/rdf+xml"

curl_try_all "http://xmlns.com/foaf/0.1/" "foaf/foaf"
# curl_try_single "http://xmlns.com/foaf/spec/index.rdf" "foaf/foaf"

curl_try_all "http://www.w3.org/1999/02/22-rdf-syntax-ns" "w3c/rdf/rdf"
curl_try_all "http://www.w3.org/2000/01/rdf-schema" "w3c/rdf/rdfs"
