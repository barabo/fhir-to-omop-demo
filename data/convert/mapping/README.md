[coherent]: https://www.mdpi.com/2079-9292/11/8/1199

[Location]: https://www.hl7.org/fhir/R4/Location.html
[Organization]: https://www.hl7.org/fhir/R4/Organization.html

[care_site]: https://ohdsi.github.io/CommonDataModel/cdm54.html#care_site
[location]: https://ohdsi.github.io/CommonDataModel/cdm54.html#location

# Mappings

Below we present a table that describes the mapping from FHIR to OMOP used for
this demo.  Not every FHIR resource can be directly mapped to an OMOP table
completely, so there is some nuance imposed by various discrepancies.  The
main challenges should be called out in this document, where needed.

## Mapping Table

| FHIR R4 Resource | OMOP Table | Notes |
| ---------------- | ---------- | ----- |
| [Organization]   | [location] | The latitude and longitude needed in the OMOP [location] table come from the FHIR [Location] resource, not the [Organization]. |
| [Location]       | [care_site] | |

## Caveats

Any notable caveats are called out in the sections below, which are names of
OMOPCDM tables that have been mapped.  The order of the sections below should
roughly follow the order they are mapped by the mapping process.

### `location`
* All FHIR [Location] resources in the [coherent] source data set are in the USA, so the name and `concept_id` are set statically.

### `care_site`
* placeholder

# Scripts

The process of mapping data from a bulk export file to a loadable TSV file
happens when scripts in this directory are run.

The scripts in this directory are named with a numberical prefix, which is
used to control the order in which they are run.  They should run in
ascending order, but they are not guaranteed to run sequentially.

## Parallelization

To parallelize the mapping work, groups of scripts that write to common OMOP
files can be *separated* to run in parallel to other mapping scripts.  All
parallel groups of scripts must run in ascending order relative to their
group, but as long as each group writes to different destinations, this is
allowed.

NOTE: when this setting is disabled, and all scripts will run sequentially.

To illustrate this feature, consider these scripts:

```
001_Location-location.sh
002_Practitioner-provider.sh
003_Organization-location.sh
```

Scripts `001` and `003` both write to the `location` table, so they must be
run in ascending order.  However, script `002` does not write to the `location`
table, so it could be run in parallel while scripts `001` and `003` run in
sequence.

## Boilerplate

Regarding the content of the scripts, each should have a common header that
looks like this:

```bash
#!/bin/bash
#
# Converts FHIR XXX resources to OMOPCDM YYY records.
#
source _common.sh
```

### `_common.sh`

The `_common.sh` file contains logic to deduce which type of FHIR resource is
being converted and which type of OMOPCDM data it should produce.  This
information is encoded in the script filename.

The filename format for all mapper scripts is:
`%03d-${FHIR_TYPE}-${OMOP_TYPE}.sh`

#### `simple_map`

For simple one-to-one mappings (from FHIR attribute to OMOPCDM table value) -
a function is provided to stream available FHIR resources from a bulk export
and feed the individual records through a `jq` based processor.

The only parameter that is required is a single-quoted string of
comma-separated `jq` attribute selectors.

*NOTE: the comments included in the scripts are ignored.*

## Example Mapping

```bash
simple_map '
#--------------------------#-----------------------#-----------------------------#
# FHIR Location            # OMOP location         # Notes                       #
#--------------------------#-----------------------#-----------------------------#
  .id,                     # location_id           #
  .address.line[0],        # address_1             #
  .address.line[1],        # address_2             #
  .address.city,           # city                  #
  .address.state,          # state                 #
  .address.postalCode,     # zip                   #
  null                     # county                # not available in FHIR
  .name,                   # location_source_value #
  4330442,                 # country_concept_id    # all coherent data set...
  "USA",                   # country_source_value  # locations are in the USA
  .position.latitude,      # latitude              #
  .position.longitude      # longitude             #
#--------------------------#-----------------------#-----------------------------#
'
```

<details><summary>Click to see example input and outputs of this script...</summary>

## Example FHIR Location

```json
{
  "resourceType": "Location",
  "id": "2002",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-06-01T20:18:01.716+00:00",
    "source": "#mUdeOzP6cjltSfM6"
  },
  "identifier": [
    {
      "system": "https://github.com/synthetichealth/synthea",
      "value": "256598cd-f8c7-38ce-81eb-17b90046f633"
    }
  ],
  "status": "active",
  "name": "BERKSHIRE FACULTY SERVICES INC",
  "telecom": [
    {
      "system": "phone",
      "value": "413-447-2745"
    }
  ],
  "address": {
    "line": [
      "777 N ST 6 FL"
    ],
    "city": "PITTSFIELD",
    "state": "MA",
    "postalCode": "01201-4147"
  },
  "position": {
    "longitude": -73.260685,
    "latitude": 42.451840000000004
  },
  "managingOrganization": {
    "reference": "Organization/2001",
    "display": "BERKSHIRE FACULTY SERVICES INC"
  }
}
```

## Destination OMOPCDM `location` Table Schema

```sql
CREATE TABLE location (
    location_id integer NOT NULL PRIMARY KEY,
    address_1 TEXT NULL,
    address_2 TEXT NULL,
    city TEXT NULL,
    state TEXT NULL,
    zip TEXT NULL,
    county TEXT NULL,
    location_source_value TEXT NULL,
    country_concept_id integer NULL REFERENCES CONCEPT (CONCEPT_ID),
    country_source_value TEXT NULL,
    latitude REAL NULL,
    longitude REAL NULL
);
```

## Example TSV Data

The `simple_map` function produces a stream of TSV data, which can be directly
loaded into the sqlite CDM database.

```tsv
2002	777 N ST 6 FL		PITTSFIELD	MA	01201-4147		4330442	USA	42.451840000000004	-73.260685
```

</details>

The `simple_map` logic streams TSV output to `${REPO}/data/convert/omop/`.
In the example above, the data would be written to a file named `location.tsv`.

If *multiple* scripts need to write to a TSV file, the default behavior is to
*append* to these files as the scripts run.  For this reason, the first mapping
script to write to a TSV file should *truncate* it before writing.

To truncate a `.tsv` file, a mapper script calls the `begin_conversion`
function.
