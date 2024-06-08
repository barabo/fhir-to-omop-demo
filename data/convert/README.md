# Notes

This is the directory where the conversion of FHIR to OMOP takes place.

## Mapping

The OMOPCDM tables do not usually have a one-to-one mapping with FHIR
resources.

To illustrate this, the FHIR resources provided in the coherent data set
were scanned to extract each of the `"code"` and `"system"` pairs from each
resource type.  These values were then joined to the `concept` terminology
table to get the assocated `domain_id`.

For example, the following codable concept was found in a FHIR resource.

```js
{
  "system": "http://snomed.info/sct",
  "code": "185349003",
  "display": "Encounter for check up (procedure)"
}
```

The `code` value `185349003` and `system` value `http://snomed.info/sct`
were used to find matching records in the `concept` terminology database.

While the `domain_id` values do not directly map to OMOPCDM tables, the
OMOPCDM tables are more closely related to the `domain_id` than the FHIR
resource types atr.

<details><summary>Click to see the results of this analysis...</summary>

### Resource Type to `domain_id`

+--------------------------+--------------------+---------------------+
|   `fhir_resource_type`   |    `domain_id`     | `total_concept_codes` |
+--------------------------+--------------------+---------------------+
| AllergyIntolerance       | Observation        | 106                 |
| CarePlan                 | Procedure          | 9797                |
| CarePlan                 | Observation        | 8188                |
| CarePlan                 | Type Concept       | 1858                |
| CarePlan                 | Measurement        | 107                 |
| CareTeam                 | Observation        | 21760               |
| CareTeam                 | Provider           | 6135                |
| CareTeam                 | Condition          | 5939                |
| Claim                    | Observation        | 215779              |
| Claim                    | Procedure          | 203039              |
| Claim                    | Condition          | 27462               |
| Claim                    | Visit              | 12083               |
| Claim                    | Measurement        | 3247                |
| Claim                    | Payer              | 1092                |
| Claim                    | Provider           | 169                 |
| Condition                | Condition          | 14191               |
| Condition                | Observation        | 1765                |
| Device                   | Device             | 416                 |
| DiagnosticReport         | Note               | 575784              |
| DiagnosticReport         | Measurement        | 55964               |
| DiagnosticReport         | Observation        | 1242                |
| DocumentReference        | Note               | 287892              |
| Encounter                | Observation        | 90952               |
| Encounter                | Procedure          | 53746               |
| Encounter                | Condition          | 36142               |
| Encounter                | Visit              | 412                 |
| ExplanationOfBenefit     | Visit              | 758062              |
| ExplanationOfBenefit     | Observation        | 560611              |
| ExplanationOfBenefit     | Procedure          | 459488              |
| ExplanationOfBenefit     | Provider           | 455958              |
| ExplanationOfBenefit     | Payer              | 418108              |
| ExplanationOfBenefit     | Measurement        | 231141              |
| ExplanationOfBenefit     | Race               | 227895              |
| ExplanationOfBenefit     | Metadata           | 227895              |
| ExplanationOfBenefit     | Unit               | 227894              |
| ExplanationOfBenefit     | Condition          | 26222               |
| ExplanationOfBenefit     | Revenue Code       | 1                   |
| ImagingStudy             | Observation        | 5674                |
| ImagingStudy             | Spec Anatomic Site | 3752                |
| ImagingStudy             | Measurement        | 1179                |
| ImagingStudy             | Geography          | 83                  |
| Immunization             | Observation        | 12891               |
| Immunization             | Visit              | 12083               |
| Immunization             | Condition          | 10843               |
| Immunization             | Payer              | 1092                |
| Immunization             | Measurement        | 270                 |
| Immunization             | Procedure          | 183                 |
| Immunization             | Provider           | 169                 |
| Media                    | Procedure          | 1072                |
| Medication               | Drug               | 1350                |
| Medication               | Geography          | 139                 |
| MedicationAdministration | Drug               | 1350                |
| MedicationAdministration | Geography          | 139                 |
| MedicationRequest        | Drug               | 208051              |
| MedicationRequest        | Geography          | 6693                |
| MedicationRequest        | Observation        | 48                  |
| Observation              | Measurement        | 708992              |
| Observation              | Unit               | 570404              |
| Observation              | Observation        | 48964               |
| Observation              | Condition          | 8034                |
| Observation              | Meas Value         | 4071                |
| Observation              | Procedure          | 1187                |
| Patient                  | Measurement        | 3834                |
| Patient                  | Observation        | 2296                |
| Patient                  | Procedure          | 1278                |
| Patient                  | Drug               | 1278                |
| Patient                  | Gender             | 1018                |
| Patient                  | Visit              | 260                 |
| Patient                  | Unit               | 260                 |
| PractitionerRole         | Provider           | 2082                |
| Procedure                | Procedure          | 52172               |
| Procedure                | Measurement        | 2977                |
| Procedure                | Observation        | 943                 |
+--------------------------+--------------------+---------------------+

