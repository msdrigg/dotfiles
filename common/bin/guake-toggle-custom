#!/bin/bash

# guake-toggle only prints to stdout if guake is active
if [ "$(guake-toggle)" == "" ]; then
    guake &
    sleep 0.5;
    guake-toggle;
fi
