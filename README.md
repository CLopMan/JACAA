# JACAA

Implementation of RISC-V integer instructions from scratch on a FPGA

## Running tests

Tests can be run with the `run.sh` script. The expected command structure is `./run.sh <entity> [loop]` where `<entity>` is the name of the testbench entity with the tests to execute, and `loop` is an optional argument which, if provided with a non-empty string, keeps automatically re-executing the tests when changes are detected

`make` can also be used to run tests:

-   `make all` runs the tests for all testbench entities
-   `make clean` removes all files generated from the compilation
-   `make run TARGET=<entity>` runs the tests for the specified testbench entity

`make` can also be used to flash implementation onto the FPGA

-   `make flash TOP_MODULE=<top_module_entity> VIVADO_PATH=<absolute path of Vivado>`
    -   It is necessary to have a constraints XDC file for proper functionality.
    -   This command creates a bitstream using the components in `src` directory and the top_module specified in `TOP_MODULE`.The bitstream is then flashed onto the FPGA.
