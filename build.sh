#!/usr/bin/env bash
# Change this value to the name of the image you would like to use
image_name=alpine-ffmpeg

# docker container names cannot have whitespace
sed -i -e 's/dffmpeg_image_name=.*/dffmpeg_image_name=$image_name/g' dffmpeg.sh

cd images/$image_name
./build.sh

