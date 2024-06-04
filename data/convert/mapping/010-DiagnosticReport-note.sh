#!/bin/bash
#
# Converts FHIR DiagnosticReport resources to OMOPCDM note records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/010-DiagnosticReport-note.sh"

simple_map '
#--------------------------#-----------------------------#-----------------------#
# FHIR DiagnosticReport    # OMOP note                   # Notes                 #
#--------------------------#-----------------------------#-----------------------#
  null,                    # note_id                     # REQUIRED              #
  null,                    # person_id                   # REQUIRED              #
  null,                    # note_date                   # REQUIRED              #
  null,                    # note_datetime               # set the time to midnight if not given
  null,                    # note_type_concept_id        # REQUIRED              #
  null,                    # note_class_concept_id       # REQUIRED              #
  null,                    # note_title                  #
  null,                    # note_text                   # REQUIRED              #
  null,                    # encoding_concept_id         # REQUIRED              #
  null,                    # language_concept_id         # REQUIRED              #
  null,                    # provider_id                 #
  null,                    # visit_occurrence_id         #
  null,                    # visit_detail_id             #
  null,                    # note_source_value           #
  null,                    # note_event_id               #
  null,                    # note_event_field_concept_id #
#--------------------------#-----------------------------#-----------------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 note TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#note
CREATE TABLE note (
  note_id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
  note_date date NOT NULL,
  note_datetime datetime NULL,
  note_type_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  note_class_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  note_title TEXT NULL,
  note_text TEXT NOT NULL,
  encoding_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  language_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
  visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID),
  visit_detail_id integer NULL REFERENCES VISIT_DETAIL (VISIT_DETAIL_ID),
  note_source_value TEXT NULL,
  note_event_id integer NULL,
  note_event_field_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID)
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
