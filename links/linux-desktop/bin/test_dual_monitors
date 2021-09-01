#!/bin/bash

function notReady() {
    echo "Monitors are not setup because $1";
    exit 1
}

monitors=$(xrandr -q);

connected=$(echo "$monitors" | grep -c "\bconnected\b");
if [ "$connected" -lt "2" ]; then
    notReady "only $monitors monitors are connected"
fi

primary=$(echo "$monitors" | grep "\bDP-4\b");
if [[ "$primary" != *"primary"* ]] || [[ "$primary" != *"2560x1440+2560+0"* ]]; then
    notReady "DP-4 is not primary or not positioned correctly"
fi

secondary=$(echo "$monitors" | grep "^DP-0\b");
if [[ "$secondary" != *"2560x1440+0+0"* ]] || [[ "$secondary" == *"primary"* ]]; then
    notReady "DP-0 is primary or not positioned correctly"
fi

echo "Monitors are setup"
