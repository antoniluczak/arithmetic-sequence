# Arithmetic Sequence

This project implements an arithmetic sequence calculation routine in x86-64 assembly language (NASM), callable from C.

Given two consecutive terms of an arithmetic sequence, the function calculates the term at an arbitrary integer index `k`, including negative indices. The implementation supports signed integers with arbitrary precision, using a two's complement representation stored in little-endian order.

## Function Interface

```c
typedef struct {
    uint64_t lo;
    int64_t  hi;
} int128_t;

int128_t arithmetic_sequence(
    uint64_t const *A0,
    uint64_t const *A1,
    uint64_t *Ak,
    size_t n,
    int64_t k
);
```

### Parameters

| Parameter | Description                                                                                              |
| --------- | -------------------------------------------------------------------------------------------------------- |
| `A0`      | Pointer to the first term, represented as an array of `n` 64-bit words.                                  |
| `A1`      | Pointer to the second term, represented as an array of `n` 64-bit words.                                 |
| `Ak`      | Pointer to the output buffer for the calculated term. The buffer must hold `n` 64-bit words.             |
| `n`       | Number of 64-bit words used to represent each input and output integer. It is guaranteed to be positive. |
| `k`       | Index of the term to calculate. Negative indices are allowed.                                            |

### Return Value

The function returns an `int128_t` structure containing the 128 most significant bits of the calculated term.

The output buffer `Ak` receives the lower `64 * n` bits of the result. Together, the output buffer and the return value represent the calculated integer.

## Building

Assemble the source file using NASM:

```bash
nasm -f elf64 -w+all -w+error \
    -o arithmetic_sequence.o arithmetic_sequence.asm
```

The resulting object file can be linked with C or C++ programs.

### Example

Compile the example:

```bash
gcc -c -Wall -Wextra -std=c23 -O2 \
    -o arithmetic_sequence_example_c.o \
    arithmetic_sequence_example.c
```

Link the executable:

```bash
gcc -z noexecstack \
    -o arithmetic_sequence_example_c \
    arithmetic_sequence_example_c.o \
    arithmetic_sequence.o
```

Run the program:

```bash
./arithmetic_sequence_example_c
```
