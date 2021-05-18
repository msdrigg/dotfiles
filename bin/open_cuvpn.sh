#!/bin/bash
VPN_SERVER="cuvpn.clemson.edu"
VPN_STATUS=$(systemctl is-active vpnagentd.service)
if [[ ! ${VPN_STATUS} == "active" ]]
then
  echo "Starting vpnagent service"
  systemctl start vpnagentd.service
fi
CUVPN_STATUS=$(/opt/cisco/anyconnect/bin/vpn state)
SUB_TEST="Disconnected"
if [[ ${CUVPN_STATUS} == *${SUB_TEST}* ]]
then
  echo "Connecting to VPN..."
  /opt/cisco/anyconnect/bin/vpn -s < /opt/cisco/anyconnect/cuvpn_creds connect ${VPN_SERVER}
else
  echo "Vpn already connected"
fi
/opt/cisco/anyconnect/bin/vpnui
