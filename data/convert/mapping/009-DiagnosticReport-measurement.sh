#!/bin/bash
#
# Converts FHIR DiagnosticReport resources to OMOPCDM measurement records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/009-DiagnosticReport-measurement.sh"

simple_map '
#--------------------------#-------------------------------#-----------------#
# FHIR DiagnosticReport    # OMOP measurement              # Notes           #
#--------------------------#-------------------------------#-----------------#
  null,                    # measurement_id                # REQUIRED        #
  null,                    # person_id                     # REQUIRED        #
  null,                    # measurement_concept_id        # REQUIRED        #
  null,                    # measurement_date              # REQUIRED        #
  null,                    # measurement_datetime          #
  null,                    # measurement_time              #
  null,                    # measurement_type_concept_id   # REQUIRED        #
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
#--------------------------#-------------------------------#-----------------#
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

# FHIR R4 Example DiagnosticReport Resource
https://www.hl7.org/fhir/R4B/DiagnosticReport.html
{
  "resourceType": "DiagnosticReport",
  "id": "4220",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:19:17.304+00:00",
    "source": "#8IRCgpLiSxJLv3VD",
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-note"
    ]
  },
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://loinc.org",
          "code": "34117-2",
          "display": "History and physical note"
        },
        {
          "system": "http://loinc.org",
          "code": "51847-2",
          "display": "Evaluation+Plan note"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "34117-2",
        "display": "History and physical note"
      },
      {
        "system": "http://loinc.org",
        "code": "51847-2",
        "display": "Evaluation+Plan note"
      }
    ]
  },
  "subject": {
    "reference": "Patient/4217"
  },
  "encounter": {
    "reference": "Encounter/4218"
  },
  "effectiveDateTime": "1959-02-22T06:37:53-05:00",
  "issued": "1959-02-22T06:37:53.630-05:00",
  "performer": [
    {
      "reference": "Practitioner/2187",
      "display": "Dr. Douglass930 Windler79"
    }
  ],
  "presentedForm": [
    {
      "contentType": "text/plain",
      "data": "CjE5NTktMDItMjIKCiMgQ2hpZWYgQ29tcGxhaW50Ck5vIGNvbXBsYWludHMuCgojIEhpc3Rvcnkgb2YgUHJlc2VudCBJbGxuZXNzCkh1bWJlcnRvNDgyCiBpcyBhIDM1IHllYXItb2xkIG5vbi1oaXNwYW5pYyB3aGl0ZSBtYWxlLgoKIyBTb2NpYWwgSGlzdG9yeQpQYXRpZW50IGlzIG1hcnJpZWQuIFBhdGllbnQgaXMgYW4gYWN0aXZlIHNtb2tlciBhbmQgaXMgYW4gYWxjb2hvbGljLgogUGF0aWVudCBpZGVudGlmaWVzIGFzIGhldGVyb3NleHVhbC4KClBhdGllbnQgY29tZXMgZnJvbSBhIGhpZ2ggc29jaW9lY29ub21pYyBiYWNrZ3JvdW5kLgogUGF0aWVudCBoYXMgY29tcGxldGVkIHNvbWUgY29sbGVnZSBjb3Vyc2VzLgpQYXRpZW50IGN1cnJlbnRseSBoYXMgSHVtYW5hLgoKIyBBbGxlcmdpZXMKTm8gS25vd24gQWxsZXJnaWVzLgoKIyBNZWRpY2F0aW9ucwpObyBBY3RpdmUgTWVkaWNhdGlvbnMuCgojIEFzc2Vzc21lbnQgYW5kIFBsYW4KUGF0aWVudCBpcyBwcmVzZW50aW5nIHdpdGggYm9keSBtYXNzIGluZGV4IDMwKyAtIG9iZXNpdHkgKGZpbmRpbmcpLiAKCiMjIFBsYW4KCg=="
    }
  ]
}

NOTES
