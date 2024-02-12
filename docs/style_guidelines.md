# Code Style Guidelines

## Introduction

This document collects the coding style which will be followed during the
development of this project.

## Table of contents

1. [Keywords](#keywords)
2. [Indentation](#indentation)
3. [Range Direction](#range-direction)
4. [Array Direction](#array-direction)
5. [Maximum Line Size](#maximum-line-size)
6. [Spaces and Blank Line Conventions](#spaces-and-blank-line-conventions)
   1. [Operations and Declarations](#operations-and-declarations)
   2. [Headers of Functions and Processes](#headers-of-functions-and-processes)
   3. [Blank Lines](#blank-lines)
7. [Modules](#modules)
8. [Naming Conventions](#naming-conventions)
   1. [Signal, Variables, and Constants](#signal-variables-and-constants)
   2. [Data Types](#data-types)
   3. [Labels](#labels)
   4. [Module Names](#module-names)
   5. [Functional Units](#functional-units)
   6. [Libraries and Packages](#libraries-and-packages)
   7. [Summary](#summary)

____

## Keywords

Every keyword should be lowercase.

```vhdl
-- total garbage
ARChITECTURE Functional OF entity_name IS
    <declarations>
    ...
bEgiN
    PROCESS(sig1, sig2)
        <declarations>
        ...
    BEGIn
        <code>
        ...
    END process;
END architecture Functional;

-- good encoding
architecture Functional of entity_name is
    <declarations>
    ...
begin
    process(sig1, sig2)
        <declarations>
        ...
    begin
        <code>
        ...
    end process;
end architecture Functional;
```

## Indentation

Indentation should use **4 spaces**, *not tabs*. Every scope should start and end
in the same indentation level.

```vhdl
-- bad indentation
architecture Functional of EntityName is
<declarations>
...
   begin
    process(sig1, sig2)
      <declarations>
        ...
  begin
        <code>
        ...
            end process;
end architecture Functional;

-- good indentation
architecture Functional of EntityName is
    <declarations>
    ...
begin
    process(sig1, sig2)
        <declarations>
        ...
    begin
        <code>
        ...
    end process;
end architecture Functional;
```

## Range direction

The direction of range expressions should be upwards, using `to`.

```vhdl
natural range 0 to 15;
```

## Array direction

The direction of array expressions should be downwards, using `downto`.

```vhdl
std_logic_vector(15 downto 0);
```

## Maximum line size

Code lines should not exceed 80 characters.

```vhdl
-- bad line
signal data_out_a, data_out_b: std_logic_vector(31 downto 0) := (others => '0');

-- good line
signal data_out_a, data_out_b:
    std_logic_vector(31 downto 0) := (others => '0');

-- good line
signal data_out_a, data_out_b:
    a_very_long_type_name_which_exceeds_80_chars(31 downto 0)
    := (others => '0');
```

## Spaces and blank line conventions

### Operations and Declarations

Every binary operator must be surrounded by a space.
In addition, every variable, constant or signal declaration must follow this format:

> `name: data_type [:= value];`

```vhdl
-- bad space use
name:intenger:=1+13;

-- good space use
name: integer := 1 + 13;
```

### Headers of Functions and processes

Every function or process header should follow this format:

> `label: process(sig1, sig2, ...)`
>
> `function func_id(arg1: type, arg2: type, ...) return rt_type is`

```vhdl
-- bad headers
uut:process ( a,b )

function suma ( a:integer, b:integer ) return type integer is

-- good headers
uut: process(a, b)

function suma(a: integer, b: integer) return type integer is
```

### Blank lines

Two pieces of code can be separated by no more than **one blank line**. This does
not apply when **separating two functional units** (i.e. architecture and entity).
In this case **two blank lines** must be used.

```vhdl
-- bad encoding
entity Mux2 is
    port(
        in_data1: in std_logic_vector (size - 1 downto 0);
        ...

    );



end Mux2;



architecture Functional of Mux2 is

-- good encoding
entity Mux2 is
    generic(constant SIZE: integer := 32);

    port(
        in_data1: in std_logic_vector (size - 1 downto 0);
        ...
    );

end Mux2;


architecture Functional of Mux2 is
...
```

## Modules

Each module can not have more than **one entity**. In addition, it can have one package,
if it is related to the mentioned entity. In the case of not having an entity, this
does not restrict the addition of a package.

## Naming conventions

Every name referring any of this elements must be **at least 3 characters** long
and be descriptive. Exceptions to this rule will be addressed later.

### Signal, Variables and Constants

Every signal, variable and constant name should use this style:

- **variables** and **signals**: must use **snake_case**.
- **constants**: must use **SCREAMING_CASE**.

In some cases, such as standard domain names, variable or signal names can be
shorter (e.g. ALU inputs).

```vhdl
-- bad naming
constant V: integer := 3; -- too short, non-descriptive name
signal THISISASIGNAL: std_logic; -- not snake_case
variable thisIsAVariable: std_logic; -- not snake_case
constant thisisaconstant: integer; -- not SCREAMING_CASE

-- good naming
constant PI: integer := 3;
signal in_data: std_logic_vector(31 downto 0);
variable control_flag: std_logic;
```

### Data types

Data types must use **snake_case**.

```vhdl
-- bad data types' name
constant PI: Integer := 3;
signal in_data: MyOwnDataType;
signal in_data: Std_Logic_Vector(31 downto 0);

-- good data types' names
constant PI: integer := 3;
signal in_data: my_own_data_type;
signal in_data: std_logic_vector(31 downto 0);
```

### Labels

Labels must use **camelCase**.

```vhdl
-- bad naming
UUT: process
unit_under_test: process
UnitUnderTest: process

-- good naming
uut: process
unitUnderTest: process
```

### Module Names

Modules and file names must use **snake_case**. Moreover, they must use the `.vhdl`
extension.

Test files must be named as `<entity_under_test>_tb.vhdl`

```bash
# bad names
FileName.vhdl # PascalCase
file_name.vhd # not the correct extension
FILE_NAME.VHDL # screaming_case

# good names
alu.vhdl
state_register.vhdl
state_register_tb.vhdl # test file
```

### Functional Units

Functional Units (i.e. **entities** and **architectures**) must use **PascalCase**.
They also must add its name when closing its scope.

```vhdl
-- bad encoding
entity entity_name is
    ...
end entity;


architecture functional of entity_name is
    ...
end architecture;

-- good encoding
entity EntityName is
    ...
end EntityName;


architecture Functional of EntityName is
    ...
end architecture Functional;
```

### Libraries and Packages

In general, these should use **PascalCase**. However, when using an already defined
library or package (e.g. `Numeric`, `Std_Logic_1164`) **Capital_Snake_Case** should
be used.

If a package is related to an entity, its name must be `<EntityName>Pkg`.

```vhdl
-- bad encoding
package alu_pkg is
    type StateName is (Zero, Negative, Carry, Overflow);
    type StateType is array (StateName) of std_logic;
end package alu_pkg;

-- good encoding
package AluPkg is
    type StateName is (Zero, Negative, Carry, Overflow);
    type StateType is array (StateName) of std_logic;
end package AluPkg;
```

### Summary

|        element         |     style      |
|:---------------------- |:--------------:|
| signals and variables  |   snake_case   |
|       constants        | SCREAMING_CASE |
|       Data types       |   snake_case   |
|         labels         |   camelCase    |
|      Module Names      |   snake_case   |
|    Functional Units    |   PascalCase   |
| Libraries and Packages |   PascalCase   |
