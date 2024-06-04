#!/bin/bash
#
# Converts FHIR Observation resources to OMOPCDM measurement records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/008-Observation-measurement.sh"

simple_map '
#--------------------------#-------------------------------#---------------------#
# FHIR Observation         # OMOP measurement              # Notes               #
#--------------------------#-------------------------------#---------------------#
  null,                    # measurement_id                #
  null,                    # person_id                     #
  null,                    # measurement_concept_id        #
  null,                    # measurement_date              #
  null,                    # measurement_datetime          #
  null,                    # measurement_time              #
  null,                    # measurement_type_concept_id   #
  null,                    # operator_concept_id           #
  null,                    # value_as_number               #
  null,                    # value_as_concept_id           #
  null,                    # unit_concept_id               #
  null,                    # range_low                     #
  null,                    # range_high                    #
  null,                    # provider_id                   #
  null,                    # visit_occurrence_id           #
  null,                    # visit_detail_id               #
  null,                    # measurement_source_value      #
  null,                    # measurement_source_concept_id #
  null,                    # unit_source_value             #
  null,                    # unit_source_concept_id        #
  null,                    # value_source_value            #
  null,                    # measurement_event_id          #
  null,                    # meas_event_field_concept_id   #
#--------------------------#-------------------------------#---------------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 measurement TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#measurement
CREATE TABLE measurement (
  measurement_id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
  measurement_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  measurement_date date NOT NULL,
  measurement_datetime datetime NULL,
  measurement_time TEXT NULL,
  measurement_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  operator_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  value_as_number REAL NULL,
  value_as_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  unit_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  range_low REAL NULL,
  range_high REAL NULL,
  provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
  visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
  visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
  measurement_source_value TEXT NULL,
  measurement_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  unit_source_value TEXT NULL,
  unit_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  value_source_value TEXT NULL,
  measurement_event_id integer NULL,
  meas_event_field_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID)
);

# FHIR R4 Example Observation Resource
https://www.hl7.org/fhir/R4B/Observation.html
{
  "resourceType": "Observation",
  "id": "4237",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:19:17.304+00:00",
    "source": "#8IRCgpLiSxJLv3VD",
    "profile": [
      "http://hl7.org/fhir/StructureDefinition/bodyheight",
      "http://hl7.org/fhir/StructureDefinition/vitalsigns"
    ]
  },
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "vital-signs",
          "display": "vital-signs"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "8302-2",
        "display": "Body Height"
      }
    ],
    "text": "Body Height"
  },
  "subject": {
    "reference": "Patient/4217"
  },
  "encounter": {
    "reference": "Encounter/4228"
  },
  "effectiveDateTime": "1996-02-18T06:37:53-05:00",
  "issued": "1996-02-18T06:37:53.630-05:00",
  "valueQuantity": {
    "value": 174.1,
    "unit": "cm",
    "system": "http://unitsofmeasure.org",
    "code": "cm"
  }
}

NOTES
