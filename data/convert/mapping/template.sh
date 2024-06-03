#!/bin/bash
#
# Converts FHIR XXX resources to OMOPCDM YYY records.
#
source _common.sh

simple_map '
# FHIR                # OMOP
#---------------------#-------------------------------#
.id,                  # location_id
.address.line[0],     # address_1
.address.line[1],     # address_2
.address.city,        # city
.address.state,       # state
.address.postalCode,  # zip
null                  # county - not available in FHIR
.name,                # location_source_value
4330442,              # country_concept_id
"USA",                # country_source_value
.position.latitude,   # latitude
.position.longitude   # longitude
'

exit 0
# Everything below is notes.

cat <<EOF >/dev/null
# OMOP

# FHIR

EOF
