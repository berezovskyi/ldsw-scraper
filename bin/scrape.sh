#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
# CURLOPT="-L --fail --silent --show-error"
CURLOPT="-L --connect-timeout 7 --fail --silent -w %{stderr}%{http_code}"

main() {

   # curl_conneg_all 'https://search.bsdd.buildingsmart.org/uri/buildingsmart/ifc/4.3' 'ifcOWL/IFC/4.3/ifc'
   curl_get_exact 'https://standards.buildingsmart.org/IFC/DEV/IFC4/ADD2_TC1/OWL/ontology.ttl' 'ifcOWL/IFC/4.2/ifc.ttl' 'text/turtle' 
   curl_get_exact 'https://standards.buildingsmart.org/IFC/DEV/IFC4/ADD2_TC1/OWL/ontology.xml' 'ifcOWL/IFC/4.2/ifc.rdf' 'application/rdf+xml'

   curl_conneg_all 'http://w3id.org/express#' 'ifcOWL/express'
   curl_conneg_all 'http://w3id.org/list#' 'ifcOWL/list'

   curl_conneg_all 'http://jazz.net/ns/dcs#' 'oslc/jazz/dcs'
   curl_conneg_all 'http://jazz.net/ns/mec#' 'oslc/jazz/mec'
   curl_conneg_all 'http://jazz.net/ns/enterprise_agile#' 'oslc/jazz/enterprise_agile'
   curl_conneg_all 'http://jazz.net/ns/functional_safety#' 'oslc/jazz/functional_safety'
   curl_conneg_all 'http://jazz.net/ns/aspice#' 'oslc/jazz/aspice'
   curl_conneg_all 'http://jazz.net/ns/discovery#' 'oslc/jazz/discovery'
   curl_conneg_all 'http://jazz.net/ns/sse#' 'oslc/jazz/sse'
   curl_conneg_all 'http://jazz.net/ns/process/shapes/Iteration' 'oslc/jazz/process_shapes_Iteration'
   curl_conneg_all 'http://jazz.net/ns/process#' 'oslc/jazz/process'
   curl_conneg_all 'http://jazz.net/ns/process/shapes/ProjectArea' 'oslc/jazz/process_shapes_ProjectArea'
   curl_conneg_all 'http://jazz.net/ns/process/shapes/TeamArea' 'oslc/jazz/process_shapes_TeamArea'
   curl_conneg_all 'http://jazz.net/ns/process/shapes/Timeline' 'oslc/jazz/process_shapes_Timeline'
   curl_conneg_all 'http://jazz.net/ns/validity#' 'oslc/jazz/validity'
   curl_conneg_all 'http://jazz.net/ns/ccm#' 'oslc/jazz/ccm'
   curl_conneg_all 'http://jazz.net/ns/dm/diagram#' 'oslc/jazz/dm_diagram'
   curl_conneg_all 'http://jazz.net/ns/dm/document#' 'oslc/jazz/dm_document'
   curl_conneg_all 'http://jazz.net/ns/dm/linktypes#' 'oslc/jazz/dm_linktypes'
   curl_conneg_all 'http://jazz.net/ns/dm/sketcher#' 'oslc/jazz/dm_sketcher'
   curl_conneg_all 'http://jazz.net/ns/pd/extensions#' 'oslc/jazz/pd_extensions'
   curl_conneg_all 'http://jazz.net/ns/psm/focalpoint/datatypes#' 'oslc/jazz/psm_focalpoint_datatypes'
   curl_conneg_all 'http://jazz.net/ns/psm/focalpoint#' 'oslc/jazz/psm_focalpoint'
   curl_conneg_all 'http://jazz.net/ns/pd#' 'oslc/jazz/pd'
   curl_conneg_all 'http://jazz.net/ns/qm/rqm#' 'oslc/jazz/qm_rqm'
   curl_conneg_all 'http://jazz.net/ns/rm/linktypes#' 'oslc/jazz/rm_linktypes'
   curl_conneg_all 'http://jazz.net/ns/rm#' 'oslc/jazz/rm'
   curl_conneg_all 'http://jazz.net/ns/dm/rhapsody/sysml#' 'oslc/jazz/dm_rhapsody_sysml'
   curl_conneg_all 'http://jazz.net/ns/dm/rhapsody/testing#' 'oslc/jazz/dm_rhapsody_testing'
   curl_conneg_all 'http://jazz.net/ns/dm/rhapsody/uml#' 'oslc/jazz/dm_rhapsody_uml'
   curl_conneg_all 'http://jazz.net/ns/dm/rsa/deployment/core#' 'oslc/jazz/dm_rsa_deployment_core'
   curl_conneg_all 'http://jazz.net/ns/dm/rsa/uml#' 'oslc/jazz/dm_rsa_uml'
   curl_conneg_all 'http://jazz.net/ns/reporting/sparqlgateway#' 'oslc/jazz/reporting_sparqlgateway'
   curl_conneg_all 'http://jazz.net/ns/rtc/scm/config#' 'oslc/jazz/rtc_scm_config'
   curl_conneg_all 'http://jazz.net/ns/qm/rtcp#' 'oslc/jazz/qm_rtcp'
   curl_conneg_all 'http://jazz.net/ns/reporting/data/dictionary#' 'oslc/jazz/reporting_data_dictionary'
   curl_conneg_all 'http://jazz.net/ns/am/rmm#' 'oslc/jazz/am_rmm'
   curl_conneg_all 'http://jazz.net/ns/scm#' 'oslc/jazz/scm'
   curl_conneg_all 'http://jazz.net/ns/dm/rhapsody/HarmonySE#' 'oslc/jazz/dm_rhapsody_HarmonySE'
   curl_conneg_all 'http://jazz.net/ns/qm/rqm/labmanagement#' 'oslc/jazz/qm_rqm_labmanagement'
   curl_conneg_all 'http://jazz.net/ns/dm/rhapsody/UPDM2_MODAF#' 'oslc/jazz/dm_rhapsody_UPDM2_MODAF'
   curl_conneg_all 'http://jazz.net/ns/ism/admin/health#' 'oslc/jazz/ism_admin_health'
   curl_conneg_all 'http://jazz.net/ns/ism/admin#' 'oslc/jazz/ism_admin'
   curl_conneg_all 'http://jazz.net/ns/ism/perfmon/tt#' 'oslc/jazz/ism_perfmon_tt'
   curl_conneg_all 'http://jazz.net/ns/ism/perfmon/itm#' 'oslc/jazz/ism_perfmon_itm'
   curl_conneg_all 'http://jazz.net/ns/ism/event/omnibus#' 'oslc/jazz/ism_event_omnibus'
   curl_conneg_all 'http://jazz.net/ns/ism/event/omnibus/itnm#' 'oslc/jazz/ism_event_omnibus_itnm'
   curl_conneg_all 'http://jazz.net/ns/ism/event/omnibus/misc#' 'oslc/jazz/ism_event_omnibus_misc'
   curl_conneg_all 'http://jazz.net/ns/ism/event/omnibus/tbsm#' 'oslc/jazz/ism_event_omnibus_tbsm'
   curl_conneg_all 'http://jazz.net/ns/ism/registry#' 'oslc/jazz/ism_registry'

   curl_conneg_all "http://www.w3.org/ns/csvw" "w3c/CVSW/csvw"

   # apparently, LDN spec added a prop to LDP
   curl_conneg_all "https://www.w3.org/ns/ldp" "w3c/LDP/ldp"

   curl_conneg_all "https://www.w3.org/ns/activitystreams" "w3c/ActivityStreams/as"

   curl_conneg_all "http://purl.org/NET/scovo#" "scovo/scovo"
   # curl_conneg_all "http://vocab.deri.ie/scovo" "scovo/scovo"

   curl_get_exact "http://purl.org/linked-data/cube#" "w3c/Data-Cube/qb.ttl" "text/turtle"
   curl_conneg_all "https://www.w3.org/ns/org#" "w3c/org/org"

   # bad conneg
   # curl_conneg_all "http://purl.org/goodrelations/v1" "goodrelations/goodrelations"
   curl_get_exact "http://purl.org/goodrelations/v1" "goodrelations/goodrelations.rdf" "application/rdf+xml"

   curl_get_exact "https://spec.ottr.xyz/wOTTR/0.4.5/all.owl.ttl" "OTTR/all.owl.ttl" "text/turtle"
   curl_get_exact "http://spec.ottr.xyz/wOTTR/0.4/core-vocabulary.owl.ttl" "OTTR/core-vocabulary.owl.ttl" "text/turtle"
   curl_get_exact "http://spec.ottr.xyz/wOTTR/0.4/core-grammar.shacl.ttl" "OTTR/core-grammar.shacl.ttl" "text/turtle"
   curl_get_exact "http://spec.ottr.xyz/rOTTR/0.2/types.owl.ttl" "OTTR/types.owl.ttl" "text/turtle"
   curl_get_exact "http://spec.ottr.xyz/rOTTR/0.2/types.shacl.ttl" "OTTR/types.shacl.ttl" "text/turtle"
   curl_get_exact "http://spec.ottr.xyz/rOTTR/0.2/puntypes.shacl.ttl" "OTTR/puntypes.shacl.ttl" "text/turtle"

   curl_get_exact "http://vocab.org/waiver/vocab.rdf" "WAIVER/waiver.rdf" "application/rdf+xml"

   curl_conneg_all "https://www.w3.org/ns/sparql-service-description" "w3c/SPARQL-SD/sd"
   
   curl_conneg_all "http://rdfs.org/ns/void" "w3c/VoID/void"
   curl_conneg_all "http://www.w3.org/ns/prov-o" "w3c/PROV/prov-o"
   curl_conneg_all "http://www.w3.org/ns/prov" "w3c/PROV/prov"
   curl_conneg_all "http://www.w3.org/ns/adms" "w3c/ADMS/adms"

   curl_conneg_all "http://rds.posccaesar.org/ontology/lis14/ont/core" "Industrial-Data-Ontology/ido-core"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/core" "Industrial-Data-Ontology/plm-core"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/chebi-adapt" "Industrial-Data-Ontology/plm-chebi"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/process" "Industrial-Data-Ontology/plm-process"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/equipment" "Industrial-Data-Ontology/plm-equipment"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/uom" "Industrial-Data-Ontology/plm-uom"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/datasheet" "Industrial-Data-Ontology/plm-datasheet"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/norsok-z001" "Industrial-Data-Ontology/plm-norsok-z001"
   curl_conneg_all "http://rds.posccaesar.org/ontology/plm/ont/core-collect" "Industrial-Data-Ontology/plm-core-collect"

   # curl_conneg_all "http://xmlns.com/wordnet/1.6" "wordnet/wordnet"
   curl_get_exact "https://www.w3.org/2006/03/wn/wn20/schemas/wnfull.rdfs" "wordnet/wnfull.rdf" "application/rdf+xml"

   curl_get_exact "https://raw.githubusercontent.com/BFO-ontology/BFO/v2.0/bfo.owl" "Basic-Formal-Ontology/bfo.rdf" "application/rdf+xml"

   # no conneg
   # curl_conneg_all "http://xmlns.com/wot/0.1/" "web-of-trust/wot"
   curl_get_exact "http://xmlns.com/wot/0.1/index.rdf" "web-of-trust/wot.rdf" "application/rdf+xml"

   curl_conneg_all "http://www.w3.org/ns/solid/terms" "solid/solid-terms"
   curl_conneg_all "http://www.w3.org/ns/pim/space" "w3c/pim/space"
   curl_conneg_all "http://www.w3.org/ns/pim/arg" "w3c/pim/arg"

   # not an RDF resource
   curl_try_shex "http://www.w3.org/2002/12/cal/ical" "w3c/w3c-ical/ical"
   # note the typo in application/rdf+xml
   # curl_conneg_all "https://www.w3.org/2002/12/cal/icaltzd" "w3c/w3c-ical/icaltzd.rdf"
   curl_get_exact "https://www.w3.org/2002/12/cal/icaltzd" "w3c/w3c-ical/icaltzd.rdf" "applications/rdf+xml"

   curl_conneg_all "http://www.w3.org/ns/auth/acl" "w3c/auth/WAC/acl"
   curl_conneg_all "http://www.w3.org/ns/auth/cert" "w3c/auth/WebID-TLS/cert"
   curl_conneg_all "http://www.w3.org/ns/posix/stat" "w3c/w3c-posix/stat"
   # bad conneg
   # curl_conneg_all "http://usefulinc.com/ns/doap" "doap/doap"
   curl_get_exact "http://usefulinc.com/ns/doap" "doap/doap.rdf" "application/rdf+xml"
   curl_conneg_all "http://purl.org/dc/elements/1.1/" "dc/elements/dc"
   curl_conneg_all "http://www.w3.org/2007/ont/http" "w3c/w3c-ont/http"
   curl_conneg_all "http://www.w3.org/2007/ont/httph" "w3c/w3c-ont/httph"

   # bad conneg
   # curl_conneg_all "http://www.w3.org/2004/02/skos/core" "skos/skos-core"
   curl_get_exact "http://www.w3.org/2004/02/skos/core" "skos/skos-core.rdf" "application/rdf+xml"

   curl_conneg_all "http://semweb.mmlab.be/ns/rml" "rml/rml-vocab/rml"
   curl_conneg_all "http://semweb.mmlab.be/ns/rml-target" "rml/rml-target/rmlt"
   # TODO: more here http://semweb.mmlab.be/ns/
   # curl_conneg_all "http://semweb.mmlab.be/ns/ql" "rml/ql-vocab/ql"
   curl_conneg_all "http://www.w3.org/ns/r2rml" "rml/r2rml-vocab/r2rml"

   curl_conneg_all "http://open-services.net/ns/sysmlv2" "oslc/oslc-sysmlv2/sysmlv2"
   # curl_conneg_all "http://open-services.net/ns/sysmlv2/shapes/" "oslc/sysmlv2-shapes"
   curl_conneg_all "http://open-services.net/ns/sysmlv2/shapes/20240801" "oslc/oslc-sysmlv2/sysmlv2-shapes"

   curl_conneg_all "https://open-services.net/ns/config" "oslc/oslc-config/config"
   curl_conneg_all "https://open-services.net/ns/config/shapes/1.0/" "oslc/oslc-config/config-shapes"

   curl_conneg_all "https://open-services.net/ns/core/trs" "oslc/oslc-trs/trs"
   curl_conneg_all "https://open-services.net/ns/core/trspatch" "oslc/oslc-trs/trspatch"
   curl_conneg_all "https://open-services.net/ns/trs/shapes/3.0/" "oslc/oslc-trs/trs-shapes"

   curl_conneg_all "https://open-services.net/ns/core" "oslc/oslc-core/core"
   curl_conneg_all "https://open-services.net/ns/core/shapes/3.0" "oslc/oslc-core/core-shapes"

   curl_conneg_all "http://purl.org/dc/terms/" "dc/terms/dcterms"

   # TODO: handle /-ending vocab without #
   # returns HTML incorrectly
   # curl_conneg_all "http://purl.org/vocab/vann/" "x/vann"
   curl_get_exact "https://purl.org/vocab/vann/vann-vocab-20100607.rdf" "vann/vann-vocab.rdf" "application/rdf+xml"

   curl_conneg_all "http://xmlns.com/foaf/0.1/" "foaf/foaf"
   # curl_try_single "http://xmlns.com/foaf/spec/index.rdf" "foaf/foaf"

   curl_conneg_all "http://www.w3.org/1999/02/22-rdf-syntax-ns" "w3c/rdf/rdf"
   curl_conneg_all "http://www.w3.org/2000/01/rdf-schema" "w3c/rdf/rdfs"
   curl_conneg_all "http://www.w3.org/2002/07/owl#" "w3c/owl"

}

