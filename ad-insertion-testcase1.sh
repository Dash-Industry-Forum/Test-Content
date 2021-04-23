#!/bin/sh
# tested with GPAC version 1.1.0-DEV-rev737-g7ee96033-master

export BATCH=batch2

# Testcase #1 https://github.com/Dash-Industry-Forum/Test-Content/issues/1
# 1) create 3 inputs, either from
#   i.  a counter from the GPAC 'avgen' js filter
#   ii. some real content
# 2) cut them at times 0, 9.6s, 19.2s
# 3) encode them with
#   a. one encoder for the main content, one encoder for the ad content
#   b. different encoders
#   c. one encoder for the 3 periods (counter content only)
# 4) dash them as separate periods 

export MPD=ad-insertion-testcase1.mpd

# TODO
# - FPS conversion since sources are 24fps
#    -> gpac -graph -i avgen:dur=10:fps=24 @ ffavf::f=fps=fps=25 @ enc:c=avc:fintra=1.920 @ -o tmp/tmp.mpd:stl
#    -> @ ffavf::f=fps=fps=25
# - Counter a: the content is invalid because the first period media is longer than 9.6s
# - Real content: MAIN_CONTENT audio entries are not ok with some value of xs: (may be related to previous)
export TID=ad-insertion-testcase1/$BATCH/counter/a
rm -rf $TID && \
gpac -graph \
  -i avgen:dur=30:sr=48000:ch=2 \
    @ enc:c=aac:FID=GEN1A @1 enc:c=avc:fintra=1.920:FID=GEN1V \
    reframer:#ClampDur=9.6:FID=RF1:SID=GEN1A,GEN1V:xs=0,9.6::props=#PStart=0:#m=m1,#PStart=19.2:#m=m3 \
  -i avgen:dur=30:sr=48000:ch=2 \
    @ enc:c=aac:FID=GEN2A @1 enc:c=avc:fintra=1.920:FID=GEN2V \
    reframer:#ClampDur=9.6:FID=RF2:SID=GEN2A,GEN2V:xs=9.6:#PStart=9.6:#m=m2:#BUrl=$AD_BASEURL \
  -o $TID/$MPD:segdur=1.920:stl:cmaf=cmf2:SID=RF1,RF2 --template='$m$_$Type$_$Number$' \
&& code $TID/$MPD && ls -l $TID

export TID=ad-insertion-testcase1/$BATCH/counter/b
export AD_BASEURL=https://dash.akamaized.net/dashif/$TID/
rm -rf $TID && \
gpac -graph \
  -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=0.0:#m=m1 \
    @ ffenc:c=aac @1 ffenc:c=avc:fintra=1.920 \
    @ @1 reframer:xs=0.0:FID=P0 \
  -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=9.6:#m=m2:#BUrl=$AD_BASEURL \
    @ ffenc:c=aac @1 ffenc:c=avc:fintra=1.920 \
    @ @1 reframer:xs=9.6:FID=P1 \
  -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=19.2:#m=m3 \
    @ ffenc:c=aac @1 ffenc:c=avc:fintra=1.920 \
    @ @1 reframer:xs=19.2:FID=P2 \
-o $TID/$MPD:segdur=1.920:stl:cmaf=cmf2:SID=P0,P1,P2 --template='$m$_$Type$_$Number$' \
&& code $TID/$MPD && ls -l $TID

export TID=ad-insertion-testcase1/$BATCH/counter/c
rm -rf $TID && \
gpac -graph -r \
  -i avgen:dur=30:sr=48000:ch=2 \
    @ ffenc:c=aac @1 ffenc:c=avc:fintra=1.920 \
    @ @1 reframer:#ClampDur=9.6:xs=0,9.6,19.2:props=#PStart=0,#PStart=9.6,#PStart=19.2 \
  @ -o $TID/$MPD:segdur=1.920:cmaf=cmf2:stl \
&& code $TID/$MPD && ls -l $TID

