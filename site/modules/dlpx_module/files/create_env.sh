#!/bin/bash

# 6.0.9.0
export API_MAJOR="1"
export API_MINOR="11"
export API_MICRO="33"
export DELPHIX_ENGINE_IP="dlpx-22001-hackthon2024.dcol1.delphix.com"
export DELPHIX_ADMIN_USER="admin"
export DELPHIX_ADMIN_PASSWORD="delphix"
export CRDB_USER="delphix"
export CRDB_PASSWORD="delphix"
export CRDB_HOST_ADDRESS=$(hostname -i)
export CRDB_HOME="/home/delphix"

echo "$CRDB_HOST_ADDRESS<<<"

curl -s -X POST -k --data @- http://$DELPHIX_ENGINE_IP/resources/json/delphix/session \
    -c ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "APISession",
    "version": {
        "type": "APIVersion",
        "major": $API_MAJOR,
        "minor": $API_MINOR,
        "micro": $API_MICRO
    }
}
EOF
echo

# login into Delphix Engine
curl -s -X POST -k --data @- http://$DELPHIX_ENGINE_IP/resources/json/delphix/login \
    -b ~/cookies.txt -c ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "LoginRequest",
    "username": "$DELPHIX_ADMIN_USER",
    "password": "$DELPHIX_ADMIN_PASSWORD"
}
EOF
echo

curl -X POST -k --data @-  http://$DELPHIX_ENGINE_IP/resources/json/delphix/environment \
-b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "HostEnvironmentCreateParameters",
    "primaryUser":{
        "type":"EnvironmentUser",
        "name": "$CRDB_USER",
        "credential":
        {
            "type": "PasswordCredential",
            "password": "$CRDB_PASSWORD"
        }
    },
    "hostEnvironment": {
        "type": "UnixHostEnvironment",
        "name": "$CRDB_HOST_ADDRESS"
    },
    "hostParameters": {
        "type": "UnixHostCreateParameters",
        "host": {
            "type": "UnixHost",
            "address": "$CRDB_HOST_ADDRESS",
            "toolkitPath": "$CRDB_HOME/toolkit"
        }
    }
}
EOF
