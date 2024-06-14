#
# Produces TSV omop data.
#

include "fhir";

# FHIR Location
[
  "location",                # OMOP table location
    .id,                     # location_id
    .address.line[0],        # address_1
    .address.line[1],        # address_2
    .address.city,           # city
    .address.state,          # state
    .address.postalCode,     # zip
    null                     # county
    .name,                   # location_source_value
    4330442,                 # country_concept_id
    "USA",                   # country_source_value
    .position.latitude,      # latitude
    .position.longitude      # longitude
]
|@tsv
