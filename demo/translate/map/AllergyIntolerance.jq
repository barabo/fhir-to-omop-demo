#
# Converts FHIR AllergyIntolerance resources to OMOPCDM condition_occurrence DB table records.
#
# REPO="https://github.com/barabo/fhir-to-omop-demo"
# FILE="demo/translate/map/AllergyIntolerance.jq"
#

include "fhir";
include "fhir/common";


# TODO: inject concepts for .clinicalStatus and .verificationStatus
def condition:
  .code.coding[] // {}
;

def clinical_status:
  .clinicalStatus.coding[] // {}
;

def verification_status:
  .verificationStatus.coding[].code.concept // {}
;


# FHIR AllergyIntolerance -> OMOPCDM condition_occurrence
AllergyIntolerance |
[
  "condition_occurrence",                # TABLE COLUMNS
    .id,                                 # condition_occurrence_id
    .patient.id,                         # person_id
    condition.concept.concept_id,        # condition_concept_id
    .recordedDate,                       # condition_start_date
    .recordedDate,                       # condition_start_datetime
    null,  # condition_end_date
    null,  # condition_end_datetime
    32817,                               # condition_type_concept_id  # provenance: EHR
    clinical_status.concept.concept_id,  # condition_status_concept_id
    null,  # stop_reason
    null,  # provider_id
    null,  # visit_occurrence_id
    null,  # visit_detail_id
    condition.code,                       # condition_source_value
    condition.vocabulary.concept_id,      # condition_source_concept_id
    clinical_status.code                  # condition_status_source_value
]
|
@tsv
