#!/bin/bash
#
# This file is to be sourced by other scripts in this directory.
#
# Each script should begin with the following lines:
#
#   #!/bin/bash
#   #
#   # Converts FHIR XXX resources to OMOPCDM YYY records.
#   #
#   source _common.sh
#
# Because this file is _sourced_ from other scripts, all these functions are
# loaded into the context of the caller, using the environment defined there.
#

#
# Enable safety features for all mapping scripts that source this file.
#
set -e
set -o pipefail
set -u

# TODO: expect these to be exported from the caller
SRC_FHIR_DIR="../fhir/export"
DST_OMOP_DIR="../omop"
OMOP_CDM_DB="TODO"  # The cdm.db being built by the converter.

#
# Variables that are used by the scripts that source this file.
#
THIS_SCRIPT="$( basename ${0} )"
FHIR_TYPE="$( cut -d- -f2 <<< ${THIS_SCRIPT} )"
OMOP_TYPE="$( sed -e 's:^[0-9]*-[^-]*-\(.*\).sh$:\1:' <<< ${THIS_SCRIPT} )"


##
# Reset the destination OMOPCDM tsv file.
#
function begin_conversion() {
  mkdir -p "${DST_OMOP_DIR}"
  touch "${DST_OMOP_DIR}/${OMOP_TYPE}.tsv"
  truncate -s 0 "$_"
}


##
# Dump the collected TSV into the cdm.db.
#
function end_conversion() {
  echo "TODO: write ${DST_OMOP_DIR}/${OMOP_TYPE}.tsv to ${OMOP_CDM_DB}"
}


##
# Iterates over all the resources being loaded and applies a mapping to each.
#
function simple_map() {
  local mapping="${1}"

  echo "Mapping FHIR ${FHIR_TYPE} resources to ${OMOP_TYPE} records..."

  while read ndjson; do

    # Display a progress indicator for each .ndjson file processed.
    echo -n . 1>&2

    # For each JSON resource in the .ndjson file...
    while read resource; do

      # Apply the jq mappings, emitting tsv.
      jq -r ".|[${mapping}]|@tsv" <<< "${resource}"

    done < "${ndjson}"

  done < <( find "${SRC_FHIR_DIR}/" -name "${FHIR_TYPE}_*.ndjson" ) \
    >> "${DST_OMOP_DIR}/${OMOP_TYPE}.tsv"

  echo 1>&2
}
