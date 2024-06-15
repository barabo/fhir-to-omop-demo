#!/bin/bash
#
# Create a new script for mapping FHIR resources to OMOPCDM records.
#
# Usage: template.sh <fhir-resource-name> <omop-table-name>
#
# TODO:
#   * accept multiple OMOP table names for a single FHIR resource type
#
#   * Mark any required mappings in the Note column using schema.sql.
#   * support flags for --sqlite cdm.db and --schema schema.sql
#   * generate schema.sql from the cdm.db on --sqlite cdm.db
#
# support the Encounter use case:
#  ./template.sh Encounter {visit,condition,procedure}_occurrence {drug,device}_exposure measurement
#
source "$( dirname "${0}" )/../../vars"
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="demo/translate/map/template.sh"

set -e
set -o pipefail
set -u

# Display usage if invoked with the wrong number of arguments.
(( $# < 2 )) && {
  echo "Usage: template.sh <fhir-resource-name> <omop-table-names>"
  exit 1
}

FHIR="$1"; shift
OMOP=( ${@} )
SCRIPT="$( printf "${FHIR}.jq" )"


#
# Sanity checks!
#
{
  # Make sure there's a fresh DB schema to read from.
  [ -e schema.sql ] || {
    echo "Generating a new schema.sql from ${CDM_DB}..."
    sqlite3 "${CDM_DB}" .schema > schema.sql
  }

  # Make sure the OMOP table exists in the schema.
  grep -q "^CREATE TABLE ${OMOP} (" schema.sql || {
    echo "Error: ${OMOP} table not found in schema.sql"
    exit 1
  }

  # Make sure there are bulk export files for the FHIR resource.
  ls "${FHIR_IN}/${FHIR}_00000.ndjson" >/dev/null || {
    echo "Error: No bulk export files found for resource type: ${FHIR}"
    exit 1
  }
}


##
# Emit a header for the jq script.
#
function get_header() {
  cat <<TEMPLATE
#
# Converts FHIR ${FHIR} resources to OMOPCDM ${OMOP[@]} DB table records.
#
# REPO="${REPO}"
# FILE="$( dirname ${FILE} )/${SCRIPT}"
#

include "fhir";

TEMPLATE
}


##
# Emit the column names of an OMOPCDM table.
#
function get_column_names() {
  local table="${1}"
  sed -n "/^CREATE TABLE ${table} (/,/);/p" schema.sql \
    | sed -n '/^\t\t*/s:\t\t*\([^ ]*\) .*:\1:p'
}

[ -e "${SCRIPT}" ] && {
  echo "Error: ${SCRIPT} already exists."
  exit 1
}

# WIP: generate the start of a jq script for mapping FHIR to OMOP.
{
  get_header
  echo "# FHIR ${FHIR} -> OMOPCDM 5.4 ${OMOP}"
  echo "["
  echo "  \"${OMOP}\",  # TABLE NAME"
  get_column_names ${OMOP} | sed -e 's:^:    null,  # :'
  echo "]"
  echo "|"
  echo "@tsv"
} > "${SCRIPT}"

##
# Emit the table definition of an OMOPCDM table.
#
function get_table_definition() {
  for table in ${OMOP[@]}; do
    sed -n "/^CREATE TABLE ${table} (/,/);/p" schema.sql \
      | sed -e 's:^\t\t*:  :' \
      | sed -e 's:);:\n);:'
  done
}


##
# Emit a positive number of dashes.
#
function dashes() {
  local zeros="$( seq -f "%0${1}g" 0 0 )"
  echo "${zeros//0/-}"
}

echo "NOT DONE"
exit 1
##
# Emit a templatized script for mapping FHIR to OMOP.
#
function get_script_template() {
  local table="${1}"
  local columns=$( get_column_names )
  local omop_w=$(( $( get_column_names | wc -L ) + 2 ))
  local notes_w=$(( 80 - 26 - omop_w - 6 ))
  local divider="#$( dashes 26 )#$( dashes ${omop_w} )#$( dashes ${notes_w} )#"
  get_header
  ow=$(( omop_w - 7 ))
  nw=$(( notes_w - 2 ))

  # Print headings.
  printf "# FHIR %-19s # OMOP %-${ow}s # %-${nw}s #\n" \
    "${FHIR}" "${OMOP}" Notes
  echo ${divider}

  # Print column mappings defaulting to null -> column.
  get_column_names | while read column; do
    local required=""  # TODO: Mark required mappings with 'REQUIRED'.
    printf "  %-24s # %-$(( omop_w - 2 ))s # %-s\n" \
      "null," "${column}" "${required}"
  done

  cat <<TEMPLATE
${divider}
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 ${OMOP} TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#${OMOP}
$( get_table_definition )

# FHIR R4 Example ${FHIR} Resource
https://www.hl7.org/fhir/R4B/${FHIR}.html
$( head -n1 ../fhir/export/${FHIR}_00000.ndjson | jq . )

NOTES
TEMPLATE
}


# Insert a templatized set of jq mappings for the FHIR to OMOP conversion.
get_script_template > "${SCRIPT}"
