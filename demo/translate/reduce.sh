#
# Reduces translated OMOPCDM data into loadable rows
#

set -e
set -o pipefail
set -u

cat <<TODO
TODO:
  * define the reverse map from OMOP table name -> source files
  * for each OMOP table, grep for the table name entries, sort, and merge rows
  * write table_name.tsv files into OMOP_OUT dir
TODO
