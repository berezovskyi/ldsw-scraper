#!/usr/bin/env bash
# set -e
set -uo pipefail
# set -x

# "Accept: text/turtle, application/trig, application/rdf+xml;q=0.9, application/ld+json;q=0.9, application/n-triples;q=0.5, application/n-quads;q=0.5"
# CURLOPT="-L --fail --silent --show-error"
CURLOPT="-L --connect-timeout 5 --max-time 10 --fail --silent -w %{stderr}%{http_code}"
PARALLEL_JOBS=16

# Define scrape_tasks array - FULL LIST
# Each element is a pipe-separated string: "type|uri|path[|accept_header]"
scrape_tasks_full=(
  "conneg|http://jazz.net/ns/dcs#|oslc/jazz/dcs"
  "conneg|http://www.w3.org/ns/prov-o|w3c/PROV/prov-o"
  "exact|https://standards.buildingsmart.org/IFC/DEV/IFC4/ADD2_TC1/OWL/ontology.ttl|ifcOWL/IFC/4.2/ifc.ttl|text/turtle"
  "exact|https://standards.buildingsmart.org/IFC/DEV/IFC4/ADD2_TC1/OWL/ontology.xml|ifcOWL/IFC/4.2/ifc.rdf|application/rdf+xml"
  "conneg|http://w3id.org/express#|ifcOWL/express"
  "conneg|http://w3id.org/list#|ifcOWL/list"
  "conneg|http://qudt.org/schema/qudt|qudt/qudt"
  "conneg|http://qudt.org/2.1/schema/shacl/qudt|qudt/shacl/qudt"
  "conneg|http://qudt.org/2.1/schema/shacl/datatype|qudt/shacl/qudt_datatype"
  "conneg|http://qudt.org/2.1/schema/shacl/overlay/qudt|qudt/shacl/qudt_overlay"
  "conneg|http://www.linkedmodel.org/schema/dtype|qudt/linkedmodels_dtype/dtype"
  "conneg|http://www.linkedmodel.org/schema/vaem|qudt/linkedmodels_vaem/vaem"
  "conneg|http://jazz.net/ns/mec#|oslc/jazz/mec"
  "conneg|http://jazz.net/ns/enterprise_agile#|oslc/jazz/enterprise_agile"
  "conneg|http://jazz.net/ns/functional_safety#|oslc/jazz/functional_safety"
  "conneg|http://jazz.net/ns/aspice#|oslc/jazz/aspice"
  "conneg|http://jazz.net/ns/discovery#|oslc/jazz/discovery"
  "conneg|http://jazz.net/ns/sse#|oslc/jazz/sse"
  "conneg|http://jazz.net/ns/process/shapes/Iteration|oslc/jazz/process_shapes_Iteration"
  "conneg|http://jazz.net/ns/process#|oslc/jazz/process"
  "conneg|http://jazz.net/ns/process/shapes/ProjectArea|oslc/jazz/process_shapes_ProjectArea"
  "conneg|http://jazz.net/ns/process/shapes/TeamArea|oslc/jazz/process_shapes_TeamArea"
  "conneg|http://jazz.net/ns/process/shapes/Timeline|oslc/jazz/process_shapes_Timeline"
  "conneg|http://jazz.net/ns/validity#|oslc/jazz/validity"
  "conneg|http://jazz.net/ns/ccm#|oslc/jazz/ccm"
  "conneg|http://jazz.net/ns/dm/diagram#|oslc/jazz/dm_diagram"
  "conneg|http://jazz.net/ns/dm/document#|oslc/jazz/dm_document"
  "conneg|http://jazz.net/ns/dm/linktypes#|oslc/jazz/dm_linktypes"
  "conneg|http://jazz.net/ns/dm/sketcher#|oslc/jazz/dm_sketcher"
  "conneg|http://jazz.net/ns/pd/extensions#|oslc/jazz/pd_extensions"
  "conneg|http://jazz.net/ns/psm/focalpoint/datatypes#|oslc/jazz/psm_focalpoint_datatypes"
  "conneg|http://jazz.net/ns/psm/focalpoint#|oslc/jazz/psm_focalpoint"
  "conneg|http://jazz.net/ns/pd#|oslc/jazz/pd"
  "conneg|http://jazz.net/ns/qm/rqm#|oslc/jazz/qm_rqm"
  "conneg|http://jazz.net/ns/rm/linktypes#|oslc/jazz/rm_linktypes"
  "conneg|http://jazz.net/ns/rm#|oslc/jazz/rm"
  "conneg|http://jazz.net/ns/dm/rhapsody/sysml#|oslc/jazz/dm_rhapsody_sysml"
  "conneg|http://jazz.net/ns/dm/rhapsody/testing#|oslc/jazz/dm_rhapsody_testing"
  "conneg|http://jazz.net/ns/dm/rhapsody/uml#|oslc/jazz/dm_rhapsody_uml"
  "conneg|http://jazz.net/ns/dm/rsa/deployment/core#|oslc/jazz/dm_rsa_deployment_core"
  "conneg|http://jazz.net/ns/dm/rsa/uml#|oslc/jazz/dm_rsa_uml"
  "conneg|http://jazz.net/ns/reporting/sparqlgateway#|oslc/jazz/reporting_sparqlgateway"
  "conneg|http://jazz.net/ns/rtc/scm/config#|oslc/jazz/rtc_scm_config"
  "conneg|http://jazz.net/ns/qm/rtcp#|oslc/jazz/qm_rtcp"
  "conneg|http://jazz.net/ns/reporting/data/dictionary#|oslc/jazz/reporting_data_dictionary"
  "conneg|http://jazz.net/ns/am/rmm#|oslc/jazz/am_rmm"
  "conneg|http://jazz.net/ns/scm#|oslc/jazz/scm"
  "conneg|http://jazz.net/ns/dm/rhapsody/HarmonySE#|oslc/jazz/dm_rhapsody_HarmonySE"
  "conneg|http://jazz.net/ns/qm/rqm/labmanagement#|oslc/jazz/qm_rqm_labmanagement"
  "conneg|http://jazz.net/ns/dm/rhapsody/UPDM2_MODAF#|oslc/jazz/dm_rhapsody_UPDM2_MODAF"
  "conneg|http://jazz.net/ns/ism/admin/health#|oslc/jazz/ism_admin_health"
  "conneg|http://jazz.net/ns/ism/admin#|oslc/jazz/ism_admin"
  "conneg|http://jazz.net/ns/ism/perfmon/tt#|oslc/jazz/ism_perfmon_tt"
  "conneg|http://jazz.net/ns/ism/perfmon/itm#|oslc/jazz/ism_perfmon_itm"
  "conneg|http://jazz.net/ns/ism/event/omnibus#|oslc/jazz/ism_event_omnibus"
  "conneg|http://jazz.net/ns/ism/event/omnibus/itnm#|oslc/jazz/ism_event_omnibus_itnm"
  "conneg|http://jazz.net/ns/ism/event/omnibus/misc#|oslc/jazz/ism_event_omnibus_misc"
  "conneg|http://jazz.net/ns/ism/event/omnibus/tbsm#|oslc/jazz/ism_event_omnibus_tbsm"
  "conneg|http://jazz.net/ns/ism/registry#|oslc/jazz/ism_registry"
  "conneg|http://www.w3.org/ns/csvw|w3c/CVSW/csvw"
  "conneg|https://www.w3.org/ns/ldp|w3c/LDP/ldp"
  "conneg|https://www.w3.org/ns/activitystreams|w3c/ActivityStreams/as"
  "conneg|http://purl.org/NET/scovo#|scovo/scovo"
  "exact|http://purl.org/linked-data/cube#|w3c/Data-Cube/qb.ttl|text/turtle"
  "conneg|https://www.w3.org/ns/org#|w3c/org/org"
  "exact|http://purl.org/goodrelations/v1|goodrelations/goodrelations.rdf|application/rdf+xml"
  "exact|https://spec.ottr.xyz/wOTTR/0.4.5/all.owl.ttl|OTTR/all.owl.ttl|text/turtle"
  "exact|http://spec.ottr.xyz/wOTTR/0.4/core-vocabulary.owl.ttl|OTTR/core-vocabulary.owl.ttl|text/turtle"
  "exact|http://spec.ottr.xyz/wOTTR/0.4/core-grammar.shacl.ttl|OTTR/core-grammar.shacl.ttl|text/turtle"
  "exact|http://spec.ottr.xyz/rOTTR/0.2/types.owl.ttl|OTTR/types.owl.ttl|text/turtle"
  "exact|http://spec.ottr.xyz/rOTTR/0.2/types.shacl.ttl|OTTR/types.shacl.ttl|text/turtle"
  "exact|http://spec.ottr.xyz/rOTTR/0.2/puntypes.shacl.ttl|OTTR/puntypes.shacl.ttl|text/turtle"
  "exact|http://vocab.org/waiver/vocab.rdf|WAIVER/waiver.rdf|application/rdf+xml"
  "conneg|https://www.w3.org/ns/sparql-service-description|w3c/SPARQL-SD/sd"
  "conneg|http://rdfs.org/ns/void|w3c/VoID/void"
  "conneg|http://www.w3.org/ns/prov|w3c/PROV/prov"
  "conneg|http://www.w3.org/ns/adms|w3c/ADMS/adms"
  "conneg|http://rds.posccaesar.org/ontology/lis14/ont/core|Industrial-Data-Ontology/ido-core"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/core|Industrial-Data-Ontology/plm-core"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/chebi-adapt|Industrial-Data-Ontology/plm-chebi"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/process|Industrial-Data-Ontology/plm-process"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/equipment|Industrial-Data-Ontology/plm-equipment"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/uom|Industrial-Data-Ontology/plm-uom"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/datasheet|Industrial-Data-Ontology/plm-datasheet"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/norsok-z001|Industrial-Data-Ontology/plm-norsok-z001"
  "conneg|http://rds.posccaesar.org/ontology/plm/ont/core-collect|Industrial-Data-Ontology/plm-core-collect"
  "exact|https://www.w3.org/2006/03/wn/wn20/schemas/wnfull.rdfs|wordnet/wnfull.rdf|application/rdf+xml"
  "exact|https://raw.githubusercontent.com/BFO-ontology/BFO/v2.0/bfo.owl|Basic-Formal-Ontology/bfo.rdf|application/rdf+xml"
  "exact|http://xmlns.com/wot/0.1/index.rdf|web-of-trust/wot.rdf|application/rdf+xml"
  "conneg|http://www.w3.org/ns/solid/terms|solid/solid-terms"
  "conneg|http://www.w3.org/ns/pim/space|w3c/pim/space"
  "conneg|http://www.w3.org/ns/pim/arg|w3c/pim/arg"
  "shex|http://www.w3.org/2002/12/cal/ical|w3c/w3c-ical/ical"
  "exact|https://www.w3.org/2002/12/cal/icaltzd|w3c/w3c-ical/icaltzd.rdf|applications/rdf+xml"
  "conneg|http://www.w3.org/ns/auth/acl|w3c/auth/WAC/acl"
  "conneg|http://www.w3.org/ns/auth/cert|w3c/auth/WebID-TLS/cert"
  "conneg|http://www.w3.org/ns/posix/stat|w3c/w3c-posix/stat"
  "exact|http://usefulinc.com/ns/doap|doap/doap.rdf|application/rdf+xml"
  "conneg|http://purl.org/dc/elements/1.1/|dc/elements/dc"
  "conneg|http://www.w3.org/2007/ont/http|w3c/w3c-ont/http"
  "conneg|http://www.w3.org/2007/ont/httph|w3c/w3c-ont/httph"
  "exact|http://www.w3.org/2004/02/skos/core|skos/skos-core.rdf|application/rdf+xml"
  "conneg|http://semweb.mmlab.be/ns/rml|rml/rml-vocab/rml"
  "conneg|http://semweb.mmlab.be/ns/rml-target|rml/rml-target/rmlt"
  "conneg|http://www.w3.org/ns/r2rml|rml/r2rml-vocab/r2rml"
  "conneg|http://open-services.net/ns/sysmlv2|oslc/oslc-sysmlv2/sysmlv2"
  "conneg|http://open-services.net/ns/sysmlv2/shapes/20240801|oslc/oslc-sysmlv2/sysmlv2-shapes"
  "conneg|https://open-services.net/ns/config|oslc/oslc-config/config"
  "conneg|https://open-services.net/ns/config/shapes/1.0/|oslc/oslc-config/config-shapes"
  "conneg|https://open-services.net/ns/core/trs|oslc/oslc-trs/trs"
  "conneg|https://open-services.net/ns/core/trspatch|oslc/oslc-trs/trspatch"
  "conneg|https://open-services.net/ns/trs/shapes/3.0/|oslc/oslc-trs/trs-shapes"
  "conneg|https://open-services.net/ns/core|oslc/oslc-core/core"
  "conneg|https://open-services.net/ns/core/shapes/3.0|oslc/oslc-core/core-shapes"
  "conneg|http://purl.org/dc/terms/|dc/terms/dcterms"
  "exact|https://purl.org/vocab/vann/vann-vocab-20100607.rdf|vann/vann-vocab.rdf|application/rdf+xml"
  "conneg|http://xmlns.com/foaf/0.1/|foaf/foaf"
  "conneg|http://www.w3.org/1999/02/22-rdf-syntax-ns|w3c/rdf/rdf"
  "conneg|http://www.w3.org/2000/01/rdf-schema|w3c/rdf/rdfs"
  "conneg|http://www.w3.org/2002/07/owl#|w3c/owl"
)
# Use the full list of tasks
scrape_tasks=("${scrape_tasks_full[@]}")


