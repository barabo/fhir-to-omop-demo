#!/bin/bash
#
# Loads data into a running hapi fhir server.
#

set -e
set -o pipefail
set -u

# Allow the script to be invoked from other directories and still work.
THIS_DIR="$( dirname ${0} )"

# Make sure the server is started already.
${THIS_DIR}/start.sh &>/dev/null

