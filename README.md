# fhir-to-omop-demo
A demo to translate synthea FHIR data to OMOP!

## Background
This demo was prepared in advance of the 2024 FHIR DevDays in Minneapolis.

Many researchers and developers will have access to either FHIR or OMOP, but
not necessarily both.  And for those with access to both, these two systems
may not be sourced with the same data.

At Mayo Clinic we have made great use of OMOPCDM data for AI applications,
but our conversion solution is not easy to share since it relies on cloud
services for the source data, conversion process, and destination.

## Demo Goals
This demo was written to serve the FHIR and OMOP communities by providing an
easy way to create a FHIR server loaded with non-trivial data, demonstrate
one approach for conversion of FHIR resources into OMOPCDM records, and to
encourage further exploration of this conversion process.

## Instructions
To get started, clone this repo and the `barabo/fhir-jq` repo.
```
mkdir ~/demo && cd $_
gh repo clone barabo/fhir-to-omop-demo
gh repo clone barabo/fhir-jq
```

Each of the directories in this repo contain instructions and notes, but you
should understand the basic flow of instructions before you begin.

You will:
- [ ] Download the MITRE Coherent data set and extract it into `data/coherent`
- [ ] Download terminology data from Athena and place it into `data/athena`
- [ ] Load the terminology into an empty OMOPCDM database by running the script provided in `demo/omopcdm`
- [ ] Load the Coherent FHIR resources into a local hapi server by running the scripts in `demo/hapi`
- [ ] Bulk Export the data from hapi, placing the ndjson files into `data/bulk-export/`
- [ ] Install `jq` and configure it to use the module provided in `fhir-jq/module`
- [ ] Translate FHIR-to-OMOP by running the script in `demo/translate`
- [ ] Load the OMOPCDM data by running the script in `demo/load`

## Get Started

Begin with the README.md in the `fhir-to-omop-demo/demo` directory!

## Citations

This demo uses the MITRE Health Coherent data set, and should be cited according to their wishes.  Thank you, MITRE Health!

If you download and use this data, be sure to remember to cite them, too!

```
Walonoski J, Hall D, Bates KM, Farris MH, Dagher J, Downs ME, Sivek RT, Wellner B, Gregorowicz A, Hadley M,
Campion FX, Levine L, Wacome K, Emmer G, Kemmer A, Malik M, Hughes J, Granger E, Russell S.

The “Coherent Data Set”: Combining Patient Data and Imaging in a Comprehensive, Synthetic Health Record.

Electronics. 2022; 11(8):1199.
```
https://doi.org/10.3390/electronics11081199
