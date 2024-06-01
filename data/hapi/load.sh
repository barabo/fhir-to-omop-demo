#!/bin/bash
#
# Loads data into a running hapi fhir server.
#

set -e
set -o pipefail
set -u

# Number of concurrent file loaders.
CONCURRENCY=4
FHIR_URL="http://localhost:8080/fhir"

# Allow the script to be invoked from other directories and still work.
THIS_DIR="$( dirname ${0} )"

# Make sure an argument has been given.
if (( $# == 0 )); then
  cat <<EOM
Usage: $( basename ${0} ) dir-name[s]

Loads FHIR bundles from a directory into: ${FHIR_URL}.

Up to ${CONCURRENCY} parallel uploads happen at once.
EOM
  exit 1
fi

# Make sure the arguments are all directories.
for x in "${@}"; do
  [ ! -d ${x} ] && echo "Not a directory: ${x}" && exit 1
done

# Make sure the server is started already.
${THIS_DIR}/start.sh >/dev/null


##
# POST a file to the server.
#
function load() {
  echo "Loading: ${1}"
  curl \
    -X POST \
    -H "X-Upsert-Extistence-Check: disabled" \
    -H "Content-Type: application/json" \
    ${FHIR_URL} \
    --data-binary "@${1}" \
    &> "${1}.log"
}


##
# Load a bunch of files in parallel.
#
function load_files_matching() {
  local dir="${1}"
  local pattern="${2}"
  export -f load
  find ${dir} -maxdepth 1 -mindepth 1 -type f -name "${pattern}" -print0 \
    | xargs -0 -n1 -P${CONCURRENCY} bash -c 'load "${@}"' "_"
}


for dir in ${@}; do
  # Synthea usually places organization and practionioner files into separate
  # bundle files that start with lowercase letters.  We want to load these
  # first.
  load_files_matching ${dir} '[a-z]*.json'
  # Load patient files next.
  load_files_matching ${dir} '[^a-z]*.json'
done
