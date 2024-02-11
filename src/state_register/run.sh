#!/bin/bash

# compiling 
echo -e "Compiling register" 
ghdl -a register.vhdl 
ghdl -a multiplexor_2to1.vhdl
ghdl -a multiplexor_2to1_tb.vhdl
ghdl -e registertb
ghdl -e Multiplexor2To1TB

# exectution
echo -e "Execution:" 
ghdl -r registertb
ghdl -r Multiplexor2To1TB