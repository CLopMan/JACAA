#!/bin/bash
# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Use: $0 <TOP_MODULE> <VIVADO_PATH>"
    exit 1
fi


# Asign arguments
TOP_MODULE=$1
VIVADO_PATH=$2

# Exec scripts
source $VIVADO_PATH/settings64.sh


vivado -mode batch -notrace -source ./scripts/generate_bit.tcl -tclargs JACAA $TOP_MODULE . && \
vivado -mode batch -notrace -source ./scripts/flash.tcl -tclargs JACAA
