#
# Transforms FHIR Patients into OMOP person table records.
#

include "fhir";
include "fhir/common";

def yob: .birthDate | split("-")[0] | tonumber;
def mob: .birthDate | split("-")[1] | tonumber;
def dob: .birthDate | split("-")[2] | tonumber;

def gender:
  (
    [
      .extension[]
      | select(.url == "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex")
    ]
  ) as $gender |
  if ($gender | length) > 1 then
    debug("Patient/\(.id) has multiple genders") |
    $gender[0]
  elif ($gender | length) == 1 then
    $gender[0]
  else
    debug("Patient/\(.id) has no gender") |
    null
  end
;

def gender_concept_id:
  gender as $gender |
  if $gender.valueCode == "M" then
    8507
  elif $gender.valueCode == "F" then
    8532
  else
    debug("Unable to determine gender for Patient/\(.id)") |
    null
  end
;

def ethnicity:
  (
    [
      .extension[]
      | select(.url == "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity")
      | .extension[]
      | select(has("valueCoding"))
      | .valueCoding
    ]
  ) as $ethnicity |
  if ($ethnicity | length) > 1 then
    debug("Multiple ethnicities in Patient/\(.id)") |
    $ethnicity[0].concept
  elif ($ethnicity | length) == 1 then
    $ethnicity[0].concept
  else
    debug("Patient/\(.id) has no ethnicity") |
    null
  end
;

def race:
  (
    [
      .extension[]
      | select(.url == "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race")
      | .extension[]
      | select(has("valueCoding"))
      | .valueCoding
    ]
  ) as $races |
  if ($races | length) > 1 then
    debug("Multiple races in Patient/\(.id)") |
    $races[0].concept
  elif ($races | length) == 1 then
    $races[0].concept
  else
    debug("Patient/\(.id) has no race") |
    null
  end
;

# Creates a link that work in the local hapi server.
def hapi_url:
  # Would be nicer if there was a module for accessing env variables for this.
  "http://localhost:8080/Patient/\(.id)"
;

Patient |
[
  "person",                    # OMOP person table
    .id,                         # person_id
    gender_concept_id,           # gender_concept_id
    yob,                         # year_of_birth
    mob,                         # month_of_birth
    dob,                         # day_of_birth
    null,                        # birth_datetime
    race.concept_id,             # race_concept_id
    ethnicity.concept_id,        # ethnicity_concept_id
    null,                        # location_id
    null,                        # provider_id - last seen general practitioner
    null,                        # care_site_id - the location of their provider
    hapi_url,                    # person_source_value
    gender.valueCode,            # gender_source_value
    null,                        # gender_source_concept_id
    race.concept_code,           # race_source_value
    race.source_concept_id,      # race_source_concept_id
    ethnicity.concept_code,      # ethnicity_source_value
    ethnicity.source_concept_id  # ethnicity_source_concept_id
]
|
@tsv
