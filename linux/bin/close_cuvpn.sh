#!/bin/bash
VPNSTATUS=$(systemctl is-active vpnagentd.service)
if [[ ${VPNSTATUS} == "active" ]]
then
  echo "Closing vpnagent service"
  systemctl stop vpnagentd.service
fi
