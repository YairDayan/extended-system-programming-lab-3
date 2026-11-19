# Lab 3 - Extended System Programming Laboratory

Low-level Linux programming with system calls, assembly (`nasm`), and C without the standard library.

## Structure

```
task0/   Print each argv argument on its own line via system_call
task1/   Encode uppercase letters (+3) in assembly, with -i/-o redirection
task2/   List directory entries (getdents) and attach infection code to matching files
```

## Build

Requires 32-bit toolchain (`gcc -m32`, `nasm`, `ld -m elf_i386`).

```bash
cd task0   # or task1 / task2
make
```

Clean build artifacts:

```bash
make clean
```

## Notes

- Each task is self-contained with its own `makefile` and sources.
- Code uses direct system calls (`int 0x80`) through `system_call` in `start.s`.
