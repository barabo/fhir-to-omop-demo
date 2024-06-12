#
#
#

include "fhir";

def specialty:
  .specialty[0].coding[0].concept
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
  # provider_id
  .pracitioner_id,
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
]
|
@tsv