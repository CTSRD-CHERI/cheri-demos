# Sail CHERI-x86 demo

## Setup

### Install needed packages:

FreeBSD:

- `sudo pkg install math/z3 devel/ocaml-opam`

macOS:

- `brew install opam z3`

### Initialize opam environment:

- `opam init`
- `eval `opam env``

### Build and install Sail:

- `git clone https://github.com/rems-project/sail.git`
- `opam pin add sail`

### Build CHERI-x86 LLVM:

Assumes cheribuild is installed and available.

- `mkdir cheri`
- `cd cheri`
- `git clone git@github.com:CTSRD-CHERI/llvm-project.git`
- `git checkout x86_assembly`
- `cheribuild llvm`

### Build executable Sail model:

- `git clone git@github.com:CTSRD-CHERI/sail-cheri-x86.git`
- `cd sail-cheri-x86`
- `git submodule init`
- `git submodule update`
- `gmake`

### Clone CHERI-x86 test programs:

- `git clone git@github.com:CTSRD-CHERI/sail-cheri-x86-tests.git`

## Walkthrough

- `cd sail-cheri-x86-tests/hybrid`
- `make clean`

### Demo 1: Simple buffer overflow

Display source:

- `tail mov-mem-bad-bounds.S`

Compile binary:

- `make CC="${HOME}/cheri/output/sdk/bin/clang" mov-mem-bad-bounds`

Show disassembly:

- `~/cheri/output/sdk/bin/objdump -d mov-mem-bad-bounds.o`

Execute binary:

Explain arguments to emulator, -b gives address and filename of binary
to load into memory, -C rip sets the PC to that address, -C cax_test
initializes CAX to a specific capability with base of 0x8000 and
length of 0x1000.

- `../../sail-cheri-x86/x86_emulator -b 0x600,mov-mem-bad-bounds -C app_view=1 -C log_register_writes=1 -C set64bit=1 -C rip=0x600 -C cax_test=1 -C rflags=2`

Note length of CAX is 0x1000, so offset 0x1000 used as the immediate
in the instruction is out of bounds, hence the fault.

Show bounds check in Sail model:

- `less ../../sail-cheri-x86/src/cheri_memory_accessors.sail`

Go to `check_linear_memory_access` function and show various checks
including permissions and bounds checks.

### Demo 2: Pointer arithmetic

Display source:

- `tail addc-81.S`

Compile binary:

- `make CC="${HOME}/cheri/output/sdk/bin/clang" addc-81`

Show disassembly:

- `~/cheri/output/sdk/bin/objdump -d addc-81.o`

Execute binary:

- `../../sail-cheri-x86/x86_emulator -b 0x600,addc-81 -C app_view=1 -C log_register_writes=1 -C set64bit=1 -C rip=0x600 -C cax_test=1 -C rflags=2`

Show how each instruction maps to the logged lines from the emulator
including fetching opcode bytes, reading/writing the cap.  Note the
altered address field when the add writes the result.  Note the offset
field when CDX is read at the end.  Finally, note we stopped at the
end due to `ud2`.

### Demo 3: Non-representable pointer arithmetic

Display source:

- `tail addc-05.S`

Compile binary:

- `make CC="${HOME}/cheri/output/sdk/bin/clang" addc-05`

Execute binary:

- `../../sail-cheri-x86/x86_emulator -b 0x600,addc-05 -C app_view=1 -C log_register_writes=1 -C set64bit=1 -C rip=0x600 -C cax_test=1 -C rflags=2`

Note resulting value of CAX: base has been changed, and tag is cleared.
