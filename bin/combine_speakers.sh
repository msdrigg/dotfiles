#!/bin/bash
logger "Running combine file"
SINKS=$(pactl list sinks)
MODS=$(pactl list modules)

if [[ $MODS != *"sink_name=delayed_speakers"* ]]; then
  /home/msd/bin/load_combined_speakers.sh
fi

if [[ $MODS != *"sink_name=remapped_bluetooth"* ]]; then
  pactl load-module module-remap-sink sink_name=remapped_bluetooth master=bluez_sink.EC_81_93_5A_66_BB.a2dp_sink channels=2 master_channel_map=front-left,front-right channel_map=rear-right,rear-left remix=no
fi

if [[ $MODS != *"sink_name=CombinedSink"* ]]; then
  pactl load-module module-combine-sink slaves=remapped_bluetooth,delayed_speakers sink_name=CombinedSink sink_properties=device.description=CombinedSpeakers
fi

MODS=$(pactl list modules)

if [[ $MODS == *"sink_name=CombinedSink"* ]]; then
echo "Not running set-default right now"
# pactl set-default-sink CombinedSink
fi
exit
