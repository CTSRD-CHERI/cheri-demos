# DARPA CPM demo, March 28-29, 2024

## QEMU CHERI

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
