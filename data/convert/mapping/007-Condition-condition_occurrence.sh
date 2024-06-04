#!/bin/bash
#
# Converts FHIR Condition resources to OMOPCDM condition_occurrence records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/007-Condition-condition_occurrence.sh"

simple_map '
#--------------------------#-------------------------------#-----------------#
# FHIR Condition           # OMOP condition_occurrence     # Notes           #
#--------------------------#-------------------------------#-----------------#
  null,                    # condition_occurrence_id       # REQUIRED        #
  null,                    # person_id                     # REQUIRED        #
  null,                    # condition_concept_id          # REQUIRED        #
  null,                    # condition_start_date          # REQUIRED        #
  null,                    # condition_start_datetime      #
  null,                    # condition_end_date            #
  null,                    # condition_end_datetime        #
  null,                    # condition_type_concept_id     # REQUIRED        #
  null,                    # condition_status_concept_id   #
  null,                    # stop_reason                   #
  null,                    # provider_id                   #
  null,                    # visit_occurrence_id           #
  null,                    # visit_detail_id               #
  null,                    # condition_source_value        #
  null,                    # condition_source_concept_id   #
  null,                    # condition_status_source_value #
#--------------------------#-------------------------------#-----------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 condition_occurrence TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#condition_occurrence
CREATE TABLE condition_occurrence (
  condition_occurrence_id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
  condition_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  condition_start_date date NOT NULL,
  condition_start_datetime datetime NULL,
  condition_end_date date NULL,
  condition_end_datetime datetime NULL,
  condition_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  condition_status_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  stop_reason TEXT NULL,
  provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
  visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
  visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
  condition_source_value TEXT NULL,
  condition_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  condition_status_source_value TEXT NULL 
);

# FHIR R4 Example Condition Resource
https://www.hl7.org/fhir/R4B/Condition.html
{
  "resourceType": "Condition",
  "id": "4219",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:19:17.304+00:00",
    "source": "#8IRCgpLiSxJLv3VD",
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition"
    ]
  },
  "clinicalStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
        "code": "active"
      }
    ]
  },
  "verificationStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
        "code": "confirmed"
      }
    ]
  },
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/condition-category",
          "code": "encounter-diagnosis",
          "display": "Encounter Diagnosis"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://snomed.info/sct",
        "code": "162864005",
        "display": "Body mass index 30+ - obesity (finding)"
      }
    ],
    "text": "Body mass index 30+ - obesity (finding)"
  },
  "subject": {
    "reference": "Patient/4217"
  },
  "encounter": {
    "reference": "Encounter/4218"
  },
  "onsetDateTime": "1959-02-22T06:37:53-05:00",
  "recordedDate": "1959-02-22T06:37:53-05:00"
}

NOTES
