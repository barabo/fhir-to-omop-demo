# Instructions

<details><summary>Click to see a shortcut.</summary>

---

To make it easier to get going with this demo, I've provided a direct download to
an example vocabulary extract.  You shouldn't use this extract long-term, but it
will allow you to started without having to wait for an Athena download.

To download and install your own terminology selections from Athena, please see
the rest of the README that follows.

Otherwise, just do this:
```bash
# Change directory to the data directory.
source ../vars && cd "${TERMINOLOGY_DIR}" 2>/dev/null

# Install a tool to download from a Google Drive folder.
pip -q --no-input install gdown
gdown --no-check-certificate 1fTSBBFPEel_mNLsMzW-I1QV3qWh-H3Gv

# Verify the download contents against a SHA256.
SHA=230d2f8b05a96f2a600d0cf0b5313894a156b78fca7145d963bcdc27086dee2c
shasum -a 256 -c <( echo "${SHA}  vocabulary.zst" )

# Unpack and return to the demo/athena dir.
unzstd --stdout vocabulary.zst | tar -x
cd - 2>/dev/null

# Build the empty OMOP CDM database
./load.sh
```
</details>

# Notes

This directory is where I load terminology data into an empty OMOPCDM
database, which I generate using a script:
`/data/omopcdm/ddl/5.4/sqlite_extended/update-ddl.sh`.

## Athena
Terminology data sets can be requested from the Athena website, and must
be loaded into the OMOPCDM database before you can load any real data
into the CDM.

### Select Vocabularies

