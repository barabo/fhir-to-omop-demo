#!/bin/bash
#
# Reduces translated OMOPCDM data into loadable rows
#
source "$( dirname "${0}" )/../vars"

set -e
set -o pipefail
set -u

echo "Resetting cdm.db..." && cp -v "${CDM_DB}" ./cdm.db | sed -e 's:^:    COPYING :'  # XXX - testing


##
# Gets the OMOPCDM table_name -> FHIR Resource names from mapping files.
#
function omop_fhir_mappings() {
  # Inspect the mapping files to determine which FHIR resources produce rows
  # of OMOPCDM and list the destination table name followed by all the
  # possible FHIR Resource types that generate input for that table.
  #
  # For example, this function emits rows like:
  #   location Location
  #   provider Practitioner PractitionerRole
  #
  grep -A1 '^\[' map/*.jq \
    | grep -v '\[' \
    | grep '^map' \
    | sed -e 's:^map/\(.*\).jq-[ ]*"\([^"]*\)",.*:\2 \1:' \
    | sort -u \
    | awk '
# Print the accumulated omop table mappings.
func emit() {
  if (omop) {
    print omop " " fhir
  }
  omop = $1
  fhir = $2
}

# Process each row, accumulating new source resource mappings.
{
  if ($1 == omop) {
    fhir = fhir " " $2
  } else {
    emit()
  }
}

# Emit the final accumulated row.
END { emit() }
'
}


##
# Gets the staged source filenames for a list of resource types.
#
function get_resource_filenames() {
  for fhir in ${@}; do
    local stg=data-omop/stg-${fhir}.tsv
    [ -e "${stg}" ] && echo "${stg}"
  done
}


##
# Extract and reduce the entries for a table from staged source files.
#
function reduce() {
  local table_name=${1}
  local resource_files=$( get_resource_filenames ${2} )

  # Skip tables that have produced no source files.
  if [[ -z ${resource_files} ]]; then
    echo "    SKIPPING ${table_name}: no staged source files!"
    return 0
  fi

  # Avoid the thundering herd, if possible, by sleeping a tiny bit.
  sleep 0.${RANDOM}

  # Use awk to reduce rows with identical first columns, which should be the
  # primary key column for the destination table.
  echo "    REDUCING ${table_name}.tsv..."
  sed -n "s/^${table_name}\t//p" ${resource_files} \
    | sort -n \
    | awk -F "\t" '
#
# inline.awk: reduces row fragments into loadable rows.
#

##
# Emit the merged row and move on to the next.
#
func emit() {
  # Print the merged row.
  ORS=""; print row[1]; for (i = 2; i <= NF; ++i) print FS row[i];
  ORS="\n"; print ""
  # Copy the current row into 'row'.
  for (i = 1; i <= NF; ++i) row[i] = $i
}

##
# Merge this row into the previous one.
#
func merge() {
  for (i = 1; i <= NF; ++i) {
    if (row[i] == "") {
      row[i] = $i
    } else if ($i != "" && row[i] != $i) {
      system("echo MERGE CONFLICT: " $i " != " row[i] " 1>&2")
    }
  }
}

{
  # Initialize row for the first line of input.
  if (row[1] == "") { row[1] = $1 }

  # Merge this line into the previous one, or emit the previous row.
  if ($1 == row[1]) { merge() } else { emit() }
}

# Be sure to emit the final row.
END { emit() }
' \
  > data-omop/${table_name}.tsv
}


# Start a timer.
start=$(( $( date +%s ) ))

#
# Use xargs to build tsv files in parallel.
#
export -f get_resource_filenames
export -f reduce

# Reduce the stg-FHIR.tsv files to OMOP.tsv files for loading.
echo "Reducing staged OMOP framents into whole rows for loading..."
omop_fhir_mappings | \
while read omop resources; do
  # Insert \0 characters between tokens for xargs to handle the variable
  # number of source files per table destination.
  echo -en "${omop}\0${resources}\0"
done \
  | xargs -0 -n2 -P${CONCURRENCY} bash -c 'reduce "${@}"' _

# Load the data into the database, one by one.
echo "Loading reduced OMOP into CDM database..."
omop_fhir_mappings | while read omop resources; do
  tsv="data-omop/${omop}.tsv"
  [ -e "${tsv}" ] || continue
  echo "    IMPORTING ${omop}..."
  sqlite3 cdm.db <<SQL
.mode ascii
.separator "\t" "\n"
.import ${tsv} ${omop}
SQL
done

# Clean up.
echo "Deleting staged OMOP fragments..."
rm -v data-omop/stg-*.tsv | sed -e 's:^:    DELETING :'

# DONE!!!
cat <<DONE
Merged and loaded rows:
$( wc -l data-omop/*.tsv )
Completed in $(( $( date +%s ) - start )) seconds!
DONE
