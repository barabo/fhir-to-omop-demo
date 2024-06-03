#!/bin/bash
#
# To be sourced by other scripts in this directory.
#

set -e
set -o pipefail
set -u

SRC_FHIR_DIR="../fhir/export"
DST_OMOP_DIR="../omop"

THIS_SCRIPT="$( basename ${0} )"
FHIR_TYPE="$( cut -d- -f2 <<< ${THIS_SCRIPT} )"
OMOP_TYPE="$( sed -e 's:^[0-9]*-[^-]*-\(.*\).sh$:\1:' <<< ${THIS_SCRIPT} )"


##
# Iterates over all the resources being loaded and applies a mapping to each.
#
function simple_map() {
  local mapping="${1}"

  echo "Mapping FHIR ${FHIR_TYPE} resources to ${OMOP_TYPE} records..."

  find "${SRC_FHIR_DIR}/" -name "${FHIR_TYPE}_*.ndjson" | \
  while read ndjson; do

    echo -n . 1>&2
    cat "${ndjson}" | \
    while read resource; do
      jq -r ".|[${mapping}]|@tsv" <<< "${resource}"
    done

  done \
  >> "${DST_OMOP_DIR}/${OMOP_TYPE}.tsv"

  echo 1>&2
}


function log() {
  echo "${THIS_SCRIPT}: ${@}"
}


function fatal() {
  log "FATAL: ${@}"
  exit 1
}
