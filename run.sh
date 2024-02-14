#!/bin/bash
# Runs the given entity, and reruns it when changes are detected
# Command structure: `./run.sh <entity> [loop]`

UPDATE_PERIOD="1s"

# Check parameters
if [[ "$1" == "" ]]; then
    echo -e "\033[31;1mError:\033[0m Missing entity to simulate"
    exit 1
fi

TARGET="TARGET=$1"
make --always-make run $TARGET
if [[ "$2" == "" ]]; then
    exit 0;
fi

# Periodically re-execute the simulation as needed
while [[ true ]]; do
    make -q run $TARGET
    if [[ "$?" == "1" ]]; then # Output is outdated, regenerate it
        echo "" # Add a blank line as separator
        make run $TARGET
    fi
    sleep $UPDATE_PERIOD
done
