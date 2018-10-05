# Helper Container to perform Packer builds against Vsphere

[![CircleCI](https://circleci.com/gh/homelabaas/helper-packer-vsphere.svg?style=svg)](https://circleci.com/gh/homelabaas/helper-packer-vsphere)

This will create a docker image for devops tasks with virtual machines in vSphere, using Packer.

## Tooling

* Packer - <https://packer.io>
* Jetbrains Packer Builder for vSphere - <https://github.com/jetbrains-infra/packer-builder-vsphere>
* Minio - <https://www.minio.io/>

Based off the official Hashicorp Packer docker image.

This image will pull files down from a minio store to run packer builds against.

## Requirements

* Minio running as a file store
* Packer files in the minio store

## Usage

### Setup minio

Ensure you have minio running. To run it, execute the following:

```bash
docker run --name minio -p "9000:9000" minio/minio
```

Grab the Access Key and Secret Key from when the container starts up using the logs of the container.

### Create environment variables file

Create an environment file called __test.env__ with contents like the following:

```ini
USERNAME=administrator@vsphere.local
PASSWORD=adminpassword
SERVER=my.vcenter.server.com
DATASTORE=Datastore
NETWORK=VM Network
HOST=ESXHost
VMNAME=my-vm
ISO=[Datastore] ISOs/ubuntu-16.04.4-server-amd64.iso
FOLDER=mybuildfolder
SSH_USERNAME=ubuntu
SSH_PASSWORD=ubuntupassword
BUCKET=build
BUILDFOLDER=packer/ubuntu1604iso
MINIO_ACCESS_KEY=HQ0XW1SN2ZXXXCRI3Y30
MINIO_SECRET_KEY=v+1dMnW88R5gxxxxxxxxxmWDRJYtLBhniXfZHhQhf
MINIO_URL=http://10.0.0.1:9000
PACKERJSONFILE=ubuntu-16.04.json
```

### Run a packer build locally

To run an ISO packer build for ubuntu 16.04:

```bash
docker run --env-file ./test-iso.env helper-packer-vsphere
```

To debug the shell scripts, by shelling into the container:

```bash
docker run --env-file ./test-iso.env -it --entrypoint bash helper-packer-vsphere
```

## Environment Variable Field Descriptions

### Packer variables

* USERNAME - VCenter username
* PASSWORD - VCenter password
* SERVER - VCenter server url
* DATASTORE - The datastore for the new VM
* NETWORK - The network for the new VM
* HOST - The host machie for the new VM
* VMNAME - The name of the new VM
* ISO - The location of the ISO file to install from. Optional.
* SSH_USERNAME - The initial root username to setup.
* SSH_PASSWORD - The initial root password to setup.
* FOLDER - The VMware folder to create the VMs in.
* TEMPLATE - The VM to clone for this operation. Optional.

### Minio variables for syncing assets

* BUCKET - The name of the minio bucket to sync files from.
* BUILDFOLDER - Folder in that bucket that contains the build files. This folder is recursively downloaded into the container. Any files with the .template extension will have environment variables replaced before the packer build takes place.
* MINIO_ACCESS_KEY - The access key for the minio bucket.
* MINIO_SECRET_KEY - The secret key for the minio store.
* MINIO_URL - The URL location of the minio server.
* PACKERJSONFILE - The name of the file to run the packer build against, which should sit in the BUILDFOLDER.

## How does it work

The container just runs /bin/packer-build.sh, which will:

* Sync files from minio using sync-minio.sh.
* Do environment variable replacement for any files with a .template extension in the BUILDFOLDER location.
* Run packer build against the PACKERJSONFILE specified.

## Notes

If a MINIO_URL is not provided to the build script, the build script will assume minio is running on the host of the machine the container is running on, on port 9000. This is suitable for single machine and developer installations. If you are running Minio somewhere else, provide the MINIO_URL.