#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE}")";

SYSTEM_NAME="linux"
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    SYSTEM_NAME="wsl"
fi

source setup_common.sh ~ $SYSTEM_NAME
