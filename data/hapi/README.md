# Notes

In this folder you can start a local HAPI FHIR server, which will persist
loaded data into `$REPO/data/hapi/h2`.

To start the server, run this.

```bash
./start.sh
```

To stop the server, run this.

```bash
./stop.sh
```

## Prerequisites

You must have Docker installed and running on your system.

## Troubleshooting

If you are unable to start the server because the container name is already in
use, the server may have crashed.  You can attempt to restart it by running:

```bash
docker container prune -f
./start.sh
```
