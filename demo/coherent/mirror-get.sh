#!/bin/bash
#
# Get the coherent data set from a published mirror if not already present.
#
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="demo/coherent/mirror-get.sh"

pushd . &>/dev/null
cd "$( dirname "${0}" )"
source "../../demo/vars" || popd &> /dev/null

set -e
set -o pipefail
set -u

cd "${DATA_DIR}/coherent/"

MIRROR_ZIP="j0mcu7rax187h6j6gr74vjto8dchbmsp.zip"
MIRROR_URL="https://mitre.box.com/shared/static/${MIRROR_ZIP}"
COHERENT="coherent-11-17-2022.zip"
SHA256="10d21ab11f4b31e57dd8b90d59dd09c09d83ed0f30882f84ea78f5feccdcefbb"

# Download the file, if not already present.
if [ ! -e "${COHERENT}" ]; then
  if [ ! -e "${MIRROR_ZIP}" ]; then
    echo "Downloading ${COHERENT} from a published mirror: ${MIRROR_URL}..."
    wget --no-check-certificate "${MIRROR_URL}"
    echo "Verifying SHA256 of downloaded file..."
    shasum -a 256 -c <( echo "${SHA256}  ${MIRROR_ZIP}" )
  fi
  mv "${MIRROR_ZIP}" "${COHERENT}"
  unzip "${COHERENT}"

  # If the zip file contained an output folder, move the contents here.
  if [ -d output ]; then
    mv output/{fhir,dicom,dna,csv} .
    mv output/README.md ./coherent-README.md
    rmdir output
  fi

else
  echo "Already downloaded!"
fi

# Generate some lightweight ETL for loading the coherent data into HAPI.
"${DEMO_DIR}/coherent/generate-etl.sh" > "${DEMO_DIR}/hapi/coherent-etl.json"

# Return to the previous CWD.
popd &>/dev/null
