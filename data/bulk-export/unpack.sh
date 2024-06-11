#!/bin/bash
#
# Unpack a compressed backup into data/bulk-export/fhir.
#
source "$( dirname "${0}" )/../../demo/vars"


##
# Returns export files matching a filename prefix, if provided.
#
function find-exports() {
  find "${EXPORT_DIR}" -type f -name "${1:-}*.tar.zst"
}


##
# Unpack a bulk export file.
#
function unpack() {
  local export_file="${1}"
  local export_id="$( basename "${1}" | sed -e 's:.tar.zst$::' )"

  # Ensure the file and destination both exist.
  [ ! -e "${export_file}" ] && echo "Export not found: ${1}" && exit 1
  mkdir -p "${FHIR_IN}"

  # Ensure the destination is empty.
  local existing="$(( $( find "${FHIR_IN}" -type f -name '*.ndjson' | wc -l ) ))"
  (( existing > 0 )) && echo "ERROR: existing files in: ${FHIR_IN}" && exit 1

  # Unpack the tar file.
  cd "${FHIR_IN}/../"
    rmdir fhir
    echo "Unpacking export into: ${FHIR_IN}..."
    unzstd --stdout "${export_file}" | tar -xz
    mv "${export_id}" "${FHIR_IN}"
  cd - &>/dev/null
}


FOUND=$(( $( find-exports "${1:-}"| wc -l ) ))


# Fail if there are no exports to unpack.
if (( FOUND == 0 )); then
  echo "No matching bulk exports found in ${EXPORT_DIR}!"
  exit 1
fi

# Unpack the only bulk export, if found.
if (( FOUND == 1 )); then
  unpack "$( find-exports )"

else
  # Display the available bulk exports.
  echo "Multiple exports found!\n"
  echo "Please provide a partial name to match one of these:"
  export-ids | sed -e 's:^:  :'
  exit 1
fi