Log in to the terminology download page: [here](https://athena.ohdsi.org/vocabulary/list)

<details><summary>Click to see the code systems used by the coherent fhir resources...</summary>

```
http://dicom.nema.org/medical/dicom/current/output/chtml/part16/sect_CID_29.html
http://hl7.org/fhir/sid/cvx
http://hl7.org/fhir/us/core/CodeSystem/careplan-category
http://hl7.org/fhir/us/core/CodeSystem/us-core-documentreference-category
http://hl7.org/fhir/us/core/CodeSystem/us-core-provenance-participant-type
http://id.loc.gov/vocabulary/iso639-1
http://ihe.net/fhir/ValueSet/IHE.FormatCode.codesystem
http://loinc.org
http://nucc.org/provider-taxonomy
http://snomed.info/sct
http://terminology.hl7.org/CodeSystem/adjudication
http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical
http://terminology.hl7.org/CodeSystem/allergyintolerance-verification
http://terminology.hl7.org/CodeSystem/claim-type
http://terminology.hl7.org/CodeSystem/claimcareteamrole
http://terminology.hl7.org/CodeSystem/claiminformationcategory
http://terminology.hl7.org/CodeSystem/condition-category
http://terminology.hl7.org/CodeSystem/condition-clinical
http://terminology.hl7.org/CodeSystem/condition-ver-status
http://terminology.hl7.org/CodeSystem/dose-rate-type
http://terminology.hl7.org/CodeSystem/ex-diagnosistype
http://terminology.hl7.org/CodeSystem/ex-serviceplace
http://terminology.hl7.org/CodeSystem/media-type
http://terminology.hl7.org/CodeSystem/observation-category
http://terminology.hl7.org/CodeSystem/processpriority
http://terminology.hl7.org/CodeSystem/provenance-participant-type
http://terminology.hl7.org/CodeSystem/v2-0074
http://terminology.hl7.org/CodeSystem/v2-0203
http://terminology.hl7.org/CodeSystem/v3-ActCode
http://terminology.hl7.org/CodeSystem/v3-MaritalStatus
http://terminology.hl7.org/CodeSystem/v3-ParticipationType
http://unitsofmeasure.org
http://www.nlm.nih.gov/research/umls/rxnorm
http://www.nubc.org/patient-discharge
https://bluebutton.cms.gov/resources/codesystem/adjudication
https://bluebutton.cms.gov/resources/variables/line_cms_type_srvc_cd
urn:ietf:bcp:47
urn:ietf:rfc:3986
urn:oid:2.16.840.1.113883.6.238
```

</details>

---
These were the selections I made for this demo:

![image](https://github.com/barabo/fhir-to-omop-demo/assets/4342684/9a2a83e6-d0ec-48bc-aa4c-4e38ee45a582)

![image](https://github.com/barabo/fhir-to-omop-demo/assets/4342684/f85d73a6-e4f0-4fb3-8359-44a733c73ee3)

Click the 'Download Vocabularies' button and wait for an email with a
download link in it.  It may take an hour or more for this step, so be
patient!

Once you have downloaded terminology sets from the Athena website, you
can unzip them and place the provided `*.csv` files in the `data/athena`
directory (not in the `demo/athena` directory).

NOTE: CPT4 codes are not required for this demo, even though they were
captured in the screenshots above.

```sh
# Run this command within this directory to copy terminology files here:
cd ../../data/athena
cp -v ~/Downloads/vocabulary_download_v5_*/*.csv .
cd -

echo ' Expected output:
~/Downloads/vocabulary_download_v5_*/CONCEPT.csv -> ./CONCEPT.csv
~/Downloads/vocabulary_download_v5_*/CONCEPT_ANCESTOR.csv -> ./CONCEPT_ANCESTOR.csv
~/Downloads/vocabulary_download_v5_*/CONCEPT_CLASS.csv -> ./CONCEPT_CLASS.csv
~/Downloads/vocabulary_download_v5_*/CONCEPT_CPT4.csv -> ./CONCEPT_CPT4.csv
~/Downloads/vocabulary_download_v5_*/CONCEPT_RELATIONSHIP.csv -> ./CONCEPT_RELATIONSHIP.csv
~/Downloads/vocabulary_download_v5_*/CONCEPT_SYNONYM.csv -> ./CONCEPT_SYNONYM.csv
~/Downloads/vocabulary_download_v5_*/DOMAIN.csv -> ./DOMAIN.csv
~/Downloads/vocabulary_download_v5_*/DRUG_STRENGTH.csv -> ./DRUG_STRENGTH.csv
~/Downloads/vocabulary_download_v5_*/RELATIONSHIP.csv -> ./RELATIONSHIP.csv
~/Downloads/vocabulary_download_v5_*/VOCABULARY.csv -> ./VOCABULARY.csv
'
```

## Setup
When the terminology files have been copied into this directory, you can
then run the `load.sh` script and it will create a new empty DB by first
transforming the OMOPCDM DDL files into a schema that sqlite can read,
and then using that schema to create an empty database.

The empty database will be copied into this folder, and the script will
then load the Athena csv data into it.

The script takes between 3 and 6 minutes to complete on my laptop, but
your time will vary based on the vocabularies you selected and your
hardware configuration.

### Example output

```
(base) carl@home athena % time ./load.sh
Creating an initial cdm.db file from DDL...
Adding PRIMARY KEYS to DDL
Adding FOREIGN KEYS to DDL
Creating empty cdm.db database
DONE!

Truncating Athena tables in cdm.db!
LOADING: domain
 - Dropping indexes on domain...
 - Importing 51 rows from DOMAIN.csv...
 - Restoring indexes on domain...
LOADING: vocabulary
 - Dropping indexes on vocabulary...
 - Importing 70 rows from VOCABULARY.csv...
 - Restoring indexes on vocabulary...
LOADING: concept_class
 - Dropping indexes on concept_class...
 - Importing 424 rows from CONCEPT_CLASS.csv...
 - Restoring indexes on concept_class...
LOADING: relationship
 - Dropping indexes on relationship...
 - Importing 697 rows from RELATIONSHIP.csv...
 - Restoring indexes on relationship...
...skipping CONCEPT_CPT4.csv
LOADING: drug_strength
 - Dropping indexes on drug_strength...
 - Importing 2981808 rows from DRUG_STRENGTH.csv...
 - Restoring indexes on drug_strength...
 - Nulling empty drug_strength.amount_unit_concept_id values...
 - Nulling empty drug_strength.numerator_unit_concept_id values...
 - Nulling empty drug_strength.denominator_unit_concept_id values...
LOADING: concept_synonym
 - Dropping indexes on concept_synonym...
 - Importing 2592890 rows from CONCEPT_SYNONYM.csv...
 - Restoring indexes on concept_synonym...
...skipping backup.CONCEPT.csv
LOADING: concept
 - Dropping indexes on concept...
 - Importing 6432565 rows from CONCEPT.csv...
 - Restoring indexes on concept...
LOADING: concept_ancestor
 - Dropping indexes on concept_ancestor...
 - Importing 73065004 rows from CONCEPT_ANCESTOR.csv...
 - Restoring indexes on concept_ancestor...
LOADING: concept_relationship
 - Dropping indexes on concept_relationship...
 - Importing 39556731 rows from CONCEPT_RELATIONSHIP.csv...
 - Restoring indexes on concept_relationship...
DEBUG: running foreign_key_check on cdm.db...

Press Ctrl-C to abort at any time.
COMPLETED: 362 seconds
./load.sh  260.69s user 98.95s system 98% cpu 6:05.20 total
```
