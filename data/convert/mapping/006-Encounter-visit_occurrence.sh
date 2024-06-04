#!/bin/bash
#
# Converts FHIR Encounter resources to OMOPCDM visit_occurrence records.
#
source _common.sh

REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/convert/mapping/006-Encounter-visit_occurrence.sh"

simple_map '
#--------------------------#-------------------------------#-----------------#
# FHIR Encounter           # OMOP visit_occurrence         # Notes           #
#--------------------------#-------------------------------#-----------------#
  null,                    # visit_occurrence_id           # REQUIRED        #
  null,                    # person_id                     # REQUIRED        #
  null,                    # visit_concept_id              # REQUIRED        #
  null,                    # visit_start_date              # REQUIRED        #
  null,                    # visit_start_datetime          #
  null,                    # visit_end_date                # REQUIRED        #
  null,                    # visit_end_datetime            #
  null,                    # visit_type_concept_id         # REQUIRED        #
  null,                    # provider_id                   #
  null,                    # care_site_id                  #
  null,                    # visit_source_value            #
  null,                    # visit_source_concept_id       #
  null,                    # admitted_from_concept_id      #
  null,                    # admitted_from_source_value    #
  null,                    # discharged_to_concept_id      #
  null,                    # discharged_to_source_value    #
  null,                    # preceding_visit_occurrence_id #
#--------------------------#-------------------------------#-----------------#
'

exit 0

cat <<NOTES  # Everything below is notes.

# Terminology search:
https://athena.ohdsi.org/search-terms/terms

# OMOP CDM 5.4 visit_occurrence TABLE
https://ohdsi.github.io/CommonDataModel/cdm54.html#visit_occurrence
CREATE TABLE visit_occurrence (
  visit_occurrence_id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL REFERENCES PERSON (PERSON_ID),
  visit_concept_id integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  visit_start_date date NOT NULL,
  visit_start_datetime datetime NULL,
  visit_end_date date NOT NULL,
  visit_end_datetime datetime NULL,
  visit_type_concept_id Integer NOT NULL REFERENCES CONCEPT (CONCEPT_ID),
  provider_id integer NULL REFERENCES PROVIDER (PROVIDER_ID),
  care_site_id integer NULL REFERENCES CARE_SITE (CARE_SITE_ID),
  visit_source_value TEXT NULL,
  visit_source_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  admitted_from_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  admitted_from_source_value TEXT NULL,
  discharged_to_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
  discharged_to_source_value TEXT NULL,
  preceding_visit_occurrence_id integer NULL REFERENCES VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID)
);

# FHIR R4 Example Encounter Resource
https://www.hl7.org/fhir/R4B/Encounter.html
{
  "resourceType": "Encounter",
  "id": "4218",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:19:17.304+00:00",
    "source": "#8IRCgpLiSxJLv3VD",
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter"
    ]
  },
  "identifier": [
    {
      "use": "official",
      "system": "https://github.com/synthetichealth/synthea",
      "value": "fe6a5bc3-6637-e625-daff-07fbd65c6b81"
    }
  ],
  "status": "finished",
  "class": {
    "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    "code": "AMB"
  },
  "type": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "185349003",
          "display": "Encounter for check up (procedure)"
        }
      ],
      "text": "Encounter for check up (procedure)"
    }
  ],
  "subject": {
    "reference": "Patient/4217",
    "display": "Mr. Humberto482 Koss676"
  },
  "participant": [
    {
      "type": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
              "code": "PPRF",
              "display": "primary performer"
            }
          ],
          "text": "primary performer"
        }
      ],
      "period": {
        "start": "1959-02-22T06:37:53-05:00",
        "end": "1959-02-22T06:52:53-05:00"
      },
      "individual": {
        "reference": "Practitioner/2187",
        "display": "Dr. Douglass930 Windler79"
      }
    }
  ],
  "period": {
    "start": "1959-02-22T06:37:53-05:00",
    "end": "1959-02-22T06:52:53-05:00"
  },
  "location": [
    {
      "location": {
        "reference": "Location/54",
        "display": "MERCY MEDICAL CTR"
      }
    }
  ],
  "serviceProvider": {
    "reference": "Organization/53",
    "display": "MERCY MEDICAL CTR"
  }
}

NOTES
