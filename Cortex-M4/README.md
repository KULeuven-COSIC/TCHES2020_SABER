
This repository contains the ARM Cortex-M4 code for SABER that demonstrate the Toom-Cook optimizations as well as the memory optimizations specific for Saber described in [eprint2020 - 268](https://eprint.iacr.org/2020/268.pdf).

## Sources

* `speed`: This code implements precomputation and lazy interpolation at the expense of memory to achieve the fastest performance.

* `mem`: This code implements the memory optimizations decribed in the paper together with the use of a memory efficient version of Karatsuba to achieve the lowest memory footprint.

* `fasteff`: In addition to the two versions reported in the paper, this code implements the precomputation and lazy interpolation together with all compatible memory optimizations to show an even slightly fastest version of Saber than in `speed` while reducing the memory usage considerably (roughly 7.5 KB and 8.5 KB less for encapsulation and decapsulation respectively).

**Note:** For other reference code for SABER on ARM Cortex-M4 microcontrollers as well as on other platforms, the reader can also visit the [official repository of the Saber submission](https://github.com/KULeuven-COSIC/SABER).

## Benchmark

Our code is compatible with the [pqm4](https://github.com/mupq/pqm4) library. The folders containing the sources can be copied directly to `pqm4/crypto_kem/saber/` for a full test, benchmark and comparison to other schemes.

Building up the `pqm4` library can be time consuming since it will compile all versions of all KEMs and digital signatures available. To avoid this and for a quick benchmark of only Saber code we have created a lightweight version of such framework in `benchmark`. All scripts are taken directly from `pqm4` library, which is under the conditions of [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

For a quick build and outputting the results in md format, the reader can execute the following commands given that the installation [requirements](https://github.com/mupq/pqm4/blob/master/README.md) for cross-compiling and running the `pqm4` framework are met.

```
python3 build_everything.py
```
```
[sudo] python3 benchmarks.py
```
```
python3 convert_benchmarks.py md
```

## Results

| scheme | implementation | key generation [cycles] | encapsulation [cycles] | decapsulation [cycles] |
| ------ | -------------- | ----------------------- | ---------------------- | ---------------------- |
| saber (1 executions) | m4-fasteff | AVG: 845,546 <br /> MIN: 845,546 <br /> MAX: 845,546 | AVG: 1,063,244 <br /> MIN: 1,063,244 <br /> MAX: 1,063,244 | AVG: 1,073,332 <br /> MIN: 1,073,332 <br /> MAX: 1,073,332 |
| saber (1 executions) | m4-mem | AVG: 2,046,183 <br /> MIN: 2,046,183 <br /> MAX: 2,046,183 | AVG: 2,538,454 <br /> MIN: 2,538,454 <br /> MAX: 2,538,454 | AVG: 2,740,263 <br /> MIN: 2,740,263 <br /> MAX: 2,740,263 |
| saber (1 executions) | m4-speed | AVG: 852,733 <br /> MIN: 852,733 <br /> MAX: 852,733 | AVG: 1,102,895 <br /> MIN: 1,102,895 <br /> MAX: 1,102,895 | AVG: 1,127,311 <br /> MIN: 1,127,311 <br /> MAX: 1,127,311 |

| Scheme | Implementation | Key Generation [bytes] | Encapsulation [bytes] | Decapsulation [bytes] |
| ------ | -------------- | ---------------------- | --------------------- | --------------------- |
| saber | m4-fasteff | 19,776 | 14,728 | 14,736 |
| saber | m4-mem | 5,116 | 3,668 | 3,684 |
| saber | m4-speed | 19,824 | 22,088 | 23,184 |
