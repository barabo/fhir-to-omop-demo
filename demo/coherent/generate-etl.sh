#!/bin/bash
#
# Use this script by streaming its output to a new file.
#
# Ex: ./generate-etl.sh > etl.json
#
source "$( dirname "${0}" )/../vars"
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="demo/coherent/generate-etl.sh"

set -e
set -o pipefail
set -u


# Apply the vars settings to the template ETL.
jq \
  --arg FHIR_BASE "${FHIR_BASE}" \
  --arg IMPORT_DIR "${IMPORT_DIR}" \
'
  # Inject the FHIR_BASE and IMPORT_DIR variables into the template etl file.
  .fhir_base |= $FHIR_BASE
  | .load_groups[].folder |= $IMPORT_DIR
' \
"${THIS_DIR}/template-coherent-etl.json"
