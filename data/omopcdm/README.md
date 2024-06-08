# Notes

To write data into an OMOPCDM database, you must first build a database
that conforms to the prescribed schema.  This directory contains a snapshot of 
the DDL which defines that schema for CDM version 5.4 in the sqlite dialect.

## sqlite

The demo uses sqlite because it is a no-network database with very few
dependencies.  It was chosen for ease of configuration, and convenience for
manipulation from the bash scripts provided.

## Instructions

If you would like to build an empty OMOPCDM database using the OMOP-provided DDL,
a script is provided here to do so.

```bash
# From this directory.
./ddl/5.4/sqlite_extended/update-ddl.sh
```

This script will generate a new empty database with the correct schema, indexes,
and foreign keys - placing it in your current directory.  The script will not
overwrite an existing `cdm.db`, though, so be sure to delete any existing one
you wish to overwrite.

Before the new database can be used, it must have terminology data inserted into
it, though.  Please see the README in the `athena` directory for those
instructions.
