# DARPA CPM demo, October 9-10, 2024

## Kernel compartmentalization

### Setup

1. Store a password for the Jenkins readonly user in:

   ```
   ~/.config/ctsrd-jenkins-readonly-user.txt
   ```

1. Install curl.

   ```
   sudo pkg64c install curl
   ```

1. Enter the directory with scripts.

   ```
   cd kernel-c18n/
   ```

1. While connected to the Computer Lab network, fetch a disk image.

   ```
   ./fetch.sh
   ```

1. Start a VM.

   ```
   ./start.sh
   ```

1. Stop a VM.

   ```
   ./stop.sh
   ```

### ddb

You can enter ddb(4) in the bhyve console by executing:

```
sysctl debug.kdb.enter=1
```

ddb implements the following commands:

* List kernel modules with their objects:

  ```
  kldstat
  ```

* List compartments:

  ```
  c18nstat
  ```

* List compartments with those automatically created for all threads:

  ```
  c18nstat/v
  ```

* Show compartment details, including symbols it imports through relocations:

  ```
  show compartment addr
  ```

### Example zlib kernel module

There are two zlib kernel modules:

* `zlib_mo` compiled for the multi-object ELF format

* `zlib` compiled for the ELF format without modifications

Loading either of them will result in using compartmentalization, with
compartments per object in the `zlib_mo`'s case.

### Demo

1. Load the multi-object ELF zlib kernel module.

   ```
   kldload zlib_mo
   ```

1. Run the `zlibtest` user-space program that uses `/dev/crypto` to
   compress data.

   ```
   zlibtest
   ```
