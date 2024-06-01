#!/bin/bash
#
# Loads data into a running hapi fhir server.
#

set -e
set -o pipefail
set -u

# Number of concurrent file loaders.
CONCURRENCY=6
export FHIR_BASE="http://localhost:8080/fhir"

# Allow the script to be invoked from other directories and still work.
THIS_DIR="$( dirname ${0} )"

# Make sure an argument has been given.
if (( $# == 0 )); then
  cat <<EOM
Usage: $( basename ${0} ) dir-name[s]

Loads FHIR bundles from a directory into: ${FHIR_BASE}.

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
# Print a summary of the load results for a loaded file.
#
function summarize() {
  local filename="${1}"
  grep '"status"' "${filename}".log \
    | sort \
    | uniq -c \
    | sed -e 's|[ ]*"status": "| - status: |;s:..$::' \
    | \
  while read status; do
    echo "FILE: ${filename}: ${status}"
  done
}


##
# POST a file to the server.
#
function load() {

  # Remove single quotes from the filename, if present.
  local file_folder="$( dirname "${1}" )"
  local filename="$( basename "${1}" )"
  filename="${file_folder}/${filename//'/_}"
  if [[ ${1} != ${filename} ]]; then
    echo "Renaming: ${1} to remove single quotes in filename..."
    mv -v "${1}" "${file_folder}/${filename}"
  fi

  # Load the file.
  curl \
    --no-progress-meter \
    --fail-with-body \
    -X POST \
    -H "X-Upsert-Extistence-Check: disabled" \
    -H "Content-Type: application/json" \
    ${FHIR_BASE} \
    --data-binary "@${filename}" \
    &> "${filename}.log"

  # Print a summary of the load results for the loaded file.
  summarize "${filename}"
}


##
# Load files in parallel, maintaining no more than CONCURRENCY simultaneous uploads.
#
function load_files_matching() {
  local dir="${1}"
  local pattern="${2}"
  export -f load
  export -f summarize
  find ${dir} -maxdepth 1 -mindepth 1 -type f -name "${pattern}" -print0 \
    | xargs -0 -n1 -P${CONCURRENCY} bash -c 'load "${@}"' "_"
}


for dir in ${@}; do
  # Synthea usually places organization and practionioner files into separate
  # bundle files that start with lowercase letters.  We want to load these
  # first.
  load_files_matching ${dir} 'organization*.json'
  load_files_matching ${dir} 'practitioner*.json'
  # Load patient files next.
  load_files_matching ${dir} '[^a-z]*.json'
done
