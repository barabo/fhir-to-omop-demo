[coherent]: https://www.mdpi.com/2079-9292/11/8/1199

# Notes

In this folder you can start a local HAPI FHIR server, which will persist
loaded data into `$REPO/data/hapi/h2`.

## Prerequisites

- [ ] You must have Docker installed and running on your system.
- [ ] The loader script requires `jq` to be installed.
- [ ] The bulk exporter script uses `zstd` to compress exports.

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
To load data into the server, you must use an ETL definition file to list
or detect the files to load, and to instruct the loader how many files can
be loaded at a time.

The files containing FHIR bundles will be loaded concurrently, with up to
`${CONCURRENCY}` simultaneous uploads.  See deails in `load.sh`.

NOTE: the loader can not load files with single quotes `'` in the filename,
and will try to rename those files, replacing the single quote with an
underscore.

NOTE: some files need to be loaded before others if you have enabled
referential integrity on writes.  You can load those files in a separate
load group first.

### ETL definition file

You must provide an ETL load definition file to load your bundle files with
the `load.sh` script.

The ETL file supports the definition of separate 'load groups', with each
load group completing before the next is started.

In the ETL definition file, a load group can either specify a static `files`
list of files to load, or a `file_name_regex` expression that will match
files in a given `folder`.  *These are mutually exclusive options.*

All filenames and regex expressions are considered relative to the `folder`
specified in the load group.

The regex format supported is the one used by the linux `find` command.

The `concurrency` definition determines how many bundle files are POST'ed to
the server at the same time.  The linux command `xargs` is used to manage
parallelization of loads.

#### Example ETL definition file

This example ETL definition file instructs the loader to load the Synthea
[coherent] set of ~1300 patients only after loading the
`organizations.json` and `practitioners.json` bundle files.

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

## Export

An experimental bulk exporter script has been provided.  It can export the
whole [coherent] data set in about 3 minutes with the provided configuration.

```
(base) carl@home hapi % time ./export.sh

EXPORT: 0ae6d078-50e1-4990-a5dd-9a1b277e59ae: waiting for http://localhost:8080/fhir to prepare export.
EXPORT: Monitoring: 'http://localhost:8080/fhir/$export-poll-status?_jobId=0ae6d078-50e1-4990-a5dd-9a1b277e59ae' for updates...
EXPORT: 0ae6d078-50e1-4990-a5dd-9a1b277e59ae: ready for download!
Downloading files...
Compressing files with zstd...
/*stdin*\            :  2.86%   (  2.67 GiB =>   78.1 MiB, 0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar.zst)
Created: ./bulk-exports/full/0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar.zst
Export completed: in 169 seconds.
./export.sh  22.84s user 48.68s system 42% cpu 2:49.53 total

(base) carl@home hapi %
```

The bulk import and export stardard uses newline delimited json (or, `.ndjson`)
files, which are faster to read and write.

The way it works in HAPI, a request is first made to create an export.  The
server responds with a URL that can be monitored for readiness.  The script
monitors this URL until the export is ready for download, then it downloads
all the files into a directory rooted in `bulk-exports`.

After downloading all the files, they are compressed with the `zstd` command
line utility.

### Extraction

To extract an archive, you must first use the `unzstd` command to inflate it,
then `tar` to extract the contents.

```bash
unzstd 0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar.zst
tar -xzf 0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar && rm $_
```

The resulting exported resources
# Troubleshooting

## Starting the server

If you are unable to start the server because the container name is already in
use, the server may have crashed.  You can attempt to restart it by running:

```bash
docker container prune -f
./start.sh
```

## Loading data

Lots can go wrong when you load data.  Some things to keep in mind will help.

### Docker

Keep an eye on the docker container stats while it's loading in the Docker Desktop UI.

![image](https://github.com/barabo/fhir-to-omop-demo/assets/4342684/e17c4d63-e122-4bec-bfc2-f68f64a581e0)

This shows the container usage for a 40 minute load of the Synthea [coherent] fhir data set.

Restarting the server also tends to reduce the H2 database size on shutdown.  If you are having disk space issues, you might try breaking up the loads into separate ETL jobs, and restart the server between them.

### FHIR Server

The default run options in the Docker image for the hapi fhir server include the ability to delete resources, the indexing of vocabularies, and referential integrity checking after writes and deletes.  These options slow insert performance, so they have been disabled in the `start.sh` script.  You can change this script to re-enable deletes after the data has been fully loaded by changing the `ALLOW_DELETES` env variable to `true`.

```bash
function start_server() {
  docker run \
    --detach \
    --interactive \
    --tty \
    --name ${NAME} \
    --publish 8080:8080 \
    --mount "type=bind,src=${H2},target=${MOUNT_TARGET}" \
    --env "hapi.fhir.allow_cascading_deletes=${ALLOW_DELETES}" \
    --env "hapi.fhir.allow_multiple_delete=${ALLOW_DELETES}" \
    --env "hapi.fhir.bulk_export_enabled=true" \
    --env "hapi.fhir.bulk_import_enabled=true" \
    --env "hapi.fhir.delete_expunge_enabled=${ALLOW_DELETES}" \
    --env "hapi.fhir.enforce_referential_integrity_on_delete=${ALLOW_DELETES}" \
    --env "hapi.fhir.enforce_referential_integrity_on_write=${ALLOW_DELETES}" \
    --env "spring.datasource.hikari.maximum-pool-size=800" \
    --env "spring.datasource.max-active=8" \
    --env "spring.datasource.url=jdbc:h2:file:${MOUNT_TARGET}/h2" \
    --env "spring.jpa.properties.hibernate.search.enabled=${ALLOW_DELETES}" \
    hapiproject/hapi:latest
}
```

You can also make changes to check or not check referential integrity after inserts, or change the thread pool sizes.

### Database

The backing H2 database is stored locally in a folder `${REPO}/data/hapi/h2` which is bind-mounted to the running container in the `start.sh` script.  In this folder are `h2.mv.db` (the database) and occasionally a `h2.trace.db` (traceback) file.  The traceback file is a text file containing stack traces from a DB crash.  You may discover clues as to why the database failed in this file (such as hints that memory or disk space was exhausted).

### Data issues

Synthea often separates resource files that must be loaded into a server before the others.  Some examples of these are `practitioners.json` and `organizations.json`.  You can specify a separate, ordered load group to run before the other resource bundles are loaded.
