# Simple GDB-based demonstrations of CHERI memory safety

Run `make` to build -aarch64 and -cheri versions of each test program.
The former use 64-bit Arm, whereas the latter are compiled for CheriABI,
a pure-capability UNIX process environment.

## buffer-overflow.c

Illustrate a classical buffer overflow against a global array.

## use-after-free.c

Demonstrate CHERI use-after-reallocation protection using Cornucopia
Reloaded (MMU-assisted capability load barrier revocation).

Notice that while the allocation remains in quarantine (i.e., has not
been revoked), the memory cannot be reallocated.

We force a revocation pass for demonstration purposes, but this is not
required for heap temporal safety.

## ptr-type-confusion.c

Illustrate how CHERI prevents integer-pointer confusion by clearing
the tag on an integer manipulation of a pointer value in memory.

## readonly-ptr.c

Demonstrate dynamic enforcement of capability protections by trying to
store via a read-only capability.

## monotonicity.c

Demonstrate the effects of monotonicity on capability bounds: Once
bounds have been narrowed to a specific allocation, they cannot be
broadened.

## sentry.c

Illustrate how sentry capabilities prevent pointer arithmetic from being
used to manipulate a control-flow pointer.

## ipc-ptr.c

Demonstrate how the OS can enforce higher level properties using CHERI:
Prevent the propagation of pointers via inter-process communication (IPC)
using UNIX pipes.