# same with Tos and BBB
# NB: timestamps are shifted because the beginning of the content is not interesting
export AD_CONTENT=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/bbb.mp4
export AD_CONTENT_SRC=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/BigBuckBunny_320x180.mp4
#ffmpeg -i $AD_CONTENT_SRC -c:a copy -r 25 -bf 0 -c:v libx264 -bf 0 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $AD_CONTENT
export MAIN_CONTENT=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tos.mp4:noedit
#export MAIN_CONTENT_SRC2=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tearsofsteel_4k.mov
#ffmpeg -y -i $MAIN_CONTENT_SRC2 -c:a copy -r 25 -vf "scale=960:-2" -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $MAIN_CONTENT
export MAIN_CONTENT_SRC=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tears_of_steel_720p.mov
#ffmpeg -i $MAIN_CONTENT_SRC -c:a copy -r 25 -bf 0 -c:v libx264 -bf 0 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $MAIN_CONTENT

export TID=ad-insertion-testcase1/$BATCH/real/a
export AD_BASEURL=https://dash.akamaized.net/dashif/$TID
rm -rf $TID && \
gpac -graph \
  -i $MAIN_CONTENT:FID=GEN1 \
    resample:osr=48k:SID=GEN1 @ enc:c=aac:FID=GEN1A \
    ffsws:osize=960x426:SID=GEN1 @ enc:c=avc:fintra=1.920:FID=GEN1V \
    reframer:#ClampDur=9.6:FID=RF1:SID=GEN1A,GEN1V:xs=19.6,29.2::props=#PStart=0:#m=m1,#PStart=19.2:#m=m3 \
  -i $AD_CONTENT:FID=GEN2 \
    resample:osr=48k:SID=GEN2 @ enc:c=aac:FID=GEN2A \
    ffsws:osize=960x426:SID=GEN2 @ enc:c=avc:fintra=1.920:FID=GEN2V \
    reframer:#ClampDur=9.6:FID=RF2:SID=GEN2A,GEN2V:xs=19.6:#PStart=9.6:#m=m2:#BUrl=$AD_BASEURL \
  -o $TID/$MPD:segdur=1.920:stl:cmaf=cmf2:SID=RF1,RF2 --template='$m$_$Type$_$Number$' \
&& code $TID/$MPD && ls -l $TID

export TID=ad-insertion-testcase1/$BATCH/real/b
export AD_BASEURL=https://dash.akamaized.net/dashif/$TID
rm -rf $TID && \
gpac -graph \
  -i $MAIN_CONTENT:FID=GEN1:#ClampDur=9.6:#PStart=0.0:#m=m1 \
    resample:osr=48k:SID=GEN1 @ enc:c=aac:FID=GEN1A \
    ffsws:osize=960x426:SID=GEN1 @ enc:c=avc:fintra=1.920:FID=GEN1V \
    reframer:xs=19.6:FID=RF1:SID=GEN1A,GEN1V \
  -i $AD_CONTENT:FID=GEN2:#ClampDur=9.6:#PStart=9.6:#m=m2:#BUrl=$AD_BASEURL \
    resample:osr=48k:SID=GEN2 @ enc:c=aac:FID=GEN2A \
    ffsws:osize=960x426:SID=GEN2 @ enc:c=avc:fintra=1.920:FID=GEN2V \
    reframer:xs=10.0:FID=RF2:SID=GEN2A,GEN2V \
  -i $MAIN_CONTENT:FID=GEN3:#ClampDur=9.6:#PStart=19.2:#m=m3 \
    resample:osr=48k:SID=GEN3 @ enc:c=aac:FID=GEN3A \
    ffsws:osize=960x426:SID=GEN3 @ enc:c=avc:fintra=1.920:FID=GEN3V \
    reframer:xs=29.2:FID=RF3:SID=GEN3A,GEN3V \
-o $TID/$MPD:segdur=1.920:stl:cmaf=cmf2:SID=RF1,RF2,RF3 --template='$m$_$Type$_$Number$' \
&& code $TID/$MPD && ls -l $TID
