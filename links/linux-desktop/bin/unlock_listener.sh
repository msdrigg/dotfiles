#!/bin/bash

dbus-monitor --session "type='signal', interface='org.gnome.ScreenSaver'" |
    while read x; do
        if [ "$x" == "boolean false" ] && ! test_dual_monitors; then
            configure_dual_monitors;
        fi
    done
