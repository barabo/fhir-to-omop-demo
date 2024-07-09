#
# Transforms FHIR Observations into OMOP table records.
#

include "fhir";
include "fhir/common";


# An alias for the unit of the measurement.
def unit:
  .valueQuantity.concept
;

def code_concept(domain):
  (.code.coding[] | [select(.concept.domain_id == domain)]) as $concepts |
  if ($concepts | length) > 1 then
    error("Multiple \(domain) codings in Observation/\(.id) code: \($concepts)")
  elif ($concepts | length) == 0 then
    empty
  else
    $concepts[0].concept
  end
;

def condition: code_concept("Condition");
def device: code_concept("Device");
def drug: code_concept("Drug");
def measurement: code_concept("Measurement");
def procedure: code_concept("Procedure");

def observation:
  ["Condition", "Device", "Drug", "Measurement", "Procedure"] as $forbidden |
  (
    .code.coding[]
    | [select(.concept.domain_id | IN($forbidden[]) | not)]
  ) as $concepts |
  if ($concepts | length) > 1 then
    error("Multiple observation codings in Observation/\(.id) code")
  elif ($concepts | length) == 0 then
    empty
  else
    $concepts[0].concept
  end
;


# HACK: the coherent data set is missing codes for DNA observations, which
#       should be considered laboratory tests.  This inserts a laboratory
#       code for any observation category that doesn't have a code.
.category |= map(
  .coding |= map(
    if has("code") | not then . + {"code": "laboratory"} else . end
  )
) |

Observation |
[
  "condition_occurrence",       # TABLE COLUMNS
    .id,                          # condition_occurrence_id
    .subject.id,                  # person_id
    condition.concept_id,         # condition_concept_id
    .effectiveDateTime,           # condition_start_date
    .effectiveDateTime,           # condition_start_datetime
    .effectiveDateTime,           # condition_end_date
    .effectiveDateTime,           # condition_end_datetime
    32817,                        # condition_type_concept_id - source EHR
    null,                         # condition_status_concept_id
    null,                         # stop_reason
    null,                         # provider_id - filled in by Encounter
    .encounter.id,                # visit_occurrence_id
    null,                         # visit_detail_id - filled in by Encounter
    condition.concept_code,       # condition_source_value
    condition.source_concept_id,  # condition_source_concept_id
    null                          # TODO: pick the best field for this.
],
[
  "device_exposure",         # TABLE COLUMNS
    .id,                       # device_exposure_id
    .subject.id,               # person_id
    device.concept_id,         # device_concept_id
    .effectiveDateTime,        # device_exposure_start_date
    .effectiveDateTime,        # device_exposure_start_datetime
    .effectiveDateTime,        # device_exposure_end_date
    .effectiveDateTime,        # device_exposure_end_datetime
    32817,                     # device_type_concept_id - source EHR
    null,                      # unique_device_id
    null,                      # production_id
    null,                      # quantity
    null,                      # provider_id - filled in by Encounter
    .encounter.id,             # visit_occurrence_id
    null,                      # visit_detail_id - filled in by Encounter
    device.concept_code,       # device_source_value
    device.source_concept_id,  # device_source_concept_id
    null,                      # unit_concept_id
    null,                      # unit_source_value
    null                       # unit_source_concept_id
],
[
  "drug_exposure",         # TABLE COLUMNS
    .id,                     # drug_exposure_id
    .subject.id,             # person_id
    drug.concept_id,         # drug_concept_id
    .effectiveDateTime,      # drug_exposure_start_date
    .effectiveDateTime,      # drug_exposure_start_datetime
    .effectiveDateTime,      # drug_exposure_end_date
    .effectiveDateTime,      # drug_exposure_end_datetime
    null,                    # verbatim_end_date
    32817,                   # drug_type_concept_id - source EHR
    null,                    # stop_reason
    null,                    # refills
    null,                    # quantity
    null,                    # days_supply
    null,                    # sig
    null,                    # route_concept_id
    null,                    # lot_number
    null,                    # provider_id - filled in by Encounter
    .encounter.id,           # visit_occurrence_id
    null,                    # visit_detail_id - filled in by Encounter
    drug.concept_code,       # drug_source_value
    drug.source_concept_id,  # drug_source_concept_id
    null,                    # route_source_value
    null                     # dose_unit_source_value
],
[
  "measurement",                  # TABLE COLUMNS
    .id,                            # measurement_id
    .subject.id,                    # person_id
    measurement.concept_id,         # measurement_concept_id
    .effectiveDateTime,             # measurement_date
    .effectiveDateTime,             # measurement_datetime
    null,                           # measurement_time
    32817,                          # measurement_type_concept_id - source EHR
    null,                           # operator_concept_id
    .valueQuantity.value,           # value_as_number
    null,                           # value_as_concept_id
    unit.concept_id,                # unit_concept_id
    null,                           # range_low
    null,                           # range_high
    null,                           # provider_id - filled in by Encounter
    .encounter.id,                  # visit_occurrence_id
    null,                           # visit_detail_id - filled in by Encounter
    measurement.concept_code,       # measurement_source_value
    measurement.source_concept_id,  # source_concept_id
    .valueQuantity.code,            # unit_source_value
    unit.source_concept_id,         # unit_source_concept_id
    null,                           # value_source_value
    .encounter.id,                  # measurement_event_id
    null                            # meas_event_field_concept_id
],
  # This CAN'T be condition, procedure, drug measurement, or device domains.
