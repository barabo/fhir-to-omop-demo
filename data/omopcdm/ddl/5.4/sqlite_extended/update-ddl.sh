#!/bin/bash
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/omopcdm/ddl/5.4/sqlite_extended/update-ddl.sh"
_URL="${REPO}/blob/main/${FILE}"
#
# Converts the OMOP-provided DDL database definition scripts into a format
# that can be loaded by sqlite3 from the command line.
#
# This has been tested against the provided sqlite_extended 5.4 schema.
#
# Run this script from a local copy of this directory.  It will produce
# patched-ddl.sql files, and an empty cdm.db database.
#

set -e
set -o pipefail
set -u

# Create ignored, temp sql files for working with.
DDL=patched-ddl.sql
FKS=patched-fks.sql
IDX=patched-idx.sql
PKS=patched-pks.sql

# There should be only one of each of these in this directory..
cp OMOPCDM*_ddl.sql ${DDL}
cp OMOPCDM*_constraints.sql ${FKS}
cp OMOPCDM*_indices.sql ${IDX}
cp OMOPCDM*_primary_keys.sql ${PKS}

# Remove the @cdmDatabaseSchema templated schema name from the patched files.
chmod 744 patched-*.sql
sed -i -e 's:@cdmDatabaseSchema.::g' patched-*.sql && rm -f patched-*.sql-e


# Awk scriptlet to add a PRIMARY KEY declaration to a table.column in a table
# definition.
#
# Assumptions:
#   'table' is padded with spaces
#   'column' begins with a tab and ends with a space
#
AWK_PK='
/^CREATE TABLE / {
  if ($0 ~ table) { target=1 } else { target=0 }
}

{
  if (target && $0 ~ column && (!($0 ~ / PRIMARY KEY,/))) {
    sub(/,/, " PRIMARY KEY,");
  }
  print $0
}
'

# Awk scriptlet to add a FOREIGN KEY declaration to a table.column in a table
# definition.
#
# Assumptions:
#   'table' is padded with spaces
#   'column' begins with a tab and ends with a space
#   'ref' is multiple words long
#
AWK_FK='
/^CREATE TABLE / {
  if ($0 ~ table) { target=1 } else { target=0 }
}

{
  if (target && $0 ~ column && (!($0 ~ / REFERENCES /))) {
    if ($0 ~ /,$/) {
      sub(/,$/, " REFERENCES " ref ",");
    } else {
      sub(/ );$/, " REFERENCES " ref ");");
    }
  }
  print $0
}
'

##
# Gets the table names and PK columns from constraints.
#
function get_pks() {
  grep '^ALTER TABLE ' ${PKS} \
    | sed -e 's:.* \(.*\) ADD CONSTRAINT .* PRIMARY KEY .\(.*\).;:\1 \2:'
}


##
# Decorate the PK columns with PRIMARY KEY if not already decorated.
#
function mark_pk() {

  # Apply the change to the ddl file content, saving into a temp file.
  cat ${DDL} | awk -v table=" ${1} " -v column="	${2} " "${AWK_PK}" \
    > ${DDL}.tmp

  # diff the files to assert diff count is 1 changed line only.
  (( $( diff -by --suppress-common-lines ${DDL} ${DDL}.tmp | wc -l ) == 1 )) || exit 1

  # Apply the temp file to the DDL file.
  mv ${DDL}.tmp ${DDL}
}


##
# Get the declared foreign keys."
#
function get_fks() {
  grep '^ALTER TABLE ' ${FKS} \
    | sed -e 's:ALTER TABLE \(.*\) ADD CONSTRAINT .* FOREIGN KEY .\([^ ]*\). REFERENCES:\1 \2:' \
    | sed -e 's:;::'
}


##
# Decorate the PK columns with PRIMARY KEY if not already decorated.
#
function mark_fk() {

  # Apply the change to the ddl file content, saving into a temp file.
  cat ${DDL} \
    | awk -v table=" ${1} " -v column="	${2} " -v ref="${3}" "${AWK_FK}" \
    > ${DDL}.tmp

  # diff the files to assert diff count is 1 changed line only.
  (( $( diff -by --suppress-common-lines ${DDL} ${DDL}.tmp | wc -l ) == 1 )) || exit 1

  # Apply the temp file to the DDL file.
  mv ${DDL}.tmp ${DDL}
}


# Update the table definitions to insert the PRIMARY KEY declarations.
echo "Adding PRIMARY KEYS to DDL"
get_pks | while read table column; do
  mark_pk ${table} ${column}
done

# Insert the FK constraints into the table.
echo "Adding FOREIGN KEYS to DDL"
get_fks | while read table column reference; do
  mark_fk ${table} ${column} "${reference}"
done

# HACK: needed to prevent the foreign key check from failing.
mark_pk cohort cohort_definition_id

# Populate the DB tables and indices.
echo "Creating empty cdm.db database"
rm -f cdm.db
touch cdm.db
sqlite3 cdm.db < ${DDL}
sqlite3 cdm.db < ${IDX}
sqlite3 cdm.db "pragma foreign_key_check"

# Success!
echo "DONE!"
