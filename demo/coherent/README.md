[Download]: https://synthea.mitre.org/downloads
[Coherent]: https://doi.org/10.3390/electronics11081199
[PDF]: https://www.mdpi.com/2079-9292/11/8/1199/pdf?version=1649835714

# Notes
The MITRE [Coherent] data set is a multi-modality collection of
1278 Synthea-generated FHIR patient bundles, clinical notes, DICOM images,
ECG readings, and DNA testing.

You can read more about the data set in the provided [PDF].

Once loaded into a FHIR server, it will add roughly 2 million resources!

<details><summary>Click to see statistics and data samples...</summary>

![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A1.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A2.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A4.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A3.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A4.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A5.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A6.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A7.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A8.png)
![image](https://www.mdpi.com/electronics/electronics-11-01199/article_deploy/html/images/electronics-11-01199-g0A9.png)

</details>

## Demo Instructions

- [ ] Run the `mirror-get.sh` script to download the coherent data into `../../data/coherent` and generate a simple ETL file, placing it into `../hapi`.

### Unpack coherent download

From this directory, you can run these steps to unpack your download.

```bash
./mirror-get.sh
```

The zip file contains four directories, but for the next step you will only need
the `fhir` directory.

The FHIR directory contains a single patient bundle file per patient, and
two separate files which contain all the Providers and Organizations.

See the `README.md` in the `hapi` directory for the next step.
