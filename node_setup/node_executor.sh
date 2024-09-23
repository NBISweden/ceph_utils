#!/bin/bash

# this script will ssh to a list of nodes and execute a command
# the command is passed as an argument to the script
#
# usage: node_executor.sh [-p] <command>
# -p: flag to execute the command in parallel on all nodes
# example: node_executor.sh "ls -l"
# example: node_executor.sh -p "df -h"

#set -e
#set -x

# list of nodes
nodes_file="node_list.txt"

# Check if the file exists
if [ ! -f "$nodes_file" ]; then
  echo "Node list file $nodes_file not found. Create this file with one node per line, format: user@hostname"
  exit 1
fi

# check if if the command is a flag
if [[ $1 == -p ]]; then
    # set parallel flag
    parallel=true

    # shift the arguments to remove the flag
    shift
fi


# iterate over the list of nodes
while IFS= read -r node; do


    echo $node
    # command to execute
    cmd="ssh -o StrictHostKeyChecking=no $node $@"

    echo -e "----------------------------------------"
    echo -e "Executing \"$cmd\" on $node\n"
    if [ "$parallel" = true ]; then
        $cmd &
    else
        $cmd
    fi
    echo -e "----------------------------------------\n\n"
done < "$nodes_file"

wait






