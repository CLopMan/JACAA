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

| Task | Date Started | Date Last Update | Last Update Author | Contributors | State |
| ---- | ------------ | ---------------- | ------------------ | ------------ | ----- |
| [Control Unit](#Control-Unit) | 2024-06-26 | 2024-06-26 | | CLopMan, ALVAROPING1 | In progress |
| [Registers](#Registers) | 2024-01-30 | 2024-02-14 | CLopMan, ALVAROPING1, Adri-Extremix | CLopMan, ALVAROPING1, 100472182 | Finished |
| [PC and IR](#PC-and-IR) | 2024-06-07 | 2024-06-13 | CLopMan, ALVAROPING1| CLopMan, ALVAROPING1 | Finished |
| [State Register](#State-Register) | 2024-02-12 | 2024-07-01 | CLopMan | CLopMan | Finished |
| [Memory](#Memory) | | | | | Not started |
| [Memory Interface](#Memory-Interface) | | | | | Not started |
| [ALU](#ALU) | 2024-01-30 | 2024-03-25 | ALVAROPING1 | Everyone | Finished |
| [GPIO](#GPIO) | | | | | Not started |
| [Interruptions](#Interruptions) | | | | | Not Started |

## Task

### Control Unit
This component controls every signal value in the cpu depending on a 80 bits vector value. Due to its complexity, it was divided in different subcomponents: 

- 
- 
- 

#### Sel R
#### Mux A
#### Mux B
#### Mux C
#### Co2microaddr

### Registers

### PC and IR
The register template developed previously will be used for implementing the IR, without requiring additional code. 

PC features a register and a multiplexer that allows choosing the next update value between the previous value incremented by 4 and the bus. 

### State Register

The design of the state register incorporates an arbitrary-size register and a generic mux, allowing the unit to choose between two inputs depending on the signal M7. Additionally, another control signal, C7, has been included to control when should the register update.

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
Parametrized mux.

**Generics**
- sel_size: Selector input size.
- data_size: entries size.

**Signals**
- sel: selector.
- data_in: vector formed via concatenation of different input signals.
- data_out: std_logic_vector. Selected entry.

**Functionality**

The multiplexer selects a `data_size` wide portion of the `data_in` based on the binary value represented by the `sel` signal, and outputs this selected portion on `data_out`.
The portion selected is data_in(sel) with 0-indexing and starting from the value in the least significant (rightmost) position. 

**Example of use** 

```
library IEEE;
use IEEE.Std_Logic_1164.all;

library Src

entity OtherComponent is
[...]
end OtherComponent;

architecture Rtl of OtherComponent is
    signal selector: std_logic_vector (1 downto 0);
    signal mux_output: std_logic_vector (11 downto 0);
begin
    -- instantiation
    mux_example: entity Src.Multiplexer
        generic map (
            sel_size => 2,
            data_size => 12 
        )
        port map (
            sel => selector,
            -- assuming s3, s2, s1, s0 are 12 bits signals
            data_in => s3 & s2 & s1 & s0, -- reverse order because of BigEndian
            data_out => mux_out
        );
end Rtl;
```

#### Generic Register (Reg)

A parameterized register that updates based on clock edges and an update signal. It includes configurable parameters for register size and the clock edge sensitivity.

**Generics:**
- `reg_size` (positive): Defines the size of the register. Default value is `Constants.WORD_SIZE`.
- `updt_rising` (std_logic): Determines whether the register updates on the rising ('1') or falling ('0') edge of the clock.

**Ports:**
- `clk` (in `std_logic`): Clock signal.
- `rst` (in `std_logic`): Reset signal. When asserted ('1'), the register is cleared to 0.
- `update` (in `std_logic`): Update control signal. When asserted ('1'), the register updates its value from `in_data`.
- `in_data` (in `std_logic_vector`): Input data vector of size `reg_size`.
- `out_data` (out `std_logic_vector`): Output data vector of size `reg_size`.

**Signals:**
- `keeped_data` (std_logic_vector): Internal signal to hold the register's current value.

**Functionality:**
- The register updates its stored value from `in_data` on the specified clock edge (rising or falling) if the `update` signal is asserted ('1').
- If the `rst` signal is asserted ('1'), the register is reset to 0, regardless of the clock or update signals.
- The `out_data` port reflects the current stored value of the register.

**Behavior:**
1. **Reset (`rst`)**: When `rst` is asserted ('1'), `keeped_data` is set to all zeros.
2. **Clock Edge Sensitivity**: The register updates its value on the clock edge specified by `updt_rising`:
   - If `updt_rising` is '1', the register updates on the rising edge of `clk`.
   - If `updt_rising` is '0', the register updates on the falling edge of `clk`.
3. **Update Control (`update`)**: When `update` is asserted ('1') and the appropriate clock edge occurs, `keeped_data` is set to the value of `in_data`.
4. **Output (`out_data`)**: Continuously reflects the value of `keeped_data`.

**Example of use** 

```
library IEEE;
use IEEE.Std_Logic_1164.all;

library Src;

entity OtherComponent is 
    [...]
end OtherComponent;


architecture Rtl of OtherComponent is
    constant SIZE: positive := 16;
    signal clk: std_logic := '0';
    signal s_rst: std_logic := '0';
    signal s_out_data: std_logic_vector (SIZE - 1 downto 0);
    signal s_in_data: std_logic_vector (SIZE - 1 downto 0);
    signal s_update: std_logic := '0';
begin
    reg_instance: entity Src.Reg is 
        generic map(
            reg_sise => 16,
            updt_rising => '1'
        );
        port map (
            clk => clk,
            rst => s_rst,
            update => s_update,
            out_data => s_out_data,
            in_data => s_in data
        );
[...]

end rtl;
```
