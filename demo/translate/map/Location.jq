#
# Maps FHIR R4 Location to OMOPCDM 5.4 location.
#

include "fhir";
include "fhir/common";


# Alias for the care_site ID from Location.
def care_site_id: .managingOrganization | dereference;


# FHIR Location
Location |
[
  "location",             # OMOP TABLE
    .id,                  # location_id
    .address.line[0],     # address_1
    .address.line[1],     # address_2
    .address.city,        # city
    .address.state,       # state
    .address.postalCode,  # zip
    null,                 # county
    .name,                # location_source_value
    4330442,              # country_concept_id     HACK
    "USA",                # country_source_value   HACK
    .position.latitude,   # latitude
    .position.longitude   # longitude
]
,
[
  "care_site",   # OMOP TABLE
  care_site_id,  # care_site_id
  null,          # care_site_name
  null,          # place_of_service_concept_id
  .id,           # location_id
  null,          # care_site_source_value
  null           # place_of_service_source_value
]
|
@tsv
