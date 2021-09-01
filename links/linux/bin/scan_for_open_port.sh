#!/bin/bash

if [ -z "$1" ]; then
    GATEWAY_IP=$(route | egrep ^default | awk '{print $2}')
else
    GATEWAY_IP=$1
fi


