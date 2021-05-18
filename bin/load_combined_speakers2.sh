#!/bin/bash
MODS=$(pactl list modules)
SINKS=$(pactl list sinks)

if [[ $SINKS != *"Name: bluez_sink"* ]]; then
  if [[ $1 != "-skip" ]]; then
    echo "Sleeping before attempting bluetooth connection"
    sleep 20
  fi
  bluetoothctl connect EC:81:93:5A:66:BB
fi

# if [[ $MODS != *"sink_name=delayed_speakers"* ]]; then
#   /home/msd/bin/load_combined_speakers.sh
# fi
# exit

#if [[ $MODS != *"sink_name=delayed_speakers"* ]]; then
#  sleep 10
#  pactl load-module module-null-sink sink_name=delayed_speakers sink_properties=device.description=DelayedSpeakers
#fi

if [[ $MODS != *"sink_name=remapped_bluetooth"* ]]; then
  sleep 10
  pactl load-module module-remap-sink sink_name=remapped_bluetooth master=bluez_sink.EC_81_93_5A_66_BB.a2dp_sink channels=2 master_channel_map=front-left,front-right channel_map=rear-right,rear-left remix=no
fi

#if [[ $MODS != *"source=delayed_speakers"* ]]; then
  sleep 10
  pactl load-module module-loopback latency_msec=80 source=remapped_bluetooth.monitor sink=alsa_output.usb-Generic_USB_Audio-00.analog-stereo
# channel_map=front-left,front-right
#fi
exit
