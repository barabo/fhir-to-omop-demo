#!/bin/bash
#
# Converts FHIR PractitionerRole resources to OMOPCDM provider records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/011-PractitionerRole-provider.sh"

#
# TODO: update the provider table with specialty details
#

exit 1

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

# FHIR R4 Example PractitionerRole Resource
https://www.hl7.org/fhir/R4B/PractitionerRole.html
{
  "resourceType": "PractitionerRole",
  "id": "4136",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:18:05.191+00:00",
    "source": "#iXYKQcXMFSkA5jKk"
  },
  "active": true,
  "practitioner": {
    "reference": "Practitioner/4135",
    "display": "Dr. Constance642 McLaughlin530"
  },
  "organization": {
    "reference": "Organization/2053",
    "display": "MASHPEE FAMILY MEDICINE"
  },
  "code": [
    {
      "coding": [
        {
          "system": "http://nucc.org/provider-taxonomy",
          "code": "208D00000X",
          "display": "General Practice"
        }
      ],
      "text": "General Practice"
    }
  ],
  "specialty": [
    {
      "coding": [
        {
          "system": "http://nucc.org/provider-taxonomy",
          "code": "208D00000X",
          "display": "General Practice"
        }
      ],
      "text": "General Practice"
    }
  ],
  "location": [
    {
      "reference": "Location/2054",
      "display": "MASHPEE FAMILY MEDICINE"
    }
  ],
  "telecom": [
    {
      "system": "email",
      "value": "Constance642.McLaughlin530@example.com",
      "use": "work"
    }
  ]
}

NOTES
