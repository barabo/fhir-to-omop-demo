#
# Maps FHIR Practitioner to OMOP provider
#
include "fhir";
#include "fhir/env";  # provides fhir_server_url, type, etc
#             ^ just an idea, not implemented.

# Creates a link that work in the local hapi server.
def hapi_url:
  # Would be nicer if there was a module for accessing env variables for this.
  "http://localhost:8080/Practitioner/\(.id)"
;


Practitioner |
[
  "provider",              # OMOP pracitioner table
  .id,                     # provider_id
  null,                    # provider_name
  .npi,                    # npi
  null,                    # dea
  null,                    # specialty_concept_id
  null,                    # care_site_id
  null,                    # year_of_birth
  .gender_concept_id,      # gender_concept_id
  hapi_url,                # provider_source_value       # synthea ID might be better here.
  null,                    # specialty_source_value      # See PractitionerRole: eg - "General Practice"
  null,                    # specialty_source_concept_id # See PractitionerRole: eg - 38004459
  .gender,                 # gender_source_value
  null                     # gender_source_concept_id
]
|
@tsv