function sleep_ci() {
   # we are not in a rush
   # but 3s increases CI runs 10x

   if [ ! -z ${CI+x} ]; then sleep 0.1; fi
}

function delete_if_html() {
   file_path="$1"

   mime_type=$(file --mime-type "$file_path" | awk '{print $2}')

   # Check if the MIME type is text/html
   if [ "$mime_type" = "text/html" ] || [ "$mime_type" = "text/xml" ]; then
      # Additional check for common HTML tags in the first 5 lines
      if head -n 5 "$file_path" | grep -q "<html" || head -n 5 "$file_path" | grep -q "<!DOCTYPE html"; then
         # Delete the file
         rm "$file_path"
         echo -n " (deleted - HTML detected)"
         # echo "File $file_path has been deleted because its MIME type is text/html or text/xml and it contains HTML tags in the first 5 lines."
      # else
         # echo
         # echo "File $file_path has a MIME type of text/html or text/xml but does not contain common HTML tags in the first 5 lines. It will not be deleted."
      fi
   fi
}

function curl_safe() {
   outpath="$1"
   accept="$2"
   ext="$3"
   name="$4"

   echo -e -n "\t${name}\t"
   # use a temp file to avoid deleting ontologies when endpoints are down
   # and to avoid clobbering
   # TODO: consider clobbering on 404 to make it visible in the history - bad UX
   { curl "$uri" --header "Accept: ${accept}" $CURLOPT >"${outpath}${ext}.tmp" ; } || { rm -f "${outpath}${ext}.tmp"; }
   delete_if_html "${outpath}${ext}.tmp"
   if [ -s "${outpath}${ext}.tmp" ]; then
      mv "${outpath}${ext}.tmp" "${outpath}${ext}"
      echo -n " ✅";
   else
      rm -f "${outpath}${ext}.tmp"
   fi
   echo
}

