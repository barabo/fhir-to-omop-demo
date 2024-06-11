# Notes

This directory is where FHIR server bulk exports are written to by the
`demo/hapi/export.sh` script.

To inflate a compressed bulk export, you must use the `unzstd` command to
convert the file to a tar file, then un-tar the file.

## Example

```bash
unzstd 0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar.zst
tar -xzf 0ae6d078-50e1-4990-a5dd-9a1b277e59ae.tar && rm $_
```
