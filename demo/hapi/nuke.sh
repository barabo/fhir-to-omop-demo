#!/bin/bash
#
# Delete the H2 database backing your hapi server.  Proceed with caution!!!
#
source "$( dirname "${0}" )/../vars"

# Stop the server.
"${DEMO_DIR}/hapi/stop.sh"

# Delete the H2 database!
echo "You are about to delete all the data in your hapi server!"
rm -i "${DATA_DIR}/hapi/h2/h2.mv.db"