# Define scrape_tasks array is above

# Variables for GNU Parallel
export CURLOPT

function sleep_ci() {
   # we are not in a rush
   # but 3s increases CI runs 10x
    :
#    if [ ! -z ${CI+x} ]; then sleep 0.1; fi
}

# Function to process tasks for a single host
process_host_tasks() {
  local hostname="$1"
  # tasks_string will be passed as the second argument
  local tasks_string="$2"

  # Count the number of actual tasks (non-empty lines)
  local num_tasks=$(echo -e "$tasks_string" | grep -c .)
  local task_count=0
  
  # 'uri' will be set in the loop and is used by the curl_* functions called.
  # The curl_* functions take uri as their first parameter and assign it to their local 'uri' variable.
  local uri 
  local last_processed_uri_for_host="" 

  echo -e "$tasks_string" | while IFS= read -r task_line; do
    if [ -z "$task_line" ]; then
      continue 
    fi

    task_count=$((task_count + 1))
    
    # type, uri, path, accept_header are set here. 
    # The 'uri' variable is then implicitly used by curl_safe via the curl_* functions.
    IFS='|' read -r type uri path accept_header <<< "$task_line" 

    if [ "$uri" != "$last_processed_uri_for_host" ] && [ -n "$last_processed_uri_for_host" ]; then
        echo "Processing new URI ($uri) for host $hostname..."
    elif [ -z "$last_processed_uri_for_host" ]; then
        echo "Processing first URI ($uri) for host $hostname..."
    fi

    case "$type" in
      "conneg")
        # These functions will use the 'uri' variable set in this loop's scope
        curl_conneg_all "$uri" "$path"
        ;;
      "exact")
        curl_get_exact "$uri" "$path" "$accept_header"
        ;;
      "shex")
        curl_try_shex "$uri" "$path"
        ;;
      *)
        echo "Unknown task type: '$type' for host $hostname"
        ;;
    esac
    last_processed_uri_for_host="$uri" 

    if [ "$task_count" -lt "$num_tasks" ]; then
        sleep_ci
    fi
  done
}
export -f process_host_tasks