### `domain_id` to Resource Type

+--------------------+--------------------------+---------------------+
|     domain_id      |    fhir_resource_type    | total_concept_codes |
+--------------------+--------------------------+---------------------+
| Condition          | Encounter                | 36142               |
| Condition          | Claim                    | 27462               |
| Condition          | ExplanationOfBenefit     | 26222               |
| Condition          | Condition                | 14191               |
| Condition          | Immunization             | 10843               |
| Condition          | Observation              | 8034                |
| Condition          | CareTeam                 | 5939                |
| Device             | Device                   | 416                 |
| Drug               | MedicationRequest        | 208051              |
| Drug               | MedicationAdministration | 1350                |
| Drug               | Medication               | 1350                |
| Drug               | Patient                  | 1278                |
| Gender             | Patient                  | 1018                |
| Geography          | MedicationRequest        | 6693                |
| Geography          | MedicationAdministration | 139                 |
| Geography          | Medication               | 139                 |
| Geography          | ImagingStudy             | 83                  |
| Meas Value         | Observation              | 4071                |
| Measurement        | Observation              | 708992              |
| Measurement        | ExplanationOfBenefit     | 231141              |
| Measurement        | DiagnosticReport         | 55964               |
| Measurement        | Patient                  | 3834                |
| Measurement        | Claim                    | 3247                |
| Measurement        | Procedure                | 2977                |
| Measurement        | ImagingStudy             | 1179                |
| Measurement        | Immunization             | 270                 |
| Measurement        | CarePlan                 | 107                 |
| Metadata           | ExplanationOfBenefit     | 227895              |
| Note               | DiagnosticReport         | 575784              |
| Note               | DocumentReference        | 287892              |
| Observation        | ExplanationOfBenefit     | 560611              |
| Observation        | Claim                    | 215779              |
| Observation        | Encounter                | 90952               |
| Observation        | Observation              | 48964               |
| Observation        | CareTeam                 | 21760               |
| Observation        | Immunization             | 12891               |
| Observation        | CarePlan                 | 8188                |
| Observation        | ImagingStudy             | 5674                |
| Observation        | Patient                  | 2296                |
| Observation        | Condition                | 1765                |
| Observation        | DiagnosticReport         | 1242                |
| Observation        | Procedure                | 943                 |
| Observation        | AllergyIntolerance       | 106                 |
| Observation        | MedicationRequest        | 48                  |
| Payer              | ExplanationOfBenefit     | 418108              |
| Payer              | Immunization             | 1092                |
| Payer              | Claim                    | 1092                |
| Procedure          | ExplanationOfBenefit     | 459488              |
| Procedure          | Claim                    | 203039              |
| Procedure          | Encounter                | 53746               |
| Procedure          | Procedure                | 52172               |
| Procedure          | CarePlan                 | 9797                |
| Procedure          | Patient                  | 1278                |
| Procedure          | Observation              | 1187                |
| Procedure          | Media                    | 1072                |
| Procedure          | Immunization             | 183                 |
| Provider           | ExplanationOfBenefit     | 455958              |
| Provider           | CareTeam                 | 6135                |
| Provider           | PractitionerRole         | 2082                |
| Provider           | Immunization             | 169                 |
| Provider           | Claim                    | 169                 |
| Race               | ExplanationOfBenefit     | 227895              |
| Revenue Code       | ExplanationOfBenefit     | 1                   |
| Spec Anatomic Site | ImagingStudy             | 3752                |
| Type Concept       | CarePlan                 | 1858                |
| Unit               | Observation              | 570404              |
| Unit               | ExplanationOfBenefit     | 227894              |
| Unit               | Patient                  | 260                 |
| Visit              | ExplanationOfBenefit     | 758062              |
| Visit              | Immunization             | 12083               |
| Visit              | Claim                    | 12083               |
| Visit              | Encounter                | 412                 |
| Visit              | Patient                  | 260                 |
+--------------------+--------------------------+---------------------+

</details>

---
### Process

The mapping process uses the `jq` tool (and language) to pre-load some of
the most commonly seen concept codes.  This helps determine whether certain
resources are eligible for mapping to OMOPCDM tables as they are being
scanned and without the use of a database.

