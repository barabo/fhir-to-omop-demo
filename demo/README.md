[coherent]: https://mitre.box.com/shared/static/j0mcu7rax187h6j6gr74vjto8dchbmsp.zip

# DEMO TIME

In this demo, you will do the following in phases.

- [ ]  Phase 1 - FHIR Setup (~90 minutes)
  - [ ]  download a non-trivial healthcare data set, this demo uses the MITRE [coherent] set (20 minutes).
  - [ ]  start a dockerized hapi FHIR server (1 minute).
  - [ ]  load patient data into the server (45 minutes).
  - [ ]  bulk export the same data to split it into files by resource type (~15 minutes).
- [ ]  Phase 2 - OMOPCDM Setup (~90 minutes)
  - [ ]  create an empty OMOPCDM database (1 minute)
  - [ ]  download terminology data from Athena (~1 hour)
  - [ ]  load terminology into the empty database (20 minutes)
- [ ]  Phase 3 - Translate FHIR to OMOP
  - [ ]  translate the bulk exported FHIR data to OMOP
- [ ]  Phase 4 - Load OMOPCDM
  - [ ]  load the converted data into the OMOPCDM database

## Phase 0 - Prerequisites

This demo assumed you have a few tools at your disposal already.

<details><summary>Click to see the pre-demo checklist...</summary>

You should have (or install)...
- [ ] Docker
- [ ] a terminal for running scripts
- [ ] `bash`
- [ ] `jq`
- [ ] `sqlite`
- [ ] `zstd` (optional, but recommended)

You will also need to download a few pieces of data.
- [ ] the MITRE [coherent] data set
- [ ] terminology data from Athena

### Install CLI Prerequisites

If you are using `apt` you can `sudo apt install jq sqlite3 zstd`, or for OSX
homebrew users: `brew install jq sqlite3 zstd`.

### Clone Repose

For this demo, I recommend cloning into a new directory (I prefer working in `~/code`).

```bash
# Make yourself a directory to check out the demo.
mkdir -p ~/code
cd ~/code

# Clone the required repos.
gh repo clone barabo/fhir-jq
gh repo clone barabo/fhir-to-omop-demo

# Get ready to start!
cd fhir-to-omop-demo
```

### Docker

To test your docker installation, run `docker run hello-world` in a terminal.

If it worked, you should see output like this:

```
$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
478afc919002: Pull complete
Digest: sha256:266b191e926f65542fa8daaec01a192c4d292bff79426f47300a046e1bc576fd
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

$
```

</details>

---
## Phase 1 - FHIR Setup

The instructions are outlined in the following READMEs

- [ ] `coherent/README.md`
- [ ] `hapi/README.md`

Once this is complete, you can stop the hapi server.  This should cause it to
shrink its H2 database (which is saved in `data/hapi/h2`) and free up some disk
space in the meantime.

You can also stop Docker at this point.  Docker does consume some disk space
while it runs, so if you are already low on available disk space, this is an
option.

### Outcome

You should now have a compressed tar file with the full bulk export contents
saved in `data/bulk-export/full`!


---
## Phase 2 - OMOPCDM Setup

The instructions are outlined in the following README

- [ ] `athena/README.md`

Once this is completed, you can delete the unzipped terminology files to save
space.  This is recommended as long as you retail the compressed download file.

### Outcome

You should have a OMOPCDM database with terminology data loaded into it in
`data/cdm.db` (which is about 9 GB), and `data/empty.db` which is an empty
OMOPCDM database with no terminology loaded into it.


---
## Phase 3 - Translate FHIR to OMOP

The instructions are outlined in the following README

- [ ] `translate/README.md`

You can probably delete the uncompressed ndjson from `data/bulk-export`, but
you will need it if you want to modify any of the translation logic.


---
## Phase 4 - Load OMOPCDM

The instructions are outlined in the following README

- [ ] `load/README.md`


---
## Now What?

You should be able to connect your database to any of the many existing
visualization tools that work with OMOPCDM databases.

