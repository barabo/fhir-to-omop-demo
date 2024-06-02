#!/bin/bash
#
# Loads Athena terminology data into an empty OMOPCDM sqlite DB.
#
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="/data/athena/load.sh"

set -e
set -o pipefail
set -u

# The OMOPCDM database we're loading terminology into.
DB="cdm.db"
DDL_DIR="../omopcdm/ddl/5.4/sqlite_extended"

# If there's no cdm.db yet, create an empty one.
if [ ! -e "${DB}" ]; then
  echo "Creating an initial ${DB} file from DDL..."
  cd "${DDL_DIR}" &>/dev/null
  ./update-ddl.sh
  cd - &>/dev/null
  cp "${DDL_DIR}/cdm.db" "${DB}"
  echo
fi


##
# Run a query or command against the DB.
#
function sql() {
  sqlite3 "${DB}" "${@}"
}


##
# List all tables in the DB.
#
function get_tables() {
  sql ".schema" | grep '^CREATE TABLE ' | awk '{ print $3 }'
}


##
# Reset the DB to an empty state.
#
function reset_db() {
  # Optimization for testing.
  [ -e empty.db ] && cp empty.db "${DB}"

  # Only truncate Athena tables that can be reloaded.
  for table in ` get_tables `; do
    local csv="$( tr 'a-z' 'A-Z' <<< ${table} ).csv"
    [ -e ${csv} ] && sql "delete from ${table};"
  done

  # Keep a copy of the empty.db for future runs.
  [ -e empty.db ] || cp "${DB}" empty.db && sqlite3 empty.db 'vacuum;'
}


##
# Returns the indexes for a table;
#
function get_indexes() {
  local table="${1}"
  sql ".schema ${table}" | grep "CREATE INDEX"
}


##
# For each foreign key, update optional columns setting "" to NULL.
#
# Without this, empty values from the input file lead to FK violations.
#
function fix_fks() {
  local table="${1}"
  sqlite3 "${DB}" ".schema ${table}" \
    | grep -v "NOT NULL" \
    | grep "REFERENCES" \
    | awk '{ print $1 }' \
    | \
  while read column; do
    echo " - Nulling empty ${table}.${column} values..."
    sql "update ${table} set ${column} = NULL where ${column} = '';"
  done || true
}


##
# Load a pre-sorted (by PK column) CSV file into a table.
#
function load() {
  local csv="${1}"
  local table="$( echo ${1} | tr 'A-Z' 'a-z' | sed -e 's:.csv$::' )"
  echo "LOADING: ${table}"
  local rows=$( wc -l ${csv} | awk '{print $1}' )

  echo " - Dropping indexes on ${table}..."
  local indexes="$( get_indexes ${table} )"
  echo "${indexes}" | awk '{print $3}' | while read idx; do
    sql "drop index ${idx};"
  done

  echo " - Importing ${rows} rows from ${csv}..."
  sqlite3 "${DB}" <<EOF
.mode ascii
.separator "\t" "\n"
.import --skip 1 ${csv} ${table}
EOF

  echo " - Restoring indexes on ${table}..."
  echo "${indexes}" | while read idx; do
    sql "${idx}"
  done

  # Fix foreign keys.
  fix_fks ${table}
}


# Start a timer.
start=$( date +%s )

# Reset the DB if it's not empty to begin with.
echo "Truncating Athena tables in ${DB}!"
reset_db

# Load all Athena vocab files in increasing size order.
for csv in ` ls -Sr *.csv `; do
  [[ ${csv} =~ CONCEPT_CPT4.* ]] && echo "...skipping ${csv}" && continue
  load ${csv}
done

# Optional sanity checks.
if [ -z ${DEBUG+on} ]; then
  echo "DEBUG: running foreign_key_check on ${DB}..."
  echo
  echo "Press Ctrl-C to abort at any time."
  sql "pragma foreign_key_check"
fi

# Done!
echo "COMPLETED: $(( $( date +%s ) - start )) seconds"
