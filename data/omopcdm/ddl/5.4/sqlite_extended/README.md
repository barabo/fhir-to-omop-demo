# Notes

The `OMOPCDM*.sql` files here were taken from the reference [sqlite_extended](https://github.com/OHDSI/CommonDataModel/tree/main/ddl/5.4/sqlite_extended) source.

There are some data definition issues to be aware of in version 5.4.
  * the `COHORT` table has no `PRIMARY KEY`, and without one the foreign key checks fail for the DB.
    * I have declared the `COHORT.cohort_definition_id` to be the PK for this table to satisfy the foreign key check.  This does not make the most sense (to me), but it was a minimal change and it seems to cover the use cases for this demo.  I expect this part of the schema will change in future releases.
  * the provided templates include a `@cdmDatabaseSchema` token, which seems to be used by a SQL templating library in R.
    * I've removed the schema entirely for sqlite, since sqlite doesn't support them this way.
    * If a schema is needed, the `cdm.db` can be attached to another database with a schema alias (but I suspect it's not needed).

## Instructions

To create a working database, run the `update-ddl.sh` script in this directory.  It will produce some ignored `patched-*.sql` files, as well as an empty `cdm.db` database.

```bash
$ ./update-ddl.sh
Adding PRIMARY KEYS to DDL
Adding FOREIGN KEYS to DDL
Creating empty cdm.db database
DONE!
$
```

To generate a single, loadable schema file which includes the tables, indexes, PKs, and FKs - run the `.schema` command in sqlite.

```bash
$ sqlite3 cdm.db .schema > omopcdm-sqlite.sql
```
