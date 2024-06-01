#!/bin/bash
#
# Loads data into a running hapi fhir server.
#

set -e
set -o pipefail
set -u

# Number of concurrent file loaders.
CONCURRENCY=4

# Allow the script to be invoked from other directories and still work.
THIS_DIR="$( dirname ${0} )"

# Make sure an argument has been given.
if (( $# == 0 )); then
  cat <<EOM
Usage: $( basename ${0} ) dir-name[s]

Loads FHIR bundles from a directory.
EOM
  exit 1
fi

# Make sure the arguments are all directories.
for x in "${@}"; do
  [ ! -d ${x} ] && echo "Not a directory: ${x}" && exit 1
done

# Make sure the server is started already.
${THIS_DIR}/start.sh >/dev/null


function load() {
  echo "Loading: ${@}"
}


function get_files() {
  local dir="${1}"
  local pattern="${2}"
  find ${dir} -maxdepth 1 -mindepth 1 -type f -name "${pattern}" -print0
}


function load_dir() {
  local dir="${1}"
  export -f load
  get_files ${dir} '[a-z]*.json' \
    | xargs -0 -n1 -P${CONCURRENCY} bash -c 'load "${@}"' "_"
  get_files ${dir} '[^a-z]*.json' \
    | xargs -0 -n1 -P${CONCURRENCY} bash -c 'load "${@}"' "_"
}


# Load a bunch of files in parallel.
for d in ${@}; do
  load_dir $d
done
