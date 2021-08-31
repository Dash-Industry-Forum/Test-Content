#!/bin/sh
set -eux
# tested with GPAC version 1.1.0-DEV-rev1153-g4ad9b4f20-master

export BATCH=batch3

export GPAC="gpac -threads=-1 -graph"
export MP4BOX="MP4Box"

# Testcase #6 https://github.com/Dash-Industry-Forum/Test-Content/issues/6
# https://reference.dashif.org/dash.js/nightly/samples/dash-if-reference-player/index.html?mpd=https://dash.akamaized.net/dashif/ad-insertion-testcase6/batch1/av.mpd

# Create test base content
# Don't add :cmaf=cmf2 due to edit list constraints
export TID=ad-insertion-testcase6/$BATCH/

export MPD=audio.mpd
$GPAC -i avgen:adjust=0:dur=0.5:sr=48000:ch=2:flen=1000 @#audio -o a1.mp4
$GPAC -i avgen:adjust=0:dur=24:sr=48000:ch=2:flen=1024 @#audio -o a2.mp4
$MP4BOX -cat a2.mp4 a1.mp4 -out a.mp4

export CMD="$GPAC -i a.mp4 @#audio enc:c=aac @ -o $TID/$MPD:stl:segdur=1.5:cues=ad-insertion-testcase6-audio-cues.xml:strict_cues --template=\$Type\$_\$Number\$"
echo $CMD && $CMD && code $TID/$MPD && ls -l $TID

# Modify the edit list in-place by adding the 0.5s
# Model can be find by editing: #$MP4BOX -add av.mp4 -edits 1=re0-0,0.5 -new av2.mp4
#cp ad-insertion-testcase6/$BATCH/audio_init.mp4 .
#disasmp4.exe ad-insertion-testcase6/$BATCH/audio_init.mp4 > audio_init.asm
#edit edit-list
#nasm -f bin audio_init.asm -o ad-insertion-testcase6/$BATCH/audio_init.mp4

export MPD=video.mpd
export CMD="$GPAC -i avgen:adjust=0:dur=24:sr=48000:ch=2:FID=GEN enc:c=avc:bf=0:SID=GEN#video:fintra=2 @ -o $TID/$MPD:stl:segdur=2 --template=\$Type\$_\$Number\$"
echo $CMD && $CMD && code $TID/$MPD && ls -l $TID

cp ad-insertion-testcase6-av*.mpd ad-insertion-testcase6/$BATCH/

