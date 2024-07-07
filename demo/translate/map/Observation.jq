#
# TODO: consider always using the encounter/ID for the visit_occurrence_id.
#

include "fhir";
include "fhir/common";


# An alias for the unit of the measurement.
def unit:
  .valueQuantity.concept
;

def category:
  .category[0].coding[0].code
;

def obs_source:
# TODO: print an error if there are multiple.
  .code.coding[0]
;

def obs_concept:
  obs_source.concept
;

# Skip Observations that are of a category that OMOP says don't belong in the
# observation table.
def skip(type):
  if .category[].coding[].code == type then empty end
;

# Route any skippeded Observations, extracting information needed for the
# relevant destination tables.
def keep(type):
  if .category[].coding[].code != type then empty end
;

def condition:
  if .code.coding[0].concept.domain_id == "Condition" then
    .code.coding[0].concept
  else
    empty
  end
;

def device:
  if .code.coding[0].concept.domain_id == "Device" then
    .code.coding[0].concept
  else
    empty
  end
;

def drug:
  if .code.coding[0].concept.domain_id == "Drug" then
    .code.coding[0].concept
  else
    empty
  end
;

def measurement:
  if .code.coding[0].concept.domain_id == "Measurement" then
    .code.coding[0].concept
  else
    empty
  end
;

def observation:
  if (.code.coding[0].concept.domain_id | IN(["Condition", "Procedure", "Drug", "Measurement", "Device"][])) then
    empty
  else
    .code.coding[0].concept
  end
;

def procedure:
  if .code.coding[0].concept.domain_id == "Procedure" then
    .code.coding[0].concept
  else
    empty
  end
;

Observation |
[
  "condition_occurrence",
  .id,                    # condition_occurrence_id
  .subject.id,            # person_id
  condition.concept_id,   # condition_concept_id
  .effectiveDateTime,     # condition_start_date
  .effectiveDateTime,     # condition_start_datetime
  .effectiveDateTime,     # condition_end_date
  .effectiveDateTime,     # condition_end_datetime
  32817,                  # condition_type_concept_id - source EHR
  null,                   # condition_status_concept_id
  null,                   # stop_reason
  null,                   # provider_id - filled in by Encounter
  null,                   # visit_occurrence_id - filled in by Encounter
  null,                   # visit_detail_id - filled in by Encounter
  condition.concept_code, # condition_source_value
  null,  # TODO: insert the source_concept_id of SNOMED/LOINC into the concept
  null   # TOD): pick the best field for this.
],
[
  "device_exposure",
  .id,                    # device_exposure_id
  .subject.id,            # person_id
  device.concept_id,      # device_concept_id
  .effectiveDateTime,     # device_exposure_start_date
  .effectiveDateTime,     # device_exposure_start_datetime
  .effectiveDateTime,     # device_exposure_end_date
  .effectiveDateTime,     # device_exposure_end_datetime
  32817,                  # device_type_concept_id - source EHR
  null,                   # unique_device_id
  null,                   # production_id
  null,                   # quantity
  null,                   # provider_id - filled in by Encounter
  null,                   # visit_occurrence_id - filled in by Encounter
  null,                   # visit_detail_id - filled in by Encounter
  device.concept_code,    # device_source_value
  null, # TODO: insert the source_concept_id of SNOMED/LOINC into the concept
  null,  #unit.concept_id         # unit_concept_id
  null,  #unit.concept_code       # unit_source_value
  null   #unit.source_concept_id  # unit_source_concept_id
],
[
  "drug_exposure",
  .id,                    # drug_exposure_id
  .subject.id,            # person_id
  drug.concept_id,        # drug_concept_id
  .effectiveDateTime,     # drug_exposure_start_date
  .effectiveDateTime,     # drug_exposure_start_datetime
  .effectiveDateTime,     # drug_exposure_end_date
  .effectiveDateTime,     # drug_exposure_end_datetime
  null,                   # verbatim_end_date
  32817,                  # drug_type_concept_id - source EHR
  null,                   # stop_reason
  null,                   # refills
  null,                   # quantity
  null,                   # days_supply
  null,                   # sig
  null,                   # route_concept_id
  null,                   # lot_number
  null,                   # provider_id - filled in by Encounter
  null,                   # visit_occurrence_id - filled in by Encounter
  null,                   # visit_detail_id - filled in by Encounter
  drug.concept_code,      # drug_source_value
  null,  # TODO: insert the source_concept_id of SNOMED/LOINC into the concept
  null,  # route_source_value
  null   # dose_unit_source_value
],
[
  "measurement",
  .id,                    # measurement_id
  .subject.id,            # person_id
  measurement.concept_id, # measurement_concept_id
  .effectiveDateTime,     # measurement_date
  .effectiveDateTime,     # measurement_datetime
  null,                   # measurement_time
  32817,                  # measurement_type_concept_id - source EHR
  null,                   # operator_concept_id
  null,                   # value_as_number
  null,                   # value_as_concept_id
  null,                   # unit_concept_id
  null,                   # range_low
  null,                   # range_high
  null,                   # provider_id - filled in by Encounter
  null,                   # visit_occurrence_id - filled in by Encounter
  null,                   # visit_detail_id - filled in by Encounter
  measurement.concept_code, # measurement_source_value
  null,  # TODO: insert the source_concept_id of SNOMED/LOINC into the concept
  null,  # unit_source_value
  null,  # unit_source_concept_id
  null,  # value_source_value
  null,  # measurement_event_id
  null   # meas_event_field_concept_id
],
  # This CAN'T be condition, procedure, drug measurement, or device domains.
[
  "observation",           # TABLE COLUMNS
    .id,                     # observation_id
    .subject.id,             # person_id
    observation.concept_id,  # observation_concept_id
    .effectiveDateTime,      # observation_date
    .effectiveDateTime,      # observation_datetime
    32817,                   # observation_type_concept_id - source EHR
    .valueQuantity.value,    # value_as_number
    .valueString,            # value_as_string
    null, # value_as_concept_id
    null, # qualifier_concept_id
    unit.concept_id,         # unit_concept_id
    # These three should potentially come from an Encounter resource.
    null, # provider_id - See Encounter!
    null, # visit_occurrence_id - See Encounter!
    null, # visit_detail_id - see Encounter!

    obs_source.code,         # observation_source_value
    obs_concept.concept_id,  # observation_source_concept_id
    .valueQuantity.unit,     # unit_source_value
    null, # qualifier_source_value
    .valueQuantity.value,    # value_source_value
    null, # observation_event_id
    null  # obs_event_field_concept_id
],
[
  "procedure_occurrence",
  .id,                    # procedure_occurrence_id
  .subject.id,            # person_id
  procedure.concept_id,   # procedure_concept_id
  .effectiveDateTime,     # procedure_date
  .effectiveDateTime,     # procedure_datetime
  .effectiveDateTime,     # procedure_end_date
  .effectiveDateTime,     # procedure_end_datetime
  32817,                  # procedure_type_concept_id - source EHR
  null,                   # modifier_concept_id
  1,                      # quantity
  null,                   # provider_id - filled in by Encounter
  null,                   # visit_occurrence_id - filled in by Encounter
  null,                   # visit_detail_id - filled in by Encounter
  procedure.concept_code, # procedure_source_value
  null, # TODO: insert the source_concept_id of SNOMED/LOINC into the concept
  null                    # modifier_source_value
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
