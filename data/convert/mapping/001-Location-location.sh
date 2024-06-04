#!/bin/bash
#
# Converts FHIR Location resources to OMOPCDM location records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/001-Location-location.sh"

begin_conversion  # Truncates the care_site.tsv file.

simple_map '
#--------------------------#-----------------------#-----------------------------#
# FHIR Location            # OMOP location         # Notes                       #
#--------------------------#-----------------------#-----------------------------#
  .id,                     # location_id           # REQUIRED                    #
  .address.line[0],        # address_1             #
  .address.line[1],        # address_2             #
  .address.city,           # city                  #
  .address.state,          # state                 #
  .address.postalCode,     # zip                   #
  null                     # county                # not available in FHIR
  .name,                   # location_source_value #
  4330442,                 # country_concept_id    # all coherent data set...
  "USA",                   # country_source_value  # locations are in the USA
  .position.latitude,      # latitude              #
  .position.longitude      # longitude             #
#--------------------------#-----------------------#-----------------------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 location TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#location
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
  longitude REAL NULL
);

# FHIR R4 Example Location Resource
https://www.hl7.org/fhir/R4B/Location.html
{
  "resourceType": "Location",
  "id": "2002",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:18:01.716+00:00",
    "source": "#mUdeOzP6cjltSfM6"
  },
  "identifier": [
    {
      "system": "https://github.com/synthetichealth/synthea",
      "value": "256598cd-f8c7-38ce-81eb-17b90046f633"
    }
  ],
  "status": "active",
  "name": "BERKSHIRE FACULTY SERVICES INC",
  "telecom": [
    {
      "system": "phone",
      "value": "413-447-2745"
    }
  ],
  "address": {
    "line": [
      "777 N ST 6 FL"
    ],
    "city": "PITTSFIELD",
    "state": "MA",
    "postalCode": "01201-4147"
  },
  "position": {
    "longitude": -73.260685,
    "latitude": 42.451840000000004
  },
  "managingOrganization": {
    "reference": "Organization/2001",
    "display": "BERKSHIRE FACULTY SERVICES INC"
  }
}

NOTES
