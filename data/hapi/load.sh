#!/bin/bash
#
# Loads data into a running hapi fhir server.
#

set -e
set -o pipefail
set -u

# Allow the script to be invoked from other directories and still work.
THIS_DIR="$( dirname ${0} )"

function usage() {
  local message="${@}"
  cat <<EOM
Usage: $( basename ${0} ) config-etl.json

Loads FHIR bundles from files a into a FHIR server.

${message}
EOM
  exit 1
}


# Check the arguments.
(( $# == 0 )) && usage "See ${THIS_DIR}/README.md for configuration options."
ETL_CONFIG="${1}"
[ -e "${ETL_CONFIG}" ] || usage "File not found: ${ETL_CONFIG}"


##
# Get a config item from the etl config file.
#
function etl() {
  local query="${1}"
  cat "${ETL_CONFIG}" | jq --raw-output .${query}
}


##
# Gets batch config from the ETL file.
#
function get_batches() {
  cat "${ETL_CONFIG}" \
    | jq -c '.load_groups[] | .concurrency, .file_name_regex, .files, .folder' \
    | xargs -n4
}


# The base server where data is loaded to.
export FHIR_BASE="$( etl fhir_base )"


# Make sure the server is started already.
${THIS_DIR}/start.sh >/dev/null
# TODO: this could be a config item .start_script


##
# Print a summary of the load results for a loaded file.
#
function summarize() {
  local filename="${1}"
  grep '"status"' "${filename}".log \
    | sort \
    | uniq -c \
    | sed -e 's|[ ]*"status": .| - status: |;s:..$::' \
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
  local file_folder="$( dirname ${1} )"
  local filename="$( basename ${1} )"
  filename="${file_folder}/${filename//\'/_}"
  if [[ ${1} != ${filename} ]]; then
    echo "Renaming: ${1} to remove single quotes in filename..."
    mv -v "${1}" "${filename}"
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
  local concurrency="${1}"
  local file_name_regex="${2}"
  local folder="${3}"

  # Export the functions needed by the loader.
  export -f load
  export -f summarize

  # Load files matching a regex in parallel.
  find "${folder}" \
    -maxdepth 1 \
    -mindepth 1 \
    -type f \
    -name "${file_name_regex}" \
    -print0 \
    | xargs -0 -n1 -P${concurrency} bash -c 'load "${@}"' _
}


# Load the load groups in batches.
batch=-1
get_batches | \
while read concurrency file_name_regex files folder; do
  # Keep track of which batch this is so we can access the batch .files.
  (( batch++ ))

  # Load files matching a regex.
  if [[ $files == null ]]; then
    load_files_matching ${concurrency} "${file_name_regex}" "${folder}"
    continue
  fi

  # Load named files.
  etl "load_groups[${batch}].files[]" | \
  while read filename; do
    if (( concurrency != 1 )); then
      echo "WARN: Loading named files with concurrency > 1 not yet supported!"
    fi
    load_files_matching 1 "${filename}" "${folder}"
  done
done
