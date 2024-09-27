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
