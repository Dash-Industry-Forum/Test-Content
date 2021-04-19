#!/bin/sh

# details at https://github.com/Dash-Industry-Forum/Test-Content/issues/1
# tested with GPAC version 1.1.0-DEV-rev713-gd36331fb-master
# 1) create 3 inputs (here a counter with the 'avgen' js filter)
# 2) cut them at times 0, 9.6s, 19.2s
# 3) encode them with different encoders
# 4) dash them as separate periods 
rm -rf ad-insertion-testcase1/counter && \
gpac -graph \
 -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=0.0:#m=m1:FID=P0S0 \
    reframer:xs=0.0:SID=P0S0 @ ffenc:c=aac:FID=P0A0 @1 ffenc:c=avc:fintra=1.920:FID=P0V0 \
 -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=9.6:#m=m2:FID=P1S0 \
    reframer:xs=9.6:SID=P1S0 @ ffenc:c=aac:FID=P1A0 @1 ffenc:c=avc:fintra=1.920:FID=P1V0 \
 -i avgen:dur=30:sr=48000:ch=2:#ClampDur=9.6:#PStart=19.2:#m=m3:FID=P2S0 \
    reframer:xs=19.2:SID=P2S0 @ ffenc:c=aac:FID=P2A0 @1 ffenc:c=avc:fintra=1.920:FID=P2V0 \
 -o ad-insertion-testcase1/counter/ad-insertion-testcase1.mpd:segdur=1.920:stl:cmaf=cmfc:SID=P0A0,P0V0,P1A0,P1V0,P2A0,P2V0 --template='$m$_$Type$_$Number$' \
 && ls -l ad-insertion-testcase1/counter

# same with Tos and BBB
export AD_CONTENT=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/bbb.mp4
export AD_CONTENT2=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/BigBuckBunny_320x180.mp4
#ffmpeg -i $AD_CONTENT2 -c:a copy -r 25 -bf 0 -c:v libx264 -bf 0 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $AD_CONTENT

export MAIN_CONTENT=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tos.mp4:noedit

#export MAIN_CONTENT2=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tearsofsteel_4k.mov
#ffmpeg -y -i $MAIN_CONTENT2 -c:a copy -r 25 -vf "scale=960:-2" -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $MAIN_CONTENT

export MAIN_CONTENT3=/home/rbouqueau/works/qualcomm/CTA-Wave/Test-Content-Generation/content_files/tears_of_steel_720p.mov
#ffmpeg -i $MAIN_CONTENT3 -c:a copy -r 25 -bf 0 -c:v libx264 -bf 0 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 6000k -maxrate 15000k -bufsize 10000k $MAIN_CONTENT

#FPS CHANGE IS BROKEN in GPAC
rm -rf ad-insertion-testcase1/real && \
gpac -graph \
 -i $MAIN_CONTENT:#ClampDur=9.6:#PStart=0.0:#m=m1:FID=P0S0 \
    resample:osr=48k:SID=P0S0:FID=P0S0A ffsws:osize=960x426:SID=P0S0 @ ffavf::f=fps=fps=25::FID=P0S0V \
    reframer:xs=30.0:SID=P0S0A,P0S0V @ ffenc:c=aac:FID=P0A0 @1 ffenc:c=avc:fintra=1.920:FID=P0V0 \
 -i $AD_CONTENT:#ClampDur=9.6:#PStart=9.6:#m=m2:FID=P1S0 \
    resample:osr=48k:SID=P1S0:FID=P1S0A ffsws:osize=960x426:SID=P1S0 @ ffavf::f=fps=fps=25::FID=P1S0V \
    reframer:xs=30.0:SID=P1S0A,P1S0V @ ffenc:c=aac:FID=P1A0 @1 ffenc:c=avc:fintra=1.920:FID=P1V0 \
 -i $MAIN_CONTENT:#ClampDur=9.6:#PStart=19.2:#m=m3:FID=P2S0 \
    resample:osr=48k:SID=P2S0:FID=P2S0A ffsws:osize=960x426:SID=P2S0 @ ffavf::f=fps=fps=25::FID=P2S0V \
    reframer:xs=39.6:SID=P2S0A,P2S0V @ ffenc:c=aac:FID=P2A0 @1 ffenc:c=avc:fintra=1.920:FID=P2V0 \
 -o ad-insertion-testcase1/real/ad-insertion-testcase1.mpd:segdur=1.920:stl:cmaf=cmfc:SID=P0A0,P0V0,P1A0,P1V0,P2A0,P2V0 --template='$m$_$Type$_$Number$' \
&& ls -l ad-insertion-testcase1/real


rm -rf ad-insertion-testcase1/real && \
gpac -graph \
 -i $MAIN_CONTENT2:#ClampDur=9.6:#PStart=0.0:#m=m1:FID=P0S0 \
    resample:osr=48k:SID=P0S0:FID=P0S0A ffsws:osize=960x426:SID=P0S0:FID=P0S0V \
    reframer:xs=30.0:SID=P0S0A,P0S0V @ ffenc:c=aac:FID=P0A0 @1 ffenc:c=avc:fintra=1.920:FID=P0V0 \
 -i $AD_CONTENT:#ClampDur=9.6:#PStart=9.6:#m=m2:FID=P1S0 \
    resample:osr=48k:SID=P1S0:FID=P1S0A ffsws:osize=960x426:SID=P1S0:FID=P1S0V \
    reframer:xs=30.0:SID=P1S0A,P1S0V @ ffenc:c=aac:FID=P1A0 @1 ffenc:c=avc:fintra=1.920:FID=P1V0 \
 -i $MAIN_CONTENT2:#ClampDur=9.6:#PStart=19.2:#m=m3:FID=P2S0 \
    resample:osr=48k:SID=P2S0:FID=P2S0A ffsws:osize=960x426:SID=P2S0:FID=P2S0V \
    reframer:xs=39.6:SID=P2S0A,P2S0V @ ffenc:c=aac:FID=P2A0 @1 ffenc:c=avc:fintra=1.920:FID=P2V0 \
 -o ad-insertion-testcase1/real/ad-insertion-testcase1.mpd:segdur=1.920:stl:cmaf=cmfc:SID=P0A0,P0V0,P1A0,P1V0,P2A0,P2V0 --template='$m$_$Type$_$Number$' \
&& ls -l ad-insertion-testcase1/real
