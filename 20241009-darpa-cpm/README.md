# DARPA CPM demo, October 9-10, 2024

## Kernel compartmentalization

### Setup

1. Run:

   ```
   ./kernel-c18n/setup.sh
   ```

### PI meeting demo

1. Run:

   ```
   ./kernel-c18n/demo-pi.sh
   ```

### Example `sift_sa` kernel module

1. Load the multi-object ELF `sift_sa` kernel module:

   ```
   kldload sift_sa
   ```

1. Overflow the public buffer by 1 byte, waiting 1s after reading 5 bytes, and
   suspend the process:

   ```
   dd if=/dev/sift_sa_public of=/dev/null bs=1 count=17 speed=5
   ```
   ```
   CTRL-z
   ```

1. Enter `ddb`:

   ```
   sysctl debug.kdb.enter=1
   ```

1. Display loaded kernel modules and their objects:

   ```
   kldstat
   ```

1. List compartments:

   ```
   c18nstat
   ```

1. Show compartment details, including symbols it imports through relocations:

   ```
   show compartment addr
   ```

### Example zlib kernel module

There are two zlib kernel modules:

* `zlib_mo` compiled for the multi-object ELF format

* `zlib` compiled for the ELF format without modifications

Loading either of them will result in using compartmentalization, with
compartments per object in the `zlib_mo`'s case.

1. Load the multi-object ELF zlib kernel module.

   ```
   kldload zlib_mo
   ```

1. Run the `zlibtest` user-space program that uses `/dev/crypto` to
   compress data.

   ```
   zlibtest -p
   ```

1. Enter `ddb` and display commands as in the `sift_sa`'s case.

## Library-based compartmentalization for multi-library ELFs

* `password_checker.c` contains a function that checks a given string against a
  secret password, stored in a static variable.
* `database.c` contains a function that returns a secret string, again stored
  in a static variable.
* `main.c` reads the user's input and calls into `password_checker` to check if
  the input matches the password. If yes, it then calls into `database` to
  obtain the secret string and print it out.

Run `make all` to compile the three files into three separate binaries that
will be dynamically linked together at runtime. Library-based
compartmentalization ensures that each binary is an isolated compartment.

Sometimes we wish to have compartments within a binary. This is possible by
combining several binaries into a single ELF that is treated as a collection of
libraries at runtime. To create such a library, run
```
objcopy -T password_checker.so -T database.so main unified_main
```
to combine all three binaries into one `unified_main` executable.

The current demo only supports invoking `unified_main` indirectly:
```
/libexec/ld-elf.so.1 ./unified_main
```
And with library-based compartmentalization enabled:
```
LD_COMPARTMENT_ENABLE=1 /libexec/ld-elf.so.1 ./unified_main
```
