#!/bin/bash
#
# Create a new script for mapping FHIR resources to OMOPCDM records.
#
# Usage: template.sh <fhir-resource-name> <omop-table-name>
#
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/template.sh"

set -e
set -o pipefail
set -u

# Display usage if invoked with the wrong number of arguments.
(( $# != 2 )) && {
  echo "Usage: template.sh <fhir-resource-name> <omop-table-name>"
  exit 1
}

FHIR="$1"
OMOP="$2"
NEXT="$(( $( find . -type f -name '[0-9]*-*.sh' | wc -l ) + 1 ))"
SCRIPT="$( printf "%03d-${FHIR}-${OMOP}.sh" ${NEXT} )"


# Make sure the OMOP table exists in the schema.
grep -q "^CREATE TABLE ${OMOP} (" schema.sql || {
  echo "Error: ${OMOP} table not found in schema.sql"
  exit 1
}

# Make sure there are bulk export files for the FHIR resource.
ls ../fhir/export/${FHIR}_00000.ndjson >/dev/null || {
  echo "Error: No bulk export files found for resource type: ${FHIR}"
  exit 1
}


##
# Emit the column names of an OMOPCDM table.
#
function get_column_names() {
  sed -n "/^CREATE TABLE ${OMOP} (/,/);/p" schema.sql \
    | sed -n '/^\t\t*/s:\t\t*\([^ ]*\) .*:\1:p'
}


##
# Emit the table definition of an OMOPCDM table.
#
function get_table_definition() {
  sed -n "/^CREATE TABLE ${OMOP} (/,/);/p" schema.sql \
    | sed -e 's:^\t\t*:  :' \
    | sed -e 's:);:\n);:'
}


##
# Emit a positive number of dashes.
#
function dashes() {
  local zeros="$( seq -f "%0${1}g" 0 0 )"
  echo "${zeros//0/-}"
}


##
# Emit a templatized script for mapping FHIR to OMOP.
#
function get_script_template() {
  local columns=$( get_column_names )
  local omop_w=$(( $( get_column_names | wc -L ) + 2 ))
  local notes_w=$(( 80 - 26 - omop_w - 2 ))
  local divider="#$( dashes 26 )#$( dashes ${omop_w} )#$( dashes ${notes_w} )#"
  cat <<TEMPLATE
#!/bin/bash
#
# Converts FHIR ${FHIR} resources to OMOPCDM ${OMOP} records.
#
REPO="${REPO}"
FILE="$( dirname ${FILE} )/${SCRIPT}"

source _common.sh

simple_map '
${divider}
TEMPLATE
  ow=$(( omop_w - 7 ))
  nw=$(( notes_w - 2 ))
  printf "# FHIR %-19s # OMOP %-${ow}s # %-${nw}s #\n" \
    "${FHIR}" "${OMOP}" Notes
  cat <<TEMPLATE
${divider}
TEMPLATE
  get_column_names | while read column; do
    ow=$(( omop_w - 2 ))
    printf "  %-24s # %-${ow}s #\n" "null," "${column}"
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
