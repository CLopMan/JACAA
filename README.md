# JACAA

Implementation of RISC-V integer instructions from scratch on a FPGA

## Running tests

Tests can be run with the `run.sh` script. The expected command structure is `./run.sh <entity> [loop]` where `<entity>` is the name of the testbench entity with the tests to execute, and `loop` is an optional argument which, if provided with a non-empty string, keeps automatically re-executing the tests when changes are detected

`make` can also be used to run tests:

- `make all` runs the tests for all testbench entities
- `make clean` removes all files generated from the compilation
- `make run TARGET=<entity>` runs the tests for the specified testbench entity
