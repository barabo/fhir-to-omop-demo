#
# Transforms FHIR Medication into OMOP table records.
#
# This transformation is needed to populate missing medication information
# from the MedicationRequest records when a MedicationReference is used.
#

include "fhir";
include "fhir/common";

##
# Select the drug concept from the Medication record.
#
def drug:
  if has("code") then
    if (.code.coding | length) > 1 then
      error("Multiple code.codings in Medication/\(.id)")
    end
    | .code.coding[0].concept
  else
    {
      "concept_id": null,
      "concept_code": null,
      "route_concept_id": null,
      "source_concept_id": null
    }
  end
;

# See: https://ohdsi.github.io/CommonDataModel/drug_dose.html
# TODO: include the 'has dose form' value in concept
# TODO: include numerator in concept
# TODO: if there is a dosageQuantity, use it, too
def quantity:
  if (drug | has("drug") and drug.has_dose_form) then
    drug.drug.numerator
  else
    null
  end
;


Medication |
[
  "drug_exposure",
    .id,                          # drug_exposure_id
    null,                         # person_id
    drug.concept_id,              # drug_concept_id
    null,                         # drug_exposure_start_date
    null,                         # drug_exposure_start_datetime
    null,                         # drug_exposure_end_date
    null,                         # drug_exposure_end_datetime
    null,                         # verbatim_end_date
    null,                         # drug_type_concept_id - EHR prescription
    null,                         # stop_reason
    null,                         # refills
    quantity,                     # quantity
    null,                         # days_supply
    null,                         # sig
    drug.route_concept_id,        # route_concept_id
    null,                         # lot_number
    null,                         # provider_id
    null,                         # visit_occurrence_id
    null,                         # visit_detail_id
    drug.concept_code,            # drug_source_value
    drug.source_concept_id,       # drug_source_concept_id
    null,                         # route_source_value
    null                          # dose_unit_source_value
]
|
@tsv
