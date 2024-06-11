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


##
# Run docker with or without sudo, depending on your settings in demo/vars.
#
function _docker() {
  if [ ${SUDO_DOCKER} ]; then
    sudo docker "${@}"
  else
    docker "${@}"
  fi
}


# Stop a running hapi fhir server.
if _docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Stopping server..."
  {
    _docker container stop "${NAME}"
    _docker container rm "${NAME}"
  } >/dev/null
  echo "DONE!"
else
  echo "Container: ${NAME} is not running."
fi

