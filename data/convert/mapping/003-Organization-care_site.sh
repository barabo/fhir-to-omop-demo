#!/bin/bash
#
# Converts FHIR Organization resources to OMOPCDM care_site records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/003-Organization-care_site.sh"

simple_map '
#--------------------------#-------------------------------#-----------------#
# FHIR Organization        # OMOP care_site                # Notes           #
#--------------------------#-------------------------------#-----------------#
  .id,                     # care_site_id                  # REQUIRED        #
  .name,                   # care_site_name                #
  null,                    # place_of_service_concept_id   # TODO: map this
  null,                    # location_id                   #
  null,                    # care_site_source_value        #
  null,                    # place_of_service_source_value #
#--------------------------#-------------------------------#-----------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 care_site TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#care_site
CREATE TABLE care_site (
  care_site_id integer NOT NULL PRIMARY KEY,
  care_site_name TEXT NULL,
  place_of_service_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  location_id integer NULL REFERENCES LOCATION (LOCATION_ID),
  care_site_source_value TEXT NULL,
  place_of_service_source_value TEXT NULL
);

# FHIR R4 Example Organization Resource
https://www.hl7.org/fhir/R4B/Organization.html
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

NOTES
