#
# Maps FHIR R4 Organization to OMOPCDM 5.4 care_site.
#
include "fhir";

def synthea_id:
  .identifier[0].value
;


Organization |
[
  "care_site",  # TABLE
  .id,          # care_site_id
  .name,        # care_site_name
  null,         # place_of_service_concept_id
  null,         # location_id - comes from FHIR Location
  synthea_id,   # care_site_source_value
  null          # place_of_service_source_value
]
|
@tsv
