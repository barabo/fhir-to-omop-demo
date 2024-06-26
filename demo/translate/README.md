# Notes

This is the directory where the conversion of FHIR to OMOP takes place.

## Mapping

The OMOPCDM tables do not usually have a one-to-one mapping with FHIR
resources.

To illustrate this, the FHIR resources provided in the coherent data set
were scanned to extract each of the `"code"` from each resource type.
These values were then joined to the `concept` terminology table to get the
assocated `domain_id`.

For example, the following codable concept was found in an Encounter FHIR
resource.

```js
{
  "resourceType": "Encounter",
...
  "type": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "185349003",
          "display": "Encounter for check up (procedure)"
        }
      ],
      "text": "Encounter for check up (procedure)"
    }
  ],
...
```

Despite the wording for the `visit_occurrence` OMOPCDM table:

> This table contains Events where Persons engage with the healthcare system for a duration of time. They are often also called “Encounters”.

If you keep reading their documentation, you will see this:

> Populate this [...] based on the kind of visit that took place for the person. For example this could be "Inpatient Visit", "Outpatient Visit", "Ambulatory Visit", etc. This table will contain standard concepts in the Visit domain.

In other words, not all "encounters" qualify as entries in the
`visit_occurrence` table - they must be within the "Visit" domain.  So, when
looking at a FHIR Encounter resource, we need to know if the particular type
of encounter code qualifies as a "Visit" in OMOPCDM parlance.

The SNOMED code `185349003` in the example above matches a record in the
`concept` table in the terminology database.

| `concept` column   | value                  |
| ------------------ | ---------------------- |
| `concept_id`       | 4085799                |
| `concept_name`     | Encounter for check up |
| `domain_id`        | Observation            |
| `vocabulary_id`    | SNOMED                 |
| `concept_class_id` | Procedure              |
| `standard_concept` | S                      |
| `concept_code`     | 185349003              |
| `valid_start_date` | 20020131               |
| `valid_end_date`   | 20991231               |
| `invalid_reason`   |                        |

Although this code was used to describe the type of a FHIR Encounter, the
concept code matches it to the domain of `Observation`, so this record will
likely contribute to the OMOPCDM `observation`, `measurement`, or 
`procedure_occurrence` tables (not the `visit_occurrence` table).

So, while the `domain_id` does not directly map to individual OMOPCDM tables, the
`domain_id` of a code is a valuable clue for determining where in OMOPCDM
the FHIR data will be needed, and whether a resource can be used to populate a
table entry.

<details><summary>Click to see the relationship between resource codings and concept domains...</summary>

### Resource Type to `domain_id`

|   `fhir_resource_type`   | `resource_domains` | `total_concept_codes` |
| ------------------------ | ------------------ | --------------------- |
| AllergyIntolerance       | 1                | 106                 |
| CarePlan                 | 4                | 19950               |
| CareTeam                 | 3                | 33834               |
| Claim                    | 7                | 462871              |
| Condition                | 2                | 15956               |
| Device                   | 1                | 416                 |
| DiagnosticReport         | 3                | 632990              |
| DocumentReference        | 1                | 287892              |
| Encounter                | 4                | 181252              |
| ExplanationOfBenefit     | 11               | 3593275             |
| ImagingStudy             | 4                | 10688               |
| Immunization             | 7                | 37531               |
| Media                    | 1                | 1072                |
| Medication               | 2                | 1489                |
| MedicationAdministration | 2                | 1489                |
| MedicationRequest        | 3                | 214792              |
| Observation              | 6                | 1341652             |
| Patient                  | 7                | 10224               |
| PractitionerRole         | 1                | 2082                |
| Procedure                | 3                | 56092               |

<details><summary>Click to see the details...</summary>

|   `fhir_resource_type`   |    `domain_id`     | `total_concept_codes` |
| ------------------------ | ------------------ | --------------------- |
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

</details>

---
### `domain_id` to Resource Type

|    `domain_id`     | `resource_types` | `total_concept_codes` |
| ------------------ | -------------- | ------------------- |
| Condition          | 7              | 128833              |
| Device             | 1              | 416                 |
| Drug               | 4              | 212029              |
| Gender             | 1              | 1018                |
| Geography          | 4              | 7054                |
| Meas Value         | 1              | 4071                |
| Measurement        | 9              | 1007711             |
| Metadata           | 1              | 227895              |
| Note               | 2              | 863676              |
| Observation        | 14             | 971219              |
| Payer              | 3              | 420292              |
| Procedure          | 9              | 781962              |
| Provider           | 5              | 464513              |
| Race               | 1              | 227895              |
| Revenue Code       | 1              | 1                   |
| Spec Anatomic Site | 1              | 3752                |
| Type Concept       | 1              | 1858                |
| Unit               | 3              | 798558              |
| Visit              | 5              | 782900              |

<details><summary>Click to see the details...</summary>

|     domain_id      |    fhir_resource_type    | total_concept_codes |
| ------------------ | ------------------------ | ------------------- |
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

</details>

---

</details>

---
### The Problem

So, the problem is that we seem to need a database lookup for codes in
the FHIR resource, and there are many codes to potentially resolve.  It
would be slow to interact with a database for each code, so what should we do?

The answer is with `jq` custom modules, and with the `fhir-jq` tool, which
provides such a module (and helpers) for working with FHIR resource json.

This mechanism is encapsulated in the accompanying repo, `fhir-jq`.


### `fhir-jq`

At this point you should confirm that you have `fhir-jq` installed and ready
to go.  If this command doesn't work for you, please visit the Installation
instructions in the `fhir-jq` README.

```bash
fhir-jq -rn 'include "fhir"; "SUCCESS"'
```

If you see the error, `command not found: fhir-jq`, it means that either the
tool is not installed, or it's not visible from your `$PATH`.

If you see no output at all, it means the tool was installed, but it has not
loaded the `"fhir"` module correctly.  Check that your `FHIR_JQ` environment
variable points to a directory with the `fhir-jq` module content.

If you see `SUCCESS`, you're ready!


### Process

The mapping process uses the `fhir-jq` tool (and `jq` language) to pre-load
some of the most commonly seen concept codes.  This helps determine whether
certain resources are eligible for mapping to OMOPCDM tables while they are being
scanned and without the use of a database.

See the README.md in the `data/translate/mapping` directory for more details.
