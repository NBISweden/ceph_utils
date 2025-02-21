#!/bin/sh

# get arguments
netdata_dest=$1
netdata_allow=$2

# download config file
wget https://raw.githubusercontent.com/nsm-lab/netdata/refs/heads/master/streaming/stream.conf

# generate api key
api_key=$(uuidgen)

awk "
    /Enable this on slaves,/ {
        print
        getline
        sub(\"enabled = no\", \"enabled = yes\")
    }
    /This communication/ {
        print
        getline
        sub(\"destination =\", \"destination = $netdata_dest\")
    }
    /The API_KEY to use/ {
        print
        getline
        sub(\"api key =\", \"api key = $api_key\")
    }
    1
" stream.conf > stream.netdata_node.conf


awk "
    /\[API_KEY\] is/ {
        print
        getline
        sub(\"\\\[API_KEY\\\]\", \"[$api_key]\")
    }
    /The default \(for unknown API keys\)/ {
        print
        getline
        sub(\"enabled = no\", \"enabled = yes\")
    }
    /should also be matched at netdata.conf/ {
        print
        getline
        sub(\"allow from = \\\*\", \"allow from = $netdata_allow\")
    }
    1
" stream.conf > stream.netdata_master.conf