function curl_conneg_all() {
   uri="$1"
   path="$2"
   firstchar="${path:0:1}"
   outpath="data/${firstchar,,}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   curl_safe "${outpath}" "text/turtle" ".ttl" "Turtle"
   sleep_ci

   curl_safe "${outpath}" "application/rdf+xml, application/xml;q=0.1" ".rdf" "RDF/XML"
   sleep_ci

   curl_safe "${outpath}" "application/n-triples" ".nt" "N-Tripl"
   sleep_ci

   curl_safe "${outpath}" "application/ld+json" ".jsonld" "JSON-LD"
   sleep_ci

   curl_safe "${outpath}" "application/n-quads" ".nq" "N-Quads"
   sleep_ci

   curl_safe "${outpath}" "application/trig" ".trig" "TriG"
   sleep_ci

   curl_safe "${outpath}" "text/n3" ".n3" "N3"
}

function curl_get_exact() {
   uri="$1"
   path="$2"
   accept="$3"
   firstchar="${path:0:1}"
   outpath="data/${firstchar,,}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   curl_safe "${outpath}" "${accept}" "" "${accept}"
}

function curl_try_shex() {
   uri="$1"
   path="$2"
   firstchar="${path:0:1}"
   outpath="data/${firstchar,,}/${path}"
   outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path}"

   curl_safe "${outpath}" "text/shex" ".shex" "ShEx"
}

main "$@"; exit
