[//]: # Link references!
[coherent]: https://www.mdpi.com/2079-9292/11/8/1199
[fhir-to-omop]: https://github.com/barabo/fhir-to-omop-demo
[NDJSON]: https://github.com/ndjson/ndjson-spec

# Introduction

This document is a reference for the custom `jq` functions that enable fast,
readable, efficient, and extensible mapping capabilities from FHIR to OMOP.

<details><summary>Click to read the background on why this exists...</summary>

## Background

This guide was written as part of a [fhir-to-omop] demo, which was presented
at the HL7 FHIR DevDays conference in June, 2024.  The scope of the DevDays
demo was purely to convert the Mitre [coherent] FHIR data into OMOP and load
it into a sqlite3 database.

### sqlite

I picked sqlite because I didn't want to spend time setting up a 'real'
database using Docker or running one locally from scratch.  While I may have
sacrificed some performance with this decision, the tradeoff was still worth
it.  I have found sqlite to be capable, ubiquitous, fast (enough), free, and
liberating!  No network databases!

Plus, sqlite easily loads 'tab separated value' (TSV) files, which is the
default format used in terminology files downloaded from Athena.

For example, the command I would use to load `example.tsv` into the `EXAMPLE`
table in the `cdm.db` database is this:

```bash
sqlite3 cdm.db .import example.tsv EXAMPLE
```

Given the ease of importing TSV into sqlite, it's clearer why the mapping
process I wrote focuses on producing TSV.  

### [NDJSON]

I picked NDJSON as the input format to `jq` because:
* `jq` supports reading NDJSON files without any pre-processing.
* The FHIR bulk export operation explicitly demands the NDJSON format for output files.
* The HAPI implementation of `$export` separates resources into files which only contain that type of resource - this turned out to be lucky because it made it easier for me to map FHIR to OMOP.

## Assumptions

The logic presented here assumes:
* You are feeding an NDJSON file directly to `jq`.
* The input file contains exactly one FHIR R4 resource type per file
  * Note: other versions of FHIR may be supported in future releases.
* You expect to receive tab separated values as output.
  * Note: other output formats may be supported in future releases.

## Incomplete Mappings

Since some OMOP records must be synthesized from multiple different FHIR
resources, the goal of this process is to map as much as possible from
a given FHIR resource, and fill in the gaps in the output with a later pass.

# Mapping Strategy

This document doesn't cover the entire strategy for determining how to map
which fields to OMOP columns; for that, you should consult the excellent OMOP
and FHIR documentation online.  Between the two sources, it's usually possible
to identify what something means in FHIR and decide whether it's the correct
value to put in OMOP.

The code and techniques presented below describe functionality that makes it
easier to map fields from FHIR to OMOP, and produce more readable mappings for
others to inspect.

## Custom FHIR Functions

The `jq` command line tool supports the creation of custom `jq` functions,
which greatly simplify your mapping logic without sacrificing performance.

Consider the following example.  I have a FHIR R4 `Encounter` resource and I
want to map it to the OMOPCDM 5.4 `visit_occurrence` table.  I'm focusing on
one or two mappings at a time, and right now I'm trying to map just the
`visit_occurrence.start_date`, `visit_occurrence.end_date`, and
`visit_occurrence.provider_id` columns.  If this sounds straightforward - 
it's not.

The fields I need are nested in structure like this:

```json
{
  "participant": [
    {
      "type": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
              "code": "PPRF",
              "display": "primary performer"
            }
          ],
          "text": "primary performer"
        }
      ],
      "period": {
        "start": "1959-02-22T06:37:53-05:00",
        "end": "1959-02-22T06:52:53-05:00"
      },
      "individual": {
        "reference": "Practitioner/2187",
        "display": "Dr. Douglass930 Windler79"
      }
    }
  ]
}
```

<details><summary>Click to view the whole `Encounter` resource.</summary>

```json
{
  "resourceType": "Encounter",
  "id": "4218",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:19:17.304+00:00",
    "source": "#8IRCgpLiSxJLv3VD",
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter"
    ]
  },
  "identifier": [
    {
      "use": "official",
      "system": "https://github.com/synthetichealth/synthea",
      "value": "fe6a5bc3-6637-e625-daff-07fbd65c6b81"
    }
  ],
  "status": "finished",
  "class": {
    "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    "code": "AMB"
  },
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
  "subject": {
    "reference": "Patient/4217",
    "display": "Mr. Humberto482 Koss676"
  },
  "participant": [
    {
      "type": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
              "code": "PPRF",
              "display": "primary performer"
            }
          ],
          "text": "primary performer"
        }
      ],
      "period": {
        "start": "1959-02-22T06:37:53-05:00",
        "end": "1959-02-22T06:52:53-05:00"
      },
      "individual": {
        "reference": "Practitioner/2187",
        "display": "Dr. Douglass930 Windler79"
      }
    }
  ],
  "period": {
    "start": "1959-02-22T06:37:53-05:00",
    "end": "1959-02-22T06:52:53-05:00"
  },
  "location": [
    {
      "location": {
        "reference": "Location/54",
        "display": "MERCY MEDICAL CTR"
      }
    }
  ],
  "serviceProvider": {
    "reference": "Organization/53",
    "display": "MERCY MEDICAL CTR"
  }
}
```
</details>

The `period.start` and `period.end` fields are attributes of the first (and
only) `participant` element.  So, to reference them with a `jq` path
expression, I need to specify `.participant[0].period.start` to get the start
time, and `.participant[0].period.start` to get the end time.

This is fine as long as there is only one participant (i.e. clinician) for the
entire encounter.  However, a complex encounter may have several participants,
and the OMOP `visit_occurrence` table requires the earliest start date paired
with the latest end date (to cover the whole encounter).  You need something
like `min` or `max` which considers an array of dates, selecting the
correct one.  Fortunately `jq` provides these already.  The updated path
selections would look like this:

```bash
  .participant[].period.start | min,  # visit_start_date
  .participant[].period.end   | max,  # visit_end_date
```

This is correct, but we can definitely do better.  If many different FHIR
resources define a range of objects that include a `period` object that has
both a `start` and `end` date - we can define a function to select the `min`
and `max` from such a list.

Now, let's address the mapping of the `provider_id`.  If there are multiple
participants during an `Encounter`, you can only pick *one* of them to be
assigned to the `visit_occurrence.provider_id` field.  According to OMOP, how
you do that is up to you - but suppose the first participant in the list was a
triage nurse who spent five minutes with the patient and the second participant
was a Doctor who spent half an hour.  Do you use time spent with the patient to
decide who gets credit for the visit?  Fortunately, FHIR Encounters may include
a `primary performer` decorator term to suggest which one should be chosen.

This is a correct (but inscrutable) `jq` path selector to do that:

```jq
.[] |
# Select the Encounter provider who is designated the primary performer.
map(select(
  .type[].coding[] |
  [.code, .system] == ["PPRF", "http://terminology.hl7.org/CodeSystem/v3-ParticipationType"]
)) |

# Convert the "Provider/1234" reference to the numerical 1234 value.
.[].individual.reference
| split("/").[1]
| tonumber
,
```

Even with the comments, this is very hard to read and would be tedious to
write more than once.

Instead, we provide a `primary_participant` function that contains all the
complexity above in one neat little package.

This is what the final mappings should look like with custom functions:

```bash
  period_start(.[]),       # visit_start_date
  period_end(.[]),         # visit_end_date
  primary_participant(.),  # provider_id
```

As we map more and more of FHIR resources to OMOP CDM records, we can
introduce more new functions like these to make your mapping work clean and
easy to read.

</details>

---

# Reference

TODO: list the custom functions and their usage.