[
  "observation",             # TABLE COLUMNS
    .id,                       # observation_id
    .subject.id,               # person_id
    observation.concept_id,    # observation_concept_id
    .effectiveDateTime,        # observation_date
    .effectiveDateTime,        # observation_datetime
    32817,                     # observation_type_concept_id - source EHR
    .valueQuantity.value,      # value_as_number
    .valueString,              # value_as_string
    null,                      # value_as_concept_id
    null,                      # qualifier_concept_id
    unit.concept_id,           # unit_concept_id
    null,                      # provider_id - See Encounter!
    .encounter.id,             # visit_occurrence_id
    null,                      # visit_detail_id - see Encounter!
    observation.concept_code,  # observation_source_value
    observation.concept_id,    # observation_source_concept_id
    .valueQuantity.unit,       # unit_source_value
    null,                      # qualifier_source_value
    .valueQuantity.value,      # value_source_value
    .encounter.id,             # observation_event_id
    null                       # obs_event_field_concept_id
],
[
  "procedure_occurrence",       # TABLE COLUMNS
    .id,                          # procedure_occurrence_id
    .subject.id,                  # person_id
    procedure.concept_id,         # procedure_concept_id
    .effectiveDateTime,           # procedure_date
    .effectiveDateTime,           # procedure_datetime
    .effectiveDateTime,           # procedure_end_date
    .effectiveDateTime,           # procedure_end_datetime
    32817,                        # procedure_type_concept_id - source EHR
    null,                         # modifier_concept_id
    1,                            # quantity
    null,                         # provider_id - filled in by Encounter
    .encounter.id,                # visit_occurrence_id
    null,                         # visit_detail_id - filled in by Encounter
    procedure.concept_code,       # procedure_source_value
    procedure.source_concept_id,  # procedure_source_concept_id
    null                          # modifier_source_value
]
# Filter out Observations that don't have the expected number of fields.
| select(
  ((.[0] == "condition_occurrence") and length == 17) or
  ((.[0] == "device_exposure") and length == 20) or
  ((.[0] == "drug_exposure") and length == 24) or
  ((.[0] == "measurement") and length == 24) or
  ((.[0] == "observation") and length == 22) or
  ((.[0] == "procedure_occurrence") and length == 17)
)
|
@tsv
