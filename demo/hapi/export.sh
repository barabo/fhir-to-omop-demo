#!/bin/bash
#
# Bulk export ndjson from a HAPI server.
#
source "$( dirname "${0}" )/../vars"
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="demo/hapi/export.sh"

set -e
set -o pipefail
set -u


##
# Get the params needed to initiate a bulk export.
#
function get_params() {
  local name="${1}"
  cat <<EOF
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "_outputFormat",
      "valueString": "application/fhir+ndjson"
    },
    {
      "name": "_exportId",
      "valueString": "${name}"
    },
    {
      "name": "_mdm",
      "valueBoolean": false
    }
  ]
}
EOF
}


##
# Begins an export job and returns the job status URL.
#
function start_export() {
  local name="${1:-export}"

  curl --fail -v -X 'POST' \
    "${FHIR_BASE}/\$export" \
    -H 'accept: application/fhir+json' \
    -H 'Content-Type: application/fhir+json' \
    -H "Prefer: respond-async" \
    -d "$( get_params "${name}" )" \
  2>&1 \
    | grep export-poll-status \
    | awk '{ print $3 }' \
    | tr -d '\n\t\r '
}


##
# Waits for the export to be ready for download.
#
function wait_for_completion() {
  local status_url="${1}"
  local header="X-Progress: Build in progress"
  local job_id="${status_url##*=}"

  echo "EXPORT: ${job_id}: waiting for ${FHIR_BASE} to prepare export."
  echo "EXPORT: Monitoring: '${status_url}' for updates..."

  # Jobs that are not ready yet return this header:
  # X-Progress: Build in progress - Status set to IN_PROGRESS at ...

  # TODO: respect the 'allow-wait' or 'retry-after' headers, if present.
  while curl -sv "${status_url}" 2>&1 >/dev/null | grep -q "${header}"; do
    sleep 3 && echo -n .
  done
  printf "\r"

  echo "EXPORT: ${job_id}: ready for download!"
}


##
# Gets the export filenames to create, and the URLs where content can be found.
#
function get_export_files() {
  local status_url="${1}"
  local destination="${2}"

  last_resource=""
  count=-1
  curl -s "${status_url}" | jq -r '.output[] | .type, .url' | xargs -n2 | \
  while read resource url; do
    (( ++count ))
    [[ $resource != $last_resource ]] && count=0

    # Print the filename and the URL to get its content.
    printf "%s/%s_%05d.ndjson %s\n" \
      "${destination}" ${resource} ${count} "${url}" \
      | tr -d '\t\r'

    last_resource=${resource}
  done
}


##
# Download a file if it's not already been downloaded.
#
function save_file() {
  local filename="${1}"
  local url="${2}"
  [ -e "${filename}" ] || curl -s -o "${filename}" "${url}"
}


##
# Create and process a bulk export from the server.
#
function bulk_export() {
  local name="${1}"
  local compress="${2:-no-compress}"
  local status_url="$( start_export "${name}" )"
  local job_id="${status_url##*=}"

  # Prepare a folder for the job.
  destination="${EXPORT_DIR}/${name}/${job_id}"
  mkdir -p "${destination}"

  # Wait for it to be ready.
  wait_for_completion "${status_url}"

  echo "Downloading files..."
  export -f save_file
  get_export_files "${status_url}" "${destination}" \
    | xargs -n2 -P8 bash -c 'save_file "${@}"' _

  [[ $compress == no-compress ]] && return

  echo "Compressing files with zstd..."
  cd "${EXPORT_DIR}/${name}"
  tar -cp "${job_id}" \
    | zstd -T0 -9 -o "${job_id}.tar.zst"
  rm -rf "${job_id}"
  cd - &>/dev/null
  echo "Created: ${destination}.tar.zst"
  ls -lh "${destination}.tar.zst"
}


start=$(( $( date +%s ) ))

# Perform a bulk export, compressing the resulting directory.
bulk_export "full" compress

echo "Export completed: in $(( $( date +%s ) - start )) seconds."
