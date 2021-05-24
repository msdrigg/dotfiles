#!/bin/bash
MODS=$(pactl list modules)
SINKS=$(pactl list sinks)

if [[ $SINKS != *"Name: bluez_sink"* ]]; then
  if [[ ($1 != "-skip") && ($2 != "-skip") ]]; then
    echo "Sleeping before attempting bluetooth connection"
    sleep 20
  fi
  bluetoothctl connect EC:81:93:5A:66:BB
fi

if [[ ($1 == "-exit") || ($2 == "-exit") ]]; then
  exit
fi
# if [[ $MODS != *"sink_name=delayed_speakers"* ]]; then
#   /home/msd/bin/load_combined_speakers.sh
# fi
# exit

if [[ $MODS != *"sink_name=delayed_speakers"* ]]; then
  sleep 10
  echo "Loading null sink";
  pacmd load-module module-null-sink sink_name=delayed_speakers sink_properties=device.description=DelayedSpeakers
fi

SINKS=$(pactl list sinks)
if [[ ($SINKS != *"Name: bluez_sink"*) ]]; then
  echo "Bluetooth failed to load, so quitting"
  exit
fi

if [[ ($MODS != *"sink_name=remapped_bluetooth"*) ]]; then
  sleep 10
  echo "Loading remap sink"
  pacmd load-module module-remap-sink sink_name=remapped_bluetooth master=bluez_sink.EC_81_93_5A_66_BB.a2dp_sink channels=2 master_channel_map=front-left,front-right channel_map=rear-right,rear-left remix=no
fi

if [[ $MODS != *"source=delayed_speakers"* ]]; then
  sleep 10
  echo "Loading delayed speakers loopback"
  pacmd load-module module-loopback latency_msec=80 source=delayed_speakers.monitor sink=alsa_output.usb-Generic_USB_Audio-00.analog-stereo
fi

if [[ $MODS != *"sink_name=CombinedSink"* ]]; then
  sleep 10
  echo "Loading combined sink"
  MODS=$(pactl list modules)
  if [[ ($MODS == *"sink_name=remapped_bluetooth"*) && ($MODS == *"sink_name=delayed_speakers"*) && ($MODS == *"source=delayed_speakers.monitor"*) ]]; then
    # echo $(pactl list sinks)
    pacmd load-module module-combine-sink slaves=remapped_bluetooth,delayed_speakers sink_name=CombinedSink sink_properties=device.description=CombinedSpeakers channel_map=front-left,front-right,rear-left,rear-right
  else
    echo "Either remapped_bluetooth or delayed_speakers was not loaded. Cannot combine. Waiting 5 seconds and retrying once."
    sleep 5
    MODS=$(pactl list modules)
    if [[ ($MODS == *"sink_name=remapped_bluetooth"*) && ($MODS == *"sink_name=delayed_speakers"*) ]]; then
      pacmd load-module module-combine-sink slaves=remapped_bluetooth,delayed_speakers sink_name=CombinedSink sink_properties=device.description=CombinedSpeakers channel_map=front-left,front-right,rear-left,rear-right
    else
      echo "Either remapped_bluetooth or delayed_speakers was not loaded. Aborting after 2 tries over 10 seconds."
    fi
  fi
fi

MODS=$(pactl list modules)

if [[ $MODS == *"sink_name=CombinedSink"* ]]; then
  sleep 2
  echo "Not running set-default right now"
  # pactl set-default-sink CombinedSink
fi
exit
