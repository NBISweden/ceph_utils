#!/bin/bash

# Function to display help message
function display_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h             Display this help message"
    echo "  -s SIZE        Size of random file (default: 1GB)"
    echo "  -n COPIES      Number of copies to upload (default: 1)"
    echo "  -c CONCURRENCY Number of concurrent uploads (default: 1)"
    echo "  -e ENDPOINT    IP address of S4 Ceph cluster endpoint (e.g. http://hostname)"
    exit 1
}

# Default values
size="1G"
copies=1
concurrency=1
endpoint=""

# Process command-line arguments
while getopts "hs:n:c:e:" opt; do
    case $opt in
        h)
            display_help
            ;;
        s)
            size=$OPTARG
            ;;
        n)
            copies=$OPTARG
            ;;
        c)
            concurrency=$OPTARG
            ;;
        e)
            endpoint=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            ;;
    esac
done

# Generate random file with the specified size
random_file="/dev/shm/random_file.txt"
dd if=/dev/urandom of=$random_file bs=${size} count=1

# Upload files concurrently
bucket_name="test"
for ((i=1; i<=$copies; i++)); do
    for ((j=1; j<=$concurrency; j++)); do
        if [[ -z "$endpoint" ]]; then
            ( aws s3 cp $random_file s3://$bucket_name/$(uuidgen) ) &
        else
            ( aws --profile ceph --endpoint $endpoint s3 cp $random_file s3://$bucket_name/$(uuidgen) ) &
        fi
    done
    wait
done

# Cleanup - delete the generated file
rm $random_file

