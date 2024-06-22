# Project

The goal of this project is to develop a `VHDL` implementation of the standard `RV32I` for `FPGA` usage.

## Authors

- [CLopMan](https://github.com/CLopMan)
- [ALVAROPING1](https://github.com/ALVAROPING1)
- [joseaverde](https://github.com/joseaverde)
- [100472182](https://github.com/100472182)

## Introduction

This document provides an overview of the project's organizational structure. Following sections delve into the specifics of each major task and the respective modules to be developed.

## Summary

| Task | Date Started | Date Last Update | Last Update Author | Contributors |
| ---- | ------------ | ----------------- | ------------------- | ------------ |
| [Control Unit](#Control-Unit) | | | | |
| [Registers](#Registers) | 2024-01-30 | 2024-02-14 | CLopMan, ALVAROPING1, 100472182 | CLopMan, ALVAROPING1, 100472182 |
| [PC and IR](#PC-and-IR) | 2024-06-07 | | | |
| [State Register](#State-Register) | 2024-02-12 | 2024-03-22 | CLopMan | CLopMan |
| [Memory](#Memory) | | | | |
| [Memory Interface](#Memory-Interface) | | | | |
| [ALU](#ALU) | 2024-01-30 | 2024-03-25 | ALVAROPING1 | Everyone |
| [GPIO](#GPIO) | | | | |
| [Interruptions](#Interruptions) | | | | |

## Task

### Control Unit

### Registers

### PC and IR
The register template developed previously will be used for implementing the IR, without requiring additional code. 

PC features a register and a multiplexer that allows choosing the next update value between the previous value incremented by 4 and the bus. 

### State Register

The design of the state register incorporates an arbitrary-size register and a multiplexer, allowing the unit to choose between two inputs depending on the signal M7. Additionally, another control signal, C7, has been included to control when should the register update.

### Memory

### Memory Interface

### ALU

This component implements a 2 input ALU with the simple logical (`AND`, `OR`, `XOR`, and `NOT`) and arithmetic (addition and subtraction) operations. It also implements logical shifts (left and right) as well as arithmetic shifts (right only). Additionally, it has a `NO-OP` operation which always results in 0.

For logical shifts, the amount of bits to shift by is interpreted as an unsigned number modulo the word size ($\text{unsigned}(B) \mod{\text{WordSize}}$). For arithmetic shifts, the value is instead clamped at the word size ($`\min(\text{unsigned}(B), \text{WordSize})`$). This is how RISC-V instructions interpret this value.

For all of the operations, state information is also calculated, which includes zero, negative, carry out, and overflow.

### GPIO

### Interruptions

### Other components
This section collects some non-main components of the processor that were developed during the project.

#### Generic Mux
Parametrized mutex.

**Generics**
- sel_size: Selector input size.
- data_size: entries size.

**Signals**
- sel: selector.
- data_in: vector formed via concatenation of different input signals.
- data_out: std_logic_vector. Selected entry.

**Functionality**
The multiplexer selects a `data_size` wide portion of the `data_in` based on the binary value represented by the `sel` signal, and outputs this selected portion on `data_out`.
