# DARPA CPM demo, March 28-29, 2024

## CHERI QEMU

1. Install CHERI QEMU:

   ```
   pkg64 install qemu
   ```

1. Install BBL for CHERI-RISC-V:

   ```
   cp -a overlay/usr/local64/share/qemu-cheri/* /usr/local64/share/qemu-cheri/
   ```

   The file was compiled with `cheribuild.py bbl-baremetal-riscv64`.
   Note that this target currently does not work on CheriBSD/Morello.

1. While connected to the Computer Lab network, fetch the latest
   CheriBSD/CHERI-RISC-V image and its corresponding purecap kernel for the dev
   branch:

   ```
   curl -u "<CRSid>:<api token>" https://ctsrd-build.cl.cam.ac.uk/job/CheriBSD-pipeline/job/dev/lastSuccessfulBuild/artifact/artifacts-riscv64-purecap/cheribsd-riscv64-purecap.img.xz --output cheribsd-riscv64-purecap.img.xz
   ```
   ```
   curl -u "<CRSid>:<api token>" https://ctsrd-build.cl.cam.ac.uk/job/CheriBSD-pipeline/job/dev/lastSuccessfulBuild/artifact/artifacts-riscv64-purecap/kernel.CHERI-PURECAP-QEMU.xz --output kernel.CHERI-PURECAP-QEMU.xz
   ```
   ```
   unxz cheribsd-riscv64-purecap.img.xz
   ```
   ```
   unxz kernel.CHERI-PURECAP-QEMU.xz
   ```

   Note that we don't host QEMU images at download.CheriBSD.org.
   ctsrd-build.cl.cam.ac.uk can only be accessed via VPN or while in the
   Computer Lab.

1. Run a VM with the files `cheribsd-riscv64-purecap.img` and
   `kernel.CHERI-PURECAP-QEMU`:

   ```
   ./run-riscv64-purecap
   ```
