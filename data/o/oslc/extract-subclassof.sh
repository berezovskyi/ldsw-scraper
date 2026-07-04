#!/usr/bin/env bash
set -euo pipefail

# Extract minimal subClassOf hierarchy from all .ttl files in this directory tree.
# Requires Apache Jena tools (arq, riot) in /opt/homebrew/bin/ or set JENA_BIN.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/subclassof.ttl"
JENA_BIN="${JENA_BIN:-/opt/homebrew/bin}"

# Collect all .ttl files under the script directory, excluding our output
mapfile -t TTL_FILES < <(find "$SCRIPT_DIR" -name '*.ttl' ! -name 'subclassof.ttl' -type f)

if [ ${#TTL_FILES[@]} -eq 0 ]; then
  echo "No .ttl files found under $SCRIPT_DIR" >&2
  exit 1
fi

echo "Processing ${#TTL_FILES[@]} Turtle files..." >&2

# Build the arq --data arguments
DATA_ARGS=()
for f in "${TTL_FILES[@]}"; do
  DATA_ARGS+=(--data "$f")
done

QUERY='
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

CONSTRUCT {
  ?sub rdfs:subClassOf ?super .
}
WHERE {
  ?sub rdfs:subClassOf ?super .
  FILTER(isIRI(?sub) && isIRI(?super))
}
'

TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT

NT_FILE="$TMPDIR_WORK/raw.nt"
PREFIXED_FILE="$TMPDIR_WORK/prefixed.ttl"

# Run SPARQL CONSTRUCT, deduplicate
"$JENA_BIN/arq" "${DATA_ARGS[@]}" --query=- --results=NT <<< "$QUERY" \
  | sort -u \
  > "$NT_FILE"

# Collect unique prefixes from source files, then append the N-Triples data.
# riot will use the prefixes when serializing to Turtle.
{
  for f in "${TTL_FILES[@]}"; do
    grep -h '^@prefix ' "$f" 2>/dev/null || true
  done | awk '!seen[$2]++' # keep first occurrence of each prefix name
  echo ""
  cat "$NT_FILE"
} > "$PREFIXED_FILE"

"$JENA_BIN/riot" --syntax=Turtle --output=Turtle "$PREFIXED_FILE" > "$OUTPUT"

COUNT=$(grep -c 'subClassOf' "$OUTPUT" 2>/dev/null || echo 0)
echo "Wrote $OUTPUT ($COUNT rdfs:subClassOf triples)" >&2
