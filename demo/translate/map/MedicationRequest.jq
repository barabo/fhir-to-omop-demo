#
# Transforms FHIR MedicationRequests into OMOP table records.
#

include "fhir";
include "fhir/common";


# Include the route_concept_id in the drug concept.
def drug:
  if has("medicationCodeableConcept") then
    if (.medicationCodeableConcept.coding | length) > 1 then
      error("Multiple medicationCodeableConcept.codings in MedicationRequest/\(.id)")
    end
    | .medicationCodeableConcept.coding[0].concept
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

# If this is a MedicationReference, then the contents of this record will be
# merged with the Medication record contents in the next phase of loading.
def id:
  if has("medicationReference") then
    .medicationReference.id
  else
    .id
  end
;


MedicationRequest |
[
  "drug_exposure",              # TABLE COLUMNS
    id,                           # drug_exposure_id
    .subject.id,                  # person_id
    drug.concept_id,              # drug_concept_id
    .authoredOn,                  # drug_exposure_start_date
    .authoredOn,                  # drug_exposure_start_datetime
    null,                  # drug_exposure_end_date
    null,                  # drug_exposure_end_datetime
    null,                         # verbatim_end_date
    32838,                        # drug_type_concept_id - EHR prescription
    null,                         # stop_reason
    null,                         # refills
    quantity,                     # quantity
    null,                         # days_supply
    .note,                        # sig
    drug.route_concept_id,        # route_concept_id
    null,                         # lot_number
    .requester.id,                # provider_id
    .encounter.id,                # visit_occurrence_id
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