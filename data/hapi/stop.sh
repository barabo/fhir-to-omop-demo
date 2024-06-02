#!/bin/bash
#
# Stops a running hapi fhir server.
#
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="/data/hapi/stop.sh"

set -e
set -o pipefail
set -u

NAME="fhir-to-omop-demo-hapi-server"

# Stop a running hapi fhir server.
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  docker container stop "${NAME}"
  docker container rm "${NAME}"
else
  echo "Container: ${NAME} is not running."
fi

