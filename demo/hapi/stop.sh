#!/bin/bash
#
# Stops a running hapi fhir server.
#
source "$( dirname "${0}" )/../vars"
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="/demo/hapi/stop.sh"

set -e
set -o pipefail
set -u

NAME="fhir-to-omop-demo-hapi-server"

# Stop a running hapi fhir server.
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Stopping server..."
  {
    docker container stop "${NAME}"
    docker container rm "${NAME}"
  } >/dev/null
  echo "DONE!"
else
  echo "Container: ${NAME} is not running."
fi

