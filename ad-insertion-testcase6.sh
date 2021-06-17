#!/bin/sh
set -eux
# tested with GPAC version 1.1.0-DEV-rev998-g206ad0907-master

export BATCH=batch1

export GPAC="gpac -threads=-1 -graph"

# Testcase #6 https://github.com/Dash-Industry-Forum/Test-Content/issues/6
# https://reference.dashif.org/dash.js/nightly/samples/dash-if-reference-player/index.html?mpd=https://dash.akamaized.net/dashif/ad-insertion-testcase6/batch1/av.mpd

# Create test base content
# Don't add :cmaf=cmf2 due to edit list constraints
export TID=ad-insertion-testcase6/$BATCH/

export MPD=audio.mpd
#export CMD="$GPAC -i pl.m3u @#audio enc:c=aac @ reframer:xs=1/2:xe=49/2:xround=seek @ -o $TID/$MPD:stl:segdur=1.5 --template=\$Type\$_\$Number\$"
export CMD="$GPAC -i ad-insertion-testcase6-pl.m3u @#audio enc:c=aac @ -o $TID/$MPD:stl:segdur=1.5:cues=ad-insertion-testcase6-audio-cues.xml:strict_cues --template=\$Type\$_\$Number\$"
echo $CMD && $CMD && code $TID/$MPD && ls -l $TID

#cp ad-insertion-testcase6/$BATCH/audio_init.mp4 .
#disasmp4.exe ad-insertion-testcase6/$BATCH/audio_init.mp4 > audio_init.asm
#edit edit-list
#nasm -f bin audio_init.asm -o ad-insertion-testcase6/$BATCH/audio_init.mp4

export MPD=video.mpd
export CMD="$GPAC -i avgen:dur=24:sr=48000:ch=2:FID=GEN enc:c=avc:SID=GEN#video:fintra=2 @ -o $TID/$MPD:stl:segdur=2 --template=\$Type\$_\$Number\$"
echo $CMD && $CMD && code $TID/$MPD && ls -l $TID

cp ad-insertion-testcase6-av.mpd ad-insertion-testcase6/$BATCH/av1.mpd

  