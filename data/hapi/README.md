# Notes

In this folder you can start a local HAPI FHIR server, which will persist
loaded data into `$REPO/data/hapi/h2`.

## Prerequisites

- [ ] You must have Docker installed and running on your system.
- [ ] The loader script requires `jq` to be installed.

# Operations

## Start

To start the server, run this.

```bash
./start.sh
```

## Stop
To stop the server, run this.

```bash
./stop.sh
```

## Load
To load data into the server, provide a directory containing FHIR resource
bundles to load.

The bundles will be loaded concurrently, with up to `${CONCURRENCY}`
simultaneous uploads.  See deails in `load.sh`.

NOTE: the loader can not load files with single quotes `'` in the filename,
and will try to rename those files, replacing the single quote with an
underscore.

NOTE: some files need to be loaded before others if you have enabled
referential integrity on writes.  You can load those files in a separate
load group first.

### ETL definition file

You must define an ETL load definition file to load your bundle objects.

The ETL file supports separate load groups, which run in list order.

You can either specify a `files` list of files to load, or a `file_name_regex`
expression that will match files in a given `folder`.  These are mutually
exclusive options.

All filenames and regex expressions are considered relative to the `folder`
specified in the load group.

The concurrency definition determines how many bundle files are POST'ed to the
server at the same time.

#### Example ETL definition file

This example file loads the Synthea coherent set of ~1000 patients after first
loading the `organizations.json` and `practitioners.json` bundles.

`coherent-etl.json`
```
{
  "fhir_base": "http://localhost:8080/fhir",
  "load_groups": [
    {
      "concurrency": 1,
      "files": [
        "organizations.json",
        "practitioners.json"
      ],
      "folder": "../coherent/fhir"
    },
    {
      "concurrency": 4,
      "file_name_regex": "[^a-z]*.json",
      "folder": "../coherent/fhir"
    }
  ]
}
```

### Example
```
(base) carl@home hapi % time ./load.sh ./coherent-etl.json
FILE: ../coherent/fhir/organizations.json: 2134 - status: 201 Created
FILE: ../coherent/fhir/practitioners.json: 2082 - status: 201 Created
FILE: ../coherent/fhir/Maurice742_Kerluke267_8b8f25df-81b5-1029-3439-98d1e4ea0241.json: 489 - status: 201 Created
FILE: ../coherent/fhir/Humberto482_Koss676_9d1ba492-68e6-c66f-78eb-1b8a2b2cd7f2.json: 643 - status: 201 Created
FILE: ../coherent/fhir/Robbi844_Beatty507_1a6ea64c-4451-34e2-f13a-04e9b3f197fa.json: 812 - status: 201 Created
FILE: ../coherent/fhir/Timmy68_Lakin515_75425ac1-ff8b-76eb-5b4b-633b619c87c3.json: 387 - status: 201 Created
FILE: ../coherent/fhir/Ambrose149_Leffler128_14e3b2af-8bdc-2bb0-57a8-e2f2ca142d41.json: 1117 - status: 201 Created
FILE: ../coherent/fhir/Earnest658_Stamm704_05cd91dc-80fc-7e98-ad89-6d3f5d141ee9.json: 114 - status: 201 Created
FILE: ../coherent/fhir/Floyd420_Mann644_aee205cf-57bc-a73a-0820-52aa481986c6.json: 1718 - status: 201 Created
FILE: ../coherent/fhir/Mallory926_Medhurst46_44185bdd-4277-d54c-de1f-2ce4fadddc11.json: 871 - status: 201 Created
FILE: ../coherent/fhir/Bruno518_Legros616_f5067689-4b86-2bc3-554b-f720c0690b75.json: 827 - status: 201 Created
FILE: ../coherent/fhir/Louie190_Weber641_837e80f6-a7a5-77f8-36aa-c7b8ff002c4b.json: 1413 - status: 201 Created
FILE: ../coherent/fhir/Amelia635_Lehner980_38e5b9a8-6f05-2fb5-b7cc-f02f9fc43ec9.json: 1128 - status: 201 Created
...

```

## Troubleshooting

If you are unable to start the server because the container name is already in
use, the server may have crashed.  You can attempt to restart it by running:

```bash
docker container prune -f
./start.sh
```
