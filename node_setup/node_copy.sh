#!/bin/bash

# this script will copy a file to all nodes in the cluster
# usage: ./node_copy.sh [-p] <file> <destination>
# -p: flag to execute the command in parallel on all nodes
# example: ./node_copy.sh /home/ubuntu/test.txt /home/ubuntu/
# example: ./node_copy.sh -p /home/ubuntu/test.txt /home/ubuntu/test.txt

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

# get the file to copy
file=$1

# get the destination
dest=$2

# iterate over the list of nodes
while IFS= read -r node; do
    echo -e "----------------------------------------"
    echo -e "Copying $file to $node:$dest"

    if [ "$parallel" = true ]; then
        rsync -avz -e "ssh -o StrictHostKeyChecking=no" $file $node:$dest &
    else
        rsync -avz -e "ssh -o StrictHostKeyChecking=no" $file $node:$dest
    fi
    echo -e "----------------------------------------\n\n"
done < "$nodes_file"

echo -e "Done\n"
 

