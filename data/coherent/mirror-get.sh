#!/bin/bash
#
# Get the coherent data set from a published mirror if not already present.
#
cd "$( dirname "${0}" )"
source "../../demo/vars"
REPO="https://github.com/barabo/fhir-to-omop-demo"
FILE="data/coherent/mirror-get.sh"

set -e
set -o pipefail
set -u

MIRROR_ZIP="j0mcu7rax187h6j6gr74vjto8dchbmsp.zip"
MIRROR_URL="https://mitre.box.com/shared/static/${MIRROR_ZIP}"
COHERENT="coherent-11-07-2022.zip"

# Download the file, if not already present.
if [ ! -e "${MIRROR_ZIP}" ] && [ ! -e "${COHERENT}" ]; then
  echo "Downloading ${COHERENT} from a published mirror: ${MIRROR_URL}..."
  wget "${MIRROR_URL}"
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

cd - &>/dev/null
