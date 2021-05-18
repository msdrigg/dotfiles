#!/bin/sh

echo "Starting"

# settings
user="msdrigg"
pass='18!JkYFUCk1d*q$S3ZGO@UYM9UNm6l9u'
pass2="push"
host="cuvpn.clemson.edu"
tmpif="tun69"
iface="ocvpnc1"
pidfile="/tmp/${iface}.pid"
script="/usr/local/sbin/vpnc/vpnc-script"


# env
openconnect="/usr/local/sbin/openconnect"
ifconfig="/sbin/ifconfig"

echo "Gotten to pt1"

# func
ifkill()
{
        $ifconfig "$1" down 2>/dev/null || :
        $ifconfig "$1" destroy 2>/dev/null || :
}


# check if we're already running
# if [ -n "$test" ] && $test; then
#         echo "Connection is already up"
#         exit 0
# fi

echo "Gotten to pt2"

# clean up previous instance, if any
if [ -e "$pidfile" ]; then
        read pid <"$pidfile"
        echo "Killing previous pid: $pid"
        kill -TERM "$pid"
        rm "$pidfile"
fi
ifkill "$tmpif"
ifkill "$iface"


echo "Opening vpn"

# open vpn connection
$openconnect \
        --pid-file="$pidfile" \
        --interface="$tmpif" \
        --form-entry "main:username=$user" \
        --form-entry "main:password=$pass" \
        --form-entry "main:secondary_password=$pass2" \
        --background \
        "$host"

echo "VPN opened"


# rename the interface
if [ "$iface" != "$tmpif" ]; then
        echo "Renaming $tmpif to $iface"
        $ifconfig "$tmpif" name "$iface"
fi
