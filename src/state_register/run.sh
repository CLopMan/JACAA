#!/bin/bash

# compiling 
echo -e "Compiling register" 
ghdl -a register_lib.vhdl 
ghdl -a multiplexor_2to1.vhdl
ghdl -a multiplexor_2to1_tb.vhdl
ghdl -e registertb
ghdl -e Multiplexor2To1TB
ghdl -a state_register.vhdl
ghdl -a state_register_tb.vhdl
ghdl -e stateregistertb

# exectution
echo -e "Execution:" 
echo -e "Tests register:" 
ghdl -r registertb
echo -e "Tests multiplexor:" 
ghdl -r Multiplexor2To1TB

echo -e "Tests SR:" 
ghdl -r stateregistertb


