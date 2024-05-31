#!/bin/bash
#
# Start a local HAPI FHIR server.
#

set -e
set -o pipefail
set -u

# Create a local folder for the H2 database that will be used by HAPI.
THIS_DIR="$( realpath $( dirname ${0} ) )"
H2="${THIS_DIR}/h2"
mkdir -p "${H2}"

# This is where the local folder will appear inside the container.
MOUNT_TARGET="/persisted"

# docker container name.
NAME="fhir-to-omop-demo-hapi-server"

# Launch the server, saving resources to the local DB.
function start_server() {
  docker run \
    --detach \
    --interactive \
    --tty \
    --name ${NAME} \
    --publish 8080:8080 \
    --mount "type=bind,src=${H2},target=${MOUNT_TARGET}" \
    --env "spring.datasource.url=jdbc:h2:file:${MOUNT_TARGET}/h2" \
    hapiproject/hapi:latest
}


# Ignore invocations if the server is already running.
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  cat <<EOM
The ${NAME} container is already running.

If you want to stop it, do this:
  docker container stop ${NAME}

Before you can restart it again, prune the stopped containers.
  docker container rm ${NAME}

EOM
else
  start_server
fi
