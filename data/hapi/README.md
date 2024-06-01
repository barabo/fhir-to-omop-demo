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
...
FILE: ../coherent/fhir/Garret233_Abernathy524_f10ad800-30f8-e856-31e3-b46dd5833d10.json: 7320 - status: 201 Created
FILE: ../coherent/fhir/Jewell855_Ullrich385_590d04c9-6ff9-d791-b9a4-23a83a9e25ba.json: 574 - status: 201 Created
FILE: ../coherent/fhir/Virgilio529_Wehner319_7359f186-9e25-5799-0065-09c284efce8a.json: 622 - status: 201 Created
FILE: ../coherent/fhir/Kaley842_Witting912_72bf3e42-0938-4339-8117-00429e98f93e.json: 8471 - status: 201 Created
FILE: ../coherent/fhir/Samuel331_Ortega866_80f28bab-c204-0a96-ea17-ab2b383fa9c2.json: 24674 - status: 201 Created
./load.sh ./coherent-etl.json  32.01s user 43.42s system 3% cpu 40:39.25 total
```

## Troubleshooting

If you are unable to start the server because the container name is already in
use, the server may have crashed.  You can attempt to restart it by running:

```bash
docker container prune -f
./start.sh
```
