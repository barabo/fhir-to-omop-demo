#!/bin/bash
#
# Loads Athena terminology data into an empty omopcdm sqlite DB.
#

set -e
set -o pipefail
set -u

# Make sure the DB exists.
#
# If you don't have one already, you need to generate one using the DDL
# provided by OMOP.
#
# See the /data/omopcdm folder in this repo to find the script.
#
DB="cdm.db"
[ -e "${DB}" ] || exit 1


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
  [ -e empty.db ] || cp "${DB}" empty.db
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
  [[ ${csv} =~ backup* ]] && echo "...skipping ${csv}" && continue
  [[ ${csv} =~ CONCEPT_CPT4.* ]] && echo "...skipping ${csv}" && continue
  load ${csv}
done

# Done!
echo "COMPLETED: $(( $( date +%s ) - start )) seconds"

# Optional sanity checks.
if [[ -n ${DEBUG} ]]; then
  echo "DEBUG: running fk sanity checks post-load..."
  echo
  echo "Press Ctrl-C to abort at any time."
  sql "pragma foreign_key_check"
fi
