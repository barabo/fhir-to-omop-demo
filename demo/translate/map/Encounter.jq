#
# Transforms FHIR Encounters into OMOP table records.
#

include "fhir";
include "fhir/common";

# An alias for the unit of the measurement.
def unit:
  .valueQuantity.concept
;

def primary_performer:
  .participant[] | select(.type[].coding[].code == "PPRF") | .individual
;

def code_concept(domain):
  (.type[].coding[] | [select(.concept.domain_id == domain)]) as $concepts |
  if ($concepts | length) > 1 then
    error("Multiple \(domain) codings in Encounter/\(.id) code: \($concepts)")
  elif ($concepts | length) == 0 then
    empty
  else
    $concepts[0].concept
  end
;

def condition: code_concept("Condition");
def procedure: code_concept("Procedure");
def visit: code_concept("Visit");

def observation:
  ["Condition", "Device", "Drug", "Measurement", "Procedure"] as $forbidden |
  (
    .type[].coding[]
    | [select(.concept.domain_id | IN($forbidden[]) | not)]
  ) as $concepts |
  if ($concepts | length) > 1 then
    error("Multiple encounter codings in Encounter/\(.id) code")
  elif ($concepts | length) == 0 then
    empty
  else
    $concepts[0].concept
  end
;

Encounter |
[
  "visit_occurrence",           # TABLE COLUMNS
    .id,                          # visit_occurrence_id
    .subject.id,                  # person_id
    visit.concept_id,             # visit_concept_id
    .period.start,                # visit_start_date
    .period.start,                # visit_start_datetime
    .period.end,                  # visit_end_date
    .period.end,                  # visit_end_datetime
    44818518,                     # visit_type_concept_id - EHR visit
    primary_performer.id,         # provider_id
    .location[0].location.id,     # care_site_id
    null,                         # visit_source_value
    null,                         # visit_source_concept_id
    null,                         # admitted_from_concept_id
    null,                         # admitted_from_source_value
    null,                         # discharge_to_concept_id
    null,                         # discharge_to_source_value
    null                          # preceding_visit_occurrence_id
],
[
  "condition_occurrence",              # TABLE COLUMNS
    .id,                                 # condition_occurrence_id
    .subject.id,                         # person_id
    condition.concept.concept_id,        # condition_concept_id
    .period.start,                       # condition_start_date
    .period.start,                       # condition_start_datetime
    .period.end,                         # condition_end_date 
    .period.end,                         # condition_end_datetime
    32817,                               # condition_type_concept_id  # provenance: EHR
    null,                                # condition_status_concept_id
    null,                                # stop_reason
    primary_performer.id,                # provider_id
    .id,                                 # visit_occurrence_id
    null,                                # visit_detail_id
    condition.concept_code,              # condition_source_value
    condition.source_concept_id,         # condition_source_concept_id
    null                                 # condition_status_source_value
],
[
  "observation",             # TABLE COLUMNS
    .id,                       # observation_id
    .subject.id,               # person_id
    observation.concept_id,    # observation_concept_id
    .period.start,             # observation_date
    .period.start,             # observation_datetime
    32817,                     # observation_type_concept_id - source EHR
    null,                      # value_as_number
    null,                      # value_as_string
    null,                      # value_as_concept_id
    null,                      # qualifier_concept_id
    null,                      # unit_concept_id
    primary_performer.id,      # provider_id
    .id,                       # visit_occurrence_id
    null,                      # visit_detail_id
    observation.concept_code,  # observation_source_value
    observation.concept_id,    # observation_source_concept_id
    null,                      # unit_source_value
    null,                      # qualifier_source_value
    null,                      # value_source_value
    .id,                       # observation_event_id
    null                       # obs_event_field_concept_id
],
[
  "procedure_occurrence",       # TABLE COLUMNS
    .id,                          # procedure_occurrence_id
    .subject.id,                  # person_id
    procedure.concept_id,         # procedure_concept_id
    .period.start,                # procedure_date
    .period.start,                # procedure_datetime
    .period.end,                  # procedure_end_date
    .period.end,                  # procedure_end_datetime
    32817,                        # procedure_type_concept_id - source EHR
    null,                         # modifier_concept_id
    null,                         # quantity
    primary_performer.id,         # provider_id
    .id,                          # visit_occurrence_id
    null,                         # visit_detail_id
    procedure.concept_code,       # procedure_source_value
    procedure.source_concept_id,  # procedure_source_concept_id
    null                          # modifier_source_value
]
| select(
  ((.[0] == "condition_occurrence") and length == 17) or
  ((.[0] == "visit_occurrence") and length == 18) or
  ((.[0] == "observation") and length == 22) or
  ((.[0] == "procedure_occurrence") and length == 17)
)
|
@tsv
