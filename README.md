
This repository contains the code for AVX2, C and Cortex-M4 platforms implementing on SABER the Toom-Cook optimizations described in [eprint2020 - 268](https://eprint.iacr.org/2020/268.pdf). In the case of the Cortex-M4 code, the memory optimizations described in that paper are also implemented.

**Note:** For other reference code for SABER on either of these three platforms, the reader can also visit the [official repository of the Saber submission](https://github.com/KULeuven-COSIC/SABER).

## AVX2

On the corresponding subdirectory `make` will compile the sources. Among the generated executables `./test/test_kex` will run speed benchmarks on the compiled version.

## C

On the corresponding subdirectory `make` will compile the sources. Among the generated executables `./test/test_kex` will run speed benchmarks on the compiled version. In the header file `poly_mul.h` the polynomial multiplication algorithm can be switched between two levels of Toom-Cook by defining `MUL_TYPE TC_TC` to `TC_TC` or the combination of Toom-Cook followed by two levels of Karatsuba with `TC_KARA`.

```c
#define MUL_TYPE TC_TC
//#define MUL_TYPE TC_KARA
```

## Cortex-M4

More detailed documentation is available in a `README` file in the corresponding subdirectory.
