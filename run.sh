#!/bin/bash
# Runs the given entity, and reruns it when changes are detected
# Command structure: `./run.sh <entity> [loop]`

UPDATE_PERIOD="1s"
MAKE_ARGS='--silent'

# Check parameters
if [[ "$0" == "" ]]; then
    echo -e "\033[31;1mError:\033[0m Missing script file path"
    exit 1
fi
if [[ "$1" == "" ]]; then
    echo -e "\033[31;1mError:\033[0m Missing entity to simulate"
    exit 2
fi

CWD=$(dirname "$0")
export WORK="$CWD/work"
# Create output directory if it doesn't exist
if [ ! -d "$WORK" ]; then
    mkdir "$WORK"
fi

export TARGET="$1"
make --always-make $MAKE_ARGS run
if [[ "$2" == "" ]]; then
    exit 0;
fi

# Periodically re-execute the simulation as needed
while [[ true ]]; do
    make -q $MAKE_ARGS
    if [[ "$?" == "1" ]]; then # Output is outdated, regenerate it
        echo "" # Add a blank line as separator
        make $MAKE_ARGS run
    fi
    sleep $UPDATE_PERIOD
done
