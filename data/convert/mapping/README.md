# Notes

The scripts in this directory are numbered to control the order in which they
run.

Each script should begin with a prefix like this:
```bash
#!/bin/bash
#
# Converts FHIR XXX resources to OMOPCDM YYY records.
#
source _common.sh
```

This `_common.sh` file contains logic to deduce which type of FHIR resource is
being converted to which type of OMOPCDM data.

The filename format is: `%02d-${FHIR_TYPE}-${OMOP_TYPE}.sh`

For simple mappings that can be done using `jq` directly from FHIR resource
attributes to destination OMOPCDM columns, these scripts can use the
`simple_map` function and pass in a single-quoted string of comma-separated
`jq` resource selectors.
