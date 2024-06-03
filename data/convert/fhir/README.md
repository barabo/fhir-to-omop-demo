# Notes

This directory should contain the extracted contents of a HAPI server bulk
export file.  See the `export.sh` script in `${REPO}/hapi` for details.

To extract the contents of a compressed export file, run these commands.

```bash
# From within this directory.
EXPORT_JOB_ID="ad3fed74-535a-4d7a-843c-2ee753c33d6d"  # For example.

# Inflate the export .ndjson files here.
zstdcat ../../hapi/bulk-exports/full/${EXPORT_JOB_ID}.tar.zst | tar -x

# Place the .ndjson files into a local directory called "export".
rm -rf ./export
mv -v "${EXPORT_JOB_ID}/" ./export/
```

Once this is in place, you are ready to convert the bulk-exported FHIR into
OMOPCDM tab-separated-value files, which can be directly loaded into an
OMOPCDM sqlite database.
