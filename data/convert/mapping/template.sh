#!/bin/bash
#
# Converts FHIR XXX resources to OMOPCDM YYY records.
#
source _common.sh

simple_map '
#-----------------------#--------------------------------#
# FHIR XXX              # OMOP YYY                       #
#-----------------------#--------------------------------#
  .id,                  # location_id
...
#-----------------------#--------------------------------#
'

exit 0
# Everything below is notes.

cat <<EOF >/dev/null
# OMOP CDM 5.4

# FHIR 4

EOF
