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
| [Registers](#Registers) | 2024-01-30 | | CLopMan, ALVAROPING1, 100472182 | CLopMan, ALVAROPING1, 100472182 |
| [PC and IR](#PC-and-IR) | | | | |
| [State Register](#State-Register) | 2024-02-12 | 2024-02-12 | CLopMan | CLopMan |
| [Memory](#Memory) | | | | |
| [Memory Interface](#Memory-Interface) | | | | |
| [ALU](#ALU) | 2024-01-30 | | Everyone | Everyone |
| [GPIO](#GPIO) | | | | |
| [Interruptions](#Interruptions) | | | | |

## Task

### Control Unit

### Registers

### PC and IR

### State Register

The design of the state register incorporates an arbitrary-size register and a multiplexer, allowing the unit to choose between two inputs depending on the signal M7. Addiotionally, another control signal, C7, has benn included to control when should the register update.  

### Memory

### Memory Interface

### ALU

### GPIO

### Interruptions