main() {
  # Check if GNU Parallel is installed
  if ! command -v parallel &> /dev/null
  then
      echo "GNU Parallel could not be found. Please install it to continue."
      exit 1
  fi

  declare -A tasks_by_host

  for task in "${scrape_tasks[@]}"; do
    IFS='|' read -r type uri path accept_header <<< "$task"
    local hostname=$(echo "$uri" | awk -F/ '{print $3}')

    # Check if hostname key exists in the associative array
    if [ ! -v tasks_by_host["$hostname"] ]; then
      tasks_by_host[$hostname]="$task"
    else
      tasks_by_host[$hostname]="${tasks_by_host[$hostname]}\n$task"
    fi
  done
  
  # Prepare arguments for parallel
  # We need to pass both hostname and its tasks string to process_host_tasks
  # GNU Parallel typically takes arguments line by line.
  # We can create a temporary list of arguments, each line containing hostname and tasks.
  
  args_for_parallel=""
  for host in "${!tasks_by_host[@]}"; do
    # Replace newlines in tasks with a placeholder if necessary, or ensure process_host_tasks can handle them.
    # For simplicity, ensure process_host_tasks gets the multiline string correctly.
    # We will pass tasks_by_host[$host] as a single argument.
    # process_host_tasks will then re-iterate over it.
    args_for_parallel+="${host}\n${tasks_by_host[$host]}\n"
  done

  # Using N=2 for parallel to take 2 arguments per job (hostname and tasks_string)
  # --pipepart and -a are used to handle multi-line arguments correctly.
  # However, a simpler approach for GNU Parallel is to pass one primary argument (hostname)
  # and then retrieve the tasks within the function using the hostname.
  # For this, tasks_by_host needs to be available in the environment of process_host_tasks.
  # Bash associative arrays cannot be directly exported.
  # So, we pass the tasks string as the second argument.
  
  parallel_args=()
  for host_key in "${!tasks_by_host[@]}"; do 
    parallel_args+=("$host_key" "${tasks_by_host[$host_key]}")
  done

  if [ ${#parallel_args[@]} -gt 0 ]; then
    printf '%s\0' "${parallel_args[@]}" | parallel -j $PARALLEL_JOBS -0 -n 2 process_host_tasks {1} {2}
  else
    echo "No tasks to process."
  fi

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
   # The 'uri' variable is implicitly used by curl here.
   # It's set in the scope of the calling function (e.g. curl_conneg_all),
   # which receives it as a parameter from process_host_tasks.
   local outpath="$1"
   local accept="$2"
   local ext="$3"
   local name="$4"

   echo -e -n "\t${name}\t"
   # use a temp file to avoid deleting ontologies when endpoints are down
   # and to avoid clobbering
   # TODO: consider clobbering on 404 to make it visible in the history - bad UX
   # The { } around curl and rm ensures that rm only happens if curl fails.
   { curl "$uri" --header "Accept: ${accept}" $CURLOPT >"${outpath}${ext}.tmp" ; } || { rm -f "${outpath}${ext}.tmp"; }
   delete_if_html "${outpath}${ext}.tmp" 
   if [ -s "${outpath}${ext}.tmp" ]; then # Check if file exists and is not empty
      mv "${outpath}${ext}.tmp" "${outpath}${ext}"
      echo -n " ✅";
   else
      # If the .tmp file was removed (by curl fail or delete_if_html), ensure no lingering empty .tmp
      rm -f "${outpath}${ext}.tmp" 
   fi
   echo
}

# Removed duplicate function definition of curl_conneg_all
function curl_conneg_all() {
   local uri="$1" # This uri is local to curl_conneg_all
   local path="$2"
   local firstchar="${path:0:1}"
   local outpath="data/${firstchar,,}/${path}" 
   local outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path} (URI: $uri)"

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
   local uri="$1" # This uri is local to curl_get_exact
   local path="$2"
   local accept="$3"
   local firstchar="${path:0:1}"
   local outpath="data/${firstchar,,}/${path}" 
   local outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path} (URI: $uri)"

   curl_safe "${outpath}" "${accept}" "" "${accept}" # Ext is empty for curl_get_exact
}

function curl_try_shex() {
   local uri="$1" # This uri is local to curl_try_shex
   local path="$2"
   local firstchar="${path:0:1}"
   local outpath="data/${firstchar,,}/${path}" 
   local outdir=$(dirname "$outpath")

   mkdir -p "$outdir"

   echo -e "\nFetching ${path} (URI: $uri)"

   curl_safe "${outpath}" "text/shex" ".shex" "ShEx"
}

# Export functions for GNU Parallel
# Must be after function definitions
export -f curl_safe
export -f curl_conneg_all
export -f curl_get_exact
export -f curl_try_shex
export -f delete_if_html
export -f sleep_ci
export -f process_host_tasks

main "$@"; exit
