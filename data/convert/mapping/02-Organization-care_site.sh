#!/bin/bash
#
# Converts FHIR XXX resources to OMOPCDM YYY records.
#
source _common.sh

simple_map '
# FHIR Organization        # OMOP care_site                 #
#--------------------------#--------------------------------#
  .id,                     # location_id
  .address[0].line[0],     # address_1
  .address[0].line[1],     # address_2
  .address[0].city,        # city
  .address[0].state,       # state
  .address[0].postalCode,  # zip
  null                     # county - not available in FHIR
  .name,                   # location_source_value
  4330442,                 # country_concept_id
  "USA",                   # country_source_value
  .position.latitude,      # latitude
  .position.longitude      # longitude
'

# TODO: finalize care_site by inserting into cdm.db

exit 0
# Everything below is notes.

cat <<EOF >/dev/null
# OMOP
CREATE TABLE location (
                        location_id integer NOT NULL PRIMARY KEY,
                        address_1 TEXT NULL,
                        address_2 TEXT NULL,
                        city TEXT NULL,
                        state TEXT NULL,
                        zip TEXT NULL,
                        county TEXT NULL,
                        location_source_value TEXT NULL,
                        country_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
                        country_source_value TEXT NULL,
                        latitude REAL NULL,
                        longitude REAL NULL );
# FHIR
{
  "resourceType": "Organization",
  "id": "2001",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:18:01.716+00:00",
    "source": "#mUdeOzP6cjltSfM6"
  },
  "identifier": [
    {
      "system": "https://github.com/synthetichealth/synthea",
      "value": "b63064df-3557-39e9-a93d-caafc1fd5954"
    }
  ],
  "active": true,
  "name": "BERKSHIRE FACULTY SERVICES INC",
  "telecom": [
    {
      "system": "phone",
      "value": "413-447-2745"
    }
  ],
  "address": [
    {
      "line": [
        "777 N ST 6 FL"
      ],
      "city": "PITTSFIELD",
      "state": "MA",
      "postalCode": "01201-4147"
    }
  ]
}
EOF
