#!/bin/bash
#
# Converts FHIR Practitioner resources to OMOPCDM provider records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/005-Practitioner-provider.sh"

simple_map '
#--------------------------#-----------------------------#-----------------------#
# FHIR Practitioner        # OMOP provider               # Notes                 #
#--------------------------#-----------------------------#-----------------------#
  null,                    # provider_id                 # REQUIRED              #
  null,                    # provider_name               #
  null,                    # npi                         #
  null,                    # dea                         #
  null,                    # specialty_concept_id        #
  null,                    # care_site_id                #
  null,                    # year_of_birth               #
  null,                    # gender_concept_id           #
  null,                    # provider_source_value       #
  null,                    # specialty_source_value      #
  null,                    # specialty_source_concept_id #
  null,                    # gender_source_value         #
  null,                    # gender_source_concept_id    #
#--------------------------#-----------------------------#-----------------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 provider TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#provider
CREATE TABLE provider (
  provider_id integer NOT NULL PRIMARY KEY,
  provider_name TEXT NULL,
  npi TEXT NULL,
  dea TEXT NULL,
  specialty_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
  year_of_birth integer NULL,
  gender_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  provider_source_value TEXT NULL,
  specialty_source_value TEXT NULL,
  specialty_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  gender_source_value TEXT NULL,
  gender_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID)
);

# FHIR R4 Example Practitioner Resource
https://www.hl7.org/fhir/R4B/Practitioner.html
{
  "resourceType": "Practitioner",
  "id": "2135",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:18:05.191+00:00",
    "source": "#iXYKQcXMFSkA5jKk"
  },
  "identifier": [
    {
      "system": "http://hl7.org/fhir/sid/us-npi",
      "value": "9999999999"
    },
    {
      "system": "https://github.com/synthetichealth/synthea",
      "value": "7a0d9463-9b7b-3c24-b14f-928d19dd5a32"
    }
  ],
  "active": true,
  "name": [
    {
      "family": "Bruen238",
      "given": [
        "Rosette746"
      ],
      "prefix": [
        "Dr."
      ]
    }
  ],
  "telecom": [
    {
      "system": "email",
      "value": "Rosette746.Bruen238@example.com",
      "use": "work"
    }
  ],
  "address": [
    {
      "line": [
        "60 HOSPITAL ROAD"
      ],
      "city": "LEOMINSTER",
      "state": "MA",
      "postalCode": "01453"
    }
  ],
  "gender": "female"
}

NOTES
