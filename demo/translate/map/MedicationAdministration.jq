#
# Transforms FHIR MedicationAdministrations into OMOP table records.
#

include "fhir";
include "fhir/common";


def drug:
  if (.medicationCodeableConcept.coding | length) > 1 then
    error("Multiple medicationCodeableConcept.codings in MedicationAdministration/\(.id)")
  end
  | .medicationCodeableConcept.coding[0].concept
;


# See: https://ohdsi.github.io/CommonDataModel/drug_dose.html
# TODO: include the 'has dose form' value in concept
# TODO: include numerator in concept
def quantity:
  if (drug | has("drug") and drug.has_dose_form) then
    drug.drug.numerator
  else
    null
  end
;

MedicationAdministration |
[
  "drug_exposure",              # TABLE COLUMNS
    .id,                          # drug_exposure_id
    .subject.id,                  # person_id
    drug.concept_id,              # drug_concept_id
    .effectiveDateTime,           # drug_exposure_start_date
    .effectiveDateTime,           # drug_exposure_start_datetime
    .effectiveDateTime,           # drug_exposure_end_date
    .effectiveDateTime,           # drug_exposure_end_datetime
    null,                         # verbatim_end_date
    32818,                        # drug_type_concept_id - EHR administration record
    null,                         # stop_reason
    null,                         # refills
    quantity,                     # quantity
    null,                         # days_supply
    .note,                        # sig
    null,                         # route_concept_id
    null,                         # lot_number
    null,                         # provider_id
    .context.id,                  # visit_occurrence_id
    null,                         # visit_detail_id
    drug.concept_code,            # drug_source_value
    drug.source_concept_id,       # drug_source_concept_id
    null,                         # route_source_value
    null                          # dose_unit_source_value
]
| select(
  ((.[0] == "drug_exposure") and length == 24)
)
|
@tsv