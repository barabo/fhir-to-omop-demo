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

These were the selections I made for this demo:

![image](https://github.com/barabo/fhir-to-omop-demo/assets/4342684/9a2a83e6-d0ec-48bc-aa4c-4e38ee45a582)

![image](https://github.com/barabo/fhir-to-omop-demo/assets/4342684/f85d73a6-e4f0-4fb3-8359-44a733c73ee3)

Click the 'Download Vocabularies' button and wait for an email with a
download link in it.  It may take an hour or more for this step, so be
patient!

Once you have downloaded terminology sets from the Athena website, you
can unzip them and place the provided `*.csv` files here.

NOTE: CPT4 codes are not required for this demo, even though they were
captured in the screenshots above.

```sh
# Run this command within this directory to copy terminology files here:

cp -v ~/Downloads/vocabulary_download_v5_*/*.csv .

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
