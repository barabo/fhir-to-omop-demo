#
# Map FHIR PractitionerRole to OMOP provider and person tables.
#

include "fhir";

##
# Extract the specialty concept from the PractitionerRole.
#
def specialty:
  if (.specialty | length) > 1 then
    debug("Multiple specialties in PractitionerRole/\(.id)")
  elif (.specialty | length) == 0 then
    debug("No specialty in PractitionerRole/\(.id)") |
    {
      "concept_id": null,
      "concept_code": null
    }
  elif (.specialty[0].coding | length) > 1 then
    debug("Multiple specialty codings in PractitionerRole/\(.id)")
  else
    .specialty[0].coding[0].concept
  end
;


# Any details about a provider that must come from this Resource
# are omitted here and merged into the other fields later.
# As long as we can inject the right provider_id from this resource,
# it will work.
PractitionerRole |
[
  "provider",              # OMOP pracitioner table

    #
    # Since this generates info for the provider table, the output structure
    # must conform to the provider table columns.  The id we want here is the
    # id of the practitioner, not the PractitionerRole ID in the fhir server.
    #
    .practitioner_id,        # provider_id
    .practitioner.display,   # provider_name
    null,                    # npi - covered in Practitioner.jq
    null,                    # dea
    specialty.concept_id,    # specialty_concept_id
    .location_ids[0],        # care_site_id
    null,                    # year_of_birth
    null,                    # gender_concept_id
    null,                    # provider_source_value
    specialty.concept_code,  # specialty_source_value
    null,                    # specialty_source_concept_id
    null,                    # gender_source_value
    null                     # gender_source_concept_id
],

# The PractitionerRole contains the care_site_id and location_id, but this
# is missing from the Practitioner, so these fields are emitted here and will
# be merged into the "person" table record later.
[
  "person",                # OMOP person table
    .practitioner_id,        # person_id
    null,                    # gender_concept_id
    .year_of_birth,          # year_of_birth
    null,                    # month_of_birth
    null,                    # day_of_birth
    null,                    # birth_datetime
    null,                    # race_concept_id
    null,                    # ethnicity_concept_id
    .location_ids[0],        # location_id
    null,                    # provider_id
    .location_ids[0],        # care_site_id
    null,                    # person_source_value
    null,                    # gender_source_value
    null,                    # gender_source_concept_id
    null,                    # race_source_value
    null,                    # race_source_concept_id
    null,                    # ethnicity_source_value
    null                     # ethnicity_source_concept_id
]
|
@tsv
