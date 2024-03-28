# DARPA CPM demo, March 28-29, 2024

## CHERI GDB demonstration

1. `gdb-cheri-c18n okular`.

1. In GDB: `r`.

1. In Okular: `File` -> `Open` and click on a file you want to open but don't
   click `Open`.

1. In GDB: `ctrl-c`

1. In GDB: `rbreak png`. This will take 5s and will display a list of breakpoints.

1. In GDB: `q<enter>` to exit the list of set breakpoints.

1. In GDB: `c`.

1. In Okular: `Open`.

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
